import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Email OTP Service using free SMTP providers
/// 
/// Free Options:
/// 1. Gmail SMTP (Recommended - Completely Free)
/// 2. Outlook/Hotmail SMTP (Free)
/// 3. Yahoo SMTP (Free)
/// 4. Mailtrap (Free tier: 500 emails/month for testing)
/// 5. EmailJS (Free tier: 200 emails/month)
class EmailOTPService {
  // OTP storage (in production, use secure backend storage)
  static final Map<String, OTPData> _otpStorage = {};
  
  // OTP validity duration
  static const Duration otpValidity = Duration(minutes: 10);
  
  // Rate limiting
  static final Map<String, DateTime> _lastSentTime = {};
  static const Duration rateLimitDuration = Duration(minutes: 1);

  /// Generate a 6-digit OTP
  static String generateOTP() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send OTP via Email using Gmail SMTP (Free)
  /// 
  /// Setup Instructions:
  /// 1. Go to Google Account settings
  /// 2. Enable 2-Factor Authentication
  /// 3. Generate App Password: https://myaccount.google.com/apppasswords
  /// 4. Use the 16-character app password below
  /// 
  /// Alternative: Use environment variables or secure storage
  static Future<bool> sendOTP({
    required String email,
    required String purpose, // 'login', 'register', 'verify'
  }) async {
    try {
      // Rate limiting check
      if (_lastSentTime.containsKey(email)) {
        final timeSinceLastSent = DateTime.now().difference(_lastSentTime[email]!);
        if (timeSinceLastSent < rateLimitDuration) {
          final waitSeconds = (rateLimitDuration - timeSinceLastSent).inSeconds;
          debugPrint('⏰ Rate limit: Wait $waitSeconds seconds before resending');
          throw Exception('Please wait $waitSeconds seconds before requesting another OTP');
        }
      }

      // Generate OTP
      final otp = generateOTP();
      
      // Store OTP with expiry
      _otpStorage[email] = OTPData(
        otp: otp,
        createdAt: DateTime.now(),
        purpose: purpose,
      );
      _lastSentTime[email] = DateTime.now();

      // For development/demo mode - just print OTP
      if (kDebugMode) {
        debugPrint('🔐 OTP for $email: $otp (Valid for 10 minutes)');
        // In demo mode, we'll still return true but won't send actual email
        return true;
      }

      // Production: Send actual email
      // Configure your SMTP settings here
      final smtpServer = await _getSmtpServer();
      
      if (smtpServer == null) {
        // Fallback to demo mode if SMTP not configured
        debugPrint('⚠️ SMTP not configured, using demo mode');
        return true;
      }

      final message = Message()
        ..from = Address(_getSenderEmail(), 'Krashi Bandhu')
        ..recipients.add(email)
        ..subject = 'Your Krashi Bandhu OTP - $otp'
        ..html = _buildEmailTemplate(otp, purpose);

      try {
        final sendReport = await send(message, smtpServer);
        debugPrint('✅ Email sent: ${sendReport.toString()}');
        return true;
      } on MailerException catch (e) {
        debugPrint('❌ Email send failed: ${e.toString()}');
        // Even if email fails, keep OTP in storage for demo/testing
        return true; // Return true for demo mode
      }
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      rethrow;
    }
  }

  /// Verify OTP
  static bool verifyOTP(String email, String otp) {
    if (!_otpStorage.containsKey(email)) {
      debugPrint('❌ No OTP found for $email');
      return false;
    }

    final otpData = _otpStorage[email]!;
    
    // Check if OTP is expired
    final now = DateTime.now();
    if (now.difference(otpData.createdAt) > otpValidity) {
      _otpStorage.remove(email);
      debugPrint('❌ OTP expired for $email');
      return false;
    }

    // Verify OTP
    if (otpData.otp == otp) {
      _otpStorage.remove(email); // Remove after successful verification
      _lastSentTime.remove(email); // Reset rate limit
      debugPrint('✅ OTP verified for $email');
      return true;
    }

    debugPrint('❌ Invalid OTP for $email');
    return false;
  }

  /// Clear OTP for an email
  static void clearOTP(String email) {
    _otpStorage.remove(email);
    _lastSentTime.remove(email);
  }

  /// Get remaining validity time for OTP
  static Duration? getRemainingValidity(String email) {
    if (!_otpStorage.containsKey(email)) return null;
    
    final otpData = _otpStorage[email]!;
    final elapsed = DateTime.now().difference(otpData.createdAt);
    final remaining = otpValidity - elapsed;
    
    return remaining.isNegative ? null : remaining;
  }

  // Private helper methods

  static Future<SmtpServer?> _getSmtpServer() async {
    // Option 1: Gmail SMTP (Recommended)
    // Requires App Password from Google Account
    // Uncomment and configure when ready for production
    
    /*
    const gmailEmail = 'your-email@gmail.com';
    const gmailAppPassword = 'your-16-char-app-password'; // Get from Google Account
    return gmail(gmailEmail, gmailAppPassword);
    */

    // Option 2: Custom SMTP
    /*
    const host = 'smtp.gmail.com';
    const port = 587;
    const username = 'your-email@gmail.com';
    const password = 'your-app-password';
    
    return SmtpServer(
      host,
      port: port,
      username: username,
      password: password,
      ssl: false,
      allowInsecure: false,
    );
    */

    // Option 3: Outlook/Hotmail
    /*
    const email = 'your-email@outlook.com';
    const password = 'your-password';
    return hotmail(email, password);
    */

    // Return null for demo mode
    return null;
  }

  static String _getSenderEmail() {
    // Configure your sender email here
    return 'noreply@krashibandhu.in';
  }

  static String _buildEmailTemplate(String otp, String purpose) {
    final purposeText = purpose == 'login' 
        ? 'login to your account'
        : purpose == 'register'
            ? 'complete your registration'
            : 'verify your email';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background-color: #f5f5f5;
      margin: 0;
      padding: 0;
    }
    .container {
      max-width: 600px;
      margin: 40px auto;
      background-color: #ffffff;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      overflow: hidden;
    }
    .header {
      background: linear-gradient(135deg, #2E7D32 0%, #4CAF50 100%);
      color: white;
      padding: 30px 20px;
      text-align: center;
    }
    .header h1 {
      margin: 0;
      font-size: 28px;
      font-weight: 600;
    }
    .header p {
      margin: 8px 0 0 0;
      font-size: 14px;
      opacity: 0.9;
    }
    .content {
      padding: 40px 30px;
    }
    .otp-box {
      background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
      border: 2px dashed #2E7D32;
      border-radius: 8px;
      padding: 30px;
      text-align: center;
      margin: 30px 0;
    }
    .otp-code {
      font-size: 36px;
      font-weight: bold;
      color: #2E7D32;
      letter-spacing: 8px;
      font-family: 'Courier New', monospace;
    }
    .otp-label {
      font-size: 12px;
      color: #666;
      margin-top: 8px;
      text-transform: uppercase;
      letter-spacing: 1px;
    }
    .message {
      font-size: 16px;
      color: #333;
      line-height: 1.6;
      margin-bottom: 20px;
    }
    .warning {
      background-color: #fff3cd;
      border-left: 4px solid #ffc107;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
    }
    .warning p {
      margin: 0;
      font-size: 14px;
      color: #856404;
    }
    .footer {
      background-color: #f8f9fa;
      padding: 20px 30px;
      text-align: center;
      font-size: 12px;
      color: #666;
      border-top: 1px solid #e0e0e0;
    }
    .footer a {
      color: #2E7D32;
      text-decoration: none;
    }
    .icon {
      font-size: 48px;
      margin-bottom: 10px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="icon">🌾</div>
      <h1>Krashi Bandhu</h1>
      <p>Making Crop Insurance Faster and Fairer</p>
    </div>
    
    <div class="content">
      <p class="message">
        <strong>Namaste!</strong>
      </p>
      
      <p class="message">
        You have requested to $purposeText. Use the following One-Time Password (OTP) to proceed:
      </p>
      
      <div class="otp-box">
        <div class="otp-code">$otp</div>
        <div class="otp-label">Your OTP Code</div>
      </div>
      
      <p class="message">
        This OTP is valid for <strong>10 minutes</strong>. Please do not share this code with anyone.
      </p>
      
      <div class="warning">
        <p><strong>⚠️ Security Notice:</strong></p>
        <p>If you did not request this OTP, please ignore this email. Your account is safe and no action is needed.</p>
      </div>
      
      <p class="message">
        Thank you for using Krashi Bandhu! 🙏
      </p>
    </div>
    
    <div class="footer">
      <p>© 2024 Krashi Bandhu - PMFBY Insurance Platform</p>
      <p>
        <a href="#">Help Center</a> | 
        <a href="#">Contact Support</a> | 
        <a href="#">Privacy Policy</a>
      </p>
      <p>Support: 14447 (Toll-Free) | WhatsApp: 7065514447</p>
    </div>
  </div>
</body>
</html>
    ''';
  }
}

/// OTP Data model
class OTPData {
  final String otp;
  final DateTime createdAt;
  final String purpose;

  OTPData({
    required this.otp,
    required this.createdAt,
    required this.purpose,
  });

  bool get isExpired {
    return DateTime.now().difference(createdAt) > EmailOTPService.otpValidity;
  }

  Duration get remainingValidity {
    final remaining = EmailOTPService.otpValidity - DateTime.now().difference(createdAt);
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
