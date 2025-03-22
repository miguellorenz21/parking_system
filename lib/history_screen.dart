import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'entry.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by car plate...',
                  hintStyle: TextStyle(color: Colors.white70, fontSize: 20),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.deepPurple.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 20),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<Entry>('entriesBox').listenable(),
                  builder: (context, Box<Entry> box, _) {
                    final entries = box.values.toList();

                    final filteredEntries =
                        entries.where((entry) {
                          return entry.carPlate.toLowerCase().contains(
                            _searchQuery,
                          );
                        }).toList();

                    return ListView.builder(
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];
                        final formattedEntryDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(entry.entryTime);
                        final formattedEntryTime = DateFormat(
                          'hh:mm a',
                        ).format(entry.entryTime);
                        final formattedExitTime =
                            entry.exitTime != null
                                ? DateFormat(
                                  'yyyy-MM-dd hh:mm a',
                                ).format(entry.exitTime!)
                                : 'Not exited yet';

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              entry.carPlate,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.deepPurple,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Entry Date: $formattedEntryDate',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Time: $formattedEntryTime',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Exit Time: $formattedExitTime',
                                  style: const TextStyle(fontSize: 17),
                                ),
                                Text(
                                  'Fee: ${entry.calculateFee().toStringAsFixed(2)} pesos',
                                  style: const TextStyle(fontSize: 17),
                                ),
                                Text(
                                  'Paid: ${entry.isPaid ? "Yes" : "No"}',
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                            trailing:
                                entry.exitTime == null
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.exit_to_app,
                                        color: Colors.deepPurple,
                                      ),
                                      onPressed: () {
                                        final key = box.keyAt(
                                          box.values.toList().indexOf(entry),
                                        );
                                        entry.exitTime = DateTime.now();
                                        entry.isPaid = true;
                                        box.put(key, entry);
                                      },
                                    )
                                    : const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
