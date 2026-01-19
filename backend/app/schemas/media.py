from datetime import datetime

from pydantic import BaseModel, Field


class VoiceSessionCreateRequest(BaseModel):
    mode: str = Field(..., description="Mode: live or standard")
    provider: str | None = None
    model: str | None = None


class VoiceSessionResponse(BaseModel):
    id: str
    status: str
    mode: str
    provider: str | None = None
    model: str | None = None
    started_at: datetime
    ended_at: datetime | None = None


class VoiceSessionListResponse(BaseModel):
    sessions: list[VoiceSessionResponse]


class VideoAvatarCreateRequest(BaseModel):
    name: str
    prompt: str | None = None
    provider: str | None = None
    model: str | None = None


class VideoAvatarResponse(BaseModel):
    id: str
    name: str
    prompt: str | None = None
    status: str
    provider: str | None = None
    model: str | None = None
    created_at: datetime
    updated_at: datetime


class VideoAvatarListResponse(BaseModel):
    avatars: list[VideoAvatarResponse]


class ImageJobCreateRequest(BaseModel):
    prompt: str
    provider: str | None = None
    model: str | None = None


class ImageJobResponse(BaseModel):
    id: str
    prompt: str
    status: str
    provider: str | None = None
    model: str | None = None
    result_url: str | None = None
    created_at: datetime
    updated_at: datetime


class ImageJobListResponse(BaseModel):
    jobs: list[ImageJobResponse]


class VideoJobCreateRequest(BaseModel):
    prompt: str
    provider: str | None = None
    model: str | None = None


class VideoJobResponse(BaseModel):
    id: str
    prompt: str
    status: str
    provider: str | None = None
    model: str | None = None
    result_url: str | None = None
    created_at: datetime
    updated_at: datetime


class VideoJobListResponse(BaseModel):
    jobs: list[VideoJobResponse]
