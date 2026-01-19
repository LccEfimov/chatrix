from __future__ import annotations

from datetime import datetime, timezone
import uuid

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.chat import Chat
from app.models.chat_message import ChatMessage
from app.services import ai_orchestrator


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def get_chat_or_404(db: Session, *, chat_id: uuid.UUID, user_id: uuid.UUID) -> Chat:
    chat = db.execute(
        select(Chat).where(Chat.id == chat_id, Chat.user_id == user_id)
    ).scalar_one_or_none()
    if not chat:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Chat not found")
    return chat


def create_chat(
    db: Session,
    *,
    user_id: uuid.UUID,
    title: str | None,
    system_prompt: str | None,
) -> Chat:
    now = utcnow()
    chat = Chat(
        user_id=user_id,
        title=title,
        system_prompt=system_prompt,
        is_archived=False,
        created_at=now,
        updated_at=now,
    )
    db.add(chat)
    db.commit()
    db.refresh(chat)
    return chat


def list_chats(db: Session, *, user_id: uuid.UUID) -> list[Chat]:
    return (
        db.execute(
            select(Chat)
            .where(Chat.user_id == user_id)
            .order_by(Chat.updated_at.desc())
        )
        .scalars()
        .all()
    )


def list_messages(db: Session, *, chat_id: uuid.UUID) -> list[ChatMessage]:
    return (
        db.execute(
            select(ChatMessage)
            .where(ChatMessage.chat_id == chat_id)
            .order_by(ChatMessage.created_at)
        )
        .scalars()
        .all()
    )


def send_message(
    db: Session,
    *,
    chat: Chat,
    user_id: uuid.UUID,
    content: str,
    provider_code: str | None,
    model: str | None,
) -> tuple[ChatMessage, ChatMessage]:
    provider = ai_orchestrator.select_provider(db, provider_code)
    if not provider:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="AI provider not available",
        )

    now = utcnow()
    user_message = ChatMessage(
        chat_id=chat.id,
        user_id=user_id,
        role="user",
        content=content,
        created_at=now,
    )
    assistant_text = ai_orchestrator.generate_stub_reply(
        user_message=content,
        system_prompt=chat.system_prompt,
        provider=provider,
        model=model,
    )
    assistant_message = ChatMessage(
        chat_id=chat.id,
        user_id=None,
        role="assistant",
        content=assistant_text,
        provider_code=provider.code,
        model=model,
        created_at=now,
    )
    chat.updated_at = now
    db.add_all([user_message, assistant_message, chat])
    db.commit()
    db.refresh(user_message)
    db.refresh(assistant_message)
    return user_message, assistant_message
