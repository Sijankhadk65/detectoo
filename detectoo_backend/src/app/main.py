from .admin.initialize import create_admin_interface
from .api import router
from .core.config import settings
from .core.setup import create_application

admin = create_admin_interface()

# Alembic is the source of truth for schema and CRUDAdmin's tables are
# bootstrapped out-of-band by src/scripts/init_admin.py, so the app must not
# create tables on startup.
app = create_application(router=router, settings=settings, create_tables_on_start=False)

if admin:
    app.mount(settings.CRUD_ADMIN_MOUNT_PATH, admin.app)
