from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field


class DevboxStackResponse(BaseModel):
    code: str
    name: str


class DevboxPackageResponse(BaseModel):
    code: str
    name: str
    cpu_cores: int
    ram_gb: int
    disk_gb: int
    duration_days: int
    included_hours: int
    egress_gb: int
    estimated_price_rub: Decimal


class DevboxRateResponse(BaseModel):
    cpu_core_hour_rub: Decimal
    ram_gb_hour_rub: Decimal
    disk_gb_month_rub: Decimal
    egress_gb_rub: Decimal
    platform_fee_rub: Decimal
    margin_percent: Decimal
    updated_at: datetime


class DevboxSessionResponse(BaseModel):
    session_id: str
    package_code: str
    stack_code: str
    status: str
    cpu_cores: int
    ram_gb: int
    disk_gb: int
    egress_gb: int
    hours: int
    price_rub: Decimal
    started_at: datetime | None
    stopped_at: datetime | None


class DevboxStartRequest(BaseModel):
    package_code: str = Field(..., min_length=1, max_length=8)
    stack_code: str = Field(..., min_length=1, max_length=32)
    idempotency_key: str | None = Field(default=None, max_length=64)


class DevboxStatusResponse(BaseModel):
    status: str
    active_session: DevboxSessionResponse | None
    packages: list[DevboxPackageResponse]
    stacks: list[DevboxStackResponse]
    rates: DevboxRateResponse | None


class DevboxStopResponse(BaseModel):
    status: str
    session: DevboxSessionResponse | None
