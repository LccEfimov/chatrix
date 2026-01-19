from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.schemas.analytics import (
    AnalyticsEventCreateRequest,
    AnalyticsEventListResponse,
    AnalyticsEventResponse,
)
from app.services import analytics as analytics_service

router = APIRouter()


def _serialize_event(event) -> AnalyticsEventResponse:
    return AnalyticsEventResponse(
        id=str(event.id),
        event_name=event.event_name,
        event_source=event.event_source,
        payload=event.payload,
        created_at=event.created_at,
    )


@router.post("/analytics/events", response_model=AnalyticsEventResponse)
def create_event(
    payload: AnalyticsEventCreateRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> AnalyticsEventResponse:
    event = analytics_service.create_event(
        db,
        user_id=user.id,
        event_name=payload.event_name,
        event_source=payload.event_source,
        payload=payload.payload,
    )
    return _serialize_event(event)


@router.get("/analytics/events", response_model=AnalyticsEventListResponse)
def list_events(
    limit: int = Query(50, ge=1, le=200),
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> AnalyticsEventListResponse:
    events = analytics_service.list_events(db, user_id=user.id, limit=limit)
    return AnalyticsEventListResponse(events=[_serialize_event(event) for event in events])
