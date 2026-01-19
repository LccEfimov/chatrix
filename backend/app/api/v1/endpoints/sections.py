from __future__ import annotations

import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.schemas.sections import (
    SectionCreateRequest,
    SectionListResponse,
    SectionResponse,
    SectionRunRequest,
    SectionRunResponse,
)
from app.services import sections as sections_service

router = APIRouter()


@router.post("/sections", response_model=SectionResponse)
def create_section(
    payload: SectionCreateRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SectionResponse:
    section = sections_service.create_section(
        db,
        user_id=user.id,
        category=payload.category,
        brief=payload.brief.model_dump(),
        ux_config=payload.ux_config,
        ai_workflow=payload.ai_workflow,
        idempotency_key=payload.idempotency_key,
    )
    return SectionResponse(
        id=str(section.id),
        category=section.category,
        title=section.title,
        brief=section.brief,
        ux_config=section.ux_config,
        ai_workflow=section.ai_workflow,
        is_active=section.is_active,
        fee_cents=section.fee_cents,
        last_run_at=section.last_run_at,
        created_at=section.created_at,
        updated_at=section.updated_at,
        note=section.note,
    )


@router.get("/sections", response_model=SectionListResponse)
def list_sections(
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SectionListResponse:
    sections = sections_service.list_sections(db, user_id=user.id)
    return SectionListResponse(
        sections=[
            SectionResponse(
                id=str(section.id),
                category=section.category,
                title=section.title,
                brief=section.brief,
                ux_config=section.ux_config,
                ai_workflow=section.ai_workflow,
                is_active=section.is_active,
                fee_cents=section.fee_cents,
                last_run_at=section.last_run_at,
                created_at=section.created_at,
                updated_at=section.updated_at,
                note=section.note,
            )
            for section in sections
        ]
    )


@router.get("/sections/{section_id}", response_model=SectionResponse)
def get_section(
    section_id: str,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SectionResponse:
    try:
        section_uuid = uuid.UUID(section_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid section id") from exc

    section = sections_service.get_section_or_404(db, section_id=section_uuid, user_id=user.id)
    return SectionResponse(
        id=str(section.id),
        category=section.category,
        title=section.title,
        brief=section.brief,
        ux_config=section.ux_config,
        ai_workflow=section.ai_workflow,
        is_active=section.is_active,
        fee_cents=section.fee_cents,
        last_run_at=section.last_run_at,
        created_at=section.created_at,
        updated_at=section.updated_at,
        note=section.note,
    )


@router.post("/sections/{section_id}/run", response_model=SectionRunResponse)
def run_section(
    section_id: str,
    payload: SectionRunRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SectionRunResponse:
    try:
        section_uuid = uuid.UUID(section_id)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid section id") from exc

    section = sections_service.get_section_or_404(db, section_id=section_uuid, user_id=user.id)
    run_at, output_preview = sections_service.run_section(
        db, section=section, input_payload=payload.input_payload
    )
    return SectionRunResponse(
        section_id=str(section.id),
        status="queued",
        run_at=run_at,
        output_preview=output_preview,
    )
