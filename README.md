# Automated Expense Tracker
### The Automated Expense Tracker is a local Android application designed to automate personal finance tracking. Instead of manually entering expenses, the app reads transaction SMS messages from your inbox and uses a locally hosted Large Language Model (LLM) to extract key details like the Merchant, Amount, and Category.

All data is processed and stored locally on your device, ensuring 100% privacy with no data ever sent to the cloud.

#### Tech Stack : 
- App : Flutter (Android)
- Backend API : FastAPI
- Database : SQLite
- AI Engine : LM Studio (Local LLM)

#### Features : 
- Automated SMS reading, parsing
- Intelligent categorisation (Food, Shopping, Health, etc.) [Expandable category]
- 100% Local Processing (No cloud)

#### System Requirements : 
- Operating System: Windows, macOS, or Linux.
- RAM: Minimum 8GB (16GB recommended).
- Software Prerequisites:
  - Python 3.8+
  - Flutter SDK
  - Android Studio (For Android SDK, Emulator)
  - LM Studio (For running local LLM)
- Installation: Clone the Repository, Install the following dependencies in "main.py": FastAPI, Uvicorn server, and Request handler, Navigate to "main app" folder and install flutter packages.

#### How to Run :
- Start the AI Server in LM Studio (e.g., Qwen 3B).
- Start the Backend API (uvicorn server) by running `uvicorn main:app --reload --host 0.0.0.0` in terminal in your project root folder.
- Ensure an android emulator is selected. Start the mobile app by running `flutter run` in terminal in the "main app" folder. The app connects through the default 10.0.2.2 IP Address.

#### How it Works :
- Sync: Click on the "Sync" Button in the App.
- Permission: The App will request for permissions to read SMS from your inbox.
- Send: The raw text in the SMS is sent via HTTP to the local backend.
- Analyse: The backend then sends the text to the local LLM which intelligently extracts merchant, value, category etc.
- Store: Valid Expenses are stored in the SQLite database.
- Display: The app then fetches the updated list from the database and displays your spending summary.

*Project developed as a privacy-first experiment in combining Mobile Development with Local AI.*
