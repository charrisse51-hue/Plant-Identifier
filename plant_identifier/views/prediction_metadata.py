import json
import os
from django.conf import settings

BASE_DIR = getattr(settings, "BASE_DIR", os.getcwd())
JSON_DIR = os.path.join(BASE_DIR, "json")


def _safe_load_json(path: str, default):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return default


class_idx_to_species_id = _safe_load_json(
    os.path.join(JSON_DIR, "class_idx_to_species_id.json"),
    {},
)

_cmn = _safe_load_json(
    os.path.join(JSON_DIR, "plantnet300k_species_id_2_CmnName.json"),
    {},
)
species_id_to_cmn_name = {str(k).strip(): v for k, v in _cmn.items()}

_scn = _safe_load_json(
    os.path.join(JSON_DIR, "plantnet300K_species_id_2_ScnName.json"),
    {},
)
species_id_to_scn_name = {str(k).strip(): v for k, v in _scn.items()}
