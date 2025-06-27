from django.test import TestCase


class BasicTestCase(TestCase):
    """Basic test to verify the test setup is working."""

    def test_basic_functionality(self):
        """Test that basic assertions work."""
        self.assertTrue(True)
        self.assertEqual(1 + 1, 2)

    def test_django_setup(self):
        """Test that Django is properly configured."""
        from django.conf import settings

        self.assertIsNotNone(settings.SECRET_KEY)
