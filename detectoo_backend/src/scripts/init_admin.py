"""One-shot bootstrap for the CRUDAdmin database.

Runs `admin.initialize()` exactly once before the web container starts so that
gunicorn workers don't race each other to create the admin tables and the
initial admin user. Intended to be invoked via the `init_admin` compose service.
"""

import asyncio
import logging

from ..app.admin.initialize import create_admin_interface

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


async def main() -> None:
    """Initialize the CRUDAdmin database and seed the initial admin user."""
    admin = create_admin_interface()
    if admin is None:
        logger.info("CRUD admin is disabled; nothing to bootstrap.")
        return

    await admin.initialize()
    logger.info("CRUDAdmin database initialized.")


if __name__ == "__main__":
    asyncio.run(main())
