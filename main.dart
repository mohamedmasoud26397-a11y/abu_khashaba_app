import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const AbuKhashabaApp());
}

class ServiceItem {
  String name;
  String category;
  String phone;
  String notes;
  bool whatsapp;

  ServiceItem({
    required this.name,
    required this.category,
    required this.phone,
    this.notes = '',
    this.whatsapp = true,
  });
}

class AbuKhashabaApp extends StatefulWidget {
  const AbuKhashabaApp({super.key});

  @override
  State<AbuKhashabaApp> createState() => _AbuKhashabaAppState();
}

class _AbuKhashabaAppState extends State<AbuKhashabaApp> {
  bool arabic = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: arabic ? 'خدمات أبو خشبه' : 'Abu Khashaba Services',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0B3D91),
        useMaterial3: true,
      ),
      home: HomePage(
        arabic: arabic,
        onLanguageChanged: () => setState(() => arabic = !arabic),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool arabic;
  final VoidCallback onLanguageChanged;

  const HomePage({
    super.key,
    required this.arabic,
    required this.onLanguageChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAdmin = false;
  final String adminPassword = 'admin123';
  final TextEditingController searchController = TextEditingController();

  final List<ServiceItem> services = [
    ServiceItem(name: 'مثال: دكتور أحمد', category: 'دكتور', phone: '+441234567890', notes: 'خدمة تجريبية'),
    ServiceItem(name: 'مثال: كهربائي محمد', category: 'كهربائي', phone: '+441111111111', notes: 'خدمة تجريبية'),
  ];

  List<ServiceItem> get filteredServices {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) return services;
    return services.where((s) =>
      s.name.toLowerCase().contains(q) ||
      s.category.toLowerCase().contains(q) ||
      s.phone.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> callNumber(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri);
  }

  Future<void> openWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openDesignerWhatsApp() async {
    final uri = Uri.parse('https://wa.me/447462567162');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void showAdminLogin() {
    final pass = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.arabic ? 'دخول الأدمن' : 'Admin Login'),
        content: TextField(
          controller: pass,
          obscureText: true,
          decoration: InputDecoration(labelText: widget.arabic ? 'كلمة السر' : 'Password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(widget.arabic ? 'إلغاء' : 'Cancel')),
          FilledButton(
            onPressed: () {
              if (pass.text == adminPassword) {
                setState(() => isAdmin = true);
                Navigator.pop(context);
              }
            },
            child: Text(widget.arabic ? 'دخول' : 'Login'),
          ),
        ],
      ),
    );
  }

  void addOrEditService({ServiceItem? item}) {
    final name = TextEditingController(text: item?.name ?? '');
    final category = TextEditingController(text: item?.category ?? '');
    final phone = TextEditingController(text: item?.phone ?? '');
    final notes = TextEditingController(text: item?.notes ?? '');
    bool whatsapp = item?.whatsapp ?? true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null
              ? (widget.arabic ? 'إضافة خدمة' : 'Add Service')
              : (widget.arabic ? 'تعديل خدمة' : 'Edit Service')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: name, decoration: InputDecoration(labelText: widget.arabic ? 'اسم الشخص/الشركة' : 'Name')),
                TextField(controller: category, decoration: InputDecoration(labelText: widget.arabic ? 'التخصص' : 'Category')),
                TextField(controller: phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: widget.arabic ? 'رقم الهاتف' : 'Phone')),
                TextField(controller: notes, decoration: InputDecoration(labelText: widget.arabic ? 'ملاحظات' : 'Notes')),
                SwitchListTile(
                  value: whatsapp,
                  onChanged: (v) => setDialogState(() => whatsapp = v),
                  title: Text(widget.arabic ? 'الرقم عليه واتساب' : 'Has WhatsApp'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(widget.arabic ? 'إلغاء' : 'Cancel')),
            FilledButton(
              onPressed: () {
                setState(() {
                  if (item == null) {
                    services.add(ServiceItem(
                      name: name.text,
                      category: category.text,
                      phone: phone.text,
                      notes: notes.text,
                      whatsapp: whatsapp,
                    ));
                  } else {
                    item.name = name.text;
                    item.category = category.text;
                    item.phone = phone.text;
                    item.notes = notes.text;
                    item.whatsapp = whatsapp;
                  }
                });
                Navigator.pop(context);
              },
              child: Text(widget.arabic ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void deleteService(ServiceItem item) {
    setState(() => services.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(ar ? 'خدمات أبو خشبه' : 'Abu Khashaba Services'),
          actions: [
            IconButton(
              onPressed: widget.onLanguageChanged,
              icon: const Icon(Icons.language),
              tooltip: ar ? 'English' : 'عربي',
            ),
            IconButton(
              onPressed: showAdminLogin,
              icon: Icon(isAdmin ? Icons.admin_panel_settings : Icons.lock),
            ),
          ],
        ),
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                onPressed: () => addOrEditService(),
                icon: const Icon(Icons.add),
                label: Text(ar ? 'إضافة' : 'Add'),
              )
            : null,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  labelText: ar ? 'بحث بالاسم أو التخصص' : 'Search by name or category',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: filteredServices.isEmpty
                  ? Center(child: Text(ar ? 'لا توجد خدمات' : 'No services found'))
                  : ListView.builder(
                      itemCount: filteredServices.length,
                      itemBuilder: (_, i) {
                        final s = filteredServices[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${ar ? 'التخصص' : 'Category'}: ${s.category}\n${s.phone}${s.notes.isNotEmpty ? '\n${s.notes}' : ''}'),
                            isThreeLine: true,
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(icon: const Icon(Icons.phone), onPressed: () => callNumber(s.phone)),
                                if (s.whatsapp) IconButton(icon: const Icon(Icons.chat), onPressed: () => openWhatsApp(s.phone)),
                                if (isAdmin) IconButton(icon: const Icon(Icons.edit), onPressed: () => addOrEditService(item: s)),
                                if (isAdmin) IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteService(s)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFEAF2FF),
              child: Column(
                children: [
                  Text(ar
                      ? 'رأيكم يهمني، ولو في أي خدمة أو رقم جديد حابين يتضاف ابعتولنا اقتراح.'
                      : 'Your feedback matters. Send us suggestions for new services or numbers.'),
                  TextButton.icon(
                    onPressed: openDesignerWhatsApp,
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp: +44 7462 567162'),
                  ),
                  Text(ar
                      ? 'تصميم التطبيق: محمد مسعود مرعي'
                      : 'Designed by: Mohammed Masoud Marei'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
