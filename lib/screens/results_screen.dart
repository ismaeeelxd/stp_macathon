import 'package:flutter/material.dart';
import 'package:my_prescription_app/models/medicine_appointment.dart';
import 'package:my_prescription_app/screens/edit_item.dart';
import 'package:my_prescription_app/screens/checkout_screen.dart';
import 'package:my_prescription_app/services/service_provider.dart';

class ResultsScreen extends StatefulWidget {
  final List<MedicineAppointment> medicineAppointments;
  const ResultsScreen({super.key, required this.medicineAppointments});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late List<MedicineAppointment> _medicineAppointments;
  final _llmService = ServiceProvider.getLlmService();
  final List<MedicineAppointment> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _medicineAppointments = List.from(widget.medicineAppointments);
  }

  void _editItem(int index) async {
    final updatedItem = await Navigator.push<MedicineAppointment>(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditItemScreen(item: _medicineAppointments[index]),
      ),
    );

    if (updatedItem != null) {
      setState(() {
        _medicineAppointments[index] = updatedItem;

        // Update item in cart if it exists there
        final cartIndex = _cartItems.indexWhere(
          (item) =>
              item.medicine == _medicineAppointments[index].medicine &&
              item.appointment == _medicineAppointments[index].appointment,
        );

        if (cartIndex != -1) {
          _cartItems[cartIndex] = updatedItem;
        }
      });
    }
  }

  void _addToCart(MedicineAppointment item) {
    setState(() {
      if (!_cartItems.contains(item)) {
        _cartItems.add(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.medicine} added to cart')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.medicine} is already in cart')),
        );
      }
    });
  }

  void _removeFromCart(MedicineAppointment item) {
    setState(() {
      _cartItems.remove(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.medicine} removed from cart')),
      );
    });
  }

  void _goToCheckout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cartItems: _cartItems),
      ),
    );
  }

  void _showMedicineInfo(MedicineAppointment item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Fetching information..."),
            ],
          ),
        );
      },
    );

    try {
      final response = await _llmService.getMedicineInfo(
        item.medicine,
        item.appointment,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(item.medicine),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'General Information:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(response.generalInfo),
                  const SizedBox(height: 16),
                  const Text(
                    'Why this medicine:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(response.reasonForPrescription),
                  const SizedBox(height: 16),
                  const Text(
                    'Usage Tips:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(response.usageTips),
                  const SizedBox(height: 16),
                  const Text(
                    'Side Effects:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(response.sideEffects),
                  const SizedBox(height: 16),
                  const Text(
                    'Contraindications:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(response.contraindications),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching information: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              try {
                final apiService = ServiceProvider.getApiService();
                await apiService.editPrescription(_medicineAppointments);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Results saved successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error saving results: ${e.toString()}'),
                  ),
                );
              }
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _goToCheckout,
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _cartItems.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body:
          _medicineAppointments.isEmpty
              ? const Center(child: Text('No data found'))
              : ListView.builder(
                itemCount: _medicineAppointments.length,
                itemBuilder: (context, index) {
                  final item = _medicineAppointments[index];
                  final bool isInCart = _cartItems.contains(item);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            item.medicine,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(item.appointment),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editItem(index),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.info_outline),
                                label: const Text('More Information'),
                                onPressed: () => _showMedicineInfo(item),
                              ),
                              ElevatedButton.icon(
                                icon: Icon(
                                  isInCart
                                      ? Icons.remove_shopping_cart
                                      : Icons.add_shopping_cart,
                                ),
                                label: Text(
                                  isInCart ? 'Remove from Cart' : 'Add to Cart',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isInCart ? Colors.red : Colors.blue,
                                ),
                                onPressed:
                                    () =>
                                        isInCart
                                            ? _removeFromCart(item)
                                            : _addToCart(item),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton:
          _cartItems.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: _goToCheckout,
                icon: const Icon(Icons.shopping_cart_checkout),
                label: Text('Checkout (${_cartItems.length})'),
              )
              : null,
    );
  }
}
