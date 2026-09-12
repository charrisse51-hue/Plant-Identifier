from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.shortcuts import get_object_or_404
from django.contrib.auth.models import User
from ..models import PlantHistory
from ..serializers.history_serializers import PlantHistorySerializer


class PlantHistoryListCreateView(generics.GenericAPIView):
    serializer_class = PlantHistorySerializer
    permission_classes = [AllowAny]

    def get(self, request):
        user_id = request.query_params.get('user_id')
        if not user_id:
            return Response({'error': 'user_id is required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        history = PlantHistory.objects.filter(user=user).order_by('-identified_at')
        serializer = PlantHistorySerializer(history, many=True)
        return Response(serializer.data)

    def post(self, request):
        user_id = request.data.get('user_id')
        if not user_id:
            return Response({'error': 'user_id is required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        serializer = PlantHistorySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request):
        user_id = request.query_params.get('user_id') or request.data.get('user_id')
        if not user_id:
            return Response({'error': 'user_id is required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        ids = request.data.get('ids')
        if ids and isinstance(ids, list):
            PlantHistory.objects.filter(user=user, id__in=ids).delete()
        else:
            PlantHistory.objects.filter(user=user).delete()

        return Response(status=status.HTTP_204_NO_CONTENT)



class PlantHistoryDetailView(generics.GenericAPIView):
    permission_classes = [AllowAny]

    def delete(self, request, id):
        user_id = request.query_params.get('user_id')
        if not user_id:
            return Response({'error': 'user_id is required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        history = get_object_or_404(PlantHistory, id=id, user=user)
        history.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
