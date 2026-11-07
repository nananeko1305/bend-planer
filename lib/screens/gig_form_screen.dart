import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/day_key.dart';
import '../models/gig.dart';
import '../models/gig_draft.dart';
import '../money/money.dart';
import '../services/background_save.dart';
import '../services/gig_repository.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import '../widgets/gig_form_fields.dart';
import '../widgets/gig_format.dart';
import '../widgets/skin_widgets.dart';

/// Adds a gig, or changes one when [gig] is given.
class GigFormScreen extends StatefulWidget {
  const GigFormScreen({
    super.key,
    required this.data,
    required this.profile,
    this.gig,
    this.day,
  });

  final LiveData data;
  final AppUser profile;
  final Gig? gig;

  /// The day picked in the calendar, for a new gig.
  final DateTime? day;

  @override
  State<GigFormScreen> createState() => _GigFormScreenState();
}

class _GigFormScreenState extends State<GigFormScreen> {
  final _form = GlobalKey<FormState>();
  late final GigDraft _start =
      widget.gig?.draft ??
      GigDraft(
        date: dateKey(widget.day ?? DateTime.now()),
        start: '20:00',
        priceMinor: 0,
      );
  late String _date = _start.date;
  late String _time = _start.start;
  late String _end = _start.end;
  late GigType _type = _start.type;
  late Currency _currency = _start.currency;
  late bool _hasTip = _start.hasTip;
  late bool _deposit = _start.depositMinor > 0;
  late String _holder = _start.depositHolder;
  late final _venue = TextEditingController(text: _start.venue);
  late final _city = TextEditingController(text: _start.city);
  late final _address = TextEditingController(text: _start.address);
  late final _client = TextEditingController(text: _start.clientName);
  late final _phone = TextEditingController(text: _start.clientPhone);
  late final _notes = TextEditingController(text: _start.notes);
  late final _price = TextEditingController(
    text: _start.priceMinor > 0 ? moneyToInput(_start.priceMinor) : '',
  );
  late final _depositAmount = TextEditingController(
    text: _start.depositMinor > 0 ? moneyToInput(_start.depositMinor) : '',
  );

  @override
  void dispose() {
    for (final c in [_venue, _city, _address, _client, _phone, _notes]) {
      c.dispose();
    }
    _price.dispose();
    _depositAmount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: parseDateKey(_date) ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3, 12, 31),
    );
    if (picked != null) setState(() => _date = dateKey(picked));
  }

  Future<String?> _pickTime(String current) async {
    final parts = (parseTime(current) ?? '20:00').split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return null;
    return parseTime(
      '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}',
    );
  }

  /// Other gigs that day, for the warning; the one being edited is not one.
  List<Gig> _sameDay() => [
    for (final g in widget.data.gigs ?? const <Gig>[])
      if (g.date == _date && !g.cancelled && g.id != widget.gig?.id) g,
  ];

  void _save() {
    if (!_form.currentState!.validate()) return;
    final draft = GigDraft(
      date: _date,
      start: _time,
      end: _end,
      type: _type,
      venue: _venue.text.trim(),
      city: _city.text.trim(),
      address: _address.text.trim(),
      clientName: _client.text.trim(),
      clientPhone: _phone.text.trim(),
      priceMinor: parseMoney(_price.text)!,
      currency: _currency,
      depositMinor: _deposit ? parseMoney(_depositAmount.text)! : 0,
      depositHolder: _deposit ? _holder : '',
      hasTip: _hasTip,
      notes: _notes.text.trim(),
    );
    final repo = GigRepository.instance;
    final uid = widget.profile.uid;
    final gig = widget.gig;
    if (gig == null) {
      final id = repo.newId();
      saveInBackground(context, () => repo.create(id, draft, uid));
    } else {
      saveInBackground(context, () => repo.update(gig, draft, uid));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final locale = intlLocale(context);
    final sameDay = _sameDay();
    const gap = SizedBox(height: 12);
    Widget section(String label) => Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(label, style: c.display(17, color: c.primary)),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gig == null ? t.newGigTitle : t.editGigTitle),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            section(t.sectionWhen),
            TapField(
              label: t.date,
              icon: Icons.event_rounded,
              value: DateFormat.yMMMMEEEEd(locale).format(parseDateKey(_date)!),
              onTap: _pickDate,
            ),
            gap,
            Row(
              children: [
                Expanded(
                  child: TapField(
                    label: t.startTime,
                    icon: Icons.schedule_rounded,
                    value: _time,
                    onTap: () async {
                      final v = await _pickTime(_time);
                      if (v != null) setState(() => _time = v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TapField(
                    label: t.endTime,
                    icon: Icons.schedule_rounded,
                    value: _end.isEmpty ? '—' : _end,
                    onClear: _end.isEmpty
                        ? null
                        : () => setState(() => _end = ''),
                    onTap: () async {
                      final v = await _pickTime(_end.isEmpty ? '02:00' : _end);
                      if (v != null) setState(() => _end = v);
                    },
                  ),
                ),
              ],
            ),
            if (sameDay.isNotEmpty) ...[
              gap,
              _Warning(
                t.sameDayWarning(
                  sameDay.map((g) => gigSummary(t, g)).join('; '),
                ),
              ),
            ],
            section(t.sectionType),
            GigTypePicker(
              value: _type,
              onChanged: (v) => setState(() => _type = v),
            ),
            section(t.sectionWhere),
            _text(_venue, t.venue, Icons.place_rounded, required: true),
            gap,
            _text(_city, t.city, Icons.location_city_rounded),
            gap,
            _text(_address, t.address, Icons.map_rounded),
            gap,
            _text(_client, t.clientName, Icons.person_rounded),
            gap,
            _text(_phone, t.clientPhone, Icons.phone_rounded, phone: true),
            section(t.sectionMoney),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: c
                        .display(22, weight: FontWeight.w800)
                        .copyWith(shadows: const []),
                    decoration: InputDecoration(labelText: t.price),
                    validator: (v) =>
                        parseMoney(v ?? '') == null ? t.enterAmount : null,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: CurrencyToggle(
                    value: _currency,
                    onChanged: (v) => setState(() => _currency = v),
                  ),
                ),
              ],
            ),
            gap,
            _DepositSection(
              on: _deposit,
              amount: _depositAmount,
              holder: _holder,
              members: widget.data.members,
              price: () => parseMoney(_price.text),
              onToggle: (v) => setState(() => _deposit = v),
              onHolder: (v) => setState(() => _holder = v),
            ),
            const SizedBox(height: 18),
            SectionLabel(t.tipQuestion),
            const SizedBox(height: 8),
            TipToggle(
              value: _hasTip,
              onChanged: (v) => setState(() => _hasTip = v),
            ),
            if (_hasTip)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  t.tipHint,
                  style: TextStyle(color: c.muted, fontSize: 13.5),
                ),
              ),
            section(t.sectionNotes),
            TextFormField(
              controller: _notes,
              minLines: 3,
              maxLines: 6,
              maxLength: 1000,
              decoration: InputDecoration(hintText: t.notesHint),
            ),
            const SizedBox(height: 12),
            Center(
              child: PrimaryPill(
                label: t.saveGig,
                icon: Icons.check_rounded,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _text(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    bool phone = false,
  }) {
    final t = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      maxLength: 120,
      keyboardType: phone ? TextInputType.phone : TextInputType.text,
      textCapitalization: phone
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        counterText: '',
      ),
      validator: required
          ? (v) => (v ?? '').trim().isEmpty ? t.required : null
          : null,
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.tip.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.tip),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: c.tipText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepositSection extends StatelessWidget {
  const _DepositSection({
    required this.on,
    required this.amount,
    required this.holder,
    required this.members,
    required this.price,
    required this.onToggle,
    required this.onHolder,
  });

  final bool on;
  final TextEditingController amount;
  final String holder;
  final List<AppUser> members;
  final int? Function() price;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onHolder;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final known = members.any((m) => m.uid == holder);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                t.depositGiven,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              value: on,
              onChanged: onToggle,
            ),
            if (on) ...[
              TextFormField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: t.depositAmount),
                validator: (v) {
                  final d = parseMoney(v ?? '');
                  if (d == null) return t.enterAmount;
                  final p = price();
                  return p != null && d > p ? t.depositTooBig : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: known ? holder : '',
                decoration: InputDecoration(labelText: t.depositHolder),
                items: [
                  const DropdownMenuItem(value: '', child: Text('—')),
                  for (final m in members)
                    DropdownMenuItem(value: m.uid, child: Text(m.displayName)),
                ],
                onChanged: (v) => onHolder(v ?? ''),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
