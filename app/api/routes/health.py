from fastapi import APIRouter

router = APIRouter()


@router.get("", name="health:check")
async def health_check() -> dict:
    return {"status": "ok"}