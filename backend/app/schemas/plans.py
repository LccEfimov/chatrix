from pydantic import BaseModel, Field


class PlanLimitResponse(BaseModel):
    key: str
    limit_value: int


class PlanEntitlementResponse(BaseModel):
    key: str
    is_enabled: bool


class PlanResponse(BaseModel):
    code: str
    name: str
    period_months: int | None
    price_rub: int
    is_active: bool
    limits: list[PlanLimitResponse]
    entitlements: list[PlanEntitlementResponse]


class SubscriptionActivateRequest(BaseModel):
    plan_code: str = Field(min_length=1, max_length=32)


class SubscriptionResponse(BaseModel):
    plan: PlanResponse
