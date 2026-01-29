import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../providers/cart_provider.dart';
import '../../../orders/providers/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isProcessing = false;

  // Shipping info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  // Payment info
  String _paymentMethod = 'card';
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Form(
            key: _formKey,
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      FilledButton(
                        onPressed: _isProcessing ? null : details.onStepContinue,
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_currentStep == 2 ? 'Place Order' : 'Continue'),
                      ),
                      const SizedBox(width: 12),
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: _isProcessing ? null : details.onStepCancel,
                          child: const Text('Back'),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Shipping'),
                  content: _buildShippingForm(theme),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Payment'),
                  content: _buildPaymentForm(theme),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Review'),
                  content: _buildOrderReview(theme, cart.subtotal, cart.items.length),
                  isActive: _currentStep >= 2,
                  state: StepState.indexed,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildShippingForm(ThemeData theme) {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: Validators.required('Name is required'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: Validators.email(),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: Validators.phone(),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Street Address',
            prefixIcon: Icon(Icons.home_outlined),
          ),
          validator: Validators.required('Address is required'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                ),
                validator: Validators.required('City is required'),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                ),
                validator: Validators.required('State is required'),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _zipController,
          decoration: const InputDecoration(
            labelText: 'ZIP Code',
            prefixIcon: Icon(Icons.pin_drop_outlined),
          ),
          validator: Validators.required('ZIP code is required'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildPaymentForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _PaymentMethodTile(
          icon: Icons.credit_card,
          title: 'Credit/Debit Card',
          subtitle: 'Pay securely with your card',
          value: 'card',
          groupValue: _paymentMethod,
          onChanged: (value) => setState(() => _paymentMethod = value!),
        ),
        _PaymentMethodTile(
          icon: Icons.account_balance_wallet,
          title: 'PayPal',
          subtitle: 'Fast and secure payment',
          value: 'paypal',
          groupValue: _paymentMethod,
          onChanged: (value) => setState(() => _paymentMethod = value!),
        ),
        _PaymentMethodTile(
          icon: Icons.money,
          title: 'Cash on Delivery',
          subtitle: 'Pay when you receive',
          value: 'cod',
          groupValue: _paymentMethod,
          onChanged: (value) => setState(() => _paymentMethod = value!),
        ),
        if (_paymentMethod == 'card') ...[
          const SizedBox(height: 24),
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              prefixIcon: Icon(Icons.credit_card),
              hintText: '1234 5678 9012 3456',
            ),
            keyboardType: TextInputType.number,
            validator: _paymentMethod == 'card'
                ? Validators.required('Card number is required')
                : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry',
                    hintText: 'MM/YY',
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: _paymentMethod == 'card'
                      ? Validators.required('Expiry is required')
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: _paymentMethod == 'card'
                      ? Validators.required('CVV is required')
                      : null,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildOrderReview(ThemeData theme, double subtotal, int itemCount) {
    final shipping = subtotal >= 50 ? 0.0 : 5.99;
    final tax = subtotal * 0.08;
    final total = subtotal + shipping + tax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Address',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_nameController.text, style: theme.textTheme.bodyMedium),
              Text(_addressController.text, style: theme.textTheme.bodySmall),
              Text(
                '${_cityController.text}, ${_stateController.text} ${_zipController.text}',
                style: theme.textTheme.bodySmall,
              ),
              Text(_phoneController.text, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Payment Method',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _paymentMethod == 'card'
                    ? Icons.credit_card
                    : _paymentMethod == 'paypal'
                        ? Icons.account_balance_wallet
                        : Icons.money,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                _paymentMethod == 'card'
                    ? 'Credit/Debit Card'
                    : _paymentMethod == 'paypal'
                        ? 'PayPal'
                        : 'Cash on Delivery',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Order Summary',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _SummaryRow(label: 'Subtotal ($itemCount items)', value: subtotal.toCurrency()),
        _SummaryRow(
          label: 'Shipping',
          value: shipping == 0 ? 'Free' : shipping.toCurrency(),
          valueColor: shipping == 0 ? Colors.green : null,
        ),
        _SummaryRow(label: 'Tax', value: tax.toCurrency()),
        const Divider(height: 24),
        _SummaryRow(
          label: 'Total',
          value: total.toCurrency(),
          isTotal: true,
        ),
      ],
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_validateShippingForm()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_validatePaymentForm()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 2) {
      _placeOrder();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _validateShippingForm() {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _stateController.text.isNotEmpty &&
        _zipController.text.isNotEmpty;
  }

  bool _validatePaymentForm() {
    if (_paymentMethod == 'card') {
      return _cardNumberController.text.isNotEmpty &&
          _expiryController.text.isNotEmpty &&
          _cvvController.text.isNotEmpty;
    }
    return true;
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      await ref.read(orderNotifierProvider.notifier).createOrder(
        shippingAddress: '${_addressController.text}, ${_cityController.text}, ${_stateController.text} ${_zipController.text}',
        paymentMethod: _paymentMethod,
      );

      ref.read(cartNotifierProvider.notifier).clearCart();

      if (mounted) {
        context.go('/orders/confirmation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
          ),
        ],
      ),
    );
  }
}
