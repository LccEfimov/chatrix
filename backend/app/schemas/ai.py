from pydantic import BaseModel


class AiProviderResponse(BaseModel):
    code: str
    display_name: str
    is_active: bool


class AiProvidersResponse(BaseModel):
    providers: list[AiProviderResponse]
