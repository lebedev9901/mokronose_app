import 'package:flutter/material.dart';
import 'services/api_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late Future<List<Map<String, dynamic>>> addressesFuture;

  @override
  void initState() {
    super.initState();
    loadAddresses();
  }

  void loadAddresses() {
    addressesFuture = ApiService.getAddresses();
  }

  Future<void> openAddAddressSheet() async {
    final cityController = TextEditingController();
    final streetController = TextEditingController();
    final houseController = TextEditingController();
    final apartmentController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF7EF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Новый адрес',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _AddressField(
                controller: cityController,
                hint: 'Город',
                icon: Icons.location_city,
              ),

              const SizedBox(height: 12),

              _AddressField(
                controller: streetController,
                hint: 'Улица',
                icon: Icons.signpost_outlined,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _AddressField(
                      controller: houseController,
                      hint: 'Дом',
                      icon: Icons.home_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AddressField(
                      controller: apartmentController,
                      hint: 'Кв.',
                      icon: Icons.door_front_door_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    await ApiService.addAddress(
                      city: cityController.text,
                      street: streetController.text,
                      house: houseController.text,
                      apartment: apartmentController.text,
                    );

                    if (!mounted) return;

                    Navigator.pop(context);

                    setState(() {
                      loadAddresses();
                    });
                  },
                  child: const Text('Сохранить адрес'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> deleteAddress(int id) async {
    await ApiService.deleteAddress(id);

    setState(() {
      loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        title: const Text('Адреса доставки'),
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddAddressSheet,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return const Center(
              child: Text(
                'Адресов пока нет',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${address['city']}, ${address['street']}, д. ${address['house']}${address['apartment'] != null && address['apartment'].toString().isNotEmpty ? ', кв. ${address['apartment']}' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => deleteAddress(address['id']),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _AddressField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}