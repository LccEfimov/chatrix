from __future__ import annotations

from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.oauth_account import OAuthAccount
from app.models.plan import Plan
from app.models.referral_reward import ReferralReward
from app.models.referral_tier import ReferralTier
from app.models.user import User

MAX_REFERRAL_LEVEL = 25


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def referral_enabled(plan_code: str) -> bool:
    return plan_code != "ZERO"


def referral_code_for_user(user: User) -> str:
    return str(user.id)


def referral_url_for_user(user: User) -> str:
    return f"https://chatrix.app/r/{user.id}"


def count_linked_providers(db: Session, user_id) -> int:
    return int(
        db.execute(
            select(func.count()).select_from(OAuthAccount).where(OAuthAccount.user_id == user_id)
        ).scalar_one()
    )


def build_referral_tree(db: Session, user_id) -> list[tuple[int, User]]:
    levels: list[tuple[int, User]] = []
    current_ids = [user_id]
    for level in range(1, MAX_REFERRAL_LEVEL + 1):
        if not current_ids:
            break
        users = db.execute(select(User).where(User.referrer_id.in_(current_ids))).scalars().all()
        if not users:
            break
        levels.extend((level, user) for user in users)
        current_ids = [user.id for user in users]
    return levels


def _reward_cents(paid_amount_cents: int, percent: Decimal) -> int:
    value = Decimal(paid_amount_cents) * percent / Decimal("100")
    return int(value.quantize(Decimal("1"), rounding=ROUND_HALF_UP))


def apply_referral_rewards_for_activation(
    db: Session,
    *,
    referred_user: User,
    paid_plan: Plan,
) -> list[ReferralReward]:
    if paid_plan.price_rub <= 0 or referred_user.referrer_id is None:
        return []
    if count_linked_providers(db, referred_user.id) < 2:
        return []

    paid_amount_cents = int(paid_plan.price_rub * 100)
    rewards: list[ReferralReward] = []
    referrer_id = referred_user.referrer_id
    for level in range(1, MAX_REFERRAL_LEVEL + 1):
        if not referrer_id:
            break
        referrer = db.get(User, referrer_id)
        if not referrer:
            break
        tier = db.execute(
            select(ReferralTier).where(
                ReferralTier.plan_code == referrer.plan_code,
                ReferralTier.level == level,
            )
        ).scalar_one_or_none()
        if tier and tier.percent > 0:
            existing = db.execute(
                select(ReferralReward).where(
                    ReferralReward.referrer_id == referrer.id,
                    ReferralReward.referred_user_id == referred_user.id,
                    ReferralReward.level == level,
                    ReferralReward.source_plan_code == paid_plan.code,
                )
            ).scalar_one_or_none()
            if not existing:
                reward = ReferralReward(
                    referrer_id=referrer.id,
                    referred_user_id=referred_user.id,
                    level=level,
                    referrer_plan_code=referrer.plan_code,
                    source_plan_code=paid_plan.code,
                    percent=tier.percent,
                    paid_amount_cents=paid_amount_cents,
                    reward_amount_cents=_reward_cents(paid_amount_cents, tier.percent),
                    created_at=utcnow(),
                )
                db.add(reward)
                rewards.append(reward)
        referrer_id = referrer.referrer_id
    return rewards
