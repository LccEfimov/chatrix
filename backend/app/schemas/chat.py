from datetime import datetime

from pydantic import BaseModel, Field


class ChatCreateRequest(BaseModel):
    title: str | None = Field(default=None, max_length=120)
    system_prompt: str | None = None


class ChatResponse(BaseModel):
    id: str
    title: str | None
    system_prompt: str | None
    is_archived: bool
    created_at: datetime
    updated_at: datetime


class ChatListResponse(BaseModel):
    chats: list[ChatResponse]


class ChatMessageCreateRequest(BaseModel):
    content: str = Field(..., min_length=1)
    provider: str | None = None
    model: str | None = None


class ChatMessageResponse(BaseModel):
    id: str
    role: str
    content: str
    provider: str | None = None
    model: str | None = None
    created_at: datetime


class ChatMessageListResponse(BaseModel):
    messages: list[ChatMessageResponse]


class ChatMessageSendResponse(BaseModel):
    message: ChatMessageResponse
    assistant_message: ChatMessageResponse
