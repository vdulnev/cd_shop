import 'package:flutter/material.dart';

import 'package:cd_shop/features/order/domain/entities/order.dart';

class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({
    super.key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
  });

  final PaymentMethod? selectedPaymentMethod;
  final ValueChanged<PaymentMethod> onPaymentMethodSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          RadioGroup<PaymentMethod>(
            groupValue: selectedPaymentMethod,
            onChanged: (value) {
              if (value != null) onPaymentMethodSelected(value);
            },
            child: Column(
              children: PaymentMethod.values
                  .map((method) => _buildPaymentMethodCard(
                        context,
                        method,
                        isSelected: method == selectedPaymentMethod,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    PaymentMethod method, {
    required bool isSelected,
  }) {
    final icon = switch (method) {
      PaymentMethod.creditCard => Icons.credit_card,
      PaymentMethod.debitCard => Icons.payment,
      PaymentMethod.paypal => Icons.account_balance_wallet,
      PaymentMethod.cashOnDelivery => Icons.money,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () => onPaymentMethodSelected(method),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<PaymentMethod>(
                value: method,
              ),
              const SizedBox(width: 12),
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  method.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
