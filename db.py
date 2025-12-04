import sqlite3
def create_db_and_table():
    conn = sqlite3.connect('expenses.db') 
    cursor = conn.cursor()
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        merchant TEXT,
        date TEXT,
        category TEXT,
        currency TEXT DEFAULT "INR"
    )
    ''')
    
    conn.commit()
    conn.close()