from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.schemas.media import (
    ImageJobCreateRequest,
    ImageJobListResponse,
    ImageJobResponse,
    VideoAvatarCreateRequest,
    VideoAvatarListResponse,
    VideoAvatarResponse,
    VideoJobCreateRequest,
    VideoJobListResponse,
    VideoJobResponse,
    VoiceSessionCreateRequest,
    VoiceSessionListResponse,
    VoiceSessionResponse,
)
from app.services import media as media_service

router = APIRouter()


def _serialize_voice_session(session) -> VoiceSessionResponse:
    return VoiceSessionResponse(
        id=str(session.id),
        status=session.status,
        mode=session.mode,
        provider=session.provider_code,
        model=session.model,
        started_at=session.started_at,
        ended_at=session.ended_at,
    )


def _serialize_video_avatar(avatar) -> VideoAvatarResponse:
    return VideoAvatarResponse(
        id=str(avatar.id),
        name=avatar.name,
        prompt=avatar.prompt,
        status=avatar.status,
        provider=avatar.provider_code,
        model=avatar.model,
        created_at=avatar.created_at,
        updated_at=avatar.updated_at,
    )


def _serialize_image_job(job) -> ImageJobResponse:
    return ImageJobResponse(
        id=str(job.id),
        prompt=job.prompt,
        status=job.status,
        provider=job.provider_code,
        model=job.model,
        result_url=job.result_url,
        created_at=job.created_at,
        updated_at=job.updated_at,
    )


def _serialize_video_job(job) -> VideoJobResponse:
    return VideoJobResponse(
        id=str(job.id),
        prompt=job.prompt,
        status=job.status,
        provider=job.provider_code,
        model=job.model,
        result_url=job.result_url,
        created_at=job.created_at,
        updated_at=job.updated_at,
    )


@router.post("/voice/sessions", response_model=VoiceSessionResponse)
def create_voice_session(
    payload: VoiceSessionCreateRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> VoiceSessionResponse:
    session = media_service.create_voice_session(
        db,
        user_id=user.id,
        mode=payload.mode,
        provider_code=payload.provider,
        model=payload.model,
    )
    return _serialize_voice_session(session)


@router.get("/voice/sessions", response_model=VoiceSessionListResponse)
def list_voice_sessions(
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> VoiceSessionListResponse:
    sessions = media_service.list_voice_sessions(db, user_id=user.id)
    return VoiceSessionListResponse(
        sessions=[_serialize_voice_session(session) for session in sessions]
    )


@router.post("/voice/sessions/{session_id}/stop", response_model=VoiceSessionResponse)
def stop_voice_session(
    session_id: str,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> VoiceSessionResponse:
    try:
        parsed_id = uuid.UUID(session_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid session id") from exc
    session = media_service.stop_voice_session(
        db,
        session_id=parsed_id,
        user_id=user.id,
    )
    return _serialize_voice_session(session)


@router.post("/video/avatars", response_model=VideoAvatarResponse)
def create_video_avatar(
    payload: VideoAvatarCreateRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> VideoAvatarResponse:
    avatar = media_service.create_video_avatar(
        db,
        user_id=user.id,
        name=payload.name,
        prompt=payload.prompt,
        provider_code=payload.provider,
        model=payload.model,
    )
    return _serialize_video_avatar(avatar)


@router.get("/video/avatars", response_model=VideoAvatarListResponse)
def list_video_avatars(
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> VideoAvatarListResponse:
    avatars = media_service.list_video_avatars(db, user_id=user.id)
    return VideoAvatarListResponse(
        avatars=[_serialize_video_avatar(avatar) for avatar in avatars]
    )


@router.post("/tools/image/jobs", response_model=ImageJobResponse)
def create_image_job(
    payload: ImageJobCreateRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ImageJobResponse:
    job = media_service.create_image_job(
        db,
        user_id=user.id,
        prompt=payload.prompt,
        provider_code=payload.provider,
        model=payload.model,
    )
    return _serialize_image_job(job)


@router.get("/tools/image/jobs", response_model=ImageJobListResponse)
def list_image_jobs(
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ImageJobListResponse:
    jobs = media_service.list_image_jobs(db, user_id=user.id)
    return ImageJobListResponse(jobs=[_serialize_image_job(job) for job in jobs])


@router.post("/tools/video/jobs", response_model=VideoJobResponse)
def create_video_job(
    payload: VideoJobCreateRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> VideoJobResponse:
    job = media_service.create_video_job(
        db,
        user_id=user.id,
        prompt=payload.prompt,
        provider_code=payload.provider,
        model=payload.model,
    )
    return _serialize_video_job(job)


@router.get("/tools/video/jobs", response_model=VideoJobListResponse)
def list_video_jobs(
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> VideoJobListResponse:
    jobs = media_service.list_video_jobs(db, user_id=user.id)
    return VideoJobListResponse(jobs=[_serialize_video_job(job) for job in jobs])
