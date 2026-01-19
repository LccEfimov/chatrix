from datetime import datetime

from pydantic import BaseModel, Field


class AnalyticsEventCreateRequest(BaseModel):
    event_name: str = Field(..., min_length=1, max_length=120)
    event_source: str | None = Field(default=None, max_length=64)
    payload: dict | None = None


class AnalyticsEventResponse(BaseModel):
    id: str
    event_name: str
    event_source: str | None
    payload: dict | None
    created_at: datetime


class AnalyticsEventListResponse(BaseModel):
    events: list[AnalyticsEventResponse]
