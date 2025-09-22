import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting numbers and dates

// Import the data model and the screens we'll navigate to
import 'package:freelance_app/app/features/earnings/transaction_model.dart';
import 'package:freelance_app/app/features/earnings/invoice_tool_screen.dart';
import 'package:freelance_app/app/features/earnings/withdraw_funds_screen.dart';

class EarningsScreen extends StatelessWidget {
  EarningsScreen({super.key});

  // Static data for recent transactions
  final List<Transaction> transactions = [
    Transaction(
      description: 'Payment: Mobile App UI/UX Design',
      amount: 1500.00,
      date: DateTime(2025, 9, 18),
      type: TransactionType.Payment,
    ),
    Transaction(
      description: 'Withdrawal to Bank Account',
      amount: 1200.00,
      date: DateTime(2025, 9, 15),
      type: TransactionType.Withdrawal,
    ),
    Transaction(
      description: 'Payment: Brand Logo & Style Guide',
      amount: 850.50,
      date: DateTime(2025, 9, 12),
      type: TransactionType.Payment,
    ),
    Transaction(
      description: 'Payment: Flutter E-commerce App (Milestone 1)',
      amount: 1600.00,
      date: DateTime(2025, 9, 9),
      type: TransactionType.Payment,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Download Report',
            onPressed: () {
              // Mock action: show a temporary message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Generating and downloading report... (mock)'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildEarningsSummary(context),
          const SizedBox(height: 24),
          _buildActionButtons(context),
          const SizedBox(height: 24),
          Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          // Create a list of transaction items from our static data
          ...transactions.map((tx) => _buildTransactionItem(context, tx))
        ],
      ),
    );
  }

  /// Builds the summary card for total and pending earnings.
  Widget _buildEarningsSummary(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow(
                'Total Earnings (This Year)', '\$15,400.00', context),
            const Divider(height: 24),
            _buildSummaryRow('Pending Payments', '\$1,600.00', context),
          ],
        ),
      ),
    );
  }

  /// A helper for creating a single row in the summary card.
  Widget _buildSummaryRow(String title, String amount, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        Text(amount,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// Builds the "Create Invoice" and "Withdraw" buttons.
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.receipt_long),
            label: const Text('Create Invoice'),
            onPressed: () {
              // ⭐ This button now navigates to the InvoiceToolScreen.
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InvoiceToolScreen()));
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.account_balance),
            label: const Text('Withdraw'),
            onPressed: () {
              // ⭐ This button now navigates to the WithdrawFundsScreen.
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const WithdrawFundsScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ),
      ],
    );
  }

  /// Builds a single transaction item card.
  Widget _buildTransactionItem(BuildContext context, Transaction tx) {
    final isCredit = tx.type == TransactionType.Payment;
    final color =
        isCredit ? Colors.green.shade700 : Theme.of(context).textTheme.bodyLarge?.color;
    final sign = isCredit ? '+' : '-';

    // Format the currency and date for display
    final formattedAmount =
        NumberFormat.simpleCurrency(locale: 'en_US').format(tx.amount);
    final formattedDate = DateFormat('MMM d, yyyy').format(tx.date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
            isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: color),
        title: Text(tx.description),
        subtitle: Text(formattedDate),
        trailing: Text('$sign$formattedAmount',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}