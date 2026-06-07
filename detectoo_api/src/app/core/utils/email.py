"""Email sending utilities backed by the Resend API."""

import asyncio
import logging
from functools import partial

import resend

from ..config import settings

logger = logging.getLogger(__name__)


def _send_verification_email_sync(to_email: str, name: str, token: str) -> None:
    """Synchronous helper that calls the Resend SDK (runs in a thread pool)."""
    resend.api_key = settings.RESEND_API_KEY.get_secret_value()

    verification_url = f"{settings.FRONTEND_URL}/api/v1/verify-email?token={token}"
    first_name = name.split()[0] if name else "there"

    html = f"""
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Verify your Detectoo email</title>
</head>
<body style="margin:0;padding:0;background:#f6f7f5;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f6f7f5;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="560" cellpadding="0" cellspacing="0"
               style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,.08);">
          <!-- Header -->
          <tr>
            <td align="center"
                style="background:linear-gradient(135deg,#2e7d32,#00897b);padding:40px 32px;">
              <div style="width:64px;height:64px;background:rgba(255,255,255,.2);
                          border-radius:16px;display:inline-flex;align-items:center;
                          justify-content:center;margin-bottom:16px;">
                <span style="font-size:32px;">🌿</span>
              </div>
              <h1 style="margin:0;color:#ffffff;font-size:24px;font-weight:700;">Detectoo</h1>
              <p style="margin:6px 0 0;color:rgba(255,255,255,.8);font-size:14px;">
                Keep your plants healthy
              </p>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:40px 32px;">
              <h2 style="margin:0 0 12px;color:#1a1a1a;font-size:20px;">
                Hi {first_name}, please verify your email
              </h2>
              <p style="margin:0 0 24px;color:#555;font-size:15px;line-height:1.6;">
                Thanks for signing up for Detectoo! Click the button below to verify your
                email address and activate your account.
              </p>
              <table cellpadding="0" cellspacing="0" width="100%">
                <tr>
                  <td align="center" style="padding:8px 0 32px;">
                    <a href="{verification_url}"
                       style="display:inline-block;background:linear-gradient(135deg,#2e7d32,#00897b);
                              color:#ffffff;text-decoration:none;font-size:16px;font-weight:600;
                              padding:14px 40px;border-radius:12px;">
                      Verify Email Address
                    </a>
                  </td>
                </tr>
              </table>
              <p style="margin:0 0 8px;color:#888;font-size:13px;">
                This link expires in 24 hours. If you didn't create an account, you can safely ignore this email.
              </p>
              <p style="margin:0;color:#aaa;font-size:12px;word-break:break-all;">
                Or copy this link: {verification_url}
              </p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="background:#f6f7f5;padding:20px 32px;text-align:center;">
              <p style="margin:0;color:#aaa;font-size:12px;">
                &copy; 2026 Detectoo. All rights reserved.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
"""

    params: resend.Emails.SendParams = {
        "from": settings.RESEND_FROM_EMAIL,
        "to": [to_email],
        "subject": "Verify your Detectoo email address",
        "html": html,
    }
    resend.Emails.send(params)


async def send_verification_email(to_email: str, name: str, token: str) -> None:
    """Send an email-verification email via Resend (non-blocking)."""
    loop = asyncio.get_event_loop()
    try:
        await loop.run_in_executor(
            None,
            partial(_send_verification_email_sync, to_email, name, token),
        )
    except Exception:
        logger.exception("Failed to send verification email to %s", to_email)
        raise
