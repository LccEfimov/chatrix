from datetime import datetime

from pydantic import BaseModel, Field


class SectionBrief(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    goal: str = Field(..., min_length=1)
    scenarios: list[str] = Field(..., min_length=1)
    inputs: list[str] = Field(..., min_length=1)
    outputs: list[str] = Field(..., min_length=1)
    ai_operations: list[str] = Field(..., min_length=1)
    constraints: str | None = None
    update_policy: str | None = None
    ui_blocks: list[str] = Field(..., min_length=1)
    limits: str | None = None


class SectionCreateRequest(BaseModel):
    category: str = Field(..., pattern="^(hobby|study|work)$")
    brief: SectionBrief
    ux_config: dict = Field(default_factory=dict)
    ai_workflow: dict = Field(default_factory=dict)
    idempotency_key: str | None = Field(default=None, max_length=64)


class SectionResponse(BaseModel):
    id: str
    category: str
    title: str
    brief: dict
    ux_config: dict
    ai_workflow: dict
    is_active: bool
    fee_cents: int
    last_run_at: datetime | None
    created_at: datetime
    updated_at: datetime
    note: str | None


class SectionListResponse(BaseModel):
    sections: list[SectionResponse]


class SectionRunRequest(BaseModel):
    input_payload: dict = Field(default_factory=dict)


class SectionRunResponse(BaseModel):
    section_id: str
    status: str
    run_at: datetime
    output_preview: dict
