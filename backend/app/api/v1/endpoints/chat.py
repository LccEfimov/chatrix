from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.schemas.chat import (
    ChatCreateRequest,
    ChatListResponse,
    ChatMessageCreateRequest,
    ChatMessageListResponse,
    ChatMessageResponse,
    ChatMessageSendResponse,
    ChatResponse,
)
from app.services import chat as chat_service

router = APIRouter()


def _serialize_chat(chat) -> ChatResponse:
    return ChatResponse(
        id=str(chat.id),
        title=chat.title,
        system_prompt=chat.system_prompt,
        is_archived=chat.is_archived,
        created_at=chat.created_at,
        updated_at=chat.updated_at,
    )


def _serialize_message(message) -> ChatMessageResponse:
    return ChatMessageResponse(
        id=str(message.id),
        role=message.role,
        content=message.content,
        provider=message.provider_code,
        model=message.model,
        created_at=message.created_at,
    )


@router.post("/chats", response_model=ChatResponse)
def create_chat(
    payload: ChatCreateRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ChatResponse:
    chat = chat_service.create_chat(
        db,
        user_id=user.id,
        title=payload.title,
        system_prompt=payload.system_prompt,
    )
    return _serialize_chat(chat)


@router.get("/chats", response_model=ChatListResponse)
def list_chats(
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ChatListResponse:
    chats = chat_service.list_chats(db, user_id=user.id)
    return ChatListResponse(chats=[_serialize_chat(chat) for chat in chats])


@router.get("/chats/{chat_id}", response_model=ChatResponse)
def get_chat(
    chat_id: str,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ChatResponse:
    try:
        parsed_id = uuid.UUID(chat_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid chat id") from exc
    chat = chat_service.get_chat_or_404(db, chat_id=parsed_id, user_id=user.id)
    return _serialize_chat(chat)


@router.get("/chats/{chat_id}/messages", response_model=ChatMessageListResponse)
def list_chat_messages(
    chat_id: str,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ChatMessageListResponse:
    try:
        parsed_id = uuid.UUID(chat_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid chat id") from exc
    chat = chat_service.get_chat_or_404(db, chat_id=parsed_id, user_id=user.id)
    messages = chat_service.list_messages(db, chat_id=chat.id)
    return ChatMessageListResponse(messages=[_serialize_message(msg) for msg in messages])


@router.post("/chats/{chat_id}/messages", response_model=ChatMessageSendResponse)
def send_message(
    chat_id: str,
    payload: ChatMessageCreateRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ChatMessageSendResponse:
    try:
        parsed_id = uuid.UUID(chat_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid chat id") from exc
    chat = chat_service.get_chat_or_404(db, chat_id=parsed_id, user_id=user.id)
    user_message, assistant_message = chat_service.send_message(
        db,
        chat=chat,
        user_id=user.id,
        content=payload.content,
        provider_code=payload.provider,
        model=payload.model,
    )
    return ChatMessageSendResponse(
        message=_serialize_message(user_message),
        assistant_message=_serialize_message(assistant_message),
    )
