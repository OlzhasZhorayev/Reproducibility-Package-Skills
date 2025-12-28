
from pathlib import Path
import os

CODE_DIR = Path(__file__).resolve().parent
BASE_DIR = Path(os.environ.get("REPRO_DIR", CODE_DIR.parent))

DATA_DIR = BASE_DIR / "Data"
TEMP_DIR = BASE_DIR / "Temp"
FIG_DIR  = BASE_DIR / "Figures"
TABLE_DIR = BASE_DIR / "Tables"
CODE_DIR = BASE_DIR / "Code"
