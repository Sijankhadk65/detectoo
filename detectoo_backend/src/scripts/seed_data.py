"""Populate the database with sample plants, scans, recovery plans, reminders, and care tasks.

Idempotent — re-running will not create duplicates (skipped by unique seed markers).
Intended to be run against a fresh or partially-populated dev database after the
admin superuser has been created.

Usage:
    docker compose run --rm seed_data
"""

import asyncio
import logging
from datetime import UTC, datetime, timedelta

from sqlalchemy import select

from ..app.core.db.database import AsyncSession, local_session
from ..app.models.care_task import CareTask
from ..app.models.plant import Plant
from ..app.models.recovery import RecoveryPlan, RecoveryStep
from ..app.models.reminder import Reminder
from ..app.models.scan import Scan
from ..app.models.user import User

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

SEED_MARKER = "[seed]"


async def _get_admin_user_id(session: AsyncSession) -> int | None:
    """Return the first superuser's id, or None if no superuser exists."""
    result = await session.execute(select(User).where(User.is_superuser.is_(True)).limit(1))
    user = result.scalar_one_or_none()
    return user.id if user else None


async def _seed_plants(session: AsyncSession, user_id: int) -> dict[str, Plant]:
    """Create sample plants owned by the user. Returns them by name."""
    plants_by_name: dict[str, Plant] = {}

    seeds = [
        ("Tomato Plant [seed]", "healthy", 0xE894, timedelta(hours=6)),
        ("Aloe Vera [seed]", "needsAttention", 0xE3F4, timedelta(days=2)),
        ("Basil [seed]", "recovering", 0xEB49, timedelta(hours=18)),
    ]

    for name, status, icon, watered_delta in seeds:
        existing = await session.execute(select(Plant).where(Plant.name == name, Plant.created_by_user_id == user_id))
        plant = existing.scalar_one_or_none()
        if plant is None:
            plant = Plant(
                created_by_user_id=user_id,
                name=name,
                health_status=status,
                last_watered=datetime.now(UTC) - watered_delta,
                icon_code_point=icon,
            )
            session.add(plant)
            await session.flush()
            logger.info("Created plant: %s (id=%s, status=%s)", name, plant.id, status)
        else:
            logger.info("Plant already seeded: %s (id=%s)", name, plant.id)
        plants_by_name[name] = plant

    return plants_by_name


async def _seed_scans(session: AsyncSession, user_id: int, plants: dict[str, Plant]) -> list[Scan]:
    """Create sample scans. Returns scans created or found."""
    basil = plants["Basil [seed]"]
    aloe = plants["Aloe Vera [seed]"]

    seeds = [
        {
            "image_url": f"https://example.com/seed-scan-basil.jpg?marker={SEED_MARKER}",
            "plant_id": basil.id,
            "plant_name": "Basil",
            "species": "Ocimum basilicum",
            "is_healthy": False,
            "issues": [
                {
                    "name": "Leaf Spot",
                    "description": "Dark brown circular spots on lower leaves.",
                    "severity": "Moderate",
                    "confidence": 0.87,
                },
                {
                    "name": "Overwatering",
                    "description": "Soil shows signs of excess moisture.",
                    "severity": "Mild",
                    "confidence": 0.62,
                },
            ],
        },
        {
            "image_url": f"https://example.com/seed-scan-aloe.jpg?marker={SEED_MARKER}",
            "plant_id": aloe.id,
            "plant_name": "Aloe Vera",
            "species": "Aloe barbadensis miller",
            "is_healthy": False,
            "issues": [
                {
                    "name": "Sunburn",
                    "description": "Yellowing and browning at leaf tips.",
                    "severity": "Mild",
                    "confidence": 0.74,
                },
            ],
        },
        {
            "image_url": f"https://example.com/seed-scan-unattached.jpg?marker={SEED_MARKER}",
            "plant_id": None,
            "plant_name": "Unknown",
            "species": "Unidentified",
            "is_healthy": True,
            "issues": [],
        },
    ]

    scans: list[Scan] = []
    for seed in seeds:
        existing = await session.execute(select(Scan).where(Scan.image_url == seed["image_url"]))
        scan = existing.scalar_one_or_none()
        if scan is None:
            scan = Scan(
                created_by_user_id=user_id,
                plant_name=seed["plant_name"],
                species=seed["species"],
                image_url=seed["image_url"],
                plant_id=seed["plant_id"],
                is_healthy=seed["is_healthy"],
                issues=seed["issues"],
            )
            session.add(scan)
            await session.flush()
            logger.info(
                "Created scan: %s, plant_id=%s, issues=%s (id=%s)",
                seed["plant_name"],
                seed["plant_id"],
                len(seed["issues"]),
                scan.id,
            )
        else:
            logger.info("Scan already seeded: %s (id=%s)", seed["image_url"], scan.id)
        scans.append(scan)

    return scans


async def _seed_recovery_plan(session: AsyncSession, user_id: int, plant: Plant, scan: Scan) -> RecoveryPlan | None:
    """Create a recovery plan with steps for the basil plant. Returns the plan."""
    summary = f"Recover basil from leaf spot and overwatering {SEED_MARKER}"
    existing = await session.execute(select(RecoveryPlan).where(RecoveryPlan.summary == summary))
    plan = existing.scalar_one_or_none()

    if plan is not None:
        logger.info("Recovery plan already seeded (id=%s)", plan.id)
        return plan

    plan = RecoveryPlan(
        created_by_user_id=user_id,
        plant_id=plant.id,
        scan_id=scan.id,
        condition="Leaf Spot + Overwatering",
        severity="Moderate",
        summary=summary,
        progress=0.25,
        started_on=datetime.now(UTC) - timedelta(days=2),
        estimated_recovery="~12 days",
        is_active=True,
        do_list=[
            "Remove and discard affected leaves",
            "Let top inch of soil dry between waterings",
            "Provide 6+ hours of indirect sunlight",
        ],
        dont_list=[
            "Don't water the leaves directly",
            "Don't move the plant to direct sun yet",
        ],
        signs_of_improvement=[
            "No new spots appearing on healthy leaves",
            "Firm stems and vibrant green color",
        ],
    )
    session.add(plan)
    await session.flush()
    logger.info("Created recovery plan (id=%s) for plant=%s", plan.id, plant.name)

    steps_seed = [
        ("Prune affected leaves", "Snip off leaves with visible spots.", 0xE8C9, True, 1),
        ("Apply neem oil treatment", "Spray a diluted neem oil mix in the evening.", 0xE3F4, False, 2),
        ("Check drainage", "Verify the pot drains well after watering.", 0xE894, False, 3),
    ]

    for title, description, icon, completed, order in steps_seed:
        step = RecoveryStep(
            recovery_plan_id=plan.id,
            title=title,
            description=description,
            icon_code_point=icon,
            completed=completed,
            step_order=order,
        )
        session.add(step)

    await session.flush()
    logger.info("Created %s recovery steps for plan %s", len(steps_seed), plan.id)
    return plan


async def _seed_reminders(session: AsyncSession, user_id: int, plants: dict[str, Plant]) -> None:
    """Create sample reminders tied to plants."""
    now = datetime.now(UTC)
    seeds = [
        (f"Water the tomato plant {SEED_MARKER}", now + timedelta(hours=4), 0xE8B5, "Tomato Plant [seed]"),
        (f"Apply neem oil to basil {SEED_MARKER}", now + timedelta(days=1), 0xE3F4, "Basil [seed]"),
        (f"Rotate plants for even sunlight {SEED_MARKER}", now + timedelta(days=2), 0xE3AF, None),
    ]

    for title, time, icon, plant_name in seeds:
        existing = await session.execute(
            select(Reminder).where(Reminder.title == title, Reminder.created_by_user_id == user_id)
        )
        if existing.scalar_one_or_none() is not None:
            logger.info("Reminder already seeded: %s", title)
            continue

        plant_id = plants[plant_name].id if plant_name else None
        reminder = Reminder(
            created_by_user_id=user_id,
            title=title,
            time=time,
            plant_id=plant_id,
            icon_code_point=icon,
        )
        session.add(reminder)
        logger.info("Created reminder: %s (plant_id=%s)", title, plant_id)

    await session.flush()


async def _seed_care_tasks(session: AsyncSession, user_id: int, plants: dict[str, Plant]) -> None:
    """Create sample care tasks tied to plants."""
    now = datetime.now(UTC)
    seeds = [
        (f"Repot aloe vera {SEED_MARKER}", False, now + timedelta(days=3), "Aloe Vera [seed]"),
        (f"Fertilize tomato plant {SEED_MARKER}", False, now + timedelta(days=1), "Tomato Plant [seed]"),
        (f"Check basil recovery progress {SEED_MARKER}", True, now - timedelta(hours=6), "Basil [seed]"),
        (f"Clean plant stand {SEED_MARKER}", False, now + timedelta(days=5), None),
    ]

    for title, done, due, plant_name in seeds:
        existing = await session.execute(
            select(CareTask).where(CareTask.title == title, CareTask.created_by_user_id == user_id)
        )
        if existing.scalar_one_or_none() is not None:
            logger.info("Care task already seeded: %s", title)
            continue

        plant_id = plants[plant_name].id if plant_name else None
        task = CareTask(
            created_by_user_id=user_id,
            title=title,
            done=done,
            due_date=due,
            plant_id=plant_id,
        )
        session.add(task)
        logger.info("Created care task: %s (done=%s, plant_id=%s)", title, done, plant_id)

    await session.flush()


async def seed(session: AsyncSession) -> None:
    """Run the full seed pipeline."""
    user_id = await _get_admin_user_id(session)
    if user_id is None:
        logger.error("No superuser found — run create_superuser first.")
        return

    logger.info("Seeding data for user_id=%s", user_id)

    plants = await _seed_plants(session, user_id)
    scans = await _seed_scans(session, user_id, plants)
    await _seed_recovery_plan(session, user_id, plants["Basil [seed]"], scans[0])
    await _seed_reminders(session, user_id, plants)
    await _seed_care_tasks(session, user_id, plants)

    await session.commit()
    logger.info("Seed complete.")


async def main() -> None:
    async with local_session() as session:
        await seed(session)


if __name__ == "__main__":
    asyncio.run(main())
