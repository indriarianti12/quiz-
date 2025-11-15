import 'package:flutter/material.dart';

void main() {
  runApp(ContactApp());
}

// 1. Make ContactApp Stateful to manage ThemeMode
class ContactApp extends StatefulWidget {
  const ContactApp({super.key});

  @override
  State<ContactApp> createState() => _ContactAppState();
}

class _ContactAppState extends State<ContactApp> {
  // ThemeMode is initially set to the system setting
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Contact List",
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Use the local state to determine the current theme mode
      themeMode: _themeMode,
      // Pass the toggle function and current mode to ContactPage
      home: ContactPage(
        currentThemeMode: _themeMode,
        onThemeToggle: toggleTheme,
      ),
    );
  }
}

class Contact {
  final String name;
  final String phone;
  final String status;
  final String initial;

  Contact({
    required this.name,
    required this.phone,
    required this.status,
  }) : initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
}

class ContactPage extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeToggle;

  const ContactPage({
    super.key,
    required this.currentThemeMode,
    required this.onThemeToggle,
  });

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> allContacts = [
    Contact(name: "Ayu Lestari", phone: "0812-8876-1234", status: "Online"),
    Contact(name: "Budi Santoso", phone: "0813-9987-4412", status: "Offline"),
    Contact(name: "Citra Maharani", phone: "0819-3321-0098", status: "Away"),
    Contact(name: "Dewi Puspita", phone: "0815-5555-6666", status: "Online"),
    Contact(name: "Eko Prasetyo", phone: "0822-1111-2222", status: "Offline"),
    Contact(name: "Fajar Nugroho", phone: "0878-3333-4444", status: "Away"),
  ];

  List<Contact> filteredContacts = [];
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredContacts = List.from(allContacts);
  }

  void filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredContacts = List.from(allContacts);
      } else {
        filteredContacts = allContacts.where((contact) {
          return contact.name.toLowerCase().contains(query.toLowerCase()) ||
              contact.phone.contains(query);
        }).toList();
      }
    });
  }

  void deleteContact(Contact contact) {
    setState(() {
      allContacts.remove(contact);
      filterContacts(searchController.text); 
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${contact.name} dihapus."),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Online":
        return Colors.green;
      case "Offline":
        return Colors.grey;
      case "Away":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color getAvatarColor(int index) {
    final colors = [
      Colors.indigo,
      Colors.purple,
      Colors.teal,
      Colors.deepOrange,
      Colors.cyan,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  // 2. New Method to toggle the theme mode
  void _handleThemeToggle() {
    ThemeMode nextMode;
    // If current mode is system or light, switch to dark
    if (widget.currentThemeMode == ThemeMode.system || widget.currentThemeMode == ThemeMode.light) {
      nextMode = ThemeMode.dark;
    } else {
      // If current mode is dark, switch to light
      nextMode = ThemeMode.light;
    }
    widget.onThemeToggle(nextMode);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine the icon based on the current mode
    final icon = widget.currentThemeMode == ThemeMode.dark
        ? Icons.light_mode_rounded // Currently Dark, show Light button
        : Icons.dark_mode_rounded; // Currently Light or System, show Dark button

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Cari kontak...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: filterContacts,
              )
            : const Text(
                "Kontak Saya",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
        centerTitle: false,
        actions: [
          // 3. Theme Toggle Button
          IconButton(
            icon: Icon(icon),
            onPressed: _handleThemeToggle,
            tooltip: widget.currentThemeMode == ThemeMode.dark ? 'Mode Terang' : 'Mode Gelap',
          ),
          // Search/Close Button
          IconButton(
            icon: Icon(isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  filterContacts('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              "${filteredContacts.length} Kontak",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: filteredContacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Kontak tidak ditemukan",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final c = filteredContacts[index];

                      return Dismissible(
                        key: ValueKey(c.phone),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          deleteContact(c);
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Stack(
                              children: [
                                // Colorful Avatar
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        getAvatarColor(index),
                                        getAvatarColor(index).withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      c.initial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Status Indicator Dot
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: getStatusColor(c.status),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark ? Colors.grey[850]! : Colors.white,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                              c.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone_rounded,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    c.phone,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.phone_rounded),
                                color: Colors.indigo,
                                iconSize: 22,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.phone_in_talk_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text("Memanggil ${c.name}..."),
                                        ],
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: Colors.indigo,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add contact logic
        },
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          "Tambah",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 4,
      ),
    );
  }
}