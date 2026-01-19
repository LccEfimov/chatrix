from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.schemas.support import (
    SupportTicketCreateRequest,
    SupportTicketListResponse,
    SupportTicketResponse,
)
from app.services import support as support_service

router = APIRouter()


def _serialize_ticket(ticket) -> SupportTicketResponse:
    return SupportTicketResponse(
        id=str(ticket.id),
        subject=ticket.subject,
        message=ticket.message,
        category=ticket.category,
        status=ticket.status,
        created_at=ticket.created_at,
        updated_at=ticket.updated_at,
    )


@router.post("/support/tickets", response_model=SupportTicketResponse)
def create_ticket(
    payload: SupportTicketCreateRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SupportTicketResponse:
    ticket = support_service.create_ticket(
        db,
        user_id=user.id,
        subject=payload.subject,
        message=payload.message,
        category=payload.category,
    )
    return _serialize_ticket(ticket)


@router.get("/support/tickets", response_model=SupportTicketListResponse)
def list_tickets(
    limit: int = Query(50, ge=1, le=200),
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> SupportTicketListResponse:
    tickets = support_service.list_tickets(db, user_id=user.id, limit=limit)
    return SupportTicketListResponse(tickets=[_serialize_ticket(ticket) for ticket in tickets])
