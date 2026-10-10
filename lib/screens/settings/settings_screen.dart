import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentName = context.read<SettingsProvider>().userName;
    if (currentName != null) {
      _nameController.text = currentName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ছোট Section-শিরোনাম ("YOUR NAME", "THEME"...)
  Widget _sectionTitle(String text, AppColors c) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: c.faint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: c.ink),
        title: Text(
          'Settings',
          style: TextStyle(color: c.ink, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ---- নাম ----
          _sectionTitle('YOUR NAME', c),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            style: TextStyle(color: c.ink),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: TextStyle(color: c.subtle),
              filled: true,
              fillColor: c.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: c.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: c.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: c.accentFg),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;

                await context.read<SettingsProvider>().setUserName(name);

                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Saved')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: c.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ---- নতুন: Theme ----
          _sectionTitle('THEME', c),
          const SizedBox(height: 10),

          // ============================================
          // তিনটা পাশাপাশি বাটন। যেটা এখন চালু, সেটা সবুজ ভরাট,
          // বাকিগুলো Border-ওয়ালা। চাপলেই Provider Theme বদলায়,
          // আর পুরো App (এই Screen-সহ) সাথে সাথে নতুন রঙে আঁকা হয়
          // ============================================
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              final c = context.colors;

              Widget option(String label, ThemeMode mode) {
                final selected = settings.themeMode == mode;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        context.read<SettingsProvider>().setThemeMode(mode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? c.accent : c.surface,
                        border: Border.all(
                          color: selected ? c.accent : c.border,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : c.ink,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Row(
                children: [
                  option('Light', ThemeMode.light),
                  const SizedBox(width: 8),
                  option('Dark', ThemeMode.dark),
                  const SizedBox(width: 8),
                  option('System', ThemeMode.system),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // ---- Alerts ----
          _sectionTitle('ALERTS', c),
          const SizedBox(height: 10),

          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              final c = context.colors;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget alerts',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: c.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Warn me when a section is running low or over budget',
                            style: TextStyle(
                              fontSize: 12,
                              color: c.faint,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: settings.budgetAlertsEnabled,
                      onChanged: (value) {
                        context.read<SettingsProvider>().setBudgetAlerts(value);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: c.accent,
                      inactiveThumbColor: c.subtle,
                      inactiveTrackColor: c.track,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
