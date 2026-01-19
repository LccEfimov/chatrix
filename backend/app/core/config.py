from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    env: str = "dev"
    app_name: str = "ChatriX API"

    database_url: str

    jwt_secret: str
    jwt_access_ttl_min: int = 30
    jwt_refresh_ttl_days: int = 30

    cors_origins: list[str] = ["*"]

    oauth_redirect_base: str = "http://localhost:8000/v1/auth/oauth"
    oauth_state_ttl_minutes: int = 10

    oauth_google_client_id: str | None = None
    oauth_google_client_secret: str | None = None
    oauth_google_auth_url: str | None = None
    oauth_google_token_url: str | None = None
    oauth_google_userinfo_url: str | None = None
    oauth_google_scopes: str | None = None

    oauth_apple_client_id: str | None = None
    oauth_apple_client_secret: str | None = None
    oauth_apple_auth_url: str | None = None
    oauth_apple_token_url: str | None = None
    oauth_apple_userinfo_url: str | None = None
    oauth_apple_scopes: str | None = None

    oauth_yandex_client_id: str | None = None
    oauth_yandex_client_secret: str | None = None
    oauth_yandex_auth_url: str | None = None
    oauth_yandex_token_url: str | None = None
    oauth_yandex_userinfo_url: str | None = None
    oauth_yandex_scopes: str | None = None

    oauth_telegram_client_id: str | None = None
    oauth_telegram_client_secret: str | None = None
    oauth_telegram_auth_url: str | None = None
    oauth_telegram_token_url: str | None = None
    oauth_telegram_userinfo_url: str | None = None
    oauth_telegram_scopes: str | None = None

    oauth_discord_client_id: str | None = None
    oauth_discord_client_secret: str | None = None
    oauth_discord_auth_url: str | None = None
    oauth_discord_token_url: str | None = None
    oauth_discord_userinfo_url: str | None = None
    oauth_discord_scopes: str | None = None

    oauth_tiktok_client_id: str | None = None
    oauth_tiktok_client_secret: str | None = None
    oauth_tiktok_auth_url: str | None = None
    oauth_tiktok_token_url: str | None = None
    oauth_tiktok_userinfo_url: str | None = None
    oauth_tiktok_scopes: str | None = None


settings = Settings()  # type: ignore
