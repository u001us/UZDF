import os
from pathlib import Path
from dotenv import load_dotenv

# Load environmental variables from the backend's .env file
backend_env_path = Path(__file__).resolve().parent.parent / "backend" / ".env"
if backend_env_path.exists():
    load_dotenv(backend_env_path)
else:
    load_dotenv()

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
DATABASE_URL = os.getenv("DATABASE_URL")

if not TELEGRAM_BOT_TOKEN:
    print("WARNING: TELEGRAM_BOT_TOKEN is not set in env variables!")
if not DATABASE_URL:
    print("WARNING: DATABASE_URL is not set in env variables!")
