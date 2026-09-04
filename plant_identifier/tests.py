import json

from django.contrib.auth.models import User
from django.test import TestCase
from django.urls import reverse


class MobileAuthenticationTests(TestCase):
    def post_json(self, url, data):
        return self.client.post(
            url,
            data=json.dumps(data),
            content_type='application/json',
        )

    def test_user_can_register_and_log_in(self):
        registration = self.post_json(reverse('mobile_register'), {
            'first_name': 'Plant',
            'last_name': 'User',
            'email': 'plant.user@example.com',
            'password': 'SecurePass123!',
            'confirm_password': 'SecurePass123!',
        })

        self.assertEqual(registration.status_code, 201)
        self.assertTrue(registration.json()['success'])
        self.assertTrue(User.objects.filter(email='plant.user@example.com').exists())

        login = self.post_json(reverse('mobile_login'), {
            'email': 'PLANT.USER@EXAMPLE.COM',
            'password': 'SecurePass123!',
        })

        self.assertEqual(login.status_code, 200)
        payload = login.json()
        self.assertTrue(payload['success'])
        self.assertEqual(payload['user']['email'], 'plant.user@example.com')

    def test_registration_rejects_duplicate_email_regardless_of_case(self):
        User.objects.create_user(
            username='existing@example.com',
            email='existing@example.com',
            password='SecurePass123!',
        )

        response = self.post_json(reverse('mobile_register'), {
            'first_name': 'Existing',
            'last_name': 'User',
            'email': 'EXISTING@EXAMPLE.COM',
            'password': 'SecurePass123!',
            'confirm_password': 'SecurePass123!',
        })

        self.assertEqual(response.status_code, 400)
        self.assertIn('email', response.json()['errors'])

    def test_login_rejects_invalid_password(self):
        User.objects.create_user(
            username='plant.user@example.com',
            email='plant.user@example.com',
            password='SecurePass123!',
        )

        response = self.post_json(reverse('mobile_login'), {
            'email': 'plant.user@example.com',
            'password': 'wrong-password',
        })

        self.assertEqual(response.status_code, 400)
        self.assertFalse(response.json()['success'])
