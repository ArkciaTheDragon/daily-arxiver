import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeRangePicker extends StatefulWidget {
  final DateTimeRange? initialRange;
  final ValueChanged<DateTimeRange> onRangeSelected;

  const TimeRangePicker({
    super.key,
    this.initialRange,
    required this.onRangeSelected,
  });

  @override
  TimeRangePickerState createState() => TimeRangePickerState();
}

class TimeRangePickerState extends State<TimeRangePicker> {
  DateTimeRange? _selectedRange;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialRange;
  }

  String _formatDateRange() {
    if (_selectedRange == null) return "No date range selected";

    final start = _dateFormat.format(_selectedRange!.start);
    final end = _dateFormat.format(_selectedRange!.end);

    return "$start to $end";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDateRange(),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_calendar),
                  tooltip: 'Select Date Range',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _selectDateRange(context),
                ),
              ],
            ),
            if (_selectedRange != null) const SizedBox(height: 8),
            if (_selectedRange != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      'From: ${_dateFormat.format(_selectedRange!.start)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      'To: ${_dateFormat.format(_selectedRange!.end)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            if (_selectedRange == null)
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('Select Date Range'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => _selectDateRange(context),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
      initialDateRange:
          _selectedRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedRange = picked);
      widget.onRangeSelected(picked);
    }
  }
}
