import 'package:flutter/material.dart';

class TimeRangePicker extends StatelessWidget {
  final ValueChanged<DateTimeRange> onRangeSelected;

  const TimeRangePicker({super.key, required this.onRangeSelected});

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDate = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: initialDate.subtract(const Duration(days: 7)),
        end: initialDate,
      ),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          ),
    );

    if (picked != null) {
      onRangeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today),
      label: const Text('Date'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      onPressed: () => _selectDateRange(context),
    );
  }
}

// 增强版带显示的时间范围预览（可选实现）
class TimeRangeDisplayPicker extends StatefulWidget {
  final DateTimeRange? initialRange;
  final ValueChanged<DateTimeRange> onRangeSelected;

  const TimeRangeDisplayPicker({
    super.key,
    this.initialRange,
    required this.onRangeSelected,
  });

  @override
  _TimeRangeDisplayPickerState createState() => _TimeRangeDisplayPickerState();
}

class _TimeRangeDisplayPickerState extends State<TimeRangeDisplayPicker> {
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialRange;
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedRange == null
                  ? "Range not selected"
                  : "${_formatDate(_selectedRange!.start)} to ${_formatDate(_selectedRange!.end)}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _selectDateRange(context),
            ),
          ],
        ),
        if (_selectedRange == null)
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            onPressed: () => _selectDateRange(context),
            child: const Text('Select Date Range'),
          ),
      ],
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
    );

    if (picked != null) {
      setState(() => _selectedRange = picked);
      widget.onRangeSelected(picked);
    }
  }
}
