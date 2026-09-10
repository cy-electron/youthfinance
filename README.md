# YouthFinance 💰

**Take control of your money, one allocation at a time.**

YouthFinance is a financial wellness and goal-planning platform built on a simple but powerful idea: **don't just track where your money went — decide where it should go.** Instead of passive expense tracking, YouthFinance puts you in the driver's seat by letting you allocate your income into meaningful buckets before you spend.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-CC0000?style=for-the-badge&logo=sqlalchemy&logoColor=white)](https://www.sqlalchemy.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

---

## What is YouthFinance?

YouthFinance is not your typical expense tracker. Most finance apps show you a **rear-view mirror** of your spending — "here's where your money went." YouthFinance gives you a **steering wheel** — "here's where your money *should* go."

When you earn money, it lands in your **General** pool. You then actively **allocate** it into:
- 🗂️ **Budgets** — monthly spending limits for categories
- 🎯 **Goals** — long-term savings targets with deadlines
- 🛡️ **Emergency Fund** — a safety net for unexpected expenses
- 🎉 **Fun Funds** — guilt-free discretionary spending carved from your budget

Every expense is then drawn from these buckets, ensuring you always know exactly what you can afford to spend.

---

## The Problem

> "I don't know where all my money goes by the end of the month."

Traditional finance apps are passive. They record transactions after the fact and show pretty charts. But they rarely help you **plan** or **control** your spending. Young adults, in particular, struggle with:

- Budgeting without clear limits
- Saving for goals without a structured plan
- Building an emergency fund
- Feeling guilty about discretionary spending

YouthFinance solves this by making **allocation** the core action. You decide where every rupee/dollar goes *before* you spend it.

---

## How It Works: The Controlled Money Model

Think of your money as a pool of water, and your buckets as containers:

```
Income (salary, allowance, etc.)
        │
        ▼
   General Pool  ◄────────────────────┐
        │                              │
        ├──► Budgets (monthly limits)  │
        │                              │
        ├──► Goals (savings targets)   │
        │                              │
        ├──► Emergency Fund            │
        │                              │
        └──► Fun Funds (50% max) ──────┘
```

### 1. Earn 💵
Record your income. New money enters the system and sits in your **General** pool.

### 2. Allocate 📊
Move money from General into your buckets:
- Set a **Budget** for groceries, transport, dining, etc.
- Create a **Goal** for a new laptop or trip
- Build up your **Emergency Fund**
- Create a **Fun Fund** for weekend adventures

### 3. Spend 🛍️
When you buy something, the system automatically deducts from the right bucket. If no specific bucket matches, it follows a priority order: **Budget → General → Goal → Emergency**.

### 4. Track & Improve 📈
View your dashboard, financial health score, and insights to stay on top of your finances.

---

## Features

### 💸 Income & Expenses
Log money coming in and going out. Expenses are smart — they automatically know which bucket to deduct from.

### 🗂️ Monthly Budgets
Create category-wise budgets (Food, Transport, Entertainment, etc.) for any month. The system tracks your spending against each limit.

### 🎯 Goal Planning
Set savings goals with target amounts and deadlines. Watch your progress fill up as you allocate money. Goals sync automatically with your ledger.

### 🛡️ Emergency Fund
Build a safety net. Your emergency balance is tracked as a dedicated bucket, and your financial health score rewards you for keeping it healthy.

### 🎉 Fun Funds
Carve out guilt-free spending money from your budget. You can create up to 2 active Fun Funds, using a maximum of 50% of your parent budget. When you're done:
- **Cancel** it → remaining money goes back to your budget
- **Finish** it → remaining balance is recorded as an expense

### 📊 Financial Health Score
YouthFinance doesn't just count your money — it evaluates your financial habits. Your score is based on:
- Savings rate
- Budget discipline
- Goal progress
- Income stability
- Expense stability
- Emergency fund coverage
- Investment activity
- Fun Fund usage

### 📈 Analytics & Insights
- Spending patterns and breakdowns
- Cash flow trends
- Future projections
- Smart financial reflections

### 📚 Learning Hub
Access curated financial literacy content — videos, articles, and tips to level up your money knowledge.

### 🔔 Notifications
Stay informed with alerts for budget limits, goal milestones, and more. Customize your notification preferences.

### 💼 Investments
Track external investments (stocks, bonds, crypto) separately from your controlled money. They don't affect your daily budgeting but help you see the bigger picture.

### 👤 Profile & Authentication
Secure JWT-based authentication. Manage your profile details (age, gender, occupation, region) for personalized insights.

---

## Tech Stack

### Frontend (Mobile)
| Tech | Usage |
|------|-------|
| **Flutter** | Cross-platform mobile framework |
| **Riverpod** | State management |
| **GoRouter** | Navigation & routing |
| **Dio** | HTTP networking |
| **flutter_secure_storage** | Secure token storage |
| **fl_chart** | Beautiful charts & graphs |
| **shimmer** | Skeleton loading effects |
| **lucide_icons** | Clean icon set |

### Backend (API)
| Tech | Usage |
|------|-------|
| **Flask** | REST API framework |
| **SQLAlchemy** | ORM for database operations |
| **Alembic** | Database migrations |
| **JWT** | Authentication & authorization |
| **Flask-Bcrypt** | Password hashing |
| **Flask-CORS** | Cross-origin resource sharing |
| **Marshmallow** | Serialization & validation |
| **PostgreSQL / SQLite** | Data persistence |

---

## Project Structure

```
youthfinance/
├── backend/                     # Flask REST API
│   ├── app/
│   │   ├── modules/             # Feature modules
│   │   │   ├── auth/            # Authentication & user management
│   │   │   ├── income/          # Income tracking
│   │   │   ├── expense/         # Expense tracking
│   │   │   ├── budget/          # Monthly budgets
│   │   │   ├── goal/            # Savings goals
│   │   │   ├── savings/         # Savings history
│   │   │   ├── fun_fund/        # Discretionary funds
│   │   │   ├── emergency/       # Emergency fund
│   │   │   ├── investment/      # External investments
│   │   │   └── notification/    # Alerts & preferences
│   │   ├── analytics/           # Business logic & scoring
│   │   │   ├── dashboard/       # Dashboard summaries
│   │   │   ├── financial_health/# Health score calculation
│   │   │   ├── spending_analysis/ # Spending insights
│   │   │   ├── goal_readiness/  # Goal feasibility
│   │   │   └── financial_planner/ # Future projections
│   │   ├── common/              # Shared utilities, validators, errors
│   │   ├── config/              # App configuration
│   │   └── models/              # Base models
│   ├── migrations/              # Alembic migration scripts
│   ├── tests/                   # Backend tests
│   ├── run.py                   # Application entry point
│   └── requirements.txt         # Python dependencies
│
├── frontend/                    # Flutter mobile app
│   └── lib/
│       └── features/            # Feature-based architecture
│           ├── auth/            # Login, signup, token management
│           ├── home/            # Dashboard & quick actions
│           ├── transactions/    # Income & expense flows
│           ├── budget/          # Budget management
│           ├── goals/           # Goal creation & tracking
│           ├── savings/         # Savings management
│           ├── fun_fund/        # Fun Fund lifecycle
│           ├── emergency/       # Emergency fund screen
│           ├── investment/      # Investment tracking
│           ├── analytics/       # Insights, charts, trends
│           ├── learning/        # Financial education content
│           ├── notifications/   # Alert management
│           ├── profile/         # User profile & settings
│           ├── splash/          # App launch screen
│           └── shell/           # App shell & navigation
│
├── docs/                        # Technical documentation
│   ├── ARCHITECTURE.md          # System design & money flow
│   ├── DATABASE.md              # Data model & schema
│   ├── FEATURES.md              # Product behavior & rules
│   └── DEVELOPMENT.md           # Setup & contribution guide
│
└── README.md                    # You are here!
```

---

## Database Design

YouthFinance uses a relational database with a unique **money ledger** approach:

- **External transactions** (`incomes`, `expenses`) represent real money entering or leaving your life.
- **Internal allocations** (`money_allocations`) track how money moves between buckets.
- **Bucket tables** (`budgets`, `goals`, `fun_funds`) define targets and limits.
- **Analytics** are computed from the ledger, ensuring consistency.

The `money_allocations` table is the heart of the system — every allocation, release, expense, and adjustment is recorded here, creating a complete audit trail of your controlled money.

> For a full ER diagram and entity descriptions, see [docs/DATABASE.md](docs/DATABASE.md).

---

## Getting Started

Ready to take control of your finances? Here's how to run YouthFinance locally:

### Prerequisites

- **Python 3.10+** for the backend
- **Flutter 3.12+** for the frontend
- **PostgreSQL** (recommended) or **SQLite**
- A code editor like VS Code

### Backend Setup

```bash
# 1. Navigate to the backend
cd backend

# 2. Create and activate a virtual environment
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS/Linux:
source .venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment variables
cp .env.example .env
# Edit .env with your database URI and JWT secret

# 5. Run database migrations
flask db upgrade

# 6. Start the server
python run.py
```

The backend will be available at `http://localhost:5000`.

### Frontend Setup

```bash
# 1. Navigate to the frontend
cd frontend

# 2. Install Flutter dependencies
flutter pub get

# 3. Run code generation (if needed)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Launch the app
# Ensure an emulator/simulator is running or a device is connected
flutter run
```

### Quick Health Check

```bash
# Backend running?
curl http://localhost:5000/db-test

# Expected response:
# {"status": "Database Connected"}
```

---

## Development Best Practices

YouthFinance handles real financial data. Please follow these guidelines:

- **Never modify database records directly in production.** Deleting a record (e.g., a Goal) via SQL bypasses the ledger logic and can orphan allocated funds.
- **Don't commit secrets.** Never commit `.env` files, database URIs, API keys, or JWT secrets.
- **Run migrations for schema changes.** Use `flask db migrate` and `flask db upgrade` when modifying models.
- **Keep providers fresh.** The Flutter frontend uses Riverpod. Ensure providers are properly invalidated after mutations to keep the UI in sync.

---

## API Overview

The backend exposes modular REST endpoints under `/api/`:

| Module | Purpose |
|--------|---------|
| `/api/auth` | Register, login, profile |
| `/api/income` | Log new money entering the system |
| `/api/expense` | Record money leaving the system |
| `/api/budget` | Manage monthly category budgets |
| `/api/goal` | Create and track savings goals |
| `/api/savings` | Record contributions to goals |
| `/api/fun-fund` | Manage discretionary funds |
| `/api/emergency` | Emergency fund operations |
| `/api/investment` | Track external investments |
| `/api/notification` | Alerts & preferences |
| `/api/dashboard` | Aggregated financial summary |
| `/api/financial-health` | Health score & breakdown |
| `/api/analysis` | Spending patterns & insights |
| `/api/planner` | Future financial projections |

All endpoints (except auth) require a valid JWT token in the `Authorization` header.

---

## Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | High-level system design and money allocation flow |
| [DATABASE.md](docs/DATABASE.md) | Conceptual data model and table structures |
| [FEATURES.md](docs/FEATURES.md) | Product behavior from a user and system perspective |
| [DEVELOPMENT.md](docs/DEVELOPMENT.md) | Setup, installation, and local development guide |

---

## Contributing

We welcome contributions! Here's how you can help:

1. **Fork the repository** and create your branch from `main`
2. **Follow the existing code style** — Riverpod for Flutter, Flask blueprints for backend
3. **Write meaningful commit messages**
4. **Add tests** where applicable
5. **Update documentation** if you change behavior
6. **Submit a pull request** with a clear description of your changes

---

## Roadmap

- [ ] Dark mode support
- [ ] Multi-currency support
- [ ] Recurring transactions (subscriptions, salaries)
- [ ] Export data to PDF/CSV
- [ ] Shared budgets for families/rooms
- [ ] Widget support for quick balance checks
- [ ] Bill reminders & due dates

---

## License

This project is open source and available under the MIT License.

---

<p align="center">
  Built with ❤️ for anyone who wants to understand, control, and grow their money.
</p>

<p align="center">
  <sub>YouthFinance — Your money, your rules, your future.</sub>
</p>
