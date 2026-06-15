import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifAktif = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Tampilan',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Consumer<ThemeViewModel>(
            builder: (_, themeVm, __) => SwitchListTile(
              secondary: Icon(
                themeVm.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: const Color(0xFFB71C1C),
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(themeVm.isDarkMode ? 'Aktif' : 'Nonaktif'),
              value: themeVm.isDarkMode,
              onChanged: (_) => themeVm.toggleTheme(),
              activeThumbColor: const Color(0xFFB71C1C),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Notifikasi',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFFB71C1C),
            ),
            title: const Text('Notifikasi Laporan'),
            subtitle: const Text('Aktifkan notifikasi barang baru'),
            value: _notifAktif,
            onChanged: (val) => setState(() => _notifAktif = val),
            activeThumbColor: const Color(0xFFB71C1C),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Informasi',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: Color(0xFFB71C1C),
            ),
            title: const Text('Tentang Aplikasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Row(
                  children: [
                    Image.asset(
                      'assets/logo_telu.png',
                      height: 30,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.school,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('FindIt Tel-U'),
                  ],
                ),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Versi: 1.0.0'),
                    SizedBox(height: 8),
                    Text(
                      'Aplikasi Lost & Found Telkom University Jakarta. '
                      'Membantu civitas akademika melaporkan dan menemukan barang hilang.'
                      'Program ini dibuat Oleh: '
                      '1. Daniel Nadeak - 103062330016'
                      '2. Disya Nabila Shativa Resnanda - 1030623300'
                      '3. Muh. Fadhil Faqih - 1030300007'
                      '4. Anissa Febrianti - 1030623000'
                      'Terimakasih kepada seluruh orang yang sudah berkontribusi terkait Tugas Besar Aplikasi Perangkat Bergerak ini',
                    ),
                    SizedBox(height: 8),
                    Text('© 2025 FindIt Tel-U'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(color: Color(0xFFB71C1C)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.help_outline,
              color: Color(0xFFB71C1C),
            ),
            title: const Text('Bantuan & FAQ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Bantuan'),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('❓ Cara melapor barang:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Klik tab "Lapor" → isi form → kirim.'),
                    SizedBox(height: 8),
                    Text('❓ Cara mengubah status:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Buka Riwayat → klik tombol status.'),
                    SizedBox(height: 8),
                    Text('❓ Cara menghapus laporan:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Buka Riwayat → klik ikon 🗑️.'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(color: Color(0xFFB71C1C)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}