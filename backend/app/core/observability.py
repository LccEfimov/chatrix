import contextvars
import logging
import time
from collections.abc import Awaitable, Callable
from uuid import uuid4

from fastapi import Request, Response

_correlation_id_ctx = contextvars.ContextVar("correlation_id", default=None)


def get_correlation_id() -> str | None:
    return _correlation_id_ctx.get()


def set_correlation_id(value: str | None) -> None:
    _correlation_id_ctx.set(value)


def correlation_id_middleware(
    app_name: str,
) -> Callable[[Request, Callable[[Request], Awaitable[Response]]], Awaitable[Response]]:
    async def middleware(request: Request, call_next: Callable[[Request], Awaitable[Response]]) -> Response:
        incoming = request.headers.get("X-Correlation-Id")
        correlation_id = incoming or str(uuid4())
        token = _correlation_id_ctx.set(correlation_id)
        try:
            response = await call_next(request)
        finally:
            _correlation_id_ctx.reset(token)
        response.headers["X-Correlation-Id"] = correlation_id
        response.headers["X-App-Name"] = app_name
        return response

    return middleware


def request_logging_middleware() -> Callable[[Request, Callable[[Request], Awaitable[Response]]], Awaitable[Response]]:
    logger = logging.getLogger("app.request")

    async def middleware(request: Request, call_next: Callable[[Request], Awaitable[Response]]) -> Response:
        start = time.perf_counter()
        response = await call_next(request)
        duration_ms = (time.perf_counter() - start) * 1000
        logger.info(
            "request",
            extra={
                "method": request.method,
                "path": request.url.path,
                "status_code": response.status_code,
                "duration_ms": round(duration_ms, 2),
            },
        )
        return response

    return middleware
