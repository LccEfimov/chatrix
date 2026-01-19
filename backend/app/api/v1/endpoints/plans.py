from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.api.deps import get_current_user, get_db
from app.models.plan import Plan
from app.models.user import User
from app.schemas.plans import PlanEntitlementResponse, PlanLimitResponse, PlanResponse
from app.schemas.plans import SubscriptionActivateRequest, SubscriptionResponse

router = APIRouter()


def _plan_response(plan: Plan) -> PlanResponse:
    return PlanResponse(
        code=plan.code,
        name=plan.name,
        period_months=plan.period_months,
        price_rub=plan.price_rub,
        is_active=plan.is_active,
        limits=[
            PlanLimitResponse(key=limit.key, limit_value=limit.limit_value)
            for limit in plan.limits
        ],
        entitlements=[
            PlanEntitlementResponse(key=entitlement.key, is_enabled=entitlement.is_enabled)
            for entitlement in plan.entitlements
        ],
    )


@router.get("/plans", response_model=list[PlanResponse])
def list_plans(db: Session = Depends(get_db)) -> list[PlanResponse]:
    plans = db.execute(
        select(Plan).options(selectinload(Plan.limits), selectinload(Plan.entitlements))
    ).scalars()
    return [_plan_response(plan) for plan in plans]


@router.post("/subscriptions/activate", response_model=SubscriptionResponse)
def activate_subscription(
    payload: SubscriptionActivateRequest,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SubscriptionResponse:
    plan = db.execute(
        select(Plan)
        .where(Plan.code == payload.plan_code)
        .options(selectinload(Plan.limits), selectinload(Plan.entitlements))
    ).scalar_one_or_none()
    if not plan or not plan.is_active:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plan not found")
    user.plan_code = plan.code
    db.add(user)
    db.commit()
    db.refresh(user)
    return SubscriptionResponse(plan=_plan_response(plan))


@router.get("/subscriptions/me", response_model=SubscriptionResponse)
def subscription_me(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SubscriptionResponse:
    plan = db.execute(
        select(Plan)
        .where(Plan.code == user.plan_code)
        .options(selectinload(Plan.limits), selectinload(Plan.entitlements))
    ).scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plan not found")
    return SubscriptionResponse(plan=_plan_response(plan))
