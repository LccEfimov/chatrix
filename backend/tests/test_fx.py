from datetime import datetime, timezone
from decimal import Decimal

from app.models.fx_rate import FxRate


def test_fx_latest(client, db_session) -> None:
    db_session.add(
        FxRate(
            rate_date=datetime(2026, 1, 19, tzinfo=timezone.utc).date(),
            ccy="USD",
            rate_to_rub=Decimal("92.50"),
            fetched_at=datetime(2026, 1, 19, tzinfo=timezone.utc),
            source="CBR",
        )
    )
    db_session.add(
        FxRate(
            rate_date=datetime(2026, 1, 19, tzinfo=timezone.utc).date(),
            ccy="EUR",
            rate_to_rub=Decimal("99.10"),
            fetched_at=datetime(2026, 1, 19, tzinfo=timezone.utc),
            source="CBR",
        )
    )
    db_session.commit()

    response = client.get("/v1/fx/rates/latest")
    assert response.status_code == 200
    payload = response.json()
    assert {item["ccy"] for item in payload} == {"USD", "EUR"}
