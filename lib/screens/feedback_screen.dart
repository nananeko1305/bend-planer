import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../services/background_save.dart';
import '../services/feedback_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/skin_widgets.dart';

/// A note from a member straight to the owner, who gets a push.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key, required this.profile});

  final AppUser profile;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _form = GlobalKey<FormState>();
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    if (!_form.currentState!.validate()) return;
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final text = _text.text;
    saveInBackground(
      context,
      () => FeedbackRepository.instance.send(widget.profile.uid, text),
    );
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(t.feedbackSent)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.sendFeedback)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t.feedbackHint, style: TextStyle(color: context.colors.muted)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _text,
              autofocus: true,
              minLines: 5,
              maxLines: 12,
              maxLength: FeedbackRepository.maxLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: t.feedbackField),
              validator: (v) => (v ?? '').trim().isEmpty ? t.required : null,
            ),
            const SizedBox(height: 16),
            Center(
              child: PrimaryPill(
                label: t.send,
                icon: Icons.send_rounded,
                onPressed: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
