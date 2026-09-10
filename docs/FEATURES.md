# Product Features

This document explains the core features of YouthFinance, detailing both the user experience and the underlying system behavior. YouthFinance is designed as a cohesive financial wellness platform, heavily emphasizing the allocation of "controlled money" rather than simple transaction tracking.

## 1. Authentication and Profile
- **User Flow:** Users can register an account, log in, and manage profile details (such as age, gender, occupation) and settings.
- **System Behavior:** Handled by the `auth` module using JSON Web Tokens (JWT). The Flutter frontend securely stores the token (`flutter_secure_storage`) and attaches it to authenticated requests via Dio interceptors.

## 2. Dashboard
- **User Flow:** Upon login, the user lands on a dashboard summarizing their financial health, recent transactions, and goal progress.
- **System Behavior:** The dashboard aggregation endpoint queries the database for total income, total expenses, active budgets, and goal progress, presenting a unified financial snapshot.

## 3. Income
- **User Flow:** Users log money entering their possession (e.g., salary, allowance).
- **System Behavior:** Adding an income record in the `incomes` table *creates* controlled money in the system. By default, this new money is placed into the `general` money bucket via the `money_allocations` ledger.

## 4. Expenses
- **User Flow:** Users record money leaving their possession (e.g., buying food).
- **System Behavior:** Recording an expense removes controlled money from the system. 
  - **Deduction Priority:** For regular expenses, the system automatically attempts to deduct from available buckets in the following order: `Budget` → `General` → `Goal` → `Emergency`.
  - The expense is recorded in the `expenses` table, and negative ledger entries are added to `money_allocations` to reflect the debit.

## 5. Budgets
- **User Flow:** Users create monthly budgets for specific categories to limit spending.
- **System Behavior:** Budgets allocate money from the `general` bucket into a `budget` bucket for the specified month and year. When expenses matching that category occur, money is drawn from the corresponding budget bucket first.

## 6. Goals & Savings
- **User Flow:** Users create savings targets (Goals) with deadlines. They can manually add money (Savings) to these goals.
- **System Behavior:** 
  - Note on categories: While early designs might have intended fixed categories (Travel, Education, etc.), the current implementation does not restrict or rigidly enforce categories at the backend level.
  - Adding a saving to a goal triggers an internal transfer in the ledger: money is moved from the `general` bucket to the `goal` bucket. The total controlled money remains the same.
  - The `current_amount` and `is_completed` fields on the Goal are derived from the ledger balance. If a goal is deleted, its allocated money is released back to the `general` bucket.

## 7. Investments
- **User Flow:** Users track external assets (stocks, bonds).
- **System Behavior:** Investments are tracked entirely separately from the "controlled money" allocation system. They exist in the `investments` table as a distinct record of value but do not interact with the general or budget buckets.

## 8. Fun Fund
- **User Flow:** Users can allocate a portion of a monthly budget into a specific "Fun Fund" to guarantee consequence-free spending money.
- **System Behavior:** 
  - A maximum of 2 active Fun Funds can exist per user, and they can consume at most 50% of the parent budget.
  - **Cancel Fun Fund:** The remaining money is released back to the parent `budget` bucket.
  - **Finish Fun Fund:** The planned fun spending has occurred. The remaining balance in the Fun Fund bucket is removed from controlled money entirely, and a corresponding `Expense` record is created.

## 9. Notifications
- **User Flow:** Users receive alerts (e.g., budget limits reached) and can toggle their notification preferences.
- **System Behavior:** Managed by the `notification` module, consisting of `notifications` and `notification_preferences`. Handled internally by the backend upon specific triggers.
