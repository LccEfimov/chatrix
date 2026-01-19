from datetime import datetime

from pydantic import BaseModel, Field


class SupportTicketCreateRequest(BaseModel):
    subject: str = Field(..., min_length=1, max_length=200)
    message: str = Field(..., min_length=1, max_length=4000)
    category: str | None = Field(default=None, max_length=64)


class SupportTicketResponse(BaseModel):
    id: str
    subject: str
    message: str
    category: str | None
    status: str
    created_at: datetime
    updated_at: datetime


class SupportTicketListResponse(BaseModel):
    tickets: list[SupportTicketResponse]
