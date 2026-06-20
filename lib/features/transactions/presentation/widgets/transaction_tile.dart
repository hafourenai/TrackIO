import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/transaction.dart';
import '../providers/transaction_provider.dart';

class TransactionTile extends ConsumerWidget {
  final Transaction transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isIncome = transaction.type == 'income';
    final amountColor = isIncome ? Colors.teal : theme.colorScheme.onSurface;
    final prefix = isIncome ? '+' : '-';

    return Dismissible(
      key: Key('tx_${transaction.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (transaction.id != null) {
          ref.read(transactionControllerProvider).deleteTransaction(transaction.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transaksi "${transaction.title}" berhasil dihapus'),
              action: SnackBarAction(
                label: 'Batal',
                onPressed: () {
                  ref.read(transactionControllerProvider).addTransaction(transaction);
                },
              ),
            ),
          );
        }
      },
      child: ListTile(
        onTap: () {
          context.push('/transactions/edit/${transaction.id}');
        },
        leading: CircleAvatar(
          backgroundColor: CategoryConstants.getColor(transaction.category).withValues(alpha: 0.15),
          child: Icon(
            CategoryConstants.getIcon(transaction.category),
            color: CategoryConstants.getColor(transaction.category),
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.note != null && transaction.note!.isNotEmpty)
              Text(
                transaction.note!,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              DateFormatter.formatShort(transaction.date),
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
        trailing: Text(
          '$prefix${CurrencyFormatter.format(transaction.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ),
    );
  }
}
