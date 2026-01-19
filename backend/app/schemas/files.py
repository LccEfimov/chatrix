from datetime import datetime

from pydantic import BaseModel, Field


class FileUploadInitRequest(BaseModel):
    filename: str = Field(..., min_length=1, max_length=255)
    content_type: str = Field(..., min_length=1, max_length=120)
    size_bytes: int = Field(..., ge=1)
    idempotency_key: str | None = Field(default=None, min_length=6, max_length=64)


class FileUploadInitResponse(BaseModel):
    file_id: str
    status: str
    filename: str
    extension: str
    content_type: str
    size_bytes: int
    upload_url: str


class FileUploadCompleteRequest(BaseModel):
    file_id: str
    storage_path: str | None = Field(default=None, max_length=500)
    content_text: str | None = None


class FileResponse(BaseModel):
    id: str
    filename: str
    extension: str
    content_type: str
    size_bytes: int
    status: str
    storage_path: str | None
    parsed_text: str | None
    created_at: datetime
    updated_at: datetime


class FileListResponse(BaseModel):
    files: list[FileResponse]


class FileDeleteResponse(BaseModel):
    id: str
    status: str


class FileDownloadResponse(BaseModel):
    id: str
    download_url: str
