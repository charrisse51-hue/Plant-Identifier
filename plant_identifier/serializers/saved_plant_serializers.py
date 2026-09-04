from rest_framework import serializers
from ..models import SavedPlant


class SavedPlantSerializer(serializers.ModelSerializer):
    class Meta:
        model = SavedPlant
        fields = '__all__'
        read_only_fields = ('user',)
