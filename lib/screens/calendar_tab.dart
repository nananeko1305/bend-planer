import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/day_key.dart';
import '../models/gig.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import '../widgets/gig_card.dart';
import '../widgets/gig_format.dart';
import '../widgets/month_grid.dart';
import '../widgets/month_switcher.dart';
import '../widgets/tab_header.dart';
import 'gig_detail_screen.dart';

/// A month of gigs: a dot per booked day, and the list of the picked day.
class CalendarTab extends StatefulWidget {
  const CalendarTab({
    super.key,
    required this.data,
    required this.profile,
    required this.onAdd,
  });

  final LiveData data;
  final AppUser profile;

  /// Opens the form for a new gig on the given day.
  final void Function(DateTime day) onAdd;

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  late DateTime _selected = dayOf(DateTime.now());
  late DateTime _month = DateTime(_selected.year, _selected.month);

  /// Gigs that are on, per day; cancelled ones do not take the day.
  Map<DateTime, int> _counts() {
    final counts = <DateTime, int>{};
    for (final g in widget.data.gigs ?? const <Gig>[]) {
      if (g.cancelled) continue;
      counts[g.day] = (counts[g.day] ?? 0) + 1;
    }
    return counts;
  }

  void _showMonth(DateTime month) => setState(() {
    _month = month;
    final today = dayOf(DateTime.now());
    _selected = month.year == today.year && month.month == today.month
        ? today
        : month;
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final now = DateTime.now();
    final dayGigs = widget.data.on(_selected);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          TabHeader(
            data: widget.data,
            profile: widget.profile,
            title: t.tabCalendar,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                MonthSwitcher(
                  month: _month,
                  first: DateTime(now.year - 2),
                  last: DateTime(now.year + 3, 12),
                  onChanged: _showMonth,
                ),
                MonthGrid(
                  month: _month,
                  selected: _selected,
                  today: dayOf(now),
                  counts: _counts(),
                  onSelect: (day) => setState(() => _selected = day),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              DateFormat.MMMMEEEEd(intlLocale(context)).format(_selected),
              style: c.display(18),
            ),
          ),
          if (dayGigs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.nothingThatDay, style: TextStyle(color: c.muted)),
                  TextButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: Text(t.addOnThisDay),
                    onPressed: () => widget.onAdd(_selected),
                  ),
                ],
              ),
            ),
          for (final g in dayGigs)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: GigCard(
                gig: g,
                now: now,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GigDetailScreen(
                      data: widget.data,
                      profile: widget.profile,
                      gigId: g.id,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
