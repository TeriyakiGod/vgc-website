# CapRover Deployment Guide

This guide explains how to deploy the VGC Website to CapRover using both automated CI/CD pipeline and manual deployment methods.

## Prerequisites

- CapRover server set up and running
- Docker installed locally (for manual deployment)
- GitHub repository with proper secrets configured (for CI/CD)

## Deployment Methods

### 1. Automated Deployment (Recommended)

The automated deployment uses GitHub Actions to build, test, and deploy your application to CapRover on every push to the main branch.

#### Setup GitHub Secrets

Add the following secrets to your GitHub repository (`Settings > Secrets and variables > Actions`):

- `CAPROVER_SERVER`: Your CapRover server URL (e.g., `https://captain.yourdomain.com`)
- `CAPROVER_APP_NAME`: Your app name in CapRover (e.g., `vgc-website`)
- `CAPROVER_APP_TOKEN`: Your CapRover app token

#### GitHub Actions Workflow

The workflow (`.github/workflows/deploy.yml`) automatically:

1. **Tests the application**:
   - Runs pre-commit hooks (linting, formatting)
   - Executes Django system checks
   - Runs unit tests
   - Checks database migrations

2. **Builds and deploys**:
   - Builds Docker image
   - Tests the built image
   - Deploys to CapRover

**Note**: The pipeline only deploys the application. Database setup must be done manually in CapRover (see Database Setup section below).

### 2. Manual Deployment

Use the provided script for manual deployments:

```bash
# Make the script executable (if not already)
chmod +x deploy-caprover.sh

# Deploy interactively (script will prompt for values)
./deploy-caprover.sh

# Deploy with arguments
./deploy-caprover.sh https://captain.yourdomain.com vgc-website your-app-token

# Deploy with environment variables
export CAPROVER_SERVER="https://captain.yourdomain.com"
export CAPROVER_APP_NAME="vgc-website"
export CAPROVER_APP_TOKEN="your-app-token"
./deploy-caprover.sh
```

## CapRover App Configuration

### Deployment Order (Important!)

**You must follow this order for successful deployment:**

1. **First**: Set up the database (PostgreSQL)
2. **Second**: Create and configure your main application
3. **Third**: Set up GitHub secrets and trigger deployment

### 2. Create New App

1. Log into your CapRover dashboard
2. Go to "Apps" section
3. Click "Create New App"
4. Enter your app name (e.g., `vgc-website`)

### 3. Configure Environment Variables

In your CapRover app settings, add these environment variables:

```env
SECRET_KEY=your-super-secret-key-here
DEBUG=False
DJANGO_SETTINGS_MODULE=mysite.settings.production
DB_NAME=vgc_website
DB_USER=vgc_user
DB_PASSWORD=your-secure-password
DB_HOST=srv-captain--vgc-website-db
DB_PORT=5432
ALLOWED_HOSTS=vgc-website.yourdomain.com,*.yourdomain.com
PORT=8000
```

### 4. Database Setup

**Important**: Database setup is **NOT** automated by the deployment pipeline. You must set up the database manually in CapRover before your first deployment.

#### Option A: Use CapRover's One-Click Apps (Recommended)

1. In CapRover dashboard, go to "Apps" → "One-Click Apps/Databases"
2. Search for "PostgreSQL" and click on it
3. Configure the following:
   - **App Name**: `vgc-website-db` (this will create service name `srv-captain--vgc-website-db`)
   - **PostgreSQL Database**: `vgc_website`
   - **PostgreSQL Username**: `vgc_user`
   - **PostgreSQL Password**: Choose a secure password
   - **PostgreSQL Version**: `15` (recommended)
4. Click "Deploy"
5. Wait for deployment to complete
6. Note the service name: `srv-captain--vgc-website-db` (use this for `DB_HOST`)

#### Option B: External Database

Configure your external PostgreSQL database and update the environment variables accordingly.

#### Database Configuration in Your App

After setting up the database, configure these environment variables in your main app:

```env
DB_HOST=srv-captain--vgc-website-db  # Use the CapRover service name
DB_NAME=vgc_website
DB_USER=vgc_user
DB_PASSWORD=your-secure-password-from-step-3
DB_PORT=5432
```

### 5. Domain Configuration

1. In your app settings, go to "HTTP Settings"
2. Add your domain name
3. Enable HTTPS
4. Configure SSL certificate (Let's Encrypt recommended)

### 6. First Deployment Setup

After your first successful deployment, you may need to run initial Django commands:

1. **Check your app logs** in CapRover to ensure the app started successfully
2. **Create a superuser** (if needed):
   ```bash
   # In CapRover app, go to "Command" tab and run:
   python manage.py createsuperuser
   ```
3. **Verify the health endpoint**: Visit `https://your-app.yourdomain.com/health/`

## File Structure

```
├── .github/workflows/
│   └── deploy.yml                    # GitHub Actions workflow
├── captain-definition                # CapRover configuration
├── captain-definition-template.json  # CapRover multi-service template
├── Dockerfile.production            # Production-optimized Dockerfile
├── deploy-caprover.sh               # Manual deployment script
├── .env.caprover                    # Environment variables template
└── CAPROVER_DEPLOYMENT.md           # This documentation
```

## Production Settings

The deployment uses `mysite.settings.production` which should include:

- `DEBUG = False`
- Proper `ALLOWED_HOSTS` configuration
- Database connection using environment variables
- Static files configuration for production
- Security middleware enabled
- Logging configuration

## Health Check

The application includes a health check endpoint at `/health/` that:
- Checks database connectivity
- Returns JSON status response
- Used by Docker healthcheck and load balancers

## Monitoring

### Application Logs

View application logs in CapRover:
1. Go to your app in CapRover dashboard
2. Click "App Logs" tab
3. Monitor real-time logs

### Health Monitoring

Access the health endpoint:
```bash
curl https://your-app.yourdomain.com/health/
```

Expected response:
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "..."
}
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
   - Ensure database service is running
   - Verify network connectivity

2. **Static Files Not Loading**
   - Run `python manage.py collectstatic` in production
   - Check STATIC_URL and STATIC_ROOT settings
   - Ensure volume mounting for static files

3. **Application Won't Start**
   - Check application logs in CapRover
   - Verify all required environment variables are set
   - Ensure SECRET_KEY is properly configured

4. **Health Check Failing**
   - Check if the application is responding on the correct port
   - Verify database connectivity
   - Check application logs for errors

### Debug Commands

```bash
# Check app status in CapRover
curl -H "x-captain-auth: YOUR_TOKEN" https://captain.yourdomain.com/api/v2/user/apps/appData/YOUR_APP_NAME

# Test health endpoint
curl https://your-app.yourdomain.com/health/

# Check Docker container locally
docker run -it --rm your-app:latest python manage.py check --deploy
```

## Security Considerations

1. **Environment Variables**: Never commit sensitive data to version control
2. **Secret Key**: Use a strong, unique SECRET_KEY for production
3. **Database**: Use strong passwords and restrict database access
4. **HTTPS**: Always use HTTPS in production
5. **Updates**: Keep dependencies and base images updated

## Backup Strategy

1. **Database Backups**: Set up regular PostgreSQL backups
2. **Media Files**: Back up user-uploaded media files
3. **Application Code**: Ensure code is properly version controlled

## Scaling

CapRover supports horizontal scaling:
1. Go to your app settings
2. Increase "Instance Count"
3. Configure load balancing if needed
4. Monitor resource usage

## Support

- CapRover Documentation: https://caprover.com/docs/
- Django Deployment: https://docs.djangoproject.com/en/stable/howto/deployment/
- Wagtail Production: https://docs.wagtail.org/en/stable/advanced_topics/deploying.html
