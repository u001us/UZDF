from aiogram import Router, types
from aiogram.filters import CommandStart
from telegram_bot import database

router = Router()

@router.message(CommandStart())
async def cmd_start(message: types.Message):
    user = message.from_user
    # Register user in DB
    await database.save_telegram_user(
        user_id=user.id,
        username=user.username,
        first_name=user.first_name,
        last_name=user.last_name
    )
    # Save command to chat history
    await database.save_telegram_message(
        telegram_user_id=user.id,
        text="/start",
        is_from_user=True
    )
    
    # Send welcome response
    await message.reply(
        "👋 Здравствуйте! Добро пожаловать в службу техподдержки UZDF Uzbekistan.\n\n"
        "Опишите ваш вопрос или проблему здесь, и наши администраторы ответят вам прямо в этот чат в ближайшее время."
    )
