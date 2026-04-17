from fastapi import APIRouter

from .care_tasks import router as care_tasks_router
from .health import router as health_router
from .login import router as login_router
from .logout import router as logout_router
from .plants import router as plants_router
from .posts import router as posts_router
from .rate_limits import router as rate_limits_router
from .recovery import router as recovery_router
from .reminders import router as reminders_router
from .scans import router as scans_router
from .tasks import router as tasks_router
from .tiers import router as tiers_router
from .users import router as users_router

router = APIRouter(prefix="/v1")
router.include_router(health_router)
router.include_router(login_router)
router.include_router(logout_router)
router.include_router(users_router)
router.include_router(posts_router)
router.include_router(plants_router)
router.include_router(scans_router)
router.include_router(recovery_router)
router.include_router(reminders_router)
router.include_router(care_tasks_router)
router.include_router(tasks_router)
router.include_router(tiers_router)
router.include_router(rate_limits_router)
