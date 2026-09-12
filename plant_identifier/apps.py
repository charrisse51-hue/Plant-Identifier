from django.apps import AppConfig


class PlantIdentifierConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'plant_identifier'

    def ready(self):
        """
        Pre-warm the MobileNetV3 backbone and reference embeddings in a
        background thread so the very first scan request is fast.
        """
        import threading

        def _prewarm():
            try:
                from plant_identifier.views.prediction_views import (
                    _get_vision_backbone,
                    _load_ph_reference_embeddings,
                )
                _get_vision_backbone()
                _load_ph_reference_embeddings()
                print("[PlantIdentifierConfig] Embeddings pre-warmed and ready.")
            except Exception as exc:
                print(f"[PlantIdentifierConfig] Pre-warm failed (non-fatal): {exc}")

        t = threading.Thread(target=_prewarm, daemon=True, name="embedding-prewarm")
        t.start()
