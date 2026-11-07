import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/app_user.dart';
import '../services/background_save.dart';
import '../services/user_repository.dart';

/// Adds a member, or edits one when [member] is given. Adding waits for the
/// answer, unlike other writes: an email already in use must show here.
Future<void> showMemberDialog(BuildContext context, {AppUser? member}) =>
    showDialog<void>(
      context: context,
      builder: (_) => _MemberDialog(member: member),
    );

class _MemberDialog extends StatefulWidget {
  const _MemberDialog({this.member});

  final AppUser? member;

  @override
  State<_MemberDialog> createState() => _MemberDialogState();
}

class _MemberDialogState extends State<_MemberDialog> {
  final _form = GlobalKey<FormState>();
  late final _first = TextEditingController(text: widget.member?.firstName);
  late final _last = TextEditingController(text: widget.member?.lastName);
  late final _instrument = TextEditingController(
    text: widget.member?.instrument,
  );
  late final _phone = TextEditingController(text: widget.member?.phone);
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  bool get _adding => widget.member == null;

  @override
  void dispose() {
    for (final c in [_first, _last, _instrument, _phone, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final t = AppLocalizations.of(context);
    final repo = UserRepository.instance;
    if (!_adding) {
      saveInBackground(
        context,
        () => repo.updateProfile(
          widget.member!.uid,
          firstName: _first.text,
          lastName: _last.text,
          instrument: _instrument.text,
          phone: _phone.text,
        ),
      );
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repo.createMember(
        email: _email.text,
        password: _password.text,
        firstName: _first.text,
        lastName: _last.text,
        instrument: _instrument.text,
        phone: _phone.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      final name = '${_first.text} ${_last.text}'.trim();
      messenger.showSnackBar(
        SnackBar(content: Text(t.memberCreated(name, _email.text.trim()))),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorText(t, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    String? required(String? v) => (v ?? '').trim().isEmpty ? t.required : null;
    const gap = SizedBox(height: 12);
    return AlertDialog(
      title: Text(_adding ? t.addMember : t.editMember),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _first,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: t.firstName),
                validator: required,
              ),
              gap,
              TextFormField(
                controller: _last,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: t.lastName),
              ),
              gap,
              TextFormField(
                controller: _instrument,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: t.instrument),
              ),
              gap,
              TextFormField(
                controller: _phone,
                // The last field when editing; email and password follow when adding.
                textInputAction: _adding
                    ? TextInputAction.next
                    : TextInputAction.done,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: t.phone),
              ),
              if (_adding) ...[
                gap,
                TextFormField(
                  controller: _email,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(labelText: t.email),
                  validator: (v) =>
                      (v ?? '').contains('@') ? null : t.invalidEmail,
                ),
                gap,
                TextFormField(
                  controller: _password,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: t.startPassword,
                    helperText: t.startPasswordHint,
                    helperMaxLines: 3,
                  ),
                  validator: (v) => (v ?? '').length < 6 ? t.minChars6 : null,
                ),
              ],
              if (_error != null) ...[
                gap,
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 46)),
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(t.save),
        ),
      ],
    );
  }
}
