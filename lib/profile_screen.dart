import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = ApiService.getMe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: userFuture,
          builder: (context, snapshot) {
            final user = snapshot.data;

            final fullName = user == null
                ? 'Пользователь'
                : [
                    user['last_name'],
                    user['first_name'],
                    user['middle_name'],
                  ]
                    .where((item) =>
                        item != null && item.toString().trim().isNotEmpty)
                    .join(' ');

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Личный кабинет',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.orange,
                        child: Icon(
                          Icons.person,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: snapshot.connectionState ==
                                ConnectionState.waiting
                            ? const Text('Загрузка...')
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName.isEmpty
                                        ? 'Пользователь'
                                        : fullName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?['email'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _MenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Мои заказы',
                  subtitle: 'История и статусы заказов',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Адреса доставки',
                  subtitle: 'Дом, работа и другие адреса',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddressesScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.star_border,
                  title: 'Мои отзывы',
                  subtitle: 'Отзывы о товарах',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Настройки профиля',
                  subtitle: 'Личные данные и безопасность',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Поддержка',
                  subtitle: 'Все обращения здесь',
                  onTap: () {},
                ),

          
                 const SizedBox(height: 12),
                _MenuItem(
                  icon: Icons.logout,
                  title: 'Выйти',
                  subtitle: 'Завершить текущую сессию',
                  color: Colors.red,
                  onTap: widget.onLogout,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: itemColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: itemColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.chevron_right,
          color: color ?? Colors.black45,
        ),
      ),
    );
  }
}