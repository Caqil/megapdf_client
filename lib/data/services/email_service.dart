// lib/data/services/email_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'email_service.g.dart';

@riverpod
EmailService emailService(Ref ref) {
  return EmailService();
}

class EmailService {
  final String smtpHost = 'mail.privateemail.com';
  final int smtpPort = 587;
  final String smtpUser = 'support@billiongroup.net';
  final String smtpPassword = 'Aqswde!123';
  final bool smtpSecure = false;
  final String emailFrom = 'support@billiongroup.net';

  Future<bool> sendEmail({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final smtpServer = SmtpServer(
        smtpHost,
        port: smtpPort,
        username: smtpUser,
        password: smtpPassword,
        ssl: smtpSecure,
        allowInsecure: true,
      );

      final emailMessage = Message()
        ..from = Address(emailFrom, 'MegaPDF Support')
        ..recipients.add(emailFrom)
        ..subject = 'Contact Form: $subject'
        ..text = '''
From: $name
Email: $email

$message
''';

      final sendReport = await send(emailMessage, smtpServer);
      return sendReport.toString().isNotEmpty;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
}
