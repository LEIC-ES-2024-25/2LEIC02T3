import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/auth_wrapper.dart';
import 'bottom_navigation_bar.dart';
import '../providers/badges_provider.dart';
import '../providers/points_provider.dart';
import '../providers/challenges_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tela de configurações que permite aos usuários gerenciar preferências
/// e realizar ações como logout e compartilhar o aplicativo.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Estado para preferências do usuário
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Português';
  bool _isLoading = false;

  // Lista de opções de idioma
  final List<String> _languages = ['Português', 'English', 'Español'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Carrega preferências salvas anteriormente
  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _selectedLanguage = prefs.getString('selected_language') ?? 'Português';
        _isLoading = false;
      });
    } catch (e) {
      // Em caso de erro, mantém os valores padrão
      setState(() => _isLoading = false);
    }
  }

  /// Salva as preferências atuais no armazenamento local
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setString('selected_language', _selectedLanguage);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurações salvas com sucesso'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Processa o logout do usuário e limpa dados locais
  Future<void> _handleLogout(BuildContext context) async {
    // Exibir diálogo de confirmação
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    // Se o usuário cancelou, retornar
    if (shouldLogout != true) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // 1. Limpar progresso local
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
                child: Column(
                  children: [
                    SwitchListTile(
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
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.language, color: Colors.green),
                      title: const Text('Idioma'),
                      subtitle: Text(_selectedLanguage),
                      onTap: () => _showLanguageDialog(),
                    ),
                  ],
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
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip, color: Colors.green),
                      title: const Text('Política de Privacidade'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Recurso em desenvolvimento'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
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

            const SizedBox(height: 10),

            // Botão de redefinir configurações
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _notificationsEnabled = true;
                  _selectedLanguage = 'Português';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configurações padrão restauradas'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Redefinir Configurações', style: TextStyle(fontSize: 16)),
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

  /// Exibe diálogo para seleção de idioma
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Idioma'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              return RadioListTile<String>(
                title: Text(_languages[index]),
                value: _languages[index],
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}