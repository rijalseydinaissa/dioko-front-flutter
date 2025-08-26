import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:payments_app/features/payments/data/payment_repository.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _type = TextEditingController();

  String? _pickedPath;
  String? _pickedName;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau paiement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                      TextFormField(
                        controller: _description,
                        decoration: const InputDecoration(labelText: 'Description'),
                        validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amount,
                        decoration: const InputDecoration(labelText: 'Montant'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? 'Montant invalide' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _type,
                        decoration: const InputDecoration(labelText: 'Type (internet, eau, etc.)'),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        FilledButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Joindre justificatif (PDF/Image)'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_pickedName ?? 'Aucun fichier sélectionné')),
                      ]),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading ? const CircularProgressIndicator() : const Text('Valider'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false, type: FileType.any);
    if (result != null && result.files.isNotEmpty) {
      final f = result.files.single;
      setState(() {
        _pickedPath = f.path;
        _pickedName = f.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final repo = ref.read(paymentRepositoryProvider);
      final payment = await repo.create(
        description: _description.text.trim(),
        amount: double.parse(_amount.text.trim()),
        type: _type.text.trim().isEmpty ? null : _type.text.trim(),
        filePath: _pickedPath,
        fileName: _pickedName,
      );
      if (mounted) context.go('/payments/${payment.id}');
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }
}
