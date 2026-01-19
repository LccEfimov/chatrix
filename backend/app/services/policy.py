from __future__ import annotations

from collections.abc import Mapping

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.plan_entitlement import PlanEntitlement
from app.models.plan_limit import PlanLimit


class PolicyEngine:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_limits(self, plan_code: str) -> dict[str, int]:
        rows = self.db.execute(
            select(PlanLimit).where(PlanLimit.plan_code == plan_code)
        ).scalars()
        return {row.key: row.limit_value for row in rows}

    def get_entitlements(self, plan_code: str) -> dict[str, bool]:
        rows = self.db.execute(
            select(PlanEntitlement).where(PlanEntitlement.plan_code == plan_code)
        ).scalars()
        return {row.key: row.is_enabled for row in rows}

    def check_entitlement(self, plan_code: str, key: str) -> bool:
        entitlements = self.get_entitlements(plan_code)
        return entitlements.get(key, False)

    def check_limit(self, plan_code: str, key: str, usage: int) -> bool:
        limits = self.get_limits(plan_code)
        limit_value = limits.get(key)
        if limit_value is None:
            return False
        return usage <= limit_value

    def snapshot(self, plan_code: str) -> Mapping[str, Mapping[str, int | bool]]:
        return {
            "limits": self.get_limits(plan_code),
            "entitlements": self.get_entitlements(plan_code),
        }
