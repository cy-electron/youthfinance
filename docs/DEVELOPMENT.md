# Development Guide

This document outlines how to set up the YouthFinance project for local development and provides safe contribution practices.

## Prerequisites

- **Python 3.10+**
- **Flutter 3.12+**
- **PostgreSQL / SQLite**

## Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create a virtual environment:**
   ```bash
   python -m venv .venv
   # On Windows:
   .venv\Scripts\activate
   # On macOS/Linux:
   source .venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Environment Configuration:**
   Copy `.env.example` to `.env` and fill in the required variables (e.g., database URI, JWT secret). Do not commit your `.env` file to version control.

5. **Database Setup & Migrations:**
   Ensure your database server is running, then apply the migrations to create the tables.
   ```bash
   flask db upgrade
   ```

6. **Start the backend server:**
   ```bash
   python run.py
   ```
   The backend typically runs on `http://localhost:5000`.

## Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation (if applicable):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application:**
   Ensure an emulator is running or a device is connected.
   ```bash
   flutter run
   ```

## Development Workflow & Safe Practices

- **Never modify database records directly in production.** The financial allocation model relies on the `money_allocations` ledger. Deleting a record (e.g., a Goal) directly via SQL bypasses the release of its allocated funds.
- **Do not commit secrets.** Never commit `.env` files, production database URIs, API keys, or JWT secrets.
- **Run migrations.** When modifying SQLAlchemy models, generate a new migration script using `flask db migrate` and apply it with `flask db upgrade`.
- **State Management:** The frontend relies heavily on Riverpod. Ensure providers are properly invalidated or refreshed after successful API mutations to keep the UI in sync.
