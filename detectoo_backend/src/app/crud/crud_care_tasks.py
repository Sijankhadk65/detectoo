from fastcrud import FastCRUD

from ..models.care_task import CareTask
from ..schemas.care_task import (
    CareTaskCreateInternal,
    CareTaskDelete,
    CareTaskRead,
    CareTaskUpdate,
    CareTaskUpdateInternal,
)

CRUDCareTask = FastCRUD[
    CareTask,
    CareTaskCreateInternal,
    CareTaskUpdate,
    CareTaskUpdateInternal,
    CareTaskDelete,
    CareTaskRead,
]
crud_care_tasks = CRUDCareTask(CareTask)
