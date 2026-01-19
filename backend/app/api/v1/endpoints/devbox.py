from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.schemas.devbox import (
    DevboxPackageResponse,
    DevboxRateResponse,
    DevboxSessionResponse,
    DevboxStackResponse,
    DevboxStartRequest,
    DevboxStatusResponse,
    DevboxStopResponse,
)
from app.services import devbox as devbox_service

router = APIRouter()


def _serialize_session(session) -> DevboxSessionResponse:
    return DevboxSessionResponse(
        session_id=str(session.id),
        package_code=session.package_code,
        stack_code=session.stack_code,
        status=session.status,
        cpu_cores=session.cpu_cores,
        ram_gb=session.ram_gb,
        disk_gb=session.disk_gb,
        egress_gb=session.egress_gb,
        hours=session.hours,
        price_rub=session.price_rub,
        started_at=session.started_at,
        stopped_at=session.stopped_at,
    )


def _serialize_packages(packages, rate) -> list[DevboxPackageResponse]:
    responses: list[DevboxPackageResponse] = []
    for package in packages:
        estimated_price = devbox_service.compute_price(
            rate=rate,
            cpu_cores=package.cpu_cores,
            ram_gb=package.ram_gb,
            disk_gb=package.disk_gb,
            hours=package.included_hours,
            duration_days=package.duration_days,
            egress_gb=package.egress_gb,
        )
        responses.append(
            DevboxPackageResponse(
                code=package.code,
                name=package.name,
                cpu_cores=package.cpu_cores,
                ram_gb=package.ram_gb,
                disk_gb=package.disk_gb,
                duration_days=package.duration_days,
                included_hours=package.included_hours,
                egress_gb=package.egress_gb,
                estimated_price_rub=estimated_price,
            )
        )
    return responses


def _serialize_rate(rate) -> DevboxRateResponse:
    return DevboxRateResponse(
        cpu_core_hour_rub=rate.cpu_core_hour_rub,
        ram_gb_hour_rub=rate.ram_gb_hour_rub,
        disk_gb_month_rub=rate.disk_gb_month_rub,
        egress_gb_rub=rate.egress_gb_rub,
        platform_fee_rub=rate.platform_fee_rub,
        margin_percent=rate.margin_percent,
        updated_at=rate.updated_at,
    )


@router.post("/devbox/start", response_model=DevboxSessionResponse)
def devbox_start(
    payload: DevboxStartRequest,
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> DevboxSessionResponse:
    if user.plan_code != "DEV":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="DevBox requires DEV plan")
    session = devbox_service.start_session(
        db,
        user_id=user.id,
        package_code=payload.package_code,
        stack_code=payload.stack_code,
        idempotency_key=payload.idempotency_key,
    )
    return _serialize_session(session)


@router.post("/devbox/stop", response_model=DevboxStopResponse)
def devbox_stop(
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> DevboxStopResponse:
    if user.plan_code != "DEV":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="DevBox requires DEV plan")
    session = devbox_service.stop_session(db, user_id=user.id)
    status_label = "stopped"
    return DevboxStopResponse(
        status=status_label,
        session=_serialize_session(session) if session else None,
    )


@router.get("/devbox/status", response_model=DevboxStatusResponse)
def devbox_status(
    user=Depends(get_current_user),
    db: Session = Depends(get_db),
) -> DevboxStatusResponse:
    if user.plan_code != "DEV":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="DevBox requires DEV plan")
    active_session = devbox_service.get_active_session(db, user_id=user.id)
    rate = devbox_service.get_active_rate(db)
    packages = devbox_service.list_packages(db)
    stacks = devbox_service.list_stacks(db)
    package_payloads = _serialize_packages(packages, rate) if rate else []
    stack_payloads = [DevboxStackResponse(code=stack.code, name=stack.name) for stack in stacks]
    return DevboxStatusResponse(
        status="running" if active_session else "stopped",
        active_session=_serialize_session(active_session) if active_session else None,
        packages=package_payloads,
        stacks=stack_payloads,
        rates=_serialize_rate(rate) if rate else None,
    )
