import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // 1. Import this

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sms = SmsQuery();
  Map<String, List<dynamic>> _groupedExpenses = {};
  String _status = "Press Sync to start";
  final String baseUrl = "http://10.0.2.2:8000"; 

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }



  Future<void> syncSMS() async {
    if (await Permission.sms.request().isGranted) {
      final prefs = await SharedPreferences.getInstance();
      int? lastSyncTime = prefs.getInt('last_sync_timestamp');
      setState(() => _status = "Reading Inbox...");

      final messages = await _sms.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 50,
      );
      int processedCount = 0;
      int skippedCount = 0;
     
      int newMaxTime = lastSyncTime ?? 0;
      for (var msg in messages) {
        if (msg.date == null) continue;
        int msgTime = msg.date!.millisecondsSinceEpoch;
        if (lastSyncTime != null && msgTime <= lastSyncTime) {
          skippedCount++;
          continue; 
        }
        if (msgTime > newMaxTime) {
          newMaxTime = msgTime;
        }
        processedCount++;
        setState(() => _status = "Processing new SMS $processedCount...");
        try {
          await http.post(
            Uri.parse("$baseUrl/api/v1/expense/parse"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"description": msg.body ?? ""}),
          );
        } catch (e) {
          print("Error sending SMS: $e");
        }
      }
      
      await prefs.setInt('last_sync_timestamp', newMaxTime);
      await fetchExpenses();
      setState(() => _status = "Sync Complete!");
    } else {
      setState(() => _status = "Permission Denied");
    }
  }



  Future<void> fetchExpenses() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/v1/expenses"));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        List<dynamic> rawList = data['expenses'];

        Map<String, List<dynamic>> tempGrouped = {};
        for (var item in rawList) {
          String category = item['category'] ?? "Uncategorized";
          if (!tempGrouped.containsKey(category)) tempGrouped[category] = [];
          tempGrouped[category]!.add(item);
        }
        setState(() => _groupedExpenses = tempGrouped);
      }
    } catch (e) {
      setState(() => _status = "Connection Error");
    }
  }

  double calculateCategoryTotal(List<dynamic> items) {
    double total = 0;
    for (var item in items) {
      total += (item['amount'] ?? 0).toDouble();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Expense Summary"), backgroundColor: Colors.green[100]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: syncSMS,
        icon: const Icon(Icons.sync),
        label: const Text("Sync SMS"),
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(10), child: Text(_status)),
          Expanded(
            child: _groupedExpenses.isEmpty
                ? const Center(child: Text("No expenses found"))
                : ListView.builder(
                    itemCount: _groupedExpenses.keys.length,
                    itemBuilder: (context, index) {
                      String category = _groupedExpenses.keys.elementAt(index);
                      List<dynamic> items = _groupedExpenses[category]!;
                      double totalAmount = calculateCategoryTotal(items);

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(category[0], style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Total: ₹$totalAmount"),
                          children: items.map((item) {
                            return ListTile(
                              title: Text(item['merchant'] ?? "Unknown"),
                              subtitle: Text(item['date'] ?? ""),
                              trailing: Text("₹${item['amount']}"),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}