"""FastCRUD instance for the Reminder model."""

from fastcrud import FastCRUD

from ..models.reminder import Reminder
from ..schemas.reminder import (
    ReminderCreateInternal,
    ReminderDelete,
    ReminderRead,
    ReminderUpdate,
    ReminderUpdateInternal,
)

CRUDReminder = FastCRUD[
    Reminder,
    ReminderCreateInternal,
    ReminderUpdate,
    ReminderUpdateInternal,
    ReminderDelete,
    ReminderRead,
]
crud_reminders = CRUDReminder(Reminder)
