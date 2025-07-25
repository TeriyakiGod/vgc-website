import os

from .base import *

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.getenv("SECRET_KEY")

# SECURITY WARNING: define the correct hosts in production!
ALLOWED_HOSTS = ["*"]

EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"

# Django Debug Toolbar
if DEBUG:
    import sys

    # Only add debug toolbar if not running tests
    if "test" not in sys.argv:
        INSTALLED_APPS += [
            "debug_toolbar",
        ]

        MIDDLEWARE += [
            "debug_toolbar.middleware.DebugToolbarMiddleware",
        ]

        # Debug Toolbar configuration
        INTERNAL_IPS = [
            "127.0.0.1",
            "localhost",
        ]

        DEBUG_TOOLBAR_CONFIG = {
            "SHOW_TOOLBAR_CALLBACK": lambda request: DEBUG,
        }

# Enhanced logging for development
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {
            "format": "{levelname} {asctime} {module} {process:d} {thread:d} {message}",
            "style": "{",
        },
        "simple": {
            "format": "{levelname} {message}",
            "style": "{",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "simple",
        },
    },
    "loggers": {
        "django": {
            "handlers": ["console"],
            "level": "INFO",
        },
        "wagtail": {
            "handlers": ["console"],
            "level": "INFO",
        },
    },
}

try:
    from .local import *
except ImportError:
    pass
