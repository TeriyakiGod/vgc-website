#!/bin/bash

# Pre-commit setup script for VGC Website

echo "Setting up pre-commit hooks..."

# Check if virtual environment is activated
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo "Warning: No virtual environment detected. Please activate your virtual environment first."
    echo "Run: source .venv/bin/activate"
    exit 1
fi

# Install requirements (including pre-commit)
echo "Installing/updating requirements..."
pip install -r requirements.txt

# Install pre-commit hooks
echo "Installing pre-commit hooks..."
pre-commit install

# Install pre-commit hooks for commit messages (optional)
echo "Installing pre-commit hooks for commit messages..."
pre-commit install --hook-type commit-msg

# Run pre-commit on all files to ensure everything works
echo "Running pre-commit on all files (this may take a while on first run)..."
pre-commit run --all-files

echo ""
echo "✅ Pre-commit setup complete!"
echo ""
echo "Pre-commit will now run automatically on every commit."
echo "To run pre-commit manually on all files: pre-commit run --all-files"
echo "To run pre-commit on specific files: pre-commit run --files file1.py file2.py"
echo "To skip pre-commit hooks: git commit --no-verify"
