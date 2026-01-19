from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.logging import configure_logging
from app.core.observability import correlation_id_middleware, request_logging_middleware
from app.api.v1.router import api_router


def create_app() -> FastAPI:
    configure_logging()
    app = FastAPI(title=settings.app_name)

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"] ,
        allow_headers=["*"],
    )

    app.middleware("http")(correlation_id_middleware(settings.app_name))
    app.middleware("http")(request_logging_middleware())

    app.include_router(api_router, prefix="/v1")
    return app


app = create_app()
