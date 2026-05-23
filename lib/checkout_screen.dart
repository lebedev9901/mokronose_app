import 'package:flutter/material.dart';
import 'services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String deliveryMethod = 'courier';
  String paymentMethod = 'cash';

  int? selectedAddressId;

  final pickupController = TextEditingController();
  final cdekController = TextEditingController();
  final postController = TextEditingController();
  final pickupPoints = [
    'г. Подольск, п. Железнодорожный, 28',
    'г. Москва, ул. Братеевская 16к3',
  ];
  final nameController = TextEditingController();
  final phoneController = TextEditingController();


String? selectedPickupPoint;

  late Future<List<Map<String, dynamic>>> addressesFuture;

  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    addressesFuture = ApiService.getAddresses();
  }

  Future<void> submitOrder() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final success = await ApiService.checkout(
      deliveryMethod: deliveryMethod,
      paymentMethod: paymentMethod,
      addressId: selectedAddressId,
      pickupPoint: selectedPickupPoint,
      cdekPoint: cdekController.text,
      postAddress: postController.text,
      first_name: nameController.text,
      phone: phoneController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (!success) {
      setState(() {
        error = 'Не удалось оформить заказ';
      });
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заказ успешно оформлен')),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        title: const Text('Оформление заказа'),
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Контактные данные',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _TextInput(
            controller: nameController,
            hint: 'Ваше имя',
          ),

          const SizedBox(height: 12),

          _TextInput(
            controller: phoneController,
            hint: 'Телефон',
          ),

          const SizedBox(height: 24),
          const Text(
            'Способ доставки',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _OptionTile(
            title: 'Курьер',
            subtitle: 'Доставка по адресу',
            value: 'courier',
            groupValue: deliveryMethod,
            onChanged: (value) {
              setState(() => deliveryMethod = value);
            },
          ),
          _OptionTile(
            title: 'Самовывоз',
            subtitle: 'Забрать из пункта выдачи',
            value: 'pickup',
            groupValue: deliveryMethod,
            onChanged: (value) {
              setState(() => deliveryMethod = value);
            },
          ),
          _OptionTile(
            title: 'СДЭК',
            subtitle: 'Доставка через СДЭК',
            value: 'cdek',
            groupValue: deliveryMethod,
            onChanged: (value) {
              setState(() => deliveryMethod = value);
            },
          ),
          _OptionTile(
            title: 'Почта России',
            subtitle: 'Доставка почтой',
            value: 'post',
            groupValue: deliveryMethod,
            onChanged: (value) {
              setState(() => deliveryMethod = value);
            },
          ),

          const SizedBox(height: 18),

          if (deliveryMethod == 'courier') _AddressSelector(
            selectedAddressId: selectedAddressId,
            addressesFuture: addressesFuture,
            onChanged: (id) {
              setState(() => selectedAddressId = id);
            },
          ),

          if (deliveryMethod == 'pickup')
            Column(
              children: pickupPoints.map((point) {
                return _OptionTileNullable(
                  title: point,
                  subtitle: 'Пункт самовывоза',
                  value: point,
                  groupValue: selectedPickupPoint,
                  onChanged: (value) {
                    setState(() {
                      selectedPickupPoint = value;
                    });
                  },
                );
              }).toList(),
            ),

          if (deliveryMethod == 'cdek')
            _TextInput(controller: cdekController, hint: 'Пункт СДЭК'),

          if (deliveryMethod == 'post')
            _TextInput(controller: postController, hint: 'Почтовый адрес'),

          const SizedBox(height: 24),

          const Text(
            'Способ оплаты',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _OptionTile(
            title: 'Наличными',
            subtitle: 'Самовывоз',
            value: 'cash',
            groupValue: paymentMethod,
            onChanged: (value) {
              setState(() => paymentMethod = value);
            },
          ),
          _OptionTile(
            title: 'Банковской картой',
            subtitle: 'Переводом',
            value: 'card',
            groupValue: paymentMethod,
            onChanged: (value) {
              setState(() => paymentMethod = value);
            },
          ),

          
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],

          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: isLoading ? null : submitOrder,
              child: Text(isLoading ? 'Оформляем...' : 'Подтвердить заказ'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressSelector extends StatelessWidget {
  final int? selectedAddressId;
  final Future<List<Map<String, dynamic>>> addressesFuture;
  final Function(int id) onChanged;

  const _AddressSelector({
    required this.selectedAddressId,
    required this.addressesFuture,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: addressesFuture,
      builder: (context, snapshot) {
        final addresses = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (addresses.isEmpty) {
          return const Text('Сначала добавьте адрес доставки в профиле');
        }

        return Column(
          children: addresses.map((address) {
            final id = address['id'];

            return _OptionTileInt(
              title:
                  '${address['city']}, ${address['street']}, д. ${address['house']}',
              subtitle: address['apartment'] != null
                  ? 'Кв. ${address['apartment']}'
                  : 'Адрес доставки',
              value: id,
              groupValue: selectedAddressId,
              onChanged: onChanged,
            );
          }).toList(),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final Function(String value) onChanged;

  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      title: Text(title),
      subtitle: Text(subtitle),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _OptionTileInt extends StatelessWidget {
  final String title;
  final String subtitle;
  final int value;
  final int? groupValue;
  final Function(int value) onChanged;

  const _OptionTileInt({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<int>(
      value: value,
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      title: Text(title),
      subtitle: Text(subtitle),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _TextInput({
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
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

class _OptionTileNullable extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String? groupValue;
  final Function(String value) onChanged;

  const _OptionTileNullable({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      title: Text(title),
      subtitle: Text(subtitle),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}