
import os
from dotenv import load_dotenv

TERYT_GMINA = 181108  # Teryt gmina Radomyśl Wielki
TERYT_MIASTO = 1811083  # Teryt miasto Radomyśl Wielki

DB_HOST = "localhost"
DB_PORT = 5433
DB_NAME = "dzialki_radomysl"
DB_USER = "postgres"

load_dotenv()
DB_PASSWORD = os.getenv("PGPASSWORD")
