from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.models.ai_provider import AiProvider
from app.schemas.ai import AiProviderResponse, AiProvidersResponse

router = APIRouter()


@router.get("/ai/providers", response_model=AiProvidersResponse)
def list_ai_providers(db: Session = Depends(get_db)) -> AiProvidersResponse:
    providers = db.execute(select(AiProvider).order_by(AiProvider.code)).scalars().all()
    return AiProvidersResponse(
        providers=[
            AiProviderResponse(
                code=provider.code,
                display_name=provider.display_name,
                is_active=provider.is_active,
            )
            for provider in providers
        ]
    )
