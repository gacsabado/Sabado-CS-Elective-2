
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _periodFilter = '30';

  static const List<String> _statuses = [
    'done',
    'pending',
    'processing',
    'shipped',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);

      final orders = List<Map<String, dynamic>>.from(response);

      final userIds = orders
          .map((order) => order['user_id']?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      Map<String, Map<String, dynamic>> profilesById = {};

      if (userIds.isNotEmpty) {
        final profiles = await _supabase
            .from('profiles')
            .select('id, email, first_name, last_name')
            .inFilter('id', userIds);

        for (final profile in profiles) {
          final map = Map<String, dynamic>.from(profile);
          profilesById[map['id'].toString()] = map;
        }
      }

      for (final order in orders) {
        final userId = order['user_id']?.toString();
        order['customer'] =
            userId == null ? null : profilesById[userId];

        order['items'] = List<Map<String, dynamic>>.from(
          order['order_items'] ?? [],
        );
      }

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _periodOrders {
    if (_periodFilter == 'all') return _orders;

    final days = int.tryParse(_periodFilter) ?? 30;
    final cutoff = DateTime.now().subtract(Duration(days: days));

    return _orders.where((order) {
      final date = DateTime.tryParse(
        order['created_at']?.toString() ?? '',
      );

      return date != null && !date.isBefore(cutoff);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredOrders {
    final query = _searchQuery.trim().toLowerCase();

    return _orders.where((order) {
      final status = _normalizeStatus(order['status']);

      if (_statusFilter != 'all' && status != _statusFilter) {
        return false;
      }

      if (query.isEmpty) return true;

      final customer = order['customer'] as Map<String, dynamic>?;
      final customerName = _customerName(customer).toLowerCase();
      final email = (customer?['email'] ?? '').toString().toLowerCase();
      final orderNumber = (order['order_number'] ?? '').toString();
      final orderId = (order['id'] ?? '').toString().toLowerCase();

      return orderNumber.contains(query) ||
          orderId.contains(query) ||
          customerName.contains(query) ||
          email.contains(query);
    }).toList();
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _normalizeStatus(dynamic value) {
    final status = value?.toString().trim().toLowerCase() ?? '';
    return status.isEmpty ? 'unknown' : status;
  }

  String _customerName(Map<String, dynamic>? customer) {
    if (customer == null) return 'Unknown customer';

    final firstName = customer['first_name']?.toString().trim() ?? '';
    final lastName = customer['last_name']?.toString().trim() ?? '';
    final fullName = '$firstName $lastName'.trim();

    return fullName.isEmpty ? 'Customer' : fullName;
  }

  String _formatCurrency(num value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Unknown date';

    final local = date.toLocal();

    return '${_monthName(local.month)} ${local.day}, ${local.year} '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return months[month - 1];
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  double get _totalSales {
    return _periodOrders
        .where((order) => _normalizeStatus(order['status']) != 'cancelled')
        .fold<double>(
          0,
          (total, order) => total + _number(order['total_amount']),
        );
  }

  int get _completedOrders {
    return _periodOrders
        .where((order) => _normalizeStatus(order['status']) == 'done')
        .length;
  }

  int get _cancelledOrders {
    return _periodOrders
        .where((order) => _normalizeStatus(order['status']) == 'cancelled')
        .length;
  }

  double get _averageOrderValue {
    final validOrders = _periodOrders
        .where((order) => _normalizeStatus(order['status']) != 'cancelled')
        .toList();

    if (validOrders.isEmpty) return 0;

    return _totalSales / validOrders.length;
  }

  List<_DailySales> get _dailySales {
    final now = DateTime.now();
    final days = _periodFilter == '7'
        ? 7
        : _periodFilter == '30'
            ? 30
            : 7;

    final result = <_DailySales>[];

    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));

      final sales = _orders.where((order) {
        if (_normalizeStatus(order['status']) == 'cancelled') {
          return false;
        }

        final createdAt = DateTime.tryParse(
          order['created_at']?.toString() ?? '',
        );

        if (createdAt == null) return false;

        final local = createdAt.toLocal();

        return local.year == day.year &&
            local.month == day.month &&
            local.day == day.day;
      }).fold<double>(
        0,
        (total, order) => total + _number(order['total_amount']),
      );

      result.add(_DailySales(day: day, amount: sales));
    }

    return result;
  }

  Future<void> _updateOrderStatus(
    Map<String, dynamic> order,
    String newStatus,
  ) async {
    final orderId = order['id']?.toString();

    if (orderId == null || orderId.isEmpty) return;

    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);

      if (!mounted) return;

      await _loadOrders();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order #${order['order_number']} updated to '
            '${_statusLabel(newStatus)}.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update order: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Unknown';

    return status
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  Color _statusColor(BuildContext context, String status) {
    final colors = Theme.of(context).colorScheme;

    switch (status) {
      case 'done':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.teal;
      case 'cancelled':
        return colors.error;
      default:
        return colors.onSurfaceVariant;
    }
  }

  Future<void> _showOrderDetails(
    Map<String, dynamic> order,
  ) async {
    final customer = order['customer'] as Map<String, dynamic>?;
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final status = _normalizeStatus(order['status']);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: Text('Order #${order['order_number'] ?? '—'}'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DetailLine(
                    label: 'Customer',
                    value: _customerName(customer),
                  ),
                  _DetailLine(
                    label: 'Email',
                    value: customer?['email']?.toString() ?? 'Not available',
                  ),
                  _DetailLine(
                    label: 'Date',
                    value: _formatDate(order['created_at']),
                  ),
                  _DetailLine(
                    label: 'Status',
                    value: _statusLabel(status),
                  ),
                  const Divider(height: 28),
                  Text(
                    'Order items',
                    style: Theme.of(dialogContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    const Text('No order items found.')
                  else
                    ...items.map((item) {
                      final quantity =
                          int.tryParse(item['quantity']?.toString() ?? '') ?? 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['product_name']?.toString() ??
                                        'Unnamed product',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '$quantity × '
                                    '${_formatCurrency(_number(item['unit_price']))}',
                                    style: Theme.of(dialogContext)
                                        .textTheme.bodySmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatCurrency(_number(item['subtotal'])),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order total',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        _formatCurrency(_number(order['total_amount'])),
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Update status',
                    style: Theme.of(dialogContext).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _statuses.contains(status) ? status : null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Order status',
                    ),
                    items: _statuses.map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(_statusLabel(value)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null || value == status) return;

                      Navigator.pop(dialogContext);
                      _updateOrderStatus(order, value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSalesReport(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final daily = _dailySales;
    final maxSales = daily.fold<double>(
      0,
      (maxValue, day) => day.amount > maxValue ? day.amount : maxValue,
    );

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sales report',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _periodFilter,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: '7', child: Text('7 days')),
                    DropdownMenuItem(value: '30', child: Text('30 days')),
                    DropdownMenuItem(value: 'all', child: Text('All time')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _periodFilter = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Sales exclude cancelled orders.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _ReportMetric(
                    label: 'Gross sales',
                    value: _formatCurrency(_totalSales),
                    icon: Icons.attach_money_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReportMetric(
                    label: 'Completed',
                    value: _completedOrders.toString(),
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ReportMetric(
                    label: 'Average order',
                    value: _formatCurrency(_averageOrderValue),
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReportMetric(
                    label: 'Cancelled',
                    value: _cancelledOrders.toString(),
                    icon: Icons.cancel_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _periodFilter == 'all'
                  ? 'Daily sales (last 7 days)'
                  : 'Daily sales',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            if (daily.every((day) => day.amount == 0))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No sales recorded for this period.'),
                ),
              )
            else
              ...daily.map((day) {
                final fraction = maxSales == 0
                    ? 0.0
                    : (day.amount / maxSales).clamp(0.0, 1.0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${day.day.month}/${day.day.day}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 12,
                            backgroundColor: colors.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 78,
                        child: Text(
                          _formatCurrency(day.amount),
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final customer = order['customer'] as Map<String, dynamic>?;
    final status = _normalizeStatus(order['status']);
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order['order_number'] ?? '—'}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _OrderStatusChip(
                    status: status,
                    label: _statusLabel(status),
                    color: _statusColor(context, status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _customerName(customer),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if ((customer?['email'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  customer!['email'].toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _formatDate(order['created_at']),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    '${items.length} item${items.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    _formatCurrency(_number(order['total_amount'])),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final orders = _filteredOrders;

    return Scaffold(
      drawer: const _OrdersAdminDrawer(),
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh orders',
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text(
                  'Order management',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track customer orders and monitor store sales.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                _buildSalesReport(context),
                const SizedBox(height: 26),
                Text(
                  'All orders',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search order number or customer...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatusFilterChip(
                        label: 'All',
                        selected: _statusFilter == 'all',
                        onTap: () => setState(() => _statusFilter = 'all'),
                      ),
                      ..._statuses.map(
                        (status) => _StatusFilterChip(
                          label: _statusLabel(status),
                          selected: _statusFilter == status,
                          onTap: () =>
                              setState(() => _statusFilter = status),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  _OrdersError(
                    message: _error!,
                    onRetry: _loadOrders,
                  )
                else if (orders.isEmpty)
                  const _EmptyOrders()
                else ...[
                  Text(
                    '${orders.length} order${orders.length == 1 ? '' : 's'} found',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...orders.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOrderCard(context, order),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailySales {
  final DateTime day;
  final double amount;

  const _DailySales({
    required this.day,
    required this.amount,
  });
}

class _ReportMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReportMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusChip extends StatelessWidget {
  final String status;
  final String label;
  final Color color;

  const _OrderStatusChip({
    required this.status,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 52,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Text(
            'No orders found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Orders will appear here when customers check out.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OrdersError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OrdersError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Could not load orders.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _OrdersAdminDrawer extends StatelessWidget {
  const _OrdersAdminDrawer();

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: 3,
      onDestinationSelected: (index) {
        Navigator.pop(context);

        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/admin');
            break;
          case 2:
            context.go('/admin/products');
            break;
          case 3:
            context.go('/admin/orders');
            break;
          case 4:
            context.push('/profile');
            break;
        }
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HIRONO',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text('STORE MANAGEMENT'),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 8, 16, 8),
          child: Text(
            'MAIN MENU',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Home'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: Text('Dashboard'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2_rounded),
          label: Text('Products'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: Text('Orders'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 24, 16, 8),
          child: Text(
            'ACCOUNT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: Text('My Profile'),
        ),
      ],
    );
  }
}

