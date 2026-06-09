import logging
import asyncio
from telegram_bot import database

class DBLogHandler(logging.Handler):
    def emit(self, record):
        try:
            log_entry = self.format(record)
            level = record.levelname
            
            try:
                loop = asyncio.get_running_loop()
                # If there's a running loop, run as task
                loop.create_task(database.save_bot_log(level, log_entry))
            except RuntimeError:
                # No running event loop (e.g. startup/shutdown), run sync-ish
                loop = asyncio.new_event_loop()
                loop.run_until_complete(database.save_bot_log(level, log_entry))
                loop.close()
        except Exception as e:
            # Prevent logging errors from crashing the app
            print(f"Error in DBLogHandler: {e}")

def setup_logger():
    # Bind to root logger to capture logs from all libraries, including aiogram
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    
    # Prevent duplicate handlers if already set up
    if not logger.handlers:
        # Console handler
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
        
        # DB handler
        db_handler = DBLogHandler()
        db_handler.setLevel(logging.INFO)
        db_handler.setFormatter(logging.Formatter('%(name)s - %(message)s'))
        logger.addHandler(db_handler)
        
    return logger
