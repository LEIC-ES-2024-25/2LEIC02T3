import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/badges_provider.dart';
import '../providers/challenges_provider.dart';
import '../providers/points_provider.dart';
import '../services/auth_service.dart';
import '../widgets/auth_wrapper.dart';
import 'bottom_navigation_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  bool _notificationsEnabled = true;

  Future<void> _savePreferences() async {
    // Implementação do salvamento de preferências
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferências salvas com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // 1. Limpar dados locais
      await Provider.of<BadgesProvider>(context, listen: false).clearLocalProgress();
      await Provider.of<PointsProvider>(context, listen: false).clearLocalPoints();
      await Provider.of<ChallengesProvider>(context, listen: false).clearLocalChallengeProgress();

      // 2. Fazer logout do usuário
      await authService.signOut();

      // 3. Limpar SnackBars pendentes
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        // 4. Navegar para tela de autenticação
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
              (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sair',
            onPressed: _isLoading ? null : () => _handleLogout(context),
          ),
        ],
      ),
      backgroundColor: Colors.green.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção de conta
            _buildSectionHeader('Conta'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListTile(
                  leading: const Icon(Icons.account_circle, color: Colors.green),
                  title: const Text('Meu Perfil'),
                  subtitle: Text(
                    Provider.of<AuthService>(context).currentUser?.email ?? 'Não logado',
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recurso em desenvolvimento'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Seção de preferências
            _buildSectionHeader('Preferências'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SwitchListTile(
                  title: const Text('Notificações'),
                  subtitle: const Text('Receber alertas sobre desafios'),
                  secondary: Icon(
                      _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                      color: Colors.green
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Seção de sobre
            _buildSectionHeader('Sobre'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.share, color: Colors.green),
                      title: const Text('Compartilhar App'),
                      onTap: () async {
                        final uri = Uri.parse('https://github.com/LuisF775/ESOF_APP');
                        try {
                          final success = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication
                          );
                          if (!success && mounted) {
                            throw 'Não foi possível abrir $uri';
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro: $e')),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.green),
                      title: const Text('Versão do App'),
                      subtitle: const Text('1.0.0'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botão de salvar configurações
            ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Salvar Configurações',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'SettingsScreen',
      ),
    );
  }

  /// Cria o cabeçalho de uma seção
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }
}