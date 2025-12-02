// Enhanced Language Support for PMFBY App
// Supports 15 Indian Languages + English

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  
  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

class AppLanguages {
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'en', name: 'English', nativeName: 'English'),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    AppLanguage(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
    AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    AppLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    AppLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    AppLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    AppLanguage(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
    AppLanguage(code: 'as', name: 'Assamese', nativeName: 'অসমীয়া'),
    AppLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
    AppLanguage(code: 'sa', name: 'Sanskrit', nativeName: 'संस्कृतम्'),
    AppLanguage(code: 'raj', name: 'Rajasthani', nativeName: 'राजस्थानी'),
    AppLanguage(code: 'bho', name: 'Bhojpuri', nativeName: 'भोजपुरी'),
  ];
}

class AppStrings {
  // Navigation
  static const Map<String, Map<String, String>> navigation = {
    'home': {
      'en': 'Home',
      'hi': 'होम',
      'pa': 'ਘਰ',
      'mr': 'मुख्यपृष्ठ',
      'gu': 'હોમ',
      'ta': 'முகப்பு',
      'te': 'హోమ్',
      'kn': 'ಮುಖಪುಟ',
      'ml': 'ഹോം',
      'bn': 'হোম',
    },
    'claims': {
      'en': 'Claims',
      'hi': 'दावे',
      'pa': 'ਦਾਅਵੇ',
      'mr': 'दावे',
      'gu': 'દાવાઓ',
      'ta': 'உரிமைகோரல்கள்',
      'te': 'క్లెయిమ్స్',
      'kn': 'ಕ್ಲೈಮ್‌ಗಳು',
      'ml': 'ക്ലെയിമുകൾ',
      'bn': 'দাবি',
    },
    'overview': {
      'en': 'Overview',
      'hi': 'अवलोकन',
      'pa': 'ਅਵਲੋਕਨ',
      'mr': 'अवलोकन',
      'gu': 'વિહંગાવલોકન',
      'ta': 'மேலோட்டம்',
      'te': 'సారాంశం',
      'kn': 'ಅವಲೋಕನ',
      'ml': 'ഓവർവ്യൂ',
      'bn': 'সারসংক্ষেপ',
    },
    'analytics': {
      'en': 'Analytics',
      'hi': 'विश्लेषण',
      'pa': 'ਵਿਸ਼ਲੇਸ਼ਣ',
      'mr': 'विश्लेषण',
      'gu': 'વિશ્લેષણ',
      'ta': 'பகுப்பாய்வு',
      'te': 'విశ్లేషణ',
      'kn': 'ವಿಶ್ಲೇಷಣ',
      'ml': 'വിശകലനം',
      'bn': 'বিশ্লেষণ',
    },
    'reports': {
      'en': 'Reports',
      'hi': 'रिपोर्ट',
      'pa': 'ਰਿਪੋਰਟਾਂ',
      'mr': 'अहवाल',
      'gu': 'અહેવાલો',
      'ta': 'அறிக்கைகள்',
      'te': 'నివేదనలు',
      'kn': 'ವರದಿಗಳು',
      'ml': 'റിപ്പോർട്ടുകൾ',
      'bn': 'প্রতিবেদন',
    },
    'schemes': {
      'en': 'Schemes',
      'hi': 'योजनाएं',
      'pa': 'ਯੋਜਨਾਵਾਂ',
      'mr': 'योजना',
      'gu': 'યોજનાઓ',
      'ta': 'திட்டங்கள்',
      'te': 'పథకాలు',
      'kn': 'ಯೋಜನೆಗಳು',
      'ml': 'പദ്ധതികൾ',
      'bn': 'প্রকল্প',
    },
    'satellite': {
      'en': 'Satellite',
      'hi': 'उपग्रह',
      'pa': 'ਸੈਟੇਲਾਈਟ',
      'mr': 'उपग्रह',
      'gu': 'ઉપગ્રહ',
      'ta': 'செயற்கைக்கோள்',
      'te': 'ఉపగ్రహం',
      'kn': 'ಉಪಗ್ರಹ',
      'ml': 'ഉപഗ്രഹം',
      'bn': 'উপগ্রহ',
    },
    'profile': {
      'en': 'Profile',
      'hi': 'प्रोफाइल',
      'pa': 'ਪ੍ਰੋਫਾਈਲ',
      'mr': 'प्रोफाइल',
      'gu': 'પ્રોફાઇલ',
      'ta': 'சுயவிவரம்',
      'te': 'ప్రొఫైల్',
      'kn': 'ಪ್ರೊಫೈಲ್',
      'ml': 'പ്രൊഫൈൽ',
      'bn': 'প্রোফাইল',
    },
  };

  // Greetings
  static const Map<String, Map<String, String>> greetings = {
    'welcome': {
      'en': 'Welcome',
      'hi': 'नमस्ते',
      'pa': 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ',
      'mr': 'नमस्कार',
      'gu': 'નમસ્તે',
      'ta': 'வணக்கம்',
      'te': 'స్వాగతం',
      'kn': 'ಸ್ವಾಗತ',
      'ml': 'സ്വാഗതം',
      'bn': 'স্বাগতম',
    },
    'farmer': {
      'en': 'Farmer',
      'hi': 'किसान',
      'pa': 'ਕਿਸਾਨ',
      'mr': 'शेतकरी',
      'gu': 'ખેડૂત',
      'ta': 'விவசாயி',
      'te': 'రైతు',
      'kn': 'ರೈತ',
      'ml': 'കർഷകൻ',
      'bn': 'কৃষক',
    },
  };

  // Actions
  static const Map<String, Map<String, String>> actions = {
    'file_claim': {
      'en': 'File New Claim',
      'hi': 'नया दावा दर्ज करें',
      'pa': 'ਨਵਾਂ ਦਾਅਵਾ ਦਰਜ ਕਰੋ',
      'mr': 'नवीन दावा दाखल करा',
      'gu': 'નવો દાવો નોંધાવો',
      'ta': 'புதிய உரிமைகோரல் பதிவு செய்யவும்',
      'te': 'కొత్త క్లెయిమ్ దాఖలు చేయండి',
      'kn': 'ಹೊಸ ಕ್ಲೈಮ್ ಸಲ್ಲಿಸಿ',
      'ml': 'പുതിയ ക്ലെയിം ഫയൽ ചെയ്യുക',
      'bn': 'নতুন দাবি দাখিল করুন',
    },
    'view_status': {
      'en': 'View Status',
      'hi': 'स्थिति देखें',
      'pa': 'ਸਥਿਤੀ ਵੇਖੋ',
      'mr': 'स्थिती पहा',
      'gu': 'સ્થિતિ જુઓ',
      'ta': 'நிலையைப் பார்க்கவும்',
      'te': 'స్థితిని చూడండి',
      'kn': 'ಸ್ಥಿತಿ ನೋಡಿ',
      'ml': 'നില കാണുക',
      'bn': 'অবস্থা দেখুন',
    },
    'upload_photo': {
      'en': 'Upload Photo',
      'hi': 'फोटो अपलोड करें',
      'pa': 'ਫੋਟੋ ਅੱਪਲੋਡ ਕਰੋ',
      'mr': 'फोटो अपलोड करा',
      'gu': 'ફોટો અપલોડ કરો',
      'ta': 'புகைப்படம் பதிவேற்று',
      'te': 'ఫోటో అప్‌లోడ్ చేయండి',
      'kn': 'ಫೋಟೋ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ',
      'ml': 'ഫോട്ടോ അപ്‌ലോഡ് ചെയ്യുക',
      'bn': 'ফটো আপলোड করুন',
    },
    'change_language': {
      'en': 'Change Language',
      'hi': 'भाषा बदलें',
      'pa': 'ਭਾਸ਼ਾ ਬਦਲੋ',
      'mr': 'भाषा बदला',
      'gu': 'ભાષા બદલો',
      'ta': 'மொழியை மாற்றவும்',
      'te': 'భాషను మార్చండి',
      'kn': 'ಭಾಷೆ ಬದಲಾಯಿಸಿ',
      'ml': 'ഭാഷ മാറ്റുക',
      'bn': 'ভাষা পরিবর্তন করুন',
    },
    'select_language': {
      'en': 'Select your preferred language',
      'hi': 'अपनी पसंदीदा भाषा चुनें',
      'pa': 'ਆਪਣੀ ਪਸੰਦ ਦੀ ਭਾਸ਼ਾ ਚੁਣੋ',
      'mr': 'आपली पसंदीची भाषा निवडा',
      'gu': 'તમારી પસંદનો ભાષા પસંદ કરો',
      'ta': 'உங்கள் விரும்பிய மொழியைத் தேர்ந்தெடுக்கவும்',
      'te': 'మీ ఇష్ట భాషను ఎంచుకోండి',
      'kn': 'ನಿಮ್ಮ ಆದ್ಯತೆಯ ಭಾಷೆ ಆಯ್ಕೆ ಮಾಡಿ',
      'ml': 'നിങ്ങളുടെ ആഗ്രഹിച്ച ഭാഷ തിരഞ്ഞെടുക്കുക',
      'bn': 'আপনার পছন্দের ভাষা নির্বাচন করুন',
    },
  };

  // Status
  static const Map<String, Map<String, String>> status = {
    'approved': {
      'en': 'Approved',
      'hi': 'स्वीकृत',
      'pa': 'ਮਨਜ਼ੂਰ',
      'mr': 'मंजूर',
      'gu': 'મંજૂર',
      'ta': 'அங்கீகரிக்கப்பட்டது',
      'te': 'ఆమోదించబడింది',
      'kn': 'ಅನುಮೋದಿಸಲಾಗಿದೆ',
      'ml': 'അംഗീകരിച്ചു',
      'bn': 'অনুমোদিত',
    },
    'pending': {
      'en': 'Pending',
      'hi': 'लंबित',
      'pa': 'ਲੰਬਿਤ',
      'mr': 'प्रलंबित',
      'gu': 'બાકી',
      'ta': 'நிலுவையில்',
      'te': 'పెండింగ్',
      'kn': 'ಬಾಕಿ',
      'ml': 'തീർപ്പാക്കാത്തത്',
      'bn': 'মুলতুবি',
    },
    'rejected': {
      'en': 'Rejected',
      'hi': 'अस्वीकृत',
      'pa': 'ਅਸਵੀਕਾਰ',
      'mr': 'नाकारले',
      'gu': 'નકારી',
      'ta': 'நிராகரிக்கப்பட்டது',
      'te': 'తిరస్కరించబడింది',
      'kn': 'ತಿರಸ್ಕರಿಸಲಾಗಿದೆ',
      'ml': 'നിരസിച്ചു',
      'bn': 'প্রত্যাখ্যাত',
    },
  };

  // PMFBY Info
  static const Map<String, Map<String, String>> pmfbyInfo = {
    'scheme_name': {
      'en': 'Pradhan Mantri Fasal Bima Yojana',
      'hi': 'प्रधानमंत्री फसल बीमा योजना',
      'pa': 'ਪ੍ਰਧਾਨ ਮੰਤਰੀ ਫਸਲ ਬੀਮਾ ਯੋਜਨਾ',
      'mr': 'प्रधानमंत्री फसल विमा योजना',
      'gu': 'પ્રધાનમંત્રી ફસલ બીમા યોજના',
      'ta': 'பிரதம மந்திரி ஃபசல் பீமா யோஜனா',
      'te': 'ప్రధాన మంత్రి ఫసల్ బీమా యోజన',
      'kn': 'ಪ್ರಧಾನ ಮಂತ್ರಿ ಫಸಲ್ ಬೀಮಾ ಯೋಜನೆ',
      'ml': 'പ്രധാനമന്ത്രി ഫസൽ ബീമ യോജന',
      'bn': 'প্রধানমন্ত্রী ফসল বিমা যোজনা',
    },
    'helpline': {
      'en': 'Helpline',
      'hi': 'हेल्पलाइन',
      'pa': 'ਹੈਲਪਲਾਈਨ',
      'mr': 'हेल्पलाइन',
      'gu': 'હેલ્પલાઇન',
      'ta': 'உதவி எண்',
      'te': 'హెల్ప్‌లైన్',
      'kn': 'ಹೆಲ್ಪ್‌ಲೈನ್',
      'ml': 'ഹെൽപ്പ് ലൈൻ',
      'bn': 'হেল্পলাইন',
    },
  };

  // Helper method to get translation
  static String get(String category, String key, String languageCode) {
    final categoryMap = _getCategoryMap(category);
    if (categoryMap == null) return key;
    
    final translations = categoryMap[key];
    if (translations == null) return key;
    
    return translations[languageCode] ?? translations['en'] ?? key;
  }

  static Map<String, Map<String, String>>? _getCategoryMap(String category) {
    switch (category) {
      case 'navigation':
        return navigation;
      case 'greetings':
        return greetings;
      case 'actions':
        return actions;
      case 'status':
        return status;
      case 'pmfbyInfo':
        return pmfbyInfo;
      default:
        return null;
    }
  }
}
