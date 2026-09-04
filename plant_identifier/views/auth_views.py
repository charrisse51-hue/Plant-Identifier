from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.views.decorators.csrf import csrf_exempt
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from plant_identifier.form import UserRegistrationForm, UserLoginForm

@csrf_exempt
@api_view(['POST'])
@authentication_classes([])
@permission_classes([AllowAny])
def registerUser(request):
    form = UserRegistrationForm(request.data)
    if form.is_valid():
        user = form.save(commit=False)
        user.set_password(form.cleaned_data['password'])
        user.save()
        return Response(
            {'success': True, 'message': 'User created successfully!'},
            status=status.HTTP_201_CREATED,
        )
    else:
        errors = form.errors if isinstance(form.errors, dict) else {'error': form.errors}
        return Response({'success': False, 'errors': errors}, status=status.HTTP_400_BAD_REQUEST)

#===================================================================================================================================================================================


@csrf_exempt
@api_view(['POST'])
@authentication_classes([])
@permission_classes([AllowAny])
def loginUser(request):
    form = UserLoginForm(request.data)
    if form.is_valid():
        email = form.cleaned_data['email']
        password = form.cleaned_data['password']

        try:
            # Find user by email
            user_obj = User.objects.filter(email__iexact=email).first()
        except User.DoesNotExist:
            user_obj = None

        if user_obj is None:
            return Response({'success': False, 'error': 'Invalid email or password'}, status=status.HTTP_400_BAD_REQUEST)

        # Authenticate using username (Django requires this internally)
        user = authenticate(username=user_obj.username, password=password)

        if user is not None and user.is_active:
            login(request, user)
            return Response({
                'success': True,
                'user': {
                    'userId': user.id,
                    'first_name': user.first_name,
                    'last_name': user.last_name,
                    'email': user.email,
                    'joined_date': user.date_joined.strftime('%b %d, %Y'),
                }
            }, status=status.HTTP_200_OK)
        else:
            return Response({'success': False, 'error': 'Invalid email or password'}, status=status.HTTP_400_BAD_REQUEST)
    else:
        errors = form.errors if isinstance(form.errors, dict) else {'error': form.errors}
        return Response({'success': False, 'errors': errors}, status=status.HTTP_400_BAD_REQUEST)


#===================================================================================================================================================================================


@csrf_exempt
@api_view(['POST'])
@authentication_classes([])
@permission_classes([AllowAny])
def update_user_account(request):
    data = request.data or {}
    user_id = data.get('userId') or data.get('user_id')
    email = (data.get('email') or '').strip()
    first_name = (data.get('first_name') or '').strip()
    last_name = (data.get('last_name') or '').strip()
    current_password = data.get('current_password')
    new_password = data.get('new_password')

    user = None
    if user_id:
        try:
            user = User.objects.filter(id=user_id).first()
        except Exception:
            user = None

    if not user and email:
        user = User.objects.filter(email__iexact=email).first()

    if not user:
        return Response(
            {'success': False, 'error': 'User not found.'},
            status=status.HTTP_404_NOT_FOUND,
        )

    # Check email changes
    new_email = (data.get('new_email') or email).strip()
    if new_email and new_email.lower() != user.email.lower():
        if User.objects.filter(email__iexact=new_email).exclude(id=user.id).exists():
            return Response(
                {'success': False, 'error': 'This email address is already in use.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        user.email = new_email
        user.username = new_email

    if first_name:
        user.first_name = first_name
    if last_name is not None:
        user.last_name = last_name

    # Optional password change
    if new_password:
        if not current_password:
            return Response(
                {'success': False, 'error': 'Current password is required to set a new password.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if not user.check_password(current_password):
            return Response(
                {'success': False, 'error': 'Current password does not match.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if len(new_password) < 6:
            return Response(
                {'success': False, 'error': 'New password must be at least 6 characters.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        user.set_password(new_password)

    user.save()

    return Response({
        'success': True,
        'message': 'Account details updated successfully!',
        'user': {
            'userId': user.id,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'email': user.email,
            'joined_date': user.date_joined.strftime('%b %d, %Y'),
        }
    }, status=status.HTTP_200_OK)
