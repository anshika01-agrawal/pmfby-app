/// Demo users for testing the application
/// These are hardcoded test accounts that bypass authentication
library;

class DemoUsers {
  // Farmer Test Accounts
  static const List<Map<String, String>> farmers = [
    {
      'name': 'Ramesh Patel',
      'phone': '9876543210',
      'email': 'ramesh@farmer.test',
      'password': 'test123',
      'role': 'farmer',
      'village': 'Khandala',
      'district': 'Nagpur',
      'state': 'Maharashtra',
    },
    {
      'name': 'Suresh Kumar',
      'phone': '9876543211',
      'email': 'suresh@farmer.test',
      'password': 'test123',
      'role': 'farmer',
      'village': 'Pipri',
      'district': 'Nagpur',
      'state': 'Maharashtra',
    },
    {
      'name': 'Anita Devi',
      'phone': '9876543212',
      'email': 'anita@farmer.test',
      'password': 'test123',
      'role': 'farmer',
      'village': 'Kamptee',
      'district': 'Nagpur',
      'state': 'Maharashtra',
    },
  ];

  // Officer Test Accounts
  static const List<Map<String, String>> officers = [
    {
      'name': 'Rahul Sharma',
      'phone': '9876543220',
      'email': 'rahul@officer.test',
      'password': 'admin123',
      'role': 'field_officer',
      'designation': 'Field Officer',
      'district': 'Nagpur',
    },
    {
      'name': 'Priya Singh',
      'phone': '9876543221',
      'email': 'priya@officer.test',
      'password': 'admin123',
      'role': 'admin',
      'designation': 'District Admin',
      'district': 'Nagpur',
    },
    {
      'name': 'Amit Verma',
      'phone': '9876543222',
      'email': 'amit@officer.test',
      'password': 'admin123',
      'role': 'data_annotator',
      'designation': 'Data Annotator',
      'district': 'Nagpur',
    },
  ];

  // Check if phone number belongs to a demo user
  static Map<String, String>? findByPhone(String phone) {
    // Remove +91 prefix if present
    final cleanPhone = phone.replaceAll('+91', '').trim();
    
    for (var farmer in farmers) {
      if (farmer['phone'] == cleanPhone) {
        return farmer;
      }
    }
    
    for (var officer in officers) {
      if (officer['phone'] == cleanPhone) {
        return officer;
      }
    }
    
    return null;
  }

  // Check if email belongs to a demo user
  static Map<String, String>? findByEmail(String email) {
    for (var farmer in farmers) {
      if (farmer['email'] == email) {
        return farmer;
      }
    }
    
    for (var officer in officers) {
      if (officer['email'] == email) {
        return officer;
      }
    }
    
    return null;
  }

  // Validate demo user credentials
  static bool validateCredentials(String emailOrPhone, String password) {
    final user = findByEmail(emailOrPhone) ?? findByPhone(emailOrPhone);
    return user != null && user['password'] == password;
  }

  // Get all demo phone numbers for reference
  static List<String> getAllPhones() {
    return [
      ...farmers.map((f) => f['phone']!),
      ...officers.map((o) => o['phone']!),
    ];
  }

  // Demo OTP (always valid for testing)
  static const String demoOTP = '123456';
  
  // Check if OTP is valid (for demo, always accept 123456)
  static bool isValidOTP(String otp) {
    return otp == demoOTP;
  }
}
