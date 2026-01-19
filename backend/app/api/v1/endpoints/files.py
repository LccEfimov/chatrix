from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.schemas.files import (
    FileDeleteResponse,
    FileDownloadResponse,
    FileListResponse,
    FileResponse,
    FileUploadCompleteRequest,
    FileUploadInitRequest,
    FileUploadInitResponse,
)
from app.services import storage as storage_service

router = APIRouter()


def _file_response(file) -> FileResponse:
    return FileResponse(
        id=str(file.id),
        filename=file.filename,
        extension=file.extension,
        content_type=file.content_type,
        size_bytes=file.size_bytes,
        status=file.status,
        storage_path=file.storage_path,
        parsed_text=file.parsed_text,
        created_at=file.created_at,
        updated_at=file.updated_at,
    )


@router.post("/files/upload/init", response_model=FileUploadInitResponse)
def upload_init(
    payload: FileUploadInitRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FileUploadInitResponse:
    stored = storage_service.init_upload(
        db,
        user_id=user.id,
        plan_code=user.plan_code,
        filename=payload.filename,
        content_type=payload.content_type,
        size_bytes=payload.size_bytes,
        idempotency_key=payload.idempotency_key,
    )
    upload_url = storage_service.build_storage_path(user.id, stored.id, stored.filename)
    return FileUploadInitResponse(
        file_id=str(stored.id),
        status=stored.status,
        filename=stored.filename,
        extension=stored.extension,
        content_type=stored.content_type,
        size_bytes=stored.size_bytes,
        upload_url=upload_url,
    )


@router.post("/files/upload/complete", response_model=FileResponse)
def upload_complete(
    payload: FileUploadCompleteRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FileResponse:
    try:
        file_uuid = uuid.UUID(payload.file_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid file id") from exc

    stored = storage_service.complete_upload(
        db,
        file_id=file_uuid,
        user_id=user.id,
        storage_path=payload.storage_path,
        content_text=payload.content_text,
    )
    return _file_response(stored)


@router.get("/files", response_model=FileListResponse)
def list_files(
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FileListResponse:
    files = storage_service.list_files(db, user_id=user.id)
    return FileListResponse(files=[_file_response(file) for file in files])


@router.delete("/files/{file_id}", response_model=FileDeleteResponse)
def delete_file(
    file_id: str,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FileDeleteResponse:
    try:
        file_uuid = uuid.UUID(file_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid file id") from exc

    file = storage_service.delete_file(db, file_id=file_uuid, user_id=user.id)
    return FileDeleteResponse(id=str(file.id), status=file.status)


@router.get("/files/{file_id}/download", response_model=FileDownloadResponse)
def download_file(
    file_id: str,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> FileDownloadResponse:
    try:
        file_uuid = uuid.UUID(file_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid file id") from exc

    download_url = storage_service.get_download_url(db, file_id=file_uuid, user_id=user.id)
    return FileDownloadResponse(id=str(file_uuid), download_url=download_url)
