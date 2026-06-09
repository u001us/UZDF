import asyncpg
from telegram_bot import config

db_pool = None

async def init_db():
    global db_pool
    if not config.DATABASE_URL:
        raise ValueError("DATABASE_URL is not set!")
    # Strip Prisma-specific query parameters (like ?schema=public) that asyncpg doesn't support
    dsn = config.DATABASE_URL.split('?')[0]
    db_pool = await asyncpg.create_pool(dsn=dsn)
    return db_pool

async def close_db():
    global db_pool
    if db_pool:
        await db_pool.close()

async def save_telegram_user(user_id: int, username: str, first_name: str, last_name: str):
    global db_pool
    if not db_pool:
        return
    async with db_pool.acquire() as conn:
        await conn.execute("""
            INSERT INTO "TelegramUser" (id, username, "firstName", "lastName", "createdAt", "updatedAt")
            VALUES ($1, $2, $3, $4, NOW(), NOW())
            ON CONFLICT (id) DO UPDATE
            SET username = EXCLUDED.username,
                "firstName" = EXCLUDED."firstName",
                "lastName" = EXCLUDED."lastName",
                "updatedAt" = NOW()
        """, user_id, username, first_name, last_name)

async def save_telegram_message(telegram_user_id: int, text: str, is_from_user: bool, admin_id: int = None):
    global db_pool
    if not db_pool:
        return
    async with db_pool.acquire() as conn:
        await conn.execute("""
            INSERT INTO "TelegramMessage" ("telegramUserId", text, "isFromUser", "adminId", "createdAt")
            VALUES ($1, $2, $3, $4, NOW())
        """, telegram_user_id, text, is_from_user, admin_id)

async def save_bot_log(level: str, message: str):
    global db_pool
    if not db_pool:
        return
    try:
        async with db_pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO "TelegramBotLog" (level, message, "createdAt")
                VALUES ($1, $2, NOW())
            """, level, message)
    except Exception as e:
        print(f"Failed to log to database: {e}")
