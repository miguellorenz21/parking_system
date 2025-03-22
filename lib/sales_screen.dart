import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'entry.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  DateTime? _selectedDate;
  DateTime? _startOfWeek;
  DateTime? _endOfWeek;
  bool _showTotalSales = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Set the initial date to today
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _startOfWeek = null;
        _endOfWeek = null;
        _showTotalSales = false;
      });
    }
  }

  void _selectWeek() {
    final now = DateTime.now();

    // If the current week has ended, reset to the next week
    if (_endOfWeek != null && now.isAfter(_endOfWeek!)) {
      _startOfWeek = _endOfWeek!.add(
        const Duration(days: 1),
      ); // Start of the next week (Monday)
      _endOfWeek = _startOfWeek!.add(
        const Duration(days: 6),
      ); // End of the next week (Sunday)
    } else {
      // Calculate the current week
      _startOfWeek = now.subtract(
        Duration(days: now.weekday - 1),
      ); // Start of the week (Monday)
      _endOfWeek = _startOfWeek!.add(
        const Duration(days: 6),
      ); // End of the week (Sunday)
    }

    setState(() {
      _selectedDate = null;
      _showTotalSales = false;
    });
  }

  void _selectTotalSales() {
    setState(() {
      _showTotalSales = true;
      _selectedDate = null;
      _startOfWeek = null;
      _endOfWeek = null;
    });
  }

  Map<String, dynamic> _calculateSalesMetrics(
    List<Entry> entries,
    DateTime? start,
    DateTime? end,
  ) {
    final filteredEntries =
        entries.where((entry) {
          if (entry.exitTime == null)
            return false; // Skip entries without exit time

          // Filter by selected date
          if (_selectedDate != null) {
            final startOfDay = DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
            );
            final endOfDay = startOfDay.add(const Duration(days: 1));
            return entry.exitTime!.isAfter(startOfDay) &&
                entry.exitTime!.isBefore(endOfDay);
          }

          // Filter by selected week
          if (_startOfWeek != null && _endOfWeek != null) {
            return (entry.exitTime!.isAfter(_startOfWeek!) ||
                    entry.exitTime!.isAtSameMomentAs(_startOfWeek!)) &&
                (entry.exitTime!.isBefore(_endOfWeek!) ||
                    entry.exitTime!.isAtSameMomentAs(_endOfWeek!));
          }

          // Show all entries for total sales
          return _showTotalSales;
        }).toList();

    double revenue = 0;
    int cars = filteredEntries.length;

    for (final entry in filteredEntries) {
      revenue += entry.calculateFee();
    }

    return {'revenue': revenue, 'cars': cars};
  }

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Column(
                children: [
                  const SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Select Date',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _selectWeek,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Select Week',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selectTotalSales,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Total Sales',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder(
                valueListenable: Hive.box<Entry>('entriesBox').listenable(),
                builder: (context, Box<Entry> box, _) {
                  final entries = box.values.toList();
                  final metrics = _calculateSalesMetrics(
                    entries,
                    _startOfWeek,
                    _endOfWeek,
                  );

                  return Column(
                    children: [
                      if (_selectedDate != null)
                        Text(
                          'Sales for ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (_startOfWeek != null && _endOfWeek != null)
                        Text(
                          'Sales for Week ${DateFormat('yyyy-MM-dd').format(_startOfWeek!)} to ${DateFormat('yyyy-MM-dd').format(_endOfWeek!)}',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (_showTotalSales)
                        Text(
                          'Total Sales',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(height: 20),
                      _buildSalesCard(
                        title: 'Revenue',
                        value: '₱${metrics['revenue'].toStringAsFixed(2)}',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _buildSalesCard(
                        title: 'Cars',
                        value: '${metrics['cars']}',
                        icon: Icons.directions_car,
                        color: Colors.blue,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
