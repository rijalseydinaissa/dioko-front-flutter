import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:payments_app/features/auth/data/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    // Nom
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Nom requis' : null,
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email requis';
                        final regex = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                        if (!regex.hasMatch(v)) return 'Email invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Mot de passe
                    TextFormField(
                      controller: _password,
                      decoration:
                          const InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Mot de passe requis';
                        if (v.length < 6) return 'Min 6 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Confirmation mot de passe
                    TextFormField(
                      controller: _passwordConfirmation,
                      decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirmation requise';
                        if (v != _password.text) return 'Les mots de passe ne correspondent pas';
                        return null;
                      },
                    ),
                     const SizedBox(height: 24), 
                    // Bouton inscription
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _onSubmit,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text("S'inscrire"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            passwordConfirmation: _passwordConfirmation.text,
          );

      if (context.mounted) context.go('/login');
    } catch (e) {
      // Gestion des erreurs Laravel (422 inclus)
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          final messages = data['errors'] ??
              {'error': [data['message'] ?? 'Erreur inconnue']};
          _error = messages.values
              .map((v) => (v as List).join(', '))
              .join('\n');
        } else {
          _error = e.response!.data.toString();
        }
      } else {
        _error = e.toString();
      }
      setState(() {});
    } finally {
      if (mounted) setState(() {
        _loading = false;
      });
    }
  }
}
