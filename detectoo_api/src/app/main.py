"""FastAPI entrypoint for `detectoo_api`."""

from .api import router
from .core.setup import create_application

app = create_application(router=router)
