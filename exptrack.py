import requests
import json

#sms_text = "Credit Alert! Rs. 1000.00 credited to HDFC Bank A/c XX4251 on 8-11-25 from VPA xxx@upi"

def extract_expense_data(sms_text):
    try:
        response= requests.post(
            "http://127.0.0.1:1234/v1/chat/completions",
            headers={"Content-Type": "application/json"},
            json={
            "messages": [
            {
                "role": "system",
                "content": '''
                Your task:
                Extract structured expense data from the SMS
                Choose the most appropriate category from the list
                Respond ONLY in JSON format with the following fields:
                amount (number, in INR)
                currency (always "INR")
                merchant (string)
                date (ISO format: YYYY-MM-DD)
                category (one from the provided list)
                '''},
            { "role": "user", 
            "content": f"SMS: '{sms_text}' , use the following category list : Categories: Food,Shopping,Travel,Bills,Health,People,Entertainment,Groceries,Recieved, do not show <think>" }
            ],
            "temperature": 0.2
        }
        )
        c = response.json()['choices'][0]['message']['content']
        return json.loads(c)
    except Exception as e:
        return {"error": str(e)}

#r = extract_expense_data(sms_text).json()['choices'][0]['message']['content']
#print(r)
