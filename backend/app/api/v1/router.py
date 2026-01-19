from fastapi import APIRouter

from app.api.v1.endpoints.ai import router as ai_router
from app.api.v1.endpoints.auth import router as auth_router
from app.api.v1.endpoints.chat import router as chat_router
from app.api.v1.endpoints.fx import router as fx_router
from app.api.v1.endpoints.health import router as health_router
from app.api.v1.endpoints.media import router as media_router
from app.api.v1.endpoints.payments import router as payments_router
from app.api.v1.endpoints.plans import router as plans_router
from app.api.v1.endpoints.referrals import router as referrals_router
from app.api.v1.endpoints.wallet import router as wallet_router

api_router = APIRouter()
api_router.include_router(health_router, tags=["health"])
api_router.include_router(auth_router, tags=["auth"])
api_router.include_router(ai_router, tags=["ai"])
api_router.include_router(plans_router, tags=["plans"])
api_router.include_router(wallet_router, tags=["wallet"])
api_router.include_router(payments_router, tags=["payments"])
api_router.include_router(fx_router, tags=["fx"])
api_router.include_router(referrals_router, tags=["referrals"])
api_router.include_router(chat_router, tags=["chat"])
api_router.include_router(media_router, tags=["media"])
