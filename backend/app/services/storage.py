from __future__ import annotations

from datetime import datetime, timezone
import uuid

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.file import StoredFile
from app.services.file_parsers import parse_content
from app.services.policy import PolicyEngine

ALLOWED_EXTENSIONS = {
    "txt",
    "doc",
    "docx",
    "xls",
    "xlsx",
    "md",
    "pdf",
    "rtf",
    "db",
    "sql",
    "epub",
    "csv",
    "mobi",
    "odt",
    "ott",
    "sxw",
    "for",
    "ods",
    "xlsm",
    "xlsb",
    "xml",
    "log",
    "ini",
    "conf",
    "pages",
    "numbers",
    "azw",
    "azw3",
    "fb2",
    "djvu",
    "cbr",
    "cbz",
    "ibooks",
}


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _extract_extension(filename: str) -> str:
    if "." not in filename:
        return ""
    return filename.rsplit(".", 1)[-1].lower()


def _storage_usage_bytes(db: Session, *, user_id: uuid.UUID) -> int:
    usage = db.execute(
        select(func.coalesce(func.sum(StoredFile.size_bytes), 0)).where(
            StoredFile.user_id == user_id,
            StoredFile.deleted_at.is_(None),
            StoredFile.status == "stored",
        )
    ).scalar_one()
    return int(usage)


def _storage_limit_bytes(db: Session, *, plan_code: str) -> int | None:
    policy = PolicyEngine(db)
    limits = policy.get_limits(plan_code)
    return limits.get("storage_bytes")


def _ensure_quota(db: Session, *, user_id: uuid.UUID, plan_code: str, size_bytes: int) -> None:
    limit = _storage_limit_bytes(db, plan_code=plan_code)
    if limit is None:
        return
    usage = _storage_usage_bytes(db, user_id=user_id)
    if usage + size_bytes > limit:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Storage quota exceeded",
        )


def build_storage_path(user_id: uuid.UUID, file_id: uuid.UUID, filename: str) -> str:
    return f"s3://stub/{user_id}/{file_id}/{filename}"


def get_file_or_404(db: Session, *, file_id: uuid.UUID, user_id: uuid.UUID) -> StoredFile:
    file = db.execute(
        select(StoredFile).where(StoredFile.id == file_id, StoredFile.user_id == user_id)
    ).scalar_one_or_none()
    if not file:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="File not found")
    return file


def list_files(db: Session, *, user_id: uuid.UUID) -> list[StoredFile]:
    return (
        db.execute(
            select(StoredFile)
            .where(StoredFile.user_id == user_id, StoredFile.deleted_at.is_(None))
            .order_by(StoredFile.created_at.desc())
        )
        .scalars()
        .all()
    )


def init_upload(
    db: Session,
    *,
    user_id: uuid.UUID,
    plan_code: str,
    filename: str,
    content_type: str,
    size_bytes: int,
    idempotency_key: str | None,
) -> StoredFile:
    extension = _extract_extension(filename)
    if extension not in ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Unsupported file type")

    if idempotency_key:
        existing = db.execute(
            select(StoredFile).where(
                StoredFile.user_id == user_id,
                StoredFile.idempotency_key == idempotency_key,
            )
        ).scalar_one_or_none()
        if existing:
            return existing

    _ensure_quota(db, user_id=user_id, plan_code=plan_code, size_bytes=size_bytes)

    now = utcnow()
    file = StoredFile(
        user_id=user_id,
        filename=filename,
        extension=extension,
        content_type=content_type,
        size_bytes=size_bytes,
        status="pending_upload",
        storage_path=None,
        idempotency_key=idempotency_key,
        parsed_text=None,
        created_at=now,
        updated_at=now,
        deleted_at=None,
    )
    db.add(file)
    db.commit()
    db.refresh(file)
    return file


def complete_upload(
    db: Session,
    *,
    file_id: uuid.UUID,
    user_id: uuid.UUID,
    storage_path: str | None,
    content_text: str | None,
) -> StoredFile:
    file = get_file_or_404(db, file_id=file_id, user_id=user_id)
    if file.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="File deleted")
    if file.status == "stored":
        return file

    now = utcnow()
    resolved_path = storage_path or build_storage_path(user_id, file.id, file.filename)
    parsed = parse_content(file.extension, content_text, file.filename)
    file.status = "stored"
    file.storage_path = resolved_path
    file.parsed_text = parsed.text if parsed else None
    file.updated_at = now
    db.add(file)
    db.commit()
    db.refresh(file)
    return file


def delete_file(db: Session, *, file_id: uuid.UUID, user_id: uuid.UUID) -> StoredFile:
    file = get_file_or_404(db, file_id=file_id, user_id=user_id)
    if file.deleted_at is None:
        now = utcnow()
        file.deleted_at = now
        file.status = "deleted"
        file.updated_at = now
        db.add(file)
        db.commit()
        db.refresh(file)
    return file


def get_download_url(db: Session, *, file_id: uuid.UUID, user_id: uuid.UUID) -> str:
    file = get_file_or_404(db, file_id=file_id, user_id=user_id)
    if file.deleted_at is not None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="File not found")
    if file.status != "stored":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="File not available for download",
        )
    return file.storage_path or build_storage_path(user_id, file.id, file.filename)
