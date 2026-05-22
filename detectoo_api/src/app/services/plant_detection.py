"""Plant detection service using Claude vision."""

import base64
import json
import logging
from dataclasses import dataclass, field

import anthropic

from ..core.config import settings

logger = logging.getLogger(__name__)

_MODEL = "claude-sonnet-4-6"

_CATEGORY_TO_ICON: dict[str, int] = {
    "tropical": 0xE56D,
    "flowering": 0xE894,
    "succulent": 0xE56D,
    "herb": 0xE894,
    "fern": 0xEA1E,
    "grass": 0xEA1E,
    "tree": 0xF483,
}
_DEFAULT_ICON = 0xE56D

_VALID_SUNLIGHT = {"low", "indirect", "bright", "direct"}
_VALID_HUMIDITY = {"low", "medium", "high"}
_VALID_SEVERITY = {"Mild", "Moderate", "Severe"}

_DETECTION_PROMPT = """\
You are a plant identification and disease detection expert. Analyze this image and respond with ONLY valid JSON — no markdown fences, no explanation.

If the image does NOT contain a plant (e.g. food, object, person, blurry image), respond with:
{"error": "not_a_plant", "message": "<brief reason, max 80 chars>"}

If the image contains a healthy plant, respond with:
{
  "plant_name": "<short concrete common name, e.g. 'Monstera', 'Snake Plant', 'Climbing Rose'>",
  "health_status": "healthy",
  "plant_category": "<one of: tropical, flowering, succulent, herb, fern, grass, tree>",
  "sunlight": "<one of: low, indirect, bright, direct>",
  "humidity": "<one of: low, medium, high>",
  "disease": null
}

If you detect any disease, pest infestation, or significant health issue, respond with:
{
  "plant_name": "<short concrete common name>",
  "health_status": "<needsAttention or recovering>",
  "plant_category": "<one of: tropical, flowering, succulent, herb, fern, grass, tree>",
  "sunlight": "<one of: low, indirect, bright, direct>",
  "humidity": "<one of: low, medium, high>",
  "disease": {
    "condition": "<name of disease/pest, e.g. 'Powdery Mildew', 'Spider Mite Infestation'>",
    "severity": "<one of: Mild, Moderate, Severe>",
    "summary": "<2-3 sentences describing the condition and its impact on the plant>",
    "estimated_recovery": "<e.g. '2-3 weeks', or null if unknown>",
    "do_list": ["<action 1>", "<action 2>"],
    "dont_list": ["<thing to avoid 1>", "<thing to avoid 2>"],
    "signs_of_improvement": ["<sign 1>", "<sign 2>"],
    "steps": [
      {"title": "<short step title>", "description": "<clear detailed instruction>", "step_order": 0}
    ]
  }
}

Rules:
- plant_name: short and concrete. No parenthetical guesses or variety qualifiers.
- health_status: healthy=lush green no visible damage; needsAttention=clear symptoms present; recovering=stressed but showing new growth
- sunlight/humidity: based on the species' typical requirements, not the current environment
- disease: only include when you can clearly see symptoms. Aim for 3-5 actionable recovery steps."""


class PlantDetectionError(Exception):
    """Raised when the image is not a recognisable plant."""

    def __init__(self, message: str) -> None:
        super().__init__(message)
        self.message = message


@dataclass
class RecoveryStepDetection:
    """A single recovery step suggested by Claude."""

    title: str
    description: str
    step_order: int


@dataclass
class RecoveryPlanDetection:
    """Disease/infestation data returned when Claude spots a health issue."""

    condition: str
    severity: str
    summary: str
    estimated_recovery: str | None
    do_list: list[str] = field(default_factory=list)
    dont_list: list[str] = field(default_factory=list)
    signs_of_improvement: list[str] = field(default_factory=list)
    steps: list[RecoveryStepDetection] = field(default_factory=list)


@dataclass
class PlantDetectionResult:
    """Structured result from plant detection."""

    name: str
    health_status: str
    icon_code_point: int
    sunlight: str
    humidity: str
    recovery_plan: RecoveryPlanDetection | None = None


_MEDIA_TYPES: dict[str, str] = {
    "jpg": "image/jpeg",
    "jpeg": "image/jpeg",
    "png": "image/png",
    "webp": "image/webp",
    "heic": "image/jpeg",
}


def _parse_recovery_plan(raw: dict) -> RecoveryPlanDetection | None:
    """Parse the optional ``disease`` block from Claude's response."""
    if not isinstance(raw, dict):
        return None

    severity = raw.get("severity", "Mild")
    if severity not in _VALID_SEVERITY:
        severity = "Mild"

    raw_steps = raw.get("steps") or []
    steps = [
        RecoveryStepDetection(
            title=str(s.get("title", "")),
            description=str(s.get("description", "")),
            step_order=int(s.get("step_order", i)),
        )
        for i, s in enumerate(raw_steps)
        if isinstance(s, dict)
    ]

    return RecoveryPlanDetection(
        condition=str(raw.get("condition", "Unknown Condition")),
        severity=severity,
        summary=str(raw.get("summary", "")),
        estimated_recovery=raw.get("estimated_recovery") or None,
        do_list=[str(x) for x in raw.get("do_list", []) if x],
        dont_list=[str(x) for x in raw.get("dont_list", []) if x],
        signs_of_improvement=[str(x) for x in raw.get("signs_of_improvement", []) if x],
        steps=steps,
    )


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
            max_tokens=1024,
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

    sunlight: str = data.get("sunlight", "indirect")
    if sunlight not in _VALID_SUNLIGHT:
        sunlight = "indirect"

    humidity: str = data.get("humidity", "medium")
    if humidity not in _VALID_HUMIDITY:
        humidity = "medium"

    recovery_plan = _parse_recovery_plan(data.get("disease")) if data.get("disease") else None

    return PlantDetectionResult(
        name=name,
        health_status=health_status,
        icon_code_point=icon_code_point,
        sunlight=sunlight,
        humidity=humidity,
        recovery_plan=recovery_plan,
    )
