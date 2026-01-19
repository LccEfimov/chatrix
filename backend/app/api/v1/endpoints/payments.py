from fastapi import APIRouter

router = APIRouter()


@router.post("/payments/webhook/{provider}")
def payments_webhook(provider: str) -> dict:
    return {"status": "ok", "provider": provider}
