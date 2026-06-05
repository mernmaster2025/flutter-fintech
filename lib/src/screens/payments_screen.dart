import 'package:flutter/material.dart';

import '../domain/crypto_models.dart';
import '../models/finance_models.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/action_sheets.dart';
import '../widgets/premium_components.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int _selectedContact = 0;
  TransferType _type = TransferType.send;
  bool _sent = false;
  final _amountController = TextEditingController(text: '240');
  final _noteController = TextEditingController(text: 'Crypto settlement');

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppController controller) async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final messenger = ScaffoldMessenger.of(context);
    final success = await controller.submitTransfer(
      type: _type,
      recipientId: controller.recipients[_selectedContact].id,
      amount: amount,
      note: _noteController.text,
    );
    if (success) {
      setState(() => _sent = true);
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() => _sent = false);
        }
      });
    }
    if (controller.message != null) {
      messenger.showSnackBar(SnackBar(content: Text(controller.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.watch(context);
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 132),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedEntrance(
                    child: _PaymentsHeader(controller: controller),
                  ),
                  const SizedBox(height: 22),
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 120),
                    child: _ContactPicker(
                      controller: controller,
                      selectedContact: _selectedContact,
                      onSelected: (index) {
                        setState(() => _selectedContact = index);
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 220),
                    child: _PaymentComposer(
                      controller: controller,
                      type: _type,
                      sent: _sent,
                      amountController: _amountController,
                      noteController: _noteController,
                      onTypeChanged: (value) => setState(() => _type = value),
                      onSend: () => _submit(controller),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SuccessBurst(active: _sent),
      ],
    );
  }
}

class _PaymentsHeader extends StatelessWidget {
  const _PaymentsHeader({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.orange.withValues(alpha: 0.26),
          AppColors.pink.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.08),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatusChip(
            label: 'Backend-ready rails',
            color: AppColors.orange,
            icon: Icons.public_rounded,
          ),
          const SizedBox(height: 22),
          Text(
            'Move USD between crypto rails with validation and activity history.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            '${money(controller.cashBalance)} cash available. Transfers persist locally and can map to real custody/banking APIs later.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          GradientButton(
            label: 'Advanced transfer',
            icon: Icons.tune_rounded,
            onPressed: () => showTransferSheet(context),
          ),
        ],
      ),
    );
  }
}

class _ContactPicker extends StatelessWidget {
  const _ContactPicker({
    required this.controller,
    required this.selectedContact,
    required this.onSelected,
  });

  final AppController controller;
  final int selectedContact;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Choose recipient', action: 'Persisted'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (var i = 0; i < controller.recipients.length; i++) ...[
                  GestureDetector(
                    onTap: () => onSelected(i),
                    child: ContactAvatar(
                      contact: ContactData(
                        name: controller.recipients[i].name,
                        initials: controller.recipients[i].initials,
                        color: _contactColor(i),
                      ),
                      selected: selectedContact == i,
                    ),
                  ),
                  if (i != controller.recipients.length - 1)
                    const SizedBox(width: 20),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentComposer extends StatelessWidget {
  const _PaymentComposer({
    required this.controller,
    required this.type,
    required this.sent,
    required this.amountController,
    required this.noteController,
    required this.onTypeChanged,
    required this.onSend,
  });

  final AppController controller;
  final TransferType type;
  final bool sent;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final ValueChanged<TransferType> onTypeChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Transfer'),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: sent
                  ? const Icon(
                      Icons.check_circle_rounded,
                      key: ValueKey('sent'),
                      color: AppColors.emerald,
                      size: 86,
                    )
                  : Column(
                      key: const ValueKey('amount'),
                      children: [
                        TextField(
                          controller: amountController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                              ),
                          decoration: const InputDecoration(
                            hintText: '0',
                            prefixText: r'$',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const StatusChip(
                          label: 'Mock fee calculated at submit',
                          color: AppColors.cyan,
                          icon: Icons.bolt_rounded,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 22),
          DropdownButtonFormField<TransferType>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Flow'),
            dropdownColor: AppColors.ink,
            items: const [
              DropdownMenuItem(value: TransferType.send, child: Text('Send')),
              DropdownMenuItem(
                value: TransferType.deposit,
                child: Text('Deposit'),
              ),
              DropdownMenuItem(
                value: TransferType.withdraw,
                child: Text('Withdraw'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onTypeChanged(value);
              }
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: 'Add a beautiful note',
              prefixIcon: const Icon(Icons.edit_note_rounded),
              suffixIcon: IconButton(
                onPressed: () {
                  noteController.text = 'AI optimized ${type.name} memo';
                },
                icon: const Icon(Icons.auto_awesome_rounded),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        money(controller.cashBalance),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.busy ? 'Processing' : 'Ready',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: sent
                ? 'Transfer complete'
                : controller.busy
                ? 'Processing...'
                : 'Submit ${type.name}',
            icon: sent ? Icons.check_rounded : Icons.near_me_rounded,
            expanded: true,
            gradient: sent ? AppColors.successGradient : AppColors.neonGradient,
            onPressed: controller.busy ? () {} : onSend,
          ),
        ],
      ),
    );
  }
}

Color _contactColor(int index) {
  const colors = [
    AppColors.pink,
    AppColors.cyan,
    AppColors.emerald,
    AppColors.orange,
  ];
  return colors[index % colors.length];
}
