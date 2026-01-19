from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.schemas.fx import FxRateResponse
from app.services import fx as fx_service

router = APIRouter()


@router.get("/fx/rates/latest", response_model=list[FxRateResponse])
def fx_latest(db: Session = Depends(get_db)) -> list[FxRateResponse]:
    rates = fx_service.get_latest_rates(db)
    return [
        FxRateResponse(
            ccy=rate.ccy,
            rate_date=rate.rate_date,
            rate_to_rub=rate.rate_to_rub,
            fetched_at=rate.fetched_at,
            source=rate.source,
        )
        for rate in rates
    ]
