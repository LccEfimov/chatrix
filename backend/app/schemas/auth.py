from pydantic import BaseModel, EmailStr, Field


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class OAuthStartResponse(BaseModel):
    provider: str
    auth_url: str
    state: str


class OAuthCallbackRequest(BaseModel):
    code: str = Field(min_length=1, max_length=2048)
    state: str = Field(min_length=1, max_length=255)


class LinkProviderRequest(BaseModel):
    code: str = Field(min_length=1, max_length=2048)
    state: str = Field(min_length=1, max_length=255)


class RefreshRequest(BaseModel):
    refresh_token: str


class LogoutRequest(BaseModel):
    refresh_token: str


class UserProvider(BaseModel):
    provider: str
    provider_user_id: str


class UserMeResponse(BaseModel):
    id: str
    email: EmailStr
    plan_code: str
    providers: list[UserProvider]


class AuthResponse(BaseModel):
    user: UserMeResponse
    tokens: TokenPair
