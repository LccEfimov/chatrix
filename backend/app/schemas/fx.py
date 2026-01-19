from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel


class FxRateResponse(BaseModel):
    ccy: str
    rate_date: date
    rate_to_rub: Decimal
    fetched_at: datetime
    source: str
