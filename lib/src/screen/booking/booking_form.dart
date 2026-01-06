import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muc_jomtravel/src/model/app_package.dart';

import 'booking_summary.dart';

class BookingForm extends StatefulWidget {
  final Package package;
  const BookingForm({super.key, required this.package});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  late String selectedPackage;
  int adults = 1;
  int children = 0;
  bool addTourGuide = false;
  bool addMeal = false;
  bool addTransport = false;
  DateTime visitDate = DateTime.now();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String get formattedDate => DateFormat('dd/MM/yyyy').format(visitDate);

  @override
  void initState() {
    super.initState();
    selectedPackage = widget.package.title;
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      nameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Form'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Package Info
            _sectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Package',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.package.title,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// People
            _sectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'People',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _counterWidget('Adults', adults, (val) {
                        setState(() => adults = val);
                      }),
                      _counterWidget('Children (below 12)', children, (val) {
                        setState(() => children = val);
                      }),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Add Ons
            _sectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Ons',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _toggleButton('Tour Guide', addTourGuide, (val) {
                        setState(() => addTourGuide = val);
                      }),
                      _toggleButton('Meal', addMeal, (val) {
                        setState(() => addMeal = val);
                      }),
                      _toggleButton('Transport', addTransport, (val) {
                        setState(() => addTransport = val);
                      }),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Visit Date
            _sectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visit Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: visitDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          visitDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate.isEmpty
                                ? 'DD/MM/YYYY'
                                : formattedDate,
                            style: TextStyle(
                              color: formattedDate.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Contact Details
            _sectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Name',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Phone Number',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Email',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Calculate Price Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty ||
                      phoneController.text.trim().isEmpty ||
                      emailController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all contact details'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PriceSummaryScreen(
                        package: widget.package,
                        visitDate: visitDate,
                        adults: adults,
                        children: children,
                        addTourGuide: addTourGuide,
                        addMeal: addMeal,
                        addTransport: addTransport,
                        name: nameController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                      ),
                    ),
                  );
                },
                child: const Text('Calculate Price'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section container helper
  Widget _sectionContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  /// Counter widget helper
  Widget _counterWidget(String title, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 8),
        Row(
          children: [
            _circleButton(Icons.remove, () {
              if (value > 0) onChanged(value - 1);
            }),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text('$value', style: const TextStyle(fontSize: 16)),
            ),
            _circleButton(Icons.add, () {
              onChanged(value + 1);
            }),
          ],
        ),
      ],
    );
  }

  /// Circle button helper
  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  /// Toggle button helper
  Widget _toggleButton(String text, bool value, Function(bool) onChanged) {
    return ChoiceChip(
      label: Text(text),
      selected: value,
      onSelected: onChanged,
      selectedColor: Colors.blue.shade300,
      backgroundColor: Colors.grey.shade300,
    );
  }
}
