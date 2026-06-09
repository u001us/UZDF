from aiogram import Router, types
from telegram_bot import database

router = Router()

@router.message()
async def handle_user_message(message: types.Message):
    if not message.text:
        await message.reply("Извините, на данный момент поддерживаются только текстовые сообщения.")
        return
        
    user = message.from_user
    
    # Ensure user profile exists/is updated in DB
    await database.save_telegram_user(
        user_id=user.id,
        username=user.username,
        first_name=user.first_name,
        last_name=user.last_name
    )
    
    # Save the user's message to database history
    await database.save_telegram_message(
        telegram_user_id=user.id,
        text=message.text,
        is_from_user=True
    )
    
    # Auto-reply to confirm receipt
    await message.reply(
        "📨 Ваше сообщение принято и передано администраторам. Мы ответим вам в ближайшее время."
    )
