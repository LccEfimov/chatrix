from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.referral_reward import ReferralReward
from app.models.user import User
from app.schemas.referrals import (
    ReferralMeResponse,
    ReferralRewardResponse,
    ReferralRewardsResponse,
    ReferralTreeNode,
    ReferralTreeResponse,
)
from app.services.referrals import (
    build_referral_tree,
    referral_code_for_user,
    referral_enabled,
    referral_url_for_user,
)

router = APIRouter()


@router.get("/referrals/me", response_model=ReferralMeResponse)
def referrals_me(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ReferralMeResponse:
    invited_count = db.execute(
        select(func.count()).select_from(User).where(User.referrer_id == user.id)
    ).scalar_one()
    enabled = referral_enabled(user.plan_code)
    return ReferralMeResponse(
        referral_enabled=enabled,
        referral_code=referral_code_for_user(user) if enabled else None,
        referral_url=referral_url_for_user(user) if enabled else None,
        plan_code=user.plan_code,
        invited_count=int(invited_count),
    )


@router.get("/referrals/tree", response_model=ReferralTreeResponse)
def referrals_tree(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ReferralTreeResponse:
    nodes = [
        ReferralTreeNode(level=level, user_id=str(node.id), email=node.email)
        for level, node in build_referral_tree(db, user.id)
    ]
    return ReferralTreeResponse(nodes=nodes)


@router.get("/referrals/rewards", response_model=ReferralRewardsResponse)
def referrals_rewards(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ReferralRewardsResponse:
    rewards = db.execute(
        select(ReferralReward)
        .where(ReferralReward.referrer_id == user.id)
        .order_by(ReferralReward.created_at.desc())
    ).scalars()
    return ReferralRewardsResponse(
        rewards=[
            ReferralRewardResponse(
                id=str(reward.id),
                referrer_plan_code=reward.referrer_plan_code,
                source_plan_code=reward.source_plan_code,
                level=reward.level,
                percent=reward.percent,
                paid_amount_cents=reward.paid_amount_cents,
                reward_amount_cents=reward.reward_amount_cents,
                created_at=reward.created_at,
            )
            for reward in rewards
        ]
    )
