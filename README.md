# Automated Expense Tracker
### An automated Android expense tracker that syncs with your SMS inbox to categorize spending. It runs locally, using a Python backend and an LLM to parse transaction messages without sending data to the cloud.
#### Tech Stack : 
- App : Flutter (Android)
- Backend : Python (FastAPI + SQLite)
- AI Engine : LM Studio (Local LLM)

#### Features : 
- Automated SMS reading, parsing
- Intelligent categorisation (Food, Shopping, Health, etc.) [Expandable category]
- 100% Local Processing (No cloud)

#### How it works :
The SMS is synced in the app by clicking on a button, which reads and parses latest SMS. The local LLM extracts amount, merchant, category, date, etc. which is stored in local database and finally displayed in the app.
