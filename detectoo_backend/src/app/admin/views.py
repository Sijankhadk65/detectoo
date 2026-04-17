from typing import Annotated

from crudadmin import CRUDAdmin
from crudadmin.admin_interface.model_view import PasswordTransformer
from pydantic import BaseModel, Field

from ..core.security import get_password_hash
from ..models.care_task import CareTask
from ..models.plant import Plant
from ..models.post import Post
from ..models.recovery import RecoveryPlan, RecoveryStep
from ..models.reminder import Reminder
from ..models.scan import Scan
from ..models.tier import Tier
from ..models.user import User
from ..schemas.care_task import CareTaskCreateInternal, CareTaskUpdate
from ..schemas.plant import PlantCreate, PlantUpdate
from ..schemas.post import PostUpdate
from ..schemas.recovery import (
    RecoveryPlanCreateInternal,
    RecoveryPlanUpdate,
    RecoveryStepCreateInternal,
    RecoveryStepUpdate,
)
from ..schemas.reminder import ReminderCreateInternal, ReminderUpdate
from ..schemas.scan import ScanCreateInternal, ScanUpdate
from ..schemas.tier import TierCreate, TierUpdate
from ..schemas.user import UserCreate, UserCreateInternal, UserUpdate


class PostCreateAdmin(BaseModel):
    title: Annotated[str, Field(min_length=2, max_length=30, examples=["This is my post"])]
    text: Annotated[str, Field(min_length=1, max_length=63206, examples=["This is the content of my post."])]
    created_by_user_id: int
    media_url: Annotated[
        str | None,
        Field(pattern=r"^(https?|ftp)://[^\s/$.?#].[^\s]*$", examples=["https://www.postimageurl.com"], default=None),
    ]


def register_admin_views(admin: CRUDAdmin) -> None:
    """Register all models and their schemas with the admin interface.

    This function adds all available models to the admin interface with appropriate
    schemas and permissions.
    """

    password_transformer = PasswordTransformer(
        password_field="password",
        hashed_field="hashed_password",
        hash_function=get_password_hash,
        required_fields=["name", "username", "email"],
    )

    admin.add_view(
        model=User,
        create_schema=UserCreate,
        update_schema=UserUpdate,
        update_internal_schema=UserCreateInternal,
        password_transformer=password_transformer,
        allowed_actions={"view", "create", "update"},
    )

    admin.add_view(
        model=Tier,
        create_schema=TierCreate,
        update_schema=TierUpdate,
        allowed_actions={"view", "create", "update", "delete"},
    )

    admin.add_view(
        model=Post,
        create_schema=PostCreateAdmin,
        update_schema=PostUpdate,
        allowed_actions={"view", "create", "update", "delete"},
    )

    admin.add_view(
        model=Plant,
        create_schema=PlantCreate,
        update_schema=PlantUpdate,
        allowed_actions={"view", "create", "update", "delete"},
    )

    admin.add_view(
        model=Scan,
        create_schema=ScanCreateInternal,
        update_schema=ScanUpdate,
        allowed_actions={"view", "create", "update", "delete"},
    )

    admin.add_view(
        model=RecoveryPlan,
        create_schema=RecoveryPlanCreateInternal,
        update_schema=RecoveryPlanUpdate,
        allowed_actions={"view", "create", "update", "delete"},
    )

    admin.add_view(
        model=RecoveryStep,
        create_schema=RecoveryStepCreateInternal,
        update_schema=RecoveryStepUpdate,
        allowed_actions={"view", "create", "update", "delete"},
    )

    admin.add_view(
        model=Reminder,
        create_schema=ReminderCreateInternal,
        update_schema=ReminderUpdate,
        allowed_actions={"view", "create", "update", "delete"},
    )

    admin.add_view(
        model=CareTask,
        create_schema=CareTaskCreateInternal,
        update_schema=CareTaskUpdate,
        allowed_actions={"view", "create", "update", "delete"},
    )
