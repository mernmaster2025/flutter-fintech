import 'package:flutter/material.dart';

import '../models/finance_models.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_components.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int _selectedContact = 0;
  bool _sent = false;

  void _sendPayment() {
    setState(() => _sent = true);
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _sent = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  const AnimatedEntrance(child: _PaymentsHeader()),
                  const SizedBox(height: 22),
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 120),
                    child: _ContactPicker(
                      selectedContact: _selectedContact,
                      onSelected: (index) {
                        setState(() => _selectedContact = index);
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 220),
                    child: _PaymentComposer(sent: _sent, onSend: _sendPayment),
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
  const _PaymentsHeader();

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
            label: 'Instant global rails',
            color: AppColors.orange,
            icon: Icons.public_rounded,
          ),
          const SizedBox(height: 22),
          Text(
            'Send money with a finish that feels magical.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Zero-friction payments, smart routing, and success states designed to feel premium.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ContactPicker extends StatelessWidget {
  const _ContactPicker({
    required this.selectedContact,
    required this.onSelected,
  });

  final int selectedContact;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Choose recipient', action: 'New'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (var i = 0; i < contacts.length; i++) ...[
                  GestureDetector(
                    onTap: () => onSelected(i),
                    child: ContactAvatar(
                      contact: contacts[i],
                      selected: selectedContact == i,
                    ),
                  ),
                  if (i != contacts.length - 1) const SizedBox(width: 20),
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
  const _PaymentComposer({required this.sent, required this.onSend});

  final bool sent;
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
                        Text(
                          r'$2,400',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const StatusChip(
                          label: 'Fastest rail • 3 sec',
                          color: AppColors.cyan,
                          icon: Icons.bolt_rounded,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 26),
          TextField(
            decoration: InputDecoration(
              hintText: 'Add a beautiful note',
              prefixIcon: const Icon(Icons.edit_note_rounded),
              suffixIcon: IconButton(
                onPressed: () {},
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
                        'From',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Aurora Black',
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
                      Text('Fee', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 6),
                      Text(
                        'Free',
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
            label: sent ? 'Payment sent' : 'Send now',
            icon: sent ? Icons.check_rounded : Icons.near_me_rounded,
            expanded: true,
            gradient: sent ? AppColors.successGradient : AppColors.neonGradient,
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
