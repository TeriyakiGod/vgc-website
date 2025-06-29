# CapRover Environment Variables Setup

When deploying to CapRover, you'll need to set these environment variables in your app configuration:

## Required Environment Variables

### Django Core Settings
- `SECRET_KEY`: A secure secret key for Django (generate with `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`)
- `DEBUG`: Set to `False` for production
- `ALLOWED_HOSTS`: Your domain(s), comma-separated (e.g., `myapp.mydomain.com,*.mydomain.com`)
- `DJANGO_SETTINGS_MODULE`: Set to `mysite.settings.production`

### Database Configuration
- `DB_NAME`: Database name (e.g., `vgc_website`)
- `DB_USER`: Database username (e.g., `vgc_user`)
- `DB_PASSWORD`: Database password (secure password)
- `DB_HOST`: Database host (e.g., `srv-captain--myapp-db` if using CapRover's PostgreSQL)
- `DB_PORT`: Database port (usually `5432`)

### Application Settings
- `PORT`: Application port (set to `8000`)
- `WAGTAILADMIN_BASE_URL`: Your app's public URL (e.g., `https://myapp.mydomain.com`)

## Example CapRover App Configuration

```env
SECRET_KEY=your-very-long-random-secret-key-here
DEBUG=False
ALLOWED_HOSTS=myapp.mydomain.com,*.mydomain.com
DJANGO_SETTINGS_MODULE=mysite.settings.production
DB_NAME=vgc_website
DB_USER=vgc_user
DB_PASSWORD=your-secure-database-password
DB_HOST=srv-captain--myapp-db
DB_PORT=5432
PORT=8000
WAGTAILADMIN_BASE_URL=https://myapp.mydomain.com
```

## Database Setup

1. **Create PostgreSQL Database First**:
   - Go to CapRover → Apps → One-Click Apps/Databases
   - Search for "PostgreSQL" and deploy it
   - Use app name like `myapp-db` (this creates service `srv-captain--myapp-db`)
   - Note the database credentials you set

2. **Update Your Main App**:
   - Set the `DB_HOST` to the PostgreSQL service name (e.g., `srv-captain--myapp-db`)
   - Use the same database credentials in both services

## Deployment Process

The startup script (`start.sh`) automatically handles:
1. ✅ Waiting for database connection
2. ✅ Running database migrations
3. ✅ Collecting static files
4. ✅ Creating superuser (if env vars provided)
5. ✅ Starting Gunicorn server

## Health Check

The app includes a health endpoint at `/health/` that checks:
- Database connectivity
- Application status
- Returns JSON response

## Volumes

The app uses persistent volumes for:
- `/app/static/` - Static files (CSS, JS, images)
- `/app/media/` - User uploaded media files

## Troubleshooting

1. **Check App Logs**: CapRover → Your App → App Logs
2. **Health Check**: Visit `https://yourapp.domain.com/health/`
3. **Database Connection**: Ensure DB_HOST matches your PostgreSQL service name
4. **Static Files**: WhiteNoise serves static files automatically
5. **Migrations**: Check startup logs for migration status

## Security Notes

- Always use strong, unique passwords
- Keep SECRET_KEY secure and unique per environment
- Use HTTPS in production (CapRover handles this)
- Regularly update dependencies and Docker images
