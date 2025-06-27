# VGC Website - Wagtail Project

A Wagtail CMS project for the VGC (Video Game Championship) website with PostgreSQL database.

## Setup

### Prerequisites
- Python 3.8+
- Docker & Docker Compose
- Virtual environment (already set up)

### Database Setup
The project uses PostgreSQL running in Docker. Database configuration:
- **Database**: vgc_website
- **User**: vgc_user
- **Password**: vgc_password
- **Host**: localhost
- **Port**: 5432

### Environment Variables
Copy `.env.example` to `.env` and update the values:

```bash
# Database Configuration
DB_NAME=vgc_website
DB_USER=vgc_user
DB_PASSWORD=vgc_password
DB_HOST=localhost
DB_PORT=5432

# Django Configuration
DEBUG=True
SECRET_KEY=your-secret-key-here
```

### Running the Project

1. **Start the database**:
   ```bash
   ./manage_db.sh start
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Run migrations**:
   ```bash
   python manage.py migrate
   ```

4. **Create a superuser**:
   ```bash
   python manage.py createsuperuser
   ```

5. **Start the development server**:
   ```bash
   python manage.py runserver
   ```

### Database Management

Use the `manage_db.sh` script to manage the PostgreSQL database:

- `./manage_db.sh start` - Start the database
- `./manage_db.sh stop` - Stop the database
- `./manage_db.sh restart` - Restart the database
- `./manage_db.sh status` - Check database status
- `./manage_db.sh logs` - View database logs
- `./manage_db.sh shell` - Open PostgreSQL shell

### Accessing the Site

- **Frontend**: http://127.0.0.1:8000/
- **Admin**: http://127.0.0.1:8000/admin/
- **Wagtail Admin**: http://127.0.0.1:8000/cms/

### Project Structure

```
vgc-website/
├── mysite/                 # Django project settings
│   ├── settings/
│   │   ├── base.py        # Base settings
│   │   ├── dev.py         # Development settings
│   │   └── production.py  # Production settings
│   ├── urls.py
│   └── wsgi.py
├── home/                   # Home app
├── search/                 # Search app
├── requirements.txt        # Python dependencies
├── manage.py              # Django management script
├── docker-compose.yml     # Docker services
├── manage_db.sh           # Database management script
└── .env                   # Environment variables
```

## Development

### Code Quality and Pre-commit Hooks

This project uses pre-commit hooks to ensure code quality and consistency. The hooks include:
- **Black**: Python code formatting
- **isort**: Import sorting
- **flake8**: Python linting
- **Bandit**: Security vulnerability scanning
- **Django check**: Django-specific validation
- **General checks**: Trailing whitespace, file endings, YAML/JSON validation

#### Setting up pre-commit

Run the setup script to install and configure pre-commit:
```bash
./setup-precommit.sh
```

Or manually:
```bash
# Install dependencies
pip install -r requirements.txt

# Install pre-commit hooks
pre-commit install

# Run on all files (first time)
pre-commit run --all-files
```

#### Using pre-commit

- Pre-commit runs automatically on every commit
- To run manually: `pre-commit run --all-files`
- To skip hooks: `git commit --no-verify` (use sparingly)
- To run on specific files: `pre-commit run --files file1.py file2.py`

### Adding New Apps
```bash
python manage.py startapp app_name
```

### Making Migrations
```bash
python manage.py makemigrations
python manage.py migrate
```

### Collecting Static Files
```bash
python manage.py collectstatic
```

## Deployment

### CapRover Deployment

This project includes automated deployment to CapRover via GitHub Actions and manual deployment scripts.

#### Quick Deployment

1. **Automated (CI/CD)**:
   - Configure GitHub secrets: `CAPROVER_SERVER`, `CAPROVER_APP_NAME`, `CAPROVER_APP_TOKEN`
   - Push to main branch - deployment happens automatically

2. **Manual**:
   ```bash
   ./deploy-caprover.sh
   ```

See [CAPROVER_DEPLOYMENT.md](CAPROVER_DEPLOYMENT.md) for detailed deployment instructions.

### Production Deployment

For production deployment, make sure to:
1. Set `DEBUG=False` in your environment variables
2. Configure proper `SECRET_KEY`
3. Set up proper database credentials
4. Configure static file serving
5. Use a production WSGI server like Gunicorn
