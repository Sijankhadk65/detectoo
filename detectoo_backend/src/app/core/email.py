import httpx

from .config import settings


async def send_verification_email(to: str, code: str) -> None:
    """Send a 6-digit OTP verification email via the Resend REST API."""
    html = (
        "<div style='font-family:sans-serif;max-width:420px;margin:0 auto'>"
        "<h2 style='color:#388E3C'>Welcome to Detectoo!</h2>"
        "<p>Use the code below to verify your email address:</p>"
        "<div style='font-size:40px;letter-spacing:12px;font-weight:bold;"
        "color:#1B5E20;padding:16px 0'>"
        f"{code}"
        "</div>"
        "<p style='color:#666;font-size:13px'>This code expires in 15 minutes. "
        "If you didn't sign up for Detectoo, you can safely ignore this email.</p>"
        "</div>"
    )

    async with httpx.AsyncClient() as client:
        response = await client.post(
            "https://api.resend.com/emails",
            headers={"Authorization": f"Bearer {settings.RESEND_API_KEY}"},
            json={
                "from": settings.EMAIL_FROM,
                "to": [to],
                "subject": "Verify your Detectoo account",
                "html": html,
            },
            timeout=10.0,
        )
        response.raise_for_status()
