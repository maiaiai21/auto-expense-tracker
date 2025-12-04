from fastapi import FastAPI
from pydantic import BaseModel
import sqlite3
import exptrack
import db

app = FastAPI()
class ExpenseRequest(BaseModel):
    description: str

@app.post('/api/v1/expense/parse')
async def parse_expense(request: ExpenseRequest):
    sms_text = request.description
    result = exptrack.extract_expense_data(sms_text)
    try:
            db.create_db_and_table()
            conn = sqlite3.connect('expenses.db')
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO expenses (amount, merchant, date, category) VALUES (?, ?, ?, ?)",
                (
                    result.get("amount"),
                    result.get("merchant"),
                    result.get("date"),
                    result.get("category")
                )
            )
            conn.commit()
            new_expense_id = cursor.lastrowid
            conn.close()
            print(result)
            return {"status" : "success","parsed_expense": result}
    except Exception as e:
            return {"error": str(e)}
    
@app.get('/api/v1/expenses')
async def get_expenses():
    try:
        conn = sqlite3.connect('expenses.db')
        cursor = conn.cursor()
        cursor.execute("SELECT id, amount, merchant, date, category, currency FROM expenses")
        rows = cursor.fetchall()
        conn.close()
        
        expenses = []
        for row in rows:
            expenses.append({
                "id": row[0],
                "amount": row[1],
                "merchant": row[2],
                "date": row[3],
                "category": row[4],
                "currency": row[5]
            })
        print(rows)
        return {"expenses": expenses}
    except Exception as e:
        return {"error": str(e)}
