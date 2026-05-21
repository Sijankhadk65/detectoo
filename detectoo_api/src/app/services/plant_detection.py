"""Plant detection service using Claude vision."""

import base64
import json
import logging

import anthropic

from ..core.config import settings

logger = logging.getLogger(__name__)

_MODEL = "claude-sonnet-4-6"

# Maps the category Claude returns to a Material Icons code point.
_CATEGORY_TO_ICON: dict[str, int] = {
    "tropical": 0xE56D,    # eco
    "flowering": 0xE894,   # local_florist
    "succulent": 0xE56D,   # eco
    "herb": 0xE894,        # local_florist
    "fern": 0xEA1E,        # yard
    "grass": 0xEA1E,       # yard
    "tree": 0xF483,        # forest
}
_DEFAULT_ICON = 0xE56D  # eco

_DETECTION_PROMPT = """\
You are a plant identification expert. Analyze this image and respond with ONLY valid JSON — no markdown fences, no explanation.

If the image does NOT contain a plant (e.g. food, object, person, blurry image), respond with:
{"error": "not_a_plant", "message": "<brief reason, max 80 chars>"}

If the image contains a plant, respond with:
{
  "plant_name": "<common name, e.g. Monstera Deliciosa>",
  "health_status": "<one of: healthy, needsAttention, recovering>",
  "plant_category": "<one of: tropical, flowering, succulent, herb, fern, grass, tree>"
}

Health status rules:
- healthy: lush green, no damage
- needsAttention: yellowing, wilting, brown spots, drooping, pests
- recovering: pale, stressed but with new growth"""


class PlantDetectionError(Exception):
    """Raised when the image is not a recognisable plant."""

    def __init__(self, message: str) -> None:
        super().__init__(message)
        self.message = message


class PlantDetectionResult:
    """Structured result from plant detection."""

    def __init__(self, name: str, health_status: str, icon_code_point: int) -> None:
        self.name = name
        self.health_status = health_status
        self.icon_code_point = icon_code_point


_MEDIA_TYPES: dict[str, str] = {
    "jpg": "image/jpeg",
    "jpeg": "image/jpeg",
    "png": "image/png",
    "webp": "image/webp",
    "heic": "image/jpeg",
}


async def detect_plant(image_path: str) -> PlantDetectionResult:
    """Analyse *image_path* with Claude and return structured plant data.

    Raises:
        PlantDetectionError: If the image is not a recognisable plant or the
            API call fails.
    """
    api_key = settings.ANTHROPIC_API_KEY.get_secret_value()
    if not api_key:
        raise PlantDetectionError("ANTHROPIC_API_KEY is not configured")

    ext = image_path.rsplit(".", 1)[-1].lower()
    media_type = _MEDIA_TYPES.get(ext, "image/jpeg")

    with open(image_path, "rb") as f:
        image_data = base64.standard_b64encode(f.read()).decode("utf-8")

    client = anthropic.AsyncAnthropic(api_key=api_key)

    try:
        response = await client.messages.create(
            model=_MODEL,
            max_tokens=256,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": media_type,
                                "data": image_data,
                            },
                        },
                        {"type": "text", "text": _DETECTION_PROMPT},
                    ],
                }
            ],
        )
    except anthropic.APIError as exc:
        logger.exception("Anthropic API error during plant detection")
        raise PlantDetectionError(f"Plant detection unavailable: {exc}") from exc

    raw = response.content[0].text.strip()
    logger.debug("Claude detection response: %s", raw)

    try:
        data: dict = json.loads(raw)
    except json.JSONDecodeError as exc:
        logger.error("Claude returned non-JSON: %s", raw)
        raise PlantDetectionError("Could not parse detection result") from exc

    if "error" in data:
        raise PlantDetectionError(data.get("message", "Image does not contain a plant"))

    name: str = data.get("plant_name") or "Unknown Plant"
    health_status: str = data.get("health_status", "healthy")
    if health_status not in {"healthy", "needsAttention", "recovering"}:
        health_status = "healthy"

    category: str = data.get("plant_category", "")
    icon_code_point = _CATEGORY_TO_ICON.get(category, _DEFAULT_ICON)

    return PlantDetectionResult(
        name=name,
        health_status=health_status,
        icon_code_point=icon_code_point,
    )
