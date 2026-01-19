from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel


class ReferralMeResponse(BaseModel):
    referral_enabled: bool
    referral_code: str | None
    referral_url: str | None
    plan_code: str
    invited_count: int


class ReferralTreeNode(BaseModel):
    level: int
    user_id: str
    email: str


class ReferralTreeResponse(BaseModel):
    nodes: list[ReferralTreeNode]


class ReferralRewardResponse(BaseModel):
    id: str
    referrer_plan_code: str
    source_plan_code: str
    level: int
    percent: Decimal
    paid_amount_cents: int
    reward_amount_cents: int
    created_at: datetime


class ReferralRewardsResponse(BaseModel):
    rewards: list[ReferralRewardResponse]
