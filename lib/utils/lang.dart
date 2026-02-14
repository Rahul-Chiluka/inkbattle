class AppLocalizations {
  static Function()? _onLanguageChanged;

  static void setOnLanguageChanged(Function() callback) {
    _onLanguageChanged = callback;

  
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Guest Signup & Profile
      'enter_username': 'Enter username',
      'language': 'Language',
      'country': 'Country',
      'save': 'Save',
      'skip': 'Skip',
      'next': 'Next',
      'please_fill_all_fields': 'Please fill all fields',
      'coins': 'Coins',
      'welcome': 'Welcome',

      // Home Screen
      'home': 'Home',
      'play': 'Play',
      'profile': 'Profile',
      'settings': 'Settings',
      'leaderboard': 'Leaderboard',
      'friends': 'Friends',
      'shop': 'Shop',
      'daily_bonus': 'Daily Bonus',
      'claim': 'Claim',
      'claimed': 'Claimed',

      // Multiplayer Screen
      'multiplayer': 'Multiplayer',
      'create_room': 'Create Room',
      'join_room': 'Join Room',
      'room_code': 'Room Code',
      'join': 'Join',
      'players': 'Players',
      'waiting_for_players': 'Waiting for players...',
      'start_game': 'Start Game',
      'leave': 'Leave',
      'mode': 'Mode',
      'individual': 'Individual',
      'team': 'Team',
      'language_filter': 'Language',
      'points': 'Points',
      'category': 'Category',
      'all': 'All',

      // Game Room Screen
      'game_room': 'Game Room',
      'gameplay': 'Gameplay',
      'drawing': 'Drawing',
      'guessing': 'Guessing',
      'selecting_drawer': 'Selecting Drawer...',
      'choosing_word': 'Choose a word!',
      'drawer_is_choosing': 'Drawer is choosing...',
      'draw': 'Draw',
      'guess_the_word': 'Guess The Word',
      'word_was': 'Word was',
      'next_round_starting': 'Next round starting...',
      'time_up': 'Time Up!',
      'well_done': 'Well Done!',
      'whos_next': "Who's Next?",
      'interval': 'Interval',
      'host': 'Host',
      'you': 'You',
      'correct': 'Correct!',
      'good_job': 'Good Job!',
      'chat': 'Chat',
      'send': 'Send',
      'type_message': 'Type a message...',
      'answers_chat': 'Answers Chat',
      'general_chat': 'General Chat',
      'team_chat': 'Team Chat',

      // Room Preferences Screen
      'room_preferences': 'Room Preferences',
      'select_language': 'Select Language',
      'select_points': 'Select Points',
      'select_category': 'Select Category',
      'voice_enabled': 'Voice Enabled',
      'select_team': 'Select Team',
      'team_selection': 'Team Selection',
      'blue_team': 'Blue Team',
      'orange_team': 'Orange Team',

      // Profile & Settings
      'edit_profile': 'Edit Profile',
      'profile_and_accounts': 'Profile & Account',
      'username': 'Username',
      'email': 'Email',
      'phone': 'Phone',
      'logout': 'Logout',
      'delete_account': 'Delete Account',
      'version': 'Version',
      'about': 'About',
      'privacy_policy': 'Privacy Policy',
      'terms_and_conditions': 'Terms & Conditions',
      'sound': 'Sound',
      'privacy_and_safety': 'Privacy & Safety',
      'contact': 'Contact',
      'rate_app': 'Rate App',
      'connect_us_at': 'CONNECT US AT',
      'are_you_sure_logout': 'Are you sure you want to logout?',
      'loading_ads': 'Loading ads...',

      // Sign In
      'ink_battle': 'Ink Battle',
      'sign_in_with_google': 'Sign in with Google',
      'sign_in_with_facebook': 'Sign in with Facebook',
      'signing_in': 'Signing in...',
      'or': 'Or',
      'play_as_guest': 'Play as a Guest',
      'progress_not_saved': 'Progress may not be saved',

      // Home Screen
      'play_random': 'Play Random',

      // Instructions
      'instructions': 'Instructions',
      'tutorial_guide': 'Tutorial Guide',
      'instructions_text':
          'Tap the screen to start your game adventure! Use the arrows to navigate through levels. Collect coins by completing challenges. Avoid obstacles to keep your score high. Switch modes for a different experience.',

      // Common
      'ok': 'OK',
      'cancel': 'Cancel',
      'yes': 'Yes',
      'no': 'No',
      'confirm': 'Confirm',
      'back': 'Back',
      'close': 'Close',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Info',

      // Messages
      'insufficient_coins': 'Insufficient Coins',
      'room_full': 'Room is Full',
      'room_not_found': 'Room Not Found',
      'already_in_room': 'Already in Room',
      'connection_lost': 'Connection Lost',
      'reconnecting': 'Reconnecting...',
      'connected': 'Connected',
      'disconnected': 'Disconnected',

      // Languages
      'hindi': 'Hindi',
      'telugu': 'Telugu',
      'english': 'English',

      // Countries
      'india': 'India',
      'usa': 'USA',
      'uk': 'UK',
      'japan': 'Japan',
      'spain': 'Spain',
      'portugal': 'Portugal',
      'france': 'France',
      'germany': 'Germany',
      'russia': 'Russia',

      // New keys
      'username_required': 'Username is required for signup.',
      'google_sign_in_failed': 'Google sign-in failed. Please try again.',
      'facebook_sign_in_failed': 'Facebook sign-in failed. Please try again.',
      'sign_in_error': 'Error',
      'word_theme': 'Word Theme',
      'word_script': 'Word Script',
      'game_play': 'Game Play',
      'voice': 'Voice',
      'public': 'Public',
      'copied': 'Copied',
      'please_fill_all_details': 'Please fill all details',
      'lets_go_room_live': "Let's go! Room is live",
      'enter_room_code': 'Enter the room code shared by your friend',
      'select_your_team': 'Select Your Team',
      'team_a': 'Team A',
      'team_b': 'Team B',
      'insufficient_coins_join':
          'Insufficient coins! You need coins to join this room.',
      'failed_to_join_room': 'Failed to join room',
      'successfully_joined_room': 'Successfully joined room!',
      'wrong': 'Wrong',
      'break_word': 'Break Word',
      'alternate': 'Alternate',
      'its_drawing_time': 'It’s drawing time, let’s rock! 🔥',
      'missed_their_turn': 'Missed Their Turn',
      'leaderboard_updates': 'Leaderboard updates as more players join.',
      'no_players_yet': 'No players yet.',
      'private': 'Private',
      'skip_turn': 'SKIP TURN',
      'are_you_sure_skip': "Are You Sure ? The Fun's just starting! :(",
      'yes_sad': 'Yes 😢',
      'no_cool': 'NO 😎',
      'oops_time_up': '😢 Oops! Time’s Up!',
      'good_job_clap': '👏 Good Job!',
      'well_done_party': '🎉 Well Done!!!',
      'teammates_guessed': 'teammates guessed !',
      'participants_guessed': 'participants guessed !',
      'oops': 'Oops!!',
      'almost_had_it': 'Almost had it… but time’s up!',
      'tough_round': 'Tough Round!',
      'no_one_cracked_it': 'No one cracked it this time. ',
      'lets_try_next': 'Let’s try the next one!',
      'close_call': 'Close Call!!',
      'few_sharp_eyes': 'A few sharp eyes caught it! ',
      'almost_there_team': 'Almost there, team!',
      'keep_it_up': 'Keep it up,',
      'artist_of_the_team': 'artist of the team ! ',
      'voice_chat_not_enabled': 'Voice chat is not enabled in this room',
      'only_drawer_can_send': 'Only the drawer can send these messages.',
      'message_label': 'Message :',
      'select': 'Select',
      'answers_chat_instruction':
          "Type your answers here. If you're correct, it will be marked in green",
      'correct_lower': 'correct',
      'type_answers_here': 'Type your answers here...',
      'correct_answer_party': 'Correct answer 🥳',
      'general_chat_welcome':
          'Welcome! This is your general \nchat area. Type below to start!',
      'type_anything': 'Type anything...',

      // Create Room & Join Room
      'please_enter_room_name': 'Please enter a room name',
      'failed_to_create_room': 'Failed to create room',
      'code_copied_clipboard': 'Code copied to clipboard!',
      'room_created': 'Room Created!',
      'share_code_with_friends': 'Share this code with your friends:',
      'enter_room': 'Enter Room',
      'create_room_configure_lobby':
          'Create a room and configure settings in the lobby',
      'enter_room_name_hint': 'Enter room name',
      'room_code_share_info':
          "You'll be able to share the room code with friends after creation",
      'create_team_room': 'Create Team Room',
      'please_check_code': 'Please check the code and try again.',

      // Random Match Screen
      'random_match': 'Random Match',
      'select_target_points': 'Select Target Points',
      'play_random_coins': 'Play Random (250 Coins)',
      'please_select_all_fields':
          'Please select all fields including Target Points',
      'failed_to_find_match': 'Failed to find match',
      'watch_ads_coming_soon': 'Watch ads feature coming soon!',
      'buy_coins_coming_soon': 'Buy coins feature coming soon!',
      'buy': 'Buy',
      'script': 'Script',
      'insufficient_coins_title': 'Insufficient Coins',
      'insufficient_coins_message':
          "You don't have enough coins to join. Watch ads or buy coins to continue playing.",
      'watch_ads': 'Watch Ads',
      'buy_coins': 'Buy Coins',
      'no_rooms_available': 'No Rooms Available',
      'select_all_filters_to_view_rooms': 'Select all filters to view rooms',
      'one_category_selected': '1 category selected',
      'categories_selected': 'categories selected',
      'no_matches_found': 'No Matches Found',
      'no_matches_message':
          'No public rooms match your preferences. Try different settings or create a new room.',
      'try_again': 'Try Again',

      'selected': 'selected',   
      'team_a_is_full': 'Team A is full',
      'team_b_is_full': 'Team B is full',
      'please_select_the_other_team': 'Please select the other team.',
      // --- Categories ---
      'animals': 'Animals',
      'countries': 'Countries',
      'everyday_objects': 'Everyday Objects',
      'food': 'Food',
      'historical_events': 'Historical Events',
      'movies': 'Movies',

    },
    'hi': {
      // Guest Signup & Profile
      'enter_username': 'उपयोगकर्ता नाम दर्ज करें',
      'language': 'भाषा',
      'country': 'देश',
      'save': 'सहेजें',
      'skip': 'छोड़ें',
      'next': 'अगला',
      'please_fill_all_fields': 'कृपया सभी फ़ील्ड भरें',
      'coins': 'सिक्के',
      'welcome': 'स्वागत है',

      // Home Screen
      'home': 'होम',
      'play': 'खेलें',
      'profile': 'प्रोफ़ाइल',
      'settings': 'सेटिंग्स',
      'leaderboard': 'लीडरबोर्ड',
      'friends': 'दोस्त',
      'shop': 'दुकान',
      'daily_bonus': 'दैनिक बोनस',
      'claim': 'दावा करें',
      'claimed': 'दावा किया',

      // Multiplayer Screen
      'multiplayer': 'मल्टीप्लेयर',
      'create_room': 'रूम बनाएं',
      'join_room': 'रूम में शामिल हों',
      'room_code': 'रूम कोड',
      'join': 'शामिल हों',
      'players': 'खिलाड़ी',
      'waiting_for_players': 'खिलाड़ियों की प्रतीक्षा...',
      'start_game': 'खेल शुरू करें',
      'leave': 'छोड़ें',
      'mode': 'मोड',
      'individual': 'व्यक्तिगत',
      'team': 'टीम',
      'language_filter': 'भाषा',
      'points': 'अंक',
      'category': 'श्रेणी',
      'all': 'सभी',

      // Game Room Screen
      'game_room': 'गेम रूम',
      'gameplay': 'गेमप्ले',
      'drawing': 'ड्राइंग',
      'guessing': 'अनुमान',
      'selecting_drawer': 'ड्रॉअर चयन...',
      'choosing_word': 'एक शब्द चुनें!',
      'drawer_is_choosing': 'ड्रॉअर चुन रहा है...',
      'draw': 'ड्रा करें',
      'guess_the_word': 'शब्द का अनुमान लगाएं',
      'word_was': 'शब्द था',
      'next_round_starting': 'अगला राउंड शुरू हो रहा है...',
      'time_up': 'समय समाप्त!',
      'well_done': 'बहुत अच्छे!',
      'whos_next': 'अगला कौन?',
      'interval': 'अंतराल',
      'host': 'होस्ट',
      'you': 'आप',
      'correct': 'सही!',
      'good_job': 'अच्छा काम!',
      'chat': 'चैट',
      'send': 'भेजें',
      'type_message': 'एक संदेश टाइप करें...',
      'answers_chat': 'उत्तर चैट',
      'general_chat': 'सामान्य चैट',
      'team_chat': 'टीम चैट',

      // Room Preferences Screen
      'room_preferences': 'रूम प्राथमिकताएं',
      'select_language': 'भाषा चुनें',
      'select_points': 'अंक चुनें',
      'select_category': 'श्रेणी चुनें',
      'voice_enabled': 'आवाज सक्षम',
      'select_team': 'टीम चुनें',
      'team_selection': 'टीम चयन',
      'blue_team': 'नीली टीम',
      'orange_team': 'नारंगी टीम',

      // Profile & Settings
      'edit_profile': 'प्रोफ़ाइल संपादित करें',
      'profile_and_accounts': 'प्रोफ़ाइल और खाते',
      'sound': 'ध्वनि',
      'privacy_and_safety': 'गोपनीयता और सुरक्षा',
      'contact': 'संपर्क',
      'rate_app': 'ऐप रेट करें',
      'connect_us_at': 'हमसे जुड़ें',
      'are_you_sure_logout': 'क्या आप वाकई लॉगआउट करना चाहते हैं?',
      'loading_ads': 'विज्ञापन लोड हो रहे हैं...',

      // Sign In
      'ink_battle': 'इंक बैटल',
      'sign_in_with_google': 'Google से साइन इन करें',
      'sign_in_with_facebook': 'Facebook से साइन इन करें',
      'signing_in': 'साइन इन हो रहा है...',
      'or': 'या',
      'play_as_guest': 'अतिथि के रूप में खेलें',
      'progress_not_saved': 'प्रगति सहेजी नहीं जा सकती',

      // Home Screen
      'play_random': 'रैंडम खेलें',

      // Instructions
      'instructions': 'निर्देश',
      'tutorial_guide': 'ट्यूटोरियल गाइड',
      'instructions_text':
          'अपना गेम एडवेंचर शुरू करने के लिए स्क्रीन पर टैप करें! लेवल के माध्यम से नेविगेट करने के लिए तीरों का उपयोग करें। चुनौतियों को पूरा करके सिक्के इकट्ठा करें। अपने स्कोर को उच्च रखने के लिए बाधाओं से बचें। एक अलग अनुभव के लिए मोड बदलें।',

      // Common
      'username': 'उपयोगकर्ता नाम',
      'email': 'ईमेल',
      'phone': 'फ़ोन',
      'logout': 'लॉगआउट',
      'delete_account': 'खाता हटाएं',
      'version': 'संस्करण',
      'about': 'के बारे में',
      'privacy_policy': 'गोपनीयता नीति',
      'terms_and_conditions': 'नियम और शर्तें',

      // Common
      'ok': 'ठीक है',
      'cancel': 'रद्द करें',
      'yes': 'हाँ',
      'no': 'नहीं',
      'confirm': 'पुष्टि करें',
      'back': 'वापस',
      'close': 'बंद करें',
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'success': 'सफलता',
      'warning': 'चेतावनी',
      'info': 'जानकारी',

      // Messages
      'insufficient_coins': 'अपर्याप्त सिक्के',
      'room_full': 'रूम भरा हुआ है',
      'room_not_found': 'रूम नहीं मिला',
      'already_in_room': 'पहले से रूम में है',
      'connection_lost': 'कनेक्शन टूट गया',
      'reconnecting': 'पुनः कनेक्ट हो रहा है...',
      'connected': 'कनेक्ट हो गया',
      'disconnected': 'डिस्कनेक्ट हो गया',

      // Languages
      'hindi': 'हिंदी',
      'telugu': 'तेलुगु',
      'english': 'अंग्रेज़ी',

      // Countries
      'india': 'भारत',
      'usa': 'अमेरिका',
      'uk': 'यूके',
      'japan': 'जापान',
      'spain': 'स्पेन',
      'portugal': 'पुर्तगाल',
      'france': 'फ्रांस',
      'germany': 'जर्मनी',
      'russia': 'रूसिया',

      // Create Room & Join Room
      'please_enter_room_name': 'कृपया रूम का नाम दर्ज करें',
      'failed_to_create_room': 'रूम बनाने में विफल',
      'code_copied_clipboard': 'कोड क्लिपबोर्ड पर कॉपी किया गया!',
      'room_created': 'रूम बनाया गया!',
      'share_code_with_friends': 'इस कोड को अपने दोस्तों के साथ साझा करें:',
      'enter_room': 'रूम में प्रवेश करें',
      'create_room_configure_lobby':
          'एक रूम बनाएं और लॉबी में सेटिंग्स कॉन्फ़िगर करें',
      'enter_room_name_hint': 'रूम का नाम दर्ज करें',
      'room_code_share_info':
          'आप रूम बनाने के बाद दोस्तों के साथ रूम कोड साझा कर सकेंगे',
      'create_team_room': 'टीम रूम बनाएं',
      'please_check_code': 'कृपया कोड जांचें और पुनः प्रयास करें।',

      // Random Match Screen
      'random_match': 'रैंडम मैच',
      'select_target_points': 'लक्ष्य अंक चुनें',
      'play_random_coins': 'रैंडम खेलें (250 सिक्के)',
      'please_select_all_fields': 'कृपया लक्ष्य अंक सहित सभी फ़ील्ड चुनें',
      'failed_to_find_match': 'मैच खोजने में विफल',
      'watch_ads_coming_soon': 'विज्ञापन देखने की सुविधा जल्द आ रही है!',
      'buy_coins_coming_soon': 'सिक्के खरीदने की सुविधा जल्द आ रही है!',
      'insufficient_coins_title': 'अपर्याप्त सिक्के',
      'insufficient_coins_message':
          'आपके पास शामिल होने के लिए पर्याप्त सिक्के नहीं हैं। खेलना जारी रखने के लिए विज्ञापन देखें या सिक्के खरीदें।',
      'watch_ads': 'विज्ञापन देखें',
      'buy_coins': 'सिक्के खरीदें',
      'no_matches_found': 'कोई मैच नहीं मिला',
      'no_matches_message':
          'कोई सार्वजनिक रूम आपकी प्राथमिकताओं से मेल नहीं खाता। विभिन्न सेटिंग्स आज़माएं या नया रूम बनाएं।',
      'try_again': 'पुनः प्रयास करें',
      'selected': 'चुना गया',
      'team_a_is_full': 'टीम A भर चुकी है',
      'team_b_is_full': 'टीम B भर चुकी है',
      'please_select_the_other_team': 'कृपया दूसरी टीम चुनें',

      'animals': 'जानवर',
      'countries': 'देश',
      'food': 'भोजन',
      'everyday_objects': 'रोजमर्रा वस्तुएं',
      'historical_events': 'ऐतिहासिक घटनाएं',
      'movies': 'चलचित्र',
    },
    'te': {
      // Guest Signup & Profile
      'enter_username': 'యూజర్ పేరు నమోదు చేయండి',
      'language': 'భాష',
      'country': 'దేశం',
      'save': 'సేవ్ చేయండి',
      'skip': 'దాటవేయండి',
      'next': 'తర్వాత',
      'please_fill_all_fields': 'దయచేసి అన్ని ఫీల్డ్‌లను పూరించండి',
      'coins': 'నాణేలు',
      'welcome': 'స్వాగతం',

      // Home Screen
      'home': 'హోమ్',
      'play': 'ఆడండి',
      'profile': 'ప్రొఫైల్',
      'settings': 'సెట్టింగ్‌లు',
      'leaderboard': 'లీడర్‌బోర్డ్',
      'friends': 'స్నేహితులు',
      'shop': 'షాప్',
      'daily_bonus': 'రోజువారీ బోనస్',
      'claim': 'క్లెయిమ్ చేయండి',
      'claimed': 'క్లెయిమ్ చేసారు',

      // Multiplayer Screen
      'multiplayer': 'మల్టీప్లేయర్',
      'create_room': 'గది సృష్టించండి',
      'join_room': 'గదిలో చేరండి',
      'room_code': 'గది కోడ్',
      'join': 'చేరండి',
      'players': 'ఆటగాళ్ళు',
      'waiting_for_players': 'ఆటగాళ్ళ కోసం వేచి ఉంది...',
      'start_game': 'ఆట ప్రారంభించండి',
      'leave': 'వదిలివెళ్ళండి',
      'mode': 'మోడ్',
      'individual': 'వ్యక్తిగత',
      'team': 'టీమ్',
      'language_filter': 'భాష',
      'points': 'పాయింట్లు',
      'category': 'వర్గం',
      'all': 'అన్నీ',

      // Game Room Screen
      'game_room': 'గేమ్ గది',
      'gameplay': 'గేమ్‌ప్లే',
      'drawing': 'డ్రాయింగ్',
      'guessing': 'ఊహించడం',
      'selecting_drawer': 'డ్రాయర్ ఎంపిక...',
      'choosing_word': 'ఒక పదాన్ని ఎంచుకోండి!',
      'drawer_is_choosing': 'డ్రాయర్ ఎంచుకుంటున్నారు...',
      'draw': 'డ్రా చేయండి',
      'guess_the_word': 'పదాన్ని ఊహించండి',
      'word_was': 'పదం',
      'next_round_starting': 'తదుపరి రౌండ్ ప్రారంభమవుతోంది...',
      'time_up': 'సమయం అయిపోయింది!',
      'well_done': 'బాగా చేసారు!',
      'whos_next': 'తర్వాత ఎవరు?',
      'interval': 'విరామం',
      'host': 'హోస్ట్',
      'you': 'మీరు',
      'correct': 'సరైనది!',
      'good_job': 'మంచి పని!',
      'chat': 'చాట్',
      'send': 'పంపండి',
      'type_message': 'సందేశం టైప్ చేయండి...',
      'answers_chat': 'సమాధానాల చాట్',
      'general_chat': 'సాధారణ చాట్',
      'team_chat': 'టీమ్ చాట్',

      // Room Preferences Screen
      'room_preferences': 'గది ప్రాధాన్యతలు',
      'select_language': 'భాష ఎంచుకోండి',
      'select_points': 'పాయింట్లు ఎంచుకోండి',
      'select_category': 'వర్గం ఎంచుకోండి',
      'voice_enabled': 'వాయిస్ ప్రారంభించబడింది',
      'select_team': 'టీమ్ ఎంచుకోండి',
      'team_selection': 'టీమ్ ఎంపిక',
      'blue_team': 'నీలం టీమ్',
      'orange_team': 'నారింజ టీమ్',

      // Profile & Settings
      'edit_profile': 'ప్రొఫైల్ సవరించండి',
      'profile_and_accounts': 'ప్రొఫైల్ మరియు ఖాతాలు',
      'sound': 'ధ్వని',
      'privacy_and_safety': 'గోప్యత & భద్రత',
      'contact': 'సంప్రదించండి',
      'rate_app': 'యాప్ రేట్ చేయండి',
      'connect_us_at': 'మాతో కనెక్ట్ అవ్వండి',
      'are_you_sure_logout': 'మీరు ఖచ్చితంగా లాగ్అవుట్ చేయాలనుకుంటున్నారా?',
      'loading_ads': 'ప్రకటనలు లోడ్ అవుతున్నాయి...',

      // Sign In
      'ink_battle': 'ఇంక్ బ్యాటిల్',
      'sign_in_with_google': 'Google తో సైన్ ఇన్ చేయండి',
      'sign_in_with_facebook': 'Facebook తో సైన్ ఇన్ చేయండి',
      'signing_in': 'సైన్ ఇన్ అవుతోంది...',
      'or': 'లేదా',
      'play_as_guest': 'అతిథిగా ఆడండి',
      'progress_not_saved': 'పురోగతి సేవ్ కాకపోవచ్చు',

      // Home Screen
      'play_random': 'రాండమ్ ఆడండి',

      // Instructions
      'instructions': 'సూచనలు',
      'tutorial_guide': 'ట్యుటోరియల్ గైడ్',
      'instructions_text':
          'మీ గేమ్ అడ్వెంచర్ ప్రారంభించడానికి స్క్రీన్‌పై ట్యాప్ చేయండి! లెవెల్స్ ద్వారా నావిగేట్ చేయడానికి బాణాలను ఉపయోగించండి. సవాళ్లను పూర్తి చేయడం ద్వారా నాణేలు సేకరించండి. మీ స్కోర్‌ను ఎక్కువగా ఉంచడానికి అడ్డంకులను తప్పించండి. వేరే అనుభవం కోసం మోడ్‌లను మార్చండి.',

      // Common
      'username': 'యూజర్ పేరు',
      'email': 'ఇమెయిల్',
      'phone': 'ఫోన్',
      'logout': 'లాగ్అవుట్',
      'delete_account': 'ఖాతా తొలగించండి',
      'version': 'సంస్కరణ',
      'about': 'గురించి',
      'privacy_policy': 'గోప్యతా విధానం',
      'terms_and_conditions': 'నియమాలు మరియు షరతులు',

      // Common
      'ok': 'సరే',
      'cancel': 'రద్దు చేయండి',
      'yes': 'అవును',
      'no': 'కాదు',
      'confirm': 'నిర్ధారించండి',
      'back': 'వెనుకకు',
      'close': 'మూసివేయండి',
      'loading': 'లోడ్ అవుతోంది...',
      'error': 'లోపం',
      'success': 'విజయం',
      'warning': 'హెచ్చరిక',
      'info': 'సమాచారం',

      // Messages
      'insufficient_coins': 'తగినంత నాణేలు లేవు',
      'room_full': 'గది నిండిపోయింది',
      'room_not_found': 'గది కనుగొనబడలేదు',
      'already_in_room': 'ఇప్పటికే గదిలో ఉన్నారు',
      'connection_lost': 'కనెక్షన్ కోల్పోయింది',
      'reconnecting': 'మళ్లీ కనెక్ట్ అవుతోంది...',
      'connected': 'కనెక్ట్ అయింది',
      'disconnected': 'డిస్‌కనెక్ట్ అయింది',

      // Languages
      'hindi': 'హిందీ',
      'telugu': 'తెలుగు',
      'english': 'ఇంగ్లీష్',

      // Countries
      'india': 'భారతదేశం',
      'usa': 'USA',
      'uk': 'UK',
      'japan': 'జపాన్',
      'spain': 'స్పేన్',
      'portugal': 'పోర్చుగల్',
      'france': 'ఫ్రాన్స్',
      'germany': 'జర్మనీ',
      'russia': 'రషియా',

      // Create Room & Join Room
      'please_enter_room_name': 'దయచేసి గది పేరును నమోదు చేయండి',
      'failed_to_create_room': 'గది సృష్టించడం విఫలమైంది',
      'code_copied_clipboard': 'కోడ్ క్లిప్‌బోర్డ్‌కి కాపీ చేయబడింది!',
      'room_created': 'గది సృష్టించబడింది!',
      'share_code_with_friends': 'ఈ కోడ్‌ని మీ స్నేహితులతో పంచుకోండి:',
      'enter_room': 'గదిలోకి ప్రవేశించండి',
      'create_room_configure_lobby':
          'గదిని సృష్టించండి మరియు లాబీలో సెట్టింగ్‌లను కాన్ఫిగర్ చేయండి',
      'enter_room_name_hint': 'గది పేరును నమోదు చేయండి',
      'room_code_share_info':
          'మీరు గది సృష్టించిన తర్వాత స్నేహితులతో గది కోడ్‌ను పంచుకోగలరు',
      'create_team_room': 'టీమ్ గది సృష్టించండి',
      'please_check_code': 'దయచేసి కోడ్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.',

      // Random Match Screen
      'random_match': 'రాండమ్ మ్యాచ్',
      'select_target_points': 'లక్ష్య పాయింట్లను ఎంచుకోండి',
      'play_random_coins': 'రాండమ్ ఆడండి (250 నాణేలు)',
      'please_select_all_fields':
          'దయచేసి లక్ష్య పాయింట్లతో సహా అన్ని ఫీల్డ్‌లను ఎంచుకోండి',
      'failed_to_find_match': 'మ్యాచ్ కనుగొనడంలో విఫలమైంది',
      'watch_ads_coming_soon': 'ప్రకటనలు చూసే ఫీచర్ త్వరలో వస్తోంది!',
      'buy_coins_coming_soon': 'నాణేలు కొనుగోలు ఫీచర్ త్వరలో వస్తోంది!',
      'insufficient_coins_title': 'తగినంత నాణేలు లేవు',
      'insufficient_coins_message':
          'మీకు చేరడానికి తగినంత నాణేలు లేవు. ఆటను కొనసాగించడానికి ప్రకటనలు చూడండి లేదా నాణేలు కొనండి।',
      'watch_ads': 'ప్రకటనలు చూడండి',
      'buy_coins': 'నాణేలు కొనండి',
      'no_matches_found': 'మ్యాచ్‌లు కనుగొనబడలేదు',
      'no_matches_message':
          'మీ ప్రాధాన్యతలకు పబ్లిక్ గదులు సరిపోలలేదు। వేర్వేరు సెట్టింగ్‌లను ప్రయత్నించండి లేదా కొత్త గదిని సృష్టించండి.',
      'try_again': 'మళ్లీ ప్రయత్నించండి',
      'selected': 'ఎంచుకోబడింది',
      'team_a_is_full': 'టీమ్ A పూర్తిగా నిండిపోయింది',
      'team_b_is_full': 'టీమ్ B పూర్తిగా నిండిపోయింది',
      'please_select_the_other_team': 'దయచేసి మరో టీమ్‌ను ఎంచుకోండి',
      
      'animals': 'జనవర్త్త',
      'countries': 'దేశాలు',
      'food': 'భోజనం',
      'everyday_objects': 'రోజరామర్వత్తులు',
      'historical_events': 'ఇతిహాసిక ఘటనలు',
      'movies': 'చలనవీక్షణలు',
    },
    'ta': {
      // Guest Signup & Profile
      'enter_username': 'பயனர்பெயரை உள்ளிடவும்',
      'language': 'மொழி',
      'country': 'நாடு',
      'save': 'சேமி',
      'skip': 'தவிர்',
      'next': 'அடுத்து',
      'please_fill_all_fields': 'அனைத்து விவரங்களையும் நிரப்பவும்',
      'coins': 'நாணயங்கள்',
      'welcome': 'வரவேற்கிறோம்',

      // Home Screen
      'home': 'முகப்பு',
      'play': 'விளையாடு',
      'profile': 'சுயவிவரம்',
      'settings': 'அமைப்புகள்',
      'leaderboard': 'தரவரிசை',
      'friends': 'நண்பர்கள்',
      'shop': 'கடை',
      'daily_bonus': 'தினசரி போனஸ்',
      'claim': 'பெறு',
      'claimed': 'பெறப்பட்டது',

      // Multiplayer Screen
      'multiplayer': 'மல்டிபிளேயர்',
      'create_room': 'அறையை உருவாக்கு',
      'join_room': 'அறையில் சேர்',
      'room_code': 'அறை குறியீடு',
      'join': 'சேர்',
      'players': 'வீரர்கள்',
      'waiting_for_players': 'வீரர்களுக்காக காத்திருக்கிறது...',
      'start_game': 'ஆட்டத்தைத் தொடங்கு',
      'leave': 'வெளியேறு',
      'mode': 'முறை',
      'individual': 'தனிநபர்',
      'team': 'குழு',
      'language_filter': 'மொழி',
      'points': 'புள்ளிகள்',
      'category': 'வகை',
      'all': 'அனைத்தும்',

      // Game Room Screen
      'game_room': 'விளையாட்டு அறை',
      'gameplay': 'விளையாட்டு முறை',
      'drawing': 'வரைதல்',
      'guessing': 'கணித்தல்',
      'selecting_drawer': 'வரைபவரைத் தேர்ந்தெடுக்கிறது...',
      'choosing_word': 'ஒரு வார்த்தையைத் தேர்ந்தெடு!',
      'drawer_is_choosing': 'வரைபவர் தேர்ந்தெடுக்கிறார்...',
      'draw': 'வரையவும்',
      'guess_the_word': 'வார்த்தையைக் கண்டுபிடி',
      'word_was': 'வார்த்தை',
      'next_round_starting': 'அடுத்த சுற்று தொடங்குகிறது...',
      'time_up': 'நேரம் முடிந்தது!',
      'well_done': 'நன்று!',
      'whos_next': 'அடுத்து யார்?',
      'interval': 'இடைவேளை',
      'host': 'தொகுப்பாளர்',
      'you': 'நீங்கள்',
      'correct': 'சரி!',
      'good_job': 'நன்று!',
      'chat': 'அரட்டை',
      'send': 'அனுப்பு',
      'type_message': 'செய்தியைத் தட்டச்சு செய்யவும்...',
      'answers_chat': 'பதில்கள் அரட்டை',
      'general_chat': 'பொது அரட்டை',
      'team_chat': 'குழு அரட்டை',

      // Room Preferences Screen
      'room_preferences': 'அறை விருப்பங்கள்',
      'select_language': 'மொழியைத் தேர்ந்தெடு',
      'select_points': 'புள்ளிகளைத் தேர்ந்தெடு',
      'select_category': 'வகையைத் தேர்ந்தெடு',
      'voice_enabled': 'குரல் இயக்கப்பட்டது',
      'select_team': 'குழுவைத் தேர்ந்தெடு',
      'team_selection': 'குழுத் தேர்வு',
      'blue_team': 'நீல குழு',
      'orange_team': 'ஆரஞ்சு குழு',

      // Profile & Settings
      'edit_profile': 'சுயவிவரத்தைத் திருத்து',
      'profile_and_accounts': 'சுயவிவரம் மற்றும் கணக்கு',
      'username': 'பயனர்பெயர்',
      'email': 'மின்னஞ்சல்',
      'phone': 'தொலைபேசி',
      'logout': 'வெளியேறு',
      'delete_account': 'கணக்கை நீக்கு',
      'version': 'பதிப்பு',
      'about': 'பற்றி',
      'privacy_policy': 'தனியுரிமைக் கொள்கை',
      'terms_and_conditions': 'விதிமுறைகள் மற்றும் நிபந்தனைகள்',
      'sound': 'ஒலி',
      'privacy_and_safety': 'தனியுரிமை மற்றும் பாதுகாப்பு',
      'contact': 'தொடர்பு',
      'rate_app': 'பயன்பாட்டை மதிப்பிடு',
      'connect_us_at': 'எங்களுடன் இணையுங்கள்',
      'are_you_sure_logout': 'நீங்கள் நிச்சயமாக வெளியேற விரும்புகிறீர்களா?',
      'loading_ads': 'விளம்பரங்கள் ஏற்றப்படுகின்றன...',

      // Sign In
      'ink_battle': 'இங்க் பேட்டில்',
      'sign_in_with_google': 'Google மூலம் உள்நுழையவும்',
      'sign_in_with_facebook': 'Facebook மூலம் உள்நுழையவும்',
      'signing_in': 'உள்நுழைகிறது...',
      'or': 'அல்லது',
      'play_as_guest': 'விருந்தினராக விளையாடு',
      'progress_not_saved': 'முன்னேற்றம் சேமிக்கப்படாது',

      // Home Screen
      'play_random': 'ரேண்டம் ப்ளே',

      // Instructions
      'instructions': 'வழிமுறைகள்',
      'tutorial_guide': 'பயிற்சி வழிகாட்டி',
      'instructions_text':
          'உங்கள் விளையாட்டு பயணத்தைத் தொடங்க திரையைத் தட்டவும்! நிலைகளுக்குச் செல்ல அம்புக்குறிகளைப் பயன்படுத்தவும். சவால்களை முடித்து நாணயங்களைச் சேகரிக்கவும். அதிக மதிப்பெண் பெற தடைகளைத் தவிர்க்கவும். மாறுபட்ட அனுபவத்திற்கு முறைகளை மாற்றவும்.',

      // Common
      'ok': 'சரி',
      'cancel': 'ரத்து',
      'yes': 'ஆம்',
      'no': 'இல்லை',
      'confirm': 'உறுதி செய்',
      'back': 'பின்',
      'close': 'மூடு',
      'loading': 'ஏற்றுகிறது...',
      'error': 'பிழை',
      'success': 'வெற்றி',
      'warning': 'எச்சரிக்கை',
      'info': 'தகவல்',

      // Messages
      'insufficient_coins': 'போதிய நாணயங்கள் இல்லை',
      'room_full': 'அறை நிரம்பியுள்ளது',
      'room_not_found': 'அறை காணப்படவில்லை',
      'already_in_room': 'ஏற்கனவே அறையில் உள்ளீர்கள்',
      'connection_lost': 'இணைப்பு துண்டிக்கப்பட்டது',
      'reconnecting': 'மீண்டும் இணைகிறது...',
      'connected': 'இணைக்கப்பட்டது',
      'disconnected': 'துண்டிக்கப்பட்டது',

      // Languages
      'hindi': 'இந்தி',
      'telugu': 'தெலுங்கு',
      'english': 'ஆங்கிலம்',

      // Countries
      'india': 'இந்தியா',
      'usa': 'அமெரிக்கா',
      'uk': 'இங்கிலாந்து',
      'japan': 'ஜப்பான்',
      'spain': 'ஸ்பெயின்',
      'portugal': 'போர்ச்சுகல்',
      'france': 'பிரான்ஸ்',
      'germany': 'ஜெர்மனி',
      'russia': 'ரஷ்யா',

      // Create Room & Join Room
      'please_enter_room_name': 'அறையின் பெயரை உள்ளிடவும்',
      'failed_to_create_room': 'அறையை உருவாக்க முடியவில்லை',
      'code_copied_clipboard': 'குறியீடு கிளிப்போர்டில் நகலெடுக்கப்பட்டது!',
      'room_created': 'அறை உருவாக்கப்பட்டது!',
      'share_code_with_friends': 'இந்தக் குறியீட்டை நண்பர்களுடன் பகிரவும்:',
      'enter_room': 'அறையில் நுழை',
      'create_room_configure_lobby':
          'அறையை உருவாக்கி லாபியில் அமைப்புகளை மாற்றவும்',
      'enter_room_name_hint': 'அறையின் பெயரை உள்ளிடவும்',
      'room_code_share_info':
          'அறையை உருவாக்கிய பிறகு குறியீட்டைப் பகிரலாம்',
      'create_team_room': 'குழு அறையை உருவாக்கு',
      'please_check_code':
          'குறியீட்டைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.',

      // Random Match Screen
      'random_match': 'ரேண்டம் மேட்ச்',
      'select_target_points': 'இலக்கு புள்ளிகளைத் தேர்ந்தெடு',
      'play_random_coins': 'ரேண்டம் ப்ளே (250 நாணயங்கள்)',
      'please_select_all_fields': 'இலக்கு புள்ளிகள் உட்பட அனைத்தையும் தேர்ந்தெடுக்கவும்',
      'failed_to_find_match': 'போட்டியை கண்டுபிடிக்க முடியவில்லை',
      'watch_ads_coming_soon': 'விளம்பரம் பார்க்கும் வசதி விரைவில்!',
      'buy_coins_coming_soon': 'நாணயம் வாங்கும் வசதி விரைவில்!',
      'insufficient_coins_title': 'போதிய நாணயங்கள் இல்லை',
      'insufficient_coins_message': 'சேர உங்களிடம் போதுமான நாணயங்கள் இல்லை. தொடர விளம்பரங்களைப் பார்க்கவும் அல்லது நாணயங்களை வாங்கவும்.',
      'watch_ads': 'விளம்பரம் பார்',
      'buy_coins': 'நாணயங்கள் வாங்கு',
      'no_matches_found': 'போட்டிகள் எதுவும் இல்லை',
      'no_matches_message': 'உங்கள் விருப்பங்களுக்கு ஏற்ற பொது அறைகள் இல்லை. வேறு அமைப்புகளை முயற்சிக்கவும் அல்லது புதிய அறையை உருவாக்கவும்.',
      'try_again': 'மீண்டும் முயற்சி',
      'selected': 'தேர்ந்தெடுக்கப்பட்டது',
      'team_a_is_full': 'அணி A நிரம்பியுள்ளது',
      'team_b_is_full': 'அணி B நிரம்பியுள்ளது',
      'please_select_the_other_team': 'தயவுசெய்து மற்ற அணியைத் தேர்வு செய்யவும்',

      'animals': 'விலங்குகள்',
      'countries': 'நாடுகள்',
      'food': 'உணவு',
      'everyday_objects': 'தினசரி பொருட்கள்',
      'historical_events': 'வரலாற்று நிகழ்வுகள்',
      'movies': 'திரைப்படங்கள்',
    },
    'mr': {
      // Guest Signup & Profile
      'enter_username': 'वापरकर्ता नाव प्रविष्ट करा',
      'language': 'भाषा',
      'country': 'देश',
      'save': 'सहजें',
      'skip': 'सोडें',
      'next': 'आगला',
      'please_fill_all_fields': 'कृपया सभी फ़ील्ड भरें',
      'coins': 'सिक्के',
      'welcome': 'स्वागत आहे',

      // Home Screen
      'home': 'होम',
      'play': 'खेळलें',
      'profile': 'प्रोफाईल',
      'settings': 'सेटिंग्स',
      'leaderboard': 'लिडरबोर्ड',
      'friends': 'मित्र',
      'shop': 'दुकान',
      'daily_bonus': 'दैनिक बोनस',
      'claim': 'दावा करतात',
      'claimed': 'दावा',

      // Multiplayer Screen
      'multiplayer': 'मल्टीप्लेयर',
      'create_room': 'रूम बनवणे',
      'join_room': 'रूम मध्ये समाविष्ट आहेत',
      'room_code': 'रूम कोड',
      'join': 'समाविष्ट करा',
      'players': 'खिलाडी',
      'waiting_for_players': 'खेळाडूंची प्रतीक्षा...',
      'start_game': 'खेळ सुरू करा',
      'leave': 'सोडें',
      'mode': 'मोड',
      'individual': 'व्यक्तीगत',
      'team': 'टीम',
      'language_filter': 'भाषा',
      'points': 'अंक',
      'category': 'श्रेणी',
      'all': 'सर्व',

      // Game Room Screen
      'game_room': 'गेम रूम',
      'gameplay': 'गेमप्ले',
      'drawing': 'ड्रायिंग',
      'guessing': 'अंदाज',
      'selecting_drawer': 'ड्रॉवर निवड...',
      'choosing_word': 'एक शब्द निवडा!',
      'drawer_is_choosing': 'ड्रॉवर चुन रहा है...',
      'draw': 'ड्रा करा',
      'guess_the_word': 'शब्द का अनुमान',
      'word_was': 'शब्द',
      'next_round_starting': 'अगला राउंड सुरू होत आहे...',
      'time_up': 'वेळ संपली!',
      'well_done': 'खूप बरं!',
      'whos_next': 'अगला कौन?',
      'interval': 'अंतराल',
      'host': 'होस्ट',
      'you': 'आपण',
      'correct': 'बरोबर!',
      'good_job': 'अच्छा काम!',
      'chat': 'चॅट',
      'send': 'भेटें',
      'type_message': 'एक संदेश टाइप करा...',
      'answers_chat': 'उत्तर चॅट',
      'general_chat': 'सामान्य गप्पा',
      'team_chat': 'टीम चॅट',

      // Room Preferences Screen
      'room_preferences': 'रूम प्राथमिकताएं',
      'select_language': 'भाषा चुनें',
      'select_points': 'अंक चुनें',
      'select_category': 'श्रेणी निवडा',
      'voice_enabled': 'आवाज सक्षम',
      'select_team': 'टीम चुनें',
      'team_selection': 'टीम चयन',
      'blue_team': 'नील टीम',
      'orange_team': 'नारंगी टीम',

      // Profile & Settings
      'edit_profile': 'प्रोफाइल संपादित करा',
      'profile_and_accounts': 'प्रोफाइल आणि खाते',
      'username': 'वापरकर्ता नाव',
      'email': 'ईमेल',
      'phone': 'फोन',
      'logout': 'लॉगआउट',
      'delete_account': 'खाते हटावें',
      'version': 'संस्कार',
      'about': 'के बद्दल',
      'privacy_policy': 'गोपनीयता नीति',
      'terms_and_conditions': 'नियम आणि अटी',
      'sound': 'ध्वनि',
      'privacy_and_safety': 'गोपनीयता आणि सुरक्षा',
      'contact': 'संपर्क',
      'rate_app': 'ऐप रेट करा',
      'connect_us_at': 'हमसे तुम्हाला',
      'are_you_sure_logout': 'काय आपण वाकई लॉगआउट करू इच्छिता?',
      'loading_ads': 'जाहिरात लोड होत आहेत...',

      // Sign In
      'ink_battle': 'इंक बॅटल',
      'sign_in_with_google': 'Google वर साइन इन करा',
      'sign_in_with_facebook': 'फेसबुकवर साइन इन करा',
      'signing_in': 'साइन इन होत आहे...',
      'or': 'या',
      'play_as_guest': 'अतिथी के रूप मध्ये',
      'progress_not_saved': 'प्रगती जतन करू शकत नाही',

      // Home Screen
      'play_random': 'रैंडम वेल',

      // Instructions
      'instructions': 'निर्देश',
      'tutorial_guide': 'ट्यूटोरियल मार्गदर्शक',
      'instructions_text':
          'तुमचा गेम ॲडव्हेंशन सुरू करण्यासाठी स्क्रीनवर कॅप करा! लेवल के माध्यमाने नेविगेट करण्यासाठी तीरांचा उपयोग करा. निवडौतियांना पूर्ण सिक्के जमा करा. आपल्यासाठी उच्च ठेवण्यासाठी बाधाओं से बचें. एक वेगळा अनुभव बदलण्यासाठी.',

      // Common
      'ok': 'ठीक आहे',
      'cancel': 'रद्द करा',
      'yes': 'हो',
      'no': 'नाही',
      'confirm': 'पुष्टि करा',
      'back': 'परत',
      'close': 'बंद करा',
      'loading': 'लोड होत आहे...',
      'error': 'त्रिती',
      'success': 'यशस्वीता',
      'warning': 'चेतवणी',
      'info': 'माहिती',

      // Messages
      'insufficient_coins': 'अपर्याप्त सिक्के',
      'room_full': 'रुम भरा हुआ आहे',
      'room_not_found': 'रूम नाही मिला',
      'already_in_room': 'पहले से रूम में है',
      'connection_lost': 'कनेक्शन टूट गया',
      'reconnecting': 'पुन्हा कनेक्ट होत आहे...',
      'connected': 'कनेक्ट झाले',
      'disconnected': 'डिस्कनेक्ट झाला',

      // Languages
      'hindi': 'हिंदी',
      'telugu': 'तेलुगु',
      'english': 'इंग्रजी',

      // Countries
      'india': 'भारत',
      'usa': 'अमेरिका',
      'uk': 'यूके',
      'japan': 'जपान',
      'spain': 'स्पेन',
      'portugal': 'पुर्तगाल',
      'france': 'फ्रांस',
      'germany': 'जर्मनी',
      'russia': 'रूसिया',

      // Create Room & Join Room
      'please_enter_room_name': 'कृपया रूम चे नाव प्रविष्ट करा',
      'failed_to_create_room': 'रूम तयार करण्यात अयशस्वी',
      'code_copied_clipboard': 'कोड क्लिपबोर्डवर कॉपी केला!',
      'room_created': 'रूम तयार झाला!',
      'share_code_with_friends': 'हा कोड तुमच्या मित्रांसह शेअर करा:',
      'enter_room': 'रूममध्ये प्रवेश करा',
      'create_room_configure_lobby':
          'एक रूम तयार करा आणि लॉबीमध्ये सेटिंग्ज कॉन्फिगर करा',
      'enter_room_name_hint': 'रूम चे नाव प्रविष्ट करा',
      'room_code_share_info':
          'तुम्ही रूम तयार केल्यानंतर मित्रांसह रूम कोड शेअर करू शकता',
      'create_team_room': 'टीम रूम तयार करा',
      'please_check_code': 'कृपया कोड तपासा आणि पुन्हा प्रयत्न करा.',

      // Random Match Screen
      'random_match': 'रँडम मॅच',
      'select_target_points': 'लक्ष्य गुण निवडा',
      'play_random_coins': 'रँडम खेळा (250 नाणी)',
      'please_select_all_fields': 'कृपया लक्ष्य गुणांसह सर्व फील्ड निवडा',
      'failed_to_find_match': 'मॅच शोधण्यात अयशस्वी',
      'watch_ads_coming_soon': 'जाहिराती पहाण्याचे वैशिष्ट्य लवकरच येत आहे!',
      'buy_coins_coming_soon': 'नाणी खरेदी करण्याचे वैशिष्ट्य लवकरच येत आहे!',
      'insufficient_coins_title': 'अपुरी नाणी',
      'insufficient_coins_message':
          'तुमच्याकडे सामील होण्यासाठी पुरेसी नाणी नाहीत। खेळणे सुरू ठेवण्यासाठी जाहिराती पहा किंवा नाणी खरेदी करा।',
      'watch_ads': 'जाहिराती पहा',
      'buy_coins': 'नाणी खरेदी करा',
      'no_matches_found': 'कोणतीही मॅच सापडली नाही',
      'no_matches_message':
          'तुमच्या प्राधान्यांशी कोणतीही सार्वजनिक खोली जुळली नाही। भिन्न सेटिंग्ज प्रयत्न करा किंवा नवीन खोली तयार करा।',
      'try_again': 'पुन्हा प्रयत्न करा',
      'selected': 'चुना गया',
      'team_a_is_full': 'टीम A पूर्ण झाली आहे',
      'team_b_is_full': 'टीम B पूर्ण झाली आहे',
      'please_select_the_other_team': 'कृपया दूसरी टीम निवडा',

      'animals': 'जानवर',
      'countries': 'देश',
      'food': 'भोजन',
      'everyday_objects': 'रोजमर्रा वस्तुएं',
      'historical_events': 'ऐतिहासिक घटनाएं',
      'movies': 'चलचित्र',
    },
    'kn': {
      // Guest Signup & Profile
      'enter_username': 'ಬಳಕೆದಾರಹೆಸರನ್ನು ನಮೂದಿಸಿ',
      'language': 'ಭಾಷೆ',
      'country': 'ದೇಶ',
      'save': 'ಉಳಿಸಿ',
      'skip': 'ಬಿಟ್ಟುಬಿಡಿ',
      'next': 'ಮುಂದೆ',
      'please_fill_all_fields': 'ದಯವಿಟ್ಟು ಎಲ್ಲಾ ಫೀಲ್ಡ್‌ಗಳನ್ನು ಭರ್ತಿ ಮಾಡಿ',
      'coins': 'ನಾಣ್ಯಗಳು',
      'welcome': 'ಸ್ವಾಗತ',

      // Home Screen
      'home': 'ಮರಳಿ ಪ್ರಥಮ ಪುಟಕ್ಕೆ',
      'play': 'ಪ್ಲೇ ಮಾಡಿ',
      'profile': 'ಪ್ರೊಫೈಲ್',
      'settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
      'leaderboard': 'ಲೀಡರ್‌ಬೋರ್ಡ್',
      'friends': 'ಸ್ನೇಹಿತರು',
      'shop': 'ಅಂಗಡಿ',
      'daily_bonus': 'ದೈನಂದಿನ ಬೋನಸ್',
      'claim': 'ಹಕ್ಕು',
      'claimed': 'ಹಕ್ಕು ಪಡೆಯಲಾಗಿದೆ',

      // Multiplayer Screen
      'multiplayer': 'ಮಲ್ಟಿಪ್ಲೇಯರ್',
      'create_room': 'ಕೊಠಡಿ ರಚಿಸಿ',
      'join_room': 'ಕೊಠಡಿಗೆ ಸೇರಿ',
      'room_code': 'ಕೊಠಡಿ ಕೋಡ್',
      'join': 'ಸೇರಿ',
      'players': 'ಆಟಗಾರರು',
      'waiting_for_players': 'ಆಟಗಾರರಿಗಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ...',
      'start_game': 'ಆಟವನ್ನು ಪ್ರಾರಂಭಿಸಿ',
      'leave': 'ಬಿಡಿ',
      'mode': 'ಮೋಡ್',
      'individual': 'ವೈಯಕ್ತಿಕ',
      'team': 'ತಂಡ',
      'language_filter': 'ಭಾಷೆ',
      'points': 'ಅಂಕಗಳು',
      'category': 'ವರ್ಗ',
      'all': 'ಎಲ್ಲವೂ',

      // Game Room Screen
      'game_room': 'ಆಟದ ಕೊಠಡಿ',
      'gameplay': 'ಆಟದ ಆಟ',
      'drawing': 'ಚಿತ್ರ',
      'guessing': 'ಊಹಿಸುವುದು',
      'selecting_drawer': 'ಡ್ರಾಯರ್ ಆಯ್ಕೆ ಮಾಡಲಾಗುತ್ತಿದೆ...',
      'choosing_word': 'ಒಂದು ಪದವನ್ನು ಆರಿಸಿ!',
      'drawer_is_choosing': 'ಡ್ರಾಯರ್ ಆಯ್ಕೆ ಮಾಡುತ್ತಿದೆ...',
      'draw': 'ಎಳೆಯಿರಿ',
      'guess_the_word': 'ಪದವನ್ನು ಊಹಿಸಿ',
      'word_was': 'ಮಾತು',
      'next_round_starting': 'ಮುಂದಿನ ಸುತ್ತು ಆರಂಭವಾಗುತ್ತಿದೆ...',
      'time_up': 'ಸಮಯ ಮುಗಿಯಿತು!',
      'well_done': 'ಚೆನ್ನಾಗಿದೆ!',
      'whos_next': 'ಮುಂದೆ ಯಾರು?',
      'interval': 'ಮಧ್ಯಂತರ',
      'host': 'ಹೋಸ್ಟ್',
      'you': 'ನೀವು',
      'correct': 'ಸರಿ!',
      'good_job': 'ಒಳ್ಳೆಯ ಕೆಲಸ!',
      'chat': 'ಚಾಟ್ ಮಾಡಿ',
      'send': 'ಕಳುಹಿಸಿ',
      'type_message': 'ಸಂದೇಶವನ್ನು ಟೈಪ್ ಮಾಡಿ...',
      'answers_chat': 'ಉತ್ತರಗಳ ಚಾಟ್',
      'general_chat': 'ಸಾಮಾನ್ಯ ಚಾಟ್',
      'team_chat': 'ತಂಡದ ಚಾಟ್',

      // Room Preferences Screen
      'room_preferences': 'ಕೊಠಡಿ ಆದ್ಯತೆಗಳು',
      'select_language': 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'select_points': 'ಪಾಯಿಂಟ್‌ಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'select_category': 'ವರ್ಗವನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'voice_enabled': 'ಧ್ವನಿ ಸಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ',
      'select_team': 'ತಂಡವನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'team_selection': 'ತಂಡದ ಆಯ್ಕೆ',
      'blue_team': 'ನೀಲಿ ತಂಡ',
      'orange_team': 'ಕಿತ್ತಳೆ ತಂಡ',

      // Profile & Settings
      'edit_profile': 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ',
      'profile_and_accounts': 'ಪ್ರೊಫೈಲ್ ಮತ್ತು ಖಾತೆ',
      'username': 'ಬಳಕೆದಾರಹೆಸರು',
      'email': 'ಇಮೇಲ್',
      'phone': 'ದೂರವಾಣಿ',
      'logout': 'ಲಾಗ್ಔಟ್',
      'delete_account': 'ಖಾತೆಯನ್ನು ಅಳಿಸಿ',
      'version': 'ಆವೃತ್ತಿ',
      'about': 'ನಮ್ಮ ಬಗ್ಗೆ',
      'privacy_policy': 'ಗೌಪ್ಯತಾ ನೀತಿ',
      'terms_and_conditions': 'ನಿಯಮ ಮತ್ತು ಶರತ್ತುಗಳು',
      'sound': 'ಧ್ವನಿ',
      'privacy_and_safety': 'ಗೌಪ್ಯತೆ ಮತ್ತು ಸುರಕ್ಷತೆ',
      'contact': 'ಸಂಪರ್ಕಿಸಿ',
      'rate_app': 'ಅಪ್ಲಿಕೇಶನ್ ರೇಟ್ ಮಾಡಿ',
      'connect_us_at': 'ನಮ್ಮನ್ನು ಇಲ್ಲಿ ಸಂಪರ್ಕಿಸಿ',
      'are_you_sure_logout': 'ನೀವು ಲಾಗ್ ಔಟ್ ಮಾಡಲು ಖಚಿತವಾಗಿ ಬಯಸುತ್ತೀರಾ?',
      'loading_ads': 'ಜಾಹೀರಾತುಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ...',

      // Sign In
      'ink_battle': 'ಇಂಕ್ ಬ್ಯಾಟಲ್',
      'sign_in_with_google': 'Google ನೊಂದಿಗೆ ಸೈನ್ ಇನ್ ಮಾಡಿ',
      'sign_in_with_facebook': 'ಫೇಸ್‌ಬುಕ್‌ನೊಂದಿಗೆ ಸೈನ್ ಇನ್ ಮಾಡಿ',
      'signing_in': 'ಸೈನ್ ಇನ್ ಮಾಡಲಾಗುತ್ತಿದೆ...',
      'or': 'ಅಥವಾ',
      'play_as_guest': 'ಅತಿಥಿಯಾಗಿ ಆಟವಾಡಿ',
      'progress_not_saved': 'ಪ್ರಗತಿಯನ್ನು ಉಳಿಸಲಾಗದಿರಬಹುದು.',

      // Home Screen
      'play_random': 'ಯಾದೃಚ್ಛಿಕ ಆಟವಾಡಿ',

      // Instructions
      'instructions': 'ಸೂಚನೆಗಳು',
      'tutorial_guide': 'ಟ್ಯುಟೋರಿಯಲ್ ಮಾರ್ಗದರ್ಶಿ',
      'instructions_text':
          'ನಿಮ್ಮ ಆಟದ ಸಾಹಸವನ್ನು ಪ್ರಾರಂಭಿಸಲು ಪರದೆಯನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ! ಹಂತಗಳ ಮೂಲಕ ನ್ಯಾವಿಗೇಟ್ ಮಾಡಲು ಬಾಣದ ಗುರುತನ್ನು ಬಳಸಿ. ಸವಾಲುಗಳನ್ನು ಪೂರ್ಣಗೊಳಿಸುವ ಮೂಲಕ ನಾಣ್ಯಗಳನ್ನು ಸಂಗ್ರಹಿಸಿ. ನಿಮ್ಮ ಸ್ಕೋರ್ ಅನ್ನು ಹೆಚ್ಚು ಇರಿಸಿಕೊಳ್ಳಲು ಅಡೆತಡೆಗಳನ್ನು ತಪ್ಪಿಸಿ. ವಿಭಿನ್ನ ಅನುಭವಕ್ಕಾಗಿ ಮೋಡ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಿ.',

      // Common
      'ok': 'ಸರಿ',
      'cancel': 'ರದ್ದುಮಾಡಿ',
      'yes': 'ಹೌದು',
      'no': 'ಇಲ್ಲ',
      'confirm': 'ದೃಢೀಕರಿಸಿ',
      'back': 'ಹಿಂದೆ',
      'close': 'ಮುಚ್ಚಿ',
      'loading': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
      'error': 'ದೋಷ',
      'success': 'ಯಶಸ್ಸು',
      'warning': 'ಎಚ್ಚರಿಕೆ',
      'info': 'ಮಾಹಿತಿ',

      // Messages
      'insufficient_coins': 'ಸಾಕಷ್ಟು ನಾಣ್ಯಗಳಿಲ್ಲ',
      'room_full': 'ಕೊಠಡಿ ತುಂಬಿದೆ',
      'room_not_found': 'ಕೊಠಡಿ ಕಂಡುಬಂದಿಲ್ಲ',
      'already_in_room': 'ಈಗಾಗಲೇ ಕೋಣೆಯಲ್ಲಿದ್ದಾರೆ',
      'connection_lost': 'ಸಂಪರ್ಕ ಕಡಿತಗೊಂಡಿದೆ',
      'reconnecting': 'ಮರುಸಂಪರ್ಕಿಸಲಾಗುತ್ತಿದೆ...',
      'connected': 'ಸಂಪರ್ಕಿಸಲಾಗಿದೆ',
      'disconnected': 'ಸಂಪರ್ಕ ಕಡಿತಗೊಂಡಿದೆ',

      // Languages
      'hindi': 'ಹಿಂದಿ',
      'telugu': 'ತೆಲುಗು',
      'english': 'ಇಂಗ್ಲೀಷ್',

      // Countries
      'india': 'ಭಾರತ',
      'usa': 'ಯುನೈಟೆಡ್ ಸ್ಟೇಟ್ಸ್',
      'uk': 'ಯುಕೆ',
      'japan': 'ಜಪಾನ್',
      'spain': 'ಸ్ಪేನ్',
      'portugal': 'ಪోರ్ಚుಗಲ్',
      'france': 'ಫ్ರಾನ్ಸ్',
      'germany': 'ಜರ్ಮನಿ',
      'russia': 'ರಷಿಯಾ',

      // Create Room & Join Room
      'please_enter_room_name': 'ದಯವಿಟ್ಟು ಕೊಂಡಿ ಹೆಸರು ನಮೂದಿಸಿ',
      'failed_to_create_room': 'ಕೊಂಡಿ ರಚಿಸಲು ವಿಫಲವಾಯಿತು',
      'code_copied_clipboard': 'ಕೋಡ್ ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ಕಾಪಿ ಮಾಡಲಾಗಿದೆ!',
      'room_created': 'ಕೊಂಡಿ ರಚಿಸಲಾಗಿದೆ!',
      'share_code_with_friends': 'ಈ ಕೋಡ್‌ನ್ನು ನಿಮ್ಮ ಸ್ನೇಹಿತರಿಗೆ ಹಂಚಿಕೊಂಡಿ:',
      'enter_room': 'ಕೊಂಡಿಗೆ ಪ್ರವೇಶಿಸಿ',
      'create_room_configure_lobby':
          'ಕೊಂಡಿನ್ನು ರಚಿಸಿ ಮತ್ತು ಲಾಬಿಯಲ್ಲಿ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಕಾನ್ಫಿಗರ್ ಮಾಡಿ',
      'enter_room_name_hint': 'ಕೊಂಡಿ ಹೆಸರು ನಮೂದಿಸಿ',
      'room_code_share_info':
          'ನೀವು ಕೊಂಡಿ ರಚಿಸಿದ ತರ್ವಾತ ಸ್ನೇಹಿತರಿಗೆ ಕೊಂಡಿ ಕೋಡ್‌ನ್ನು ಹಂಚಿಕೊಳ್ಳಲು ಸಾಧ್ಯ',
      'create_team_room': 'ಟೀಮ್ ಕೊಂಡಿ ರಚಿಸಿ',
      'please_check_code':
          'ದಯವಿಟ್ಟು ಕೋಡ್‌ನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',

      // Random Match Screen
      'random_match': 'ಯಾದೃಚ್ಛಿಕ ಮ್ಯಾಚ್',
      'select_target_points': 'ಗುರಿ ಅಂಕಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'play_random_coins': 'ಯಾದೃಚ್ಛಿಕ ಆಡಿ (250 ನಾಣ್ಯಗಳು)',
      'please_select_all_fields':
          'ದಯವಿಟ್ಟು ಗುರಿ ಅಂಕಗಳೊಂದಿಗೆ ಎಲ್ಲಾ ಕ್ಷೇತ್ರಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'failed_to_find_match': 'ಮ್ಯಾಚ್ ಹುಡುಕಲು ವಿಫಲವಾಗಿದೆ',
      'watch_ads_coming_soon':
          'ಜಾಹೀರಾತುಗಳನ್ನು ವೀಕ್ಷಿಸುವ ವೈಶಿಷ್ಟ್ಯ ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ!',
      'buy_coins_coming_soon':
          'ನಾಣ್ಯಗಳನ್ನು ಖರೀದಿಸುವ ವೈಶಿಷ್ಟ್ಯ ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ!',
      'insufficient_coins_title': 'ಸಾಕಷ್ಟು ನಾಣ್ಯಗಳಿಲ್ಲ',
      'insufficient_coins_message':
          'ನೀವು ಸೇರಲು ಸಾಕಷ್ಟು ನಾಣ್ಯಗಳನ್ನು ಹೊಂದಿಲ್ಲ। ಆಟವನ್ನು ಮುಂದುವರಿಸಲು ಜಾಹೀರಾತುಗಳನ್ನು ವೀಕ್ಷಿಸಿ ಅಥವಾ ನಾಣ್ಯಗಳನ್ನು ಖರೀದಿಸಿ।',
      'watch_ads': 'ಜಾಹೀರಾತುಗಳನ್ನು ವೀಕ್ಷಿಸಿ',
      'buy_coins': 'ನಾಣ್ಯಗಳನ್ನು ಖರೀದಿಸಿ',
      'no_matches_found': 'ಯಾವುದೇ ಮ್ಯಾಚ್‌ಗಳು ಕಂಡುಬಂದಿಲ್ಲ',
      'no_matches_message':
          'ನಿಮ್ಮ ಆದ್ಯತೆಗಳಿಗೆ ಯಾವುದೇ ಸಾರ್ವಜನಿಕ ಕೊಠಡಿಗಳು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ। ವಿಭಿನ್ನ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಪ್ರಯತ್ನಿಸಿ ಅಥವಾ ಹೊಸ ಕೊಠಡಿಯನ್ನು ರಚಿಸಿ.',
      'try_again': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
      'selected': 'ಎಂಚుಕోಬಡಿಂದಿ',
      'team_a_is_full': 'ಟೀಮ್ A ತುಂಬಿಕೊಂಡಿದೆ',
      'team_b_is_full': 'ಟೀಮ್ B ತುಂಬಿಕೊಂಡಿದೆ',
      'please_select_the_other_team': 'ದಯವಿಟ್ಟು ಇನ್ನೊಂದು ತಂಡವನ್ನು ಆಯ್ಕೆಮಾಡಿ',

      'animals': 'ಜನವರ్ತ్ತ',
      'countries': 'ದేಶಾಲు',
      'food': 'ಭోಜನ',
      'everyday_objects': 'ರోಜರಾಮರ్ವತ్ತుಲు',
      'historical_events': 'ಇತಿಹಾಸಿಕ ಘಟನಲు',
      'movies': 'ಚಲನವీಕ్ಷಣಲు',
    },
    'ml': {
      // Guest Signup & Profile
      'enter_username': 'ಉಪയോക്തൃനാമം നൽകുക',
      'language': 'ഭാഷ',
      'country': 'രാജ്യം',
      'save': 'രക്ഷിക്കും',
      'skip': 'ഒഴിവാക്കുക',
      'next': 'അടുത്തത്',
      'please_fill_all_fields': 'ദയവായി എല്ലാ ഫീൽഡുകളും പൂരിപ്പിക്കുക',
      'coins': 'നാണയങ്ങൾ',
      'welcome': 'സ്വാഗതം',

      // Home Screen
      'home': 'വീട്',
      'play': 'കളിക്കുക',
      'profile': 'പ്രൊഫൈൽ',
      'settings': 'ക്രമീകരണങ്ങൾ',
      'leaderboard': 'ലീഡർബോർഡ്',
      'friends': 'സുഹൃത്തുക്കൾ',
      'shop': 'ഷോപ്പ്',
      'daily_bonus': 'പ്രതിദിന ബോണസ്',
      'claim': 'അവകാശം',
      'claimed': 'അവകാശപ്പെട്ടു',

      // Multiplayer Screen
      'multiplayer': 'മൾട്ടിപ്ലെയർ',
      'create_room': 'മുറി സൃഷ്ടിക്കുക',
      'join_room': 'റൂമിൽ ചേരുക',
      'room_code': 'റൂം കോഡ്',
      'join': 'ചേരുക',
      'players': 'കളിക്കാർ',
      'waiting_for_players': 'കളിക്കാർക്കായി കാത്തിരിക്കുന്നു...',
      'start_game': 'ഗെയിം ആരംഭിക്കുക',
      'leave': 'വിടുക',
      'mode': 'മോഡ്',
      'individual': 'വ്യക്തി',
      'team': 'ടീം',
      'language_filter': 'ഭാഷ',
      'points': 'പോയിന്റുകൾ',
      'category': 'വിഭാഗം',
      'all': 'എല്ലാം',

      // Game Room Screen
      'game_room': 'ഗെയിം റൂം',
      'gameplay': 'ഗെയിംപ്ലേ',
      'drawing': 'ഡ്രോയിംഗ്',
      'guessing': 'ഊഹിക്കുന്നു',
      'selecting_drawer': 'ഡ്രോയർ തിരഞ്ഞെടുക്കുന്നു...',
      'choosing_word': 'ഒരു വാക്ക് തിരഞ്ഞെടുക്കുക!',
      'drawer_is_choosing': 'ഡ്രോയർ തിരഞ്ഞെടുക്കുന്നു...',
      'draw': 'വരയ്ക്കുക',
      'guess_the_word': 'വാക്ക് ഊഹിക്കുക',
      'word_was': 'വാക്ക് ആയിരുന്നു',
      'next_round_starting': 'അടുത്ത റൗണ്ട് ആരംഭിക്കുന്നു...',
      'time_up': 'സമയം കഴിഞ്ഞു!',
      'well_done': 'നന്നായി ചെയ്തു!',
      'whos_next': 'അടുത്തത് ആരാണ്?',
      'interval': 'ഇടവേള',
      'host': 'ഹോസ്റ്റ്',
      'you': 'നീ',
      'correct': 'ശരി!',
      'good_job': 'നല്ല ജോലി!',
      'chat': 'ചാറ്റ്',
      'send': 'അയയ്‌ക്കുക',
      'type_message': 'ഒരു സന്ദേശം ടൈപ്പ് ചെയ്യുക...',
      'answers_chat': 'ഉത്തര ചാറ്റ്',
      'general_chat': 'ജനറൽ ചാറ്റ്',
      'team_chat': 'ടീം ചാറ്റ്',

      // Room Preferences Screen
      'room_preferences': 'റൂം മുൻഗണനകൾ',
      'select_language': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
      'select_points': 'പോയിന്റുകൾ തിരഞ്ഞെടുക്കുക',
      'select_category': 'വിഭാഗം തിരഞ്ഞെടുക്കുക',
      'voice_enabled': 'ശബ്ദം പ്രവർത്തനക്ഷമമാക്കി',
      'select_team': 'ടീമിനെ തിരഞ്ഞെടുക്കുക',
      'team_selection': 'ടീം തിരഞ്ഞെടുപ്പ്',
      'blue_team': 'ബ്ലൂ ടീം',
      'orange_team': 'ഓറഞ്ച് ടീം',

      // Profile & Settings
      'edit_profile': 'പ്രൊഫൈൽ എഡിറ്റ് ചെയ്യുക',
      'profile_and_accounts': 'പ്രൊഫൈലും അക്കൗണ്ടും',
      'username': 'ഉപയോക്തൃനാമം',
      'email': 'ഇമെയിൽ',
      'phone': 'ഫോൺ',
      'logout': 'ലോഗ്ഔട്ട് ചെയ്യുക',
      'delete_account': 'അക്കൗണ്ട് ഇല്ലാതാക്കുക',
      'version': 'പതിപ്പ്',
      'about': 'കുറിച്ച്',
      'privacy_policy': 'സ്വകാര്യതാ നയം',
      'terms_and_conditions': 'നിബന്ധനകളും വ്യവസ്ഥകളും',
      'sound': 'ശബ്ദം',
      'privacy_and_safety': 'സ്വകാര്യതയും സുരക്ഷയും',
      'contact': 'ബന്ധപ്പെടുക',
      'rate_app': 'ആപ്പ് റേറ്റ് ചെയ്യുക',
      'connect_us_at': 'ഞങ്ങളെ ഇവിടെ ബന്ധിപ്പിക്കുക',
      'are_you_sure_logout': 'നിങ്ങൾക്ക് ലോഗ് ഔട്ട് ചെയ്യണമെന്ന് ഉറപ്പാണോ?',
      'loading_ads': 'പരസ്യങ്ങൾ ലോഡ് ചെയ്യുന്നു...',

      // Sign In
      'ink_battle': 'ഇങ്ക് ബാറ്റിൽ',
      'sign_in_with_google': 'Google ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക',
      'sign_in_with_facebook': 'ഫേസ്ബുക്ക് ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക',
      'signing_in': 'സൈൻ ഇൻ ചെയ്യുന്നു...',
      'or': 'അഥവാ',
      'play_as_guest': 'അതിഥിയായി കളിക്കൂ',
      'progress_not_saved': 'പുരോഗതി സംരക്ഷിക്കപ്പെട്ടേക്കില്ല.',

      // Home Screen
      'play_random': 'റാൻഡം പ്ലേ ചെയ്യുക',

      // Instructions
      'instructions': 'നിർദ്ദേശങ്ങൾ',
      'tutorial_guide': 'ട്യൂട്ടോറിയൽ ഗൈഡ്',
      'instructions_text':
          'നിങ്ങളുടെ ഗെയിം സാഹസികത ആരംഭിക്കാൻ സ്ക്രീനിൽ ടാപ്പ് ചെയ്യുക! ലെവലുകളിലൂടെ നാവിഗേറ്റ് ചെയ്യാൻ അമ്പടയാളങ്ങൾ ഉപയോഗിക്കുക. വെല്ലുവിളികൾ പൂർത്തിയാക്കി നാണയങ്ങൾ ശേഖരിക്കുക. നിങ്ങളുടെ സ്കോർ ഉയർന്ന നിലയിൽ നിലനിർത്താൻ തടസ്സങ്ങൾ ഒഴിവാക്കുക. വ്യത്യസ്തമായ അനുഭവത്തിനായി മോഡുകൾ മാറ്റുക.',

      // Common
      'ok': 'ശരി',
      'cancel': 'റദ്ദാക്കുക',
      'yes': 'അതെ',
      'no': 'ഇല്ല',
      'confirm': 'സ്ഥിരീകരിക്കുക',
      'back': 'തിരികെ',
      'close': 'അടയ്ക്കുക',
      'loading': 'ലോഡ് ചെയ്യുന്നു...',
      'error': 'പിശക്',
      'success': 'വിജയം',
      'warning': 'മുന്നറിയിപ്പ്',
      'info': 'വിവരം',

      // Messages
      'insufficient_coins': 'ആവശ്യത്തിന് നാണയങ്ങളില്ല',
      'room_full': 'മുറി നിറഞ്ഞിരിക്കുന്നു',
      'room_not_found': 'മുറി കണ്ടെത്തിയില്ല',
      'already_in_room': 'റൂമിൽ ഉണ്ട്',
      'connection_lost': 'കണക്ഷൻ നഷ്ടപ്പെട്ടു',
      'reconnecting': 'വീണ്ടും ബന്ധിപ്പിക്കുന്നു...',
      'connected': 'ബന്ധിപ്പിച്ചു',
      'disconnected': 'വിച്ഛേദിച്ചു',

      // Languages
      'hindi': 'ഹിന്ദി',
      'telugu': 'തെലുങ്ക്',
      'english': 'ഇംഗ്ലീഷ്',

      // Countries
      'india': 'ഇന്ത്യ',
      'usa': 'യുഎസ്എ',
      'uk': 'യുകെ',
      'japan': 'ജപ്പാൻ',
      'spain': 'സ్പേന്',
      'portugal': 'പോര്ച്ചുഗൽ',
      'france': 'ഫ്രാന്സ്',
      'germany': 'ജർമ്മനി',
      'russia': 'റഷ്യ',

      // Create Room & Join Room
      'please_enter_room_name': 'ദയവായി റൂമിൻ്റെ പേര് നൽകുക',
      'failed_to_create_room': 'റൂം സൃഷ്ടിക്കുന്നതിൽ പരാജയപ്പെട്ടു',
      'code_copied_clipboard': 'കോഡ് ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തി!',
      'room_created': 'റൂം സൃഷ്ടിച്ചു!',
      'share_code_with_friends': 'ഈ കോഡ് നിങ്ങളുടെ സുഹൃത്തുക്കളുമായി പങ്കിടുക:',
      'enter_room': 'റൂമിൽ പ്രവേശിക്കുക',
      'create_room_configure_lobby':
          'റൂം സൃഷ്ടിക്കുകയും ലോബിയിൽ ക്രമീകരണങ്ങൾ കോൺഫിഗർ ചെയ്യുകയും ചെയ്യുക',
      'enter_room_name_hint': 'റൂമിൻ്റെ പേര് നൽകുക',
      'room_code_share_info':
          'റൂം സൃഷ്ടിച്ച ശേഷം നിങ്ങൾക്ക് സുഹൃത്തുക്കളുമായി റൂം കോഡ് പങ്കിടാം',
      'create_team_room': 'ടീം റൂം സൃഷ്ടിക്കുക',
      'please_check_code':
          'ദയവായി കോഡ് പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.',

      // Random Match Screen
      'random_match': 'റാൻഡം മാച്ച്',
      'select_target_points': 'ടാർഗെറ്റ് പോയിന്റുകൾ തിരഞ്ഞെടുക്കുക',
      'play_random_coins': 'റാൻഡം കളിക്കുക (250 നാണയങ്ങൾ)',
      'please_select_all_fields': 'ദയവായി ടാർഗെറ്റ് പോയിന്റുകൾ ഉൾപ്പെടെ എല്ലാ ഫീൽഡുകളും തിരഞ്ഞെടുക്കുക',
      'failed_to_find_match': 'മാച്ച് കണ്ടെത്തുന്നതിൽ പരാജയപ്പെട്ടു',
      'watch_ads_coming_soon': 'പരസ്യങ്ങൾ കാണാനുള്ള സൗകര്യം ഉടൻ വരുന്നു!',
      'buy_coins_coming_soon': 'നാണയങ്ങൾ വാങ്ങാനുള്ള സൗകര്യം ഉടൻ വരുന്നു!',
      'insufficient_coins_title': 'മതിയായ നാണയങ്ങൾ ഇല്ല',
      'insufficient_coins_message': 'ഗെയിമിൽ ചേരാൻ ആവശ്യമായ നാണയങ്ങൾ നിങ്ങളുടെ കൈവശമില്ല. തുടരാൻ പരസ്യങ്ങൾ കാണുക അല്ലെങ്കിൽ നാണയങ്ങൾ വാങ്ങുക.',
      'watch_ads': 'പരസ്യങ്ങൾ കാണുക',
      'buy_coins': 'നാണയങ്ങൾ വാങ്ങുക',
      'no_matches_found': 'മാച്ചുകളൊന്നും കണ്ടെത്തിയില്ല',
      'no_matches_message': 'നിങ്ങളുടെ മുൻഗണനകളുമായി പൊരുത്തപ്പെടുന്ന പബ്ലിക് റൂമുകളൊന്നുമില്ല. വ്യത്യസ്ത ക്രമീകരണങ്ങൾ പരീക്ഷിക്കുക അല്ലെങ്കിൽ പുതിയ റൂം സൃഷ്ടിക്കുക.',
      'try_again': 'വീണ്ടും ശ്രമിക്കുക',
      'selected': 'തിരഞ്ഞെടുത്തു',
      'team_a_is_full': 'ടീം A നിറഞ്ഞിരിക്കുന്നു',
      'team_b_is_full': 'ടീം B നിറഞ്ഞിരിക്കുന്നു',
      'please_select_the_other_team': 'ദയവായി മറ്റൊരു ടീമിനെ തിരഞ്ഞെടുക്കൂ',

      'animals': 'മൃഗങ്ങൾ',
      'countries': 'രാജ്യങ്ങൾ',
      'food': 'ഭക്ഷണം',
      'everyday_objects': 'നിത്യോപയോഗ വസ്തുക്കൾ',
      'historical_events': 'ചരിത്ര സംഭവങ്ങൾ',
      'movies': 'സിനിമകൾ',
        
    },
    'bn': {
      // Guest Signup & Profile
      'enter_username': 'ব্যবহারকারীর নাম লিখুন',
      'language': 'ভাষা',
      'country': 'দেশ',
      'save': 'সংরক্ষণ করুন',
      'skip': 'এড়িয়ে যান',
      'next': 'পরবর্তী',
      'please_fill_all_fields': 'দয়া করে সমস্ত ক্ষেত্র পূরণ করুন',
      'coins': 'কয়েন',
      'welcome': 'স্বাগতম',

      // Home Screen
      'home': 'হোম',
      'play': 'খেলা',
      'profile': 'প্রোফাইলের',
      'settings': 'সেটিংস',
      'leaderboard': 'লিডারবোর্ড',
      'friends': 'বন্ধুরা',
      'shop': 'দোকান',
      'daily_bonus': 'দৈনিক বোনাস',
      'claim': 'দাবি',
      'claimed': 'দাবি করা হয়েছে',

      // Multiplayer Screen
      'multiplayer': 'মাল্টিপ্লেয়ার',
      'create_room': 'রুম তৈরি করুন',
      'join_room': 'রুমে যোগদান করুন',
      'room_code': 'রুম কোড',
      'join': 'যোগদান করুন',
      'players': 'খেলোয়াড়রা',
      'waiting_for_players': 'খেলোয়াড়দের জন্য অপেক্ষা করছি...',
      'start_game': 'খেলা শুরু করুন',
      'leave': 'ছেড়ে দিন',
      'mode': 'মোড',
      'individual': 'স্বতন্ত্র',
      'team': 'টীম',
      'language_filter': 'ভাষা',
      'points': 'পয়েন্ট',
      'category': 'বিভাগ',
      'all': 'সব',

      // Game Room Screen
      'game_room': 'খেলার ঘর',
      'gameplay': 'গেমপ্লে',
      'drawing': 'অঙ্কন',
      'guessing': 'অনুমান করা',
      'selecting_drawer': 'ড্রয়ার নির্বাচন করা হচ্ছে...',
      'choosing_word': 'একটি শব্দ বেছে নাও!',
      'drawer_is_choosing': 'ড্রয়ারটি বেছে নিচ্ছে...',
      'draw': 'আঁকা',
      'guess_the_word': 'শব্দ অনুমান করুন',
      'word_was': 'কথাটি ছিল',
      'next_round_starting': 'পরবর্তী রাউন্ড শুরু...',
      'time_up': 'সময় শেষ!',
      'well_done': 'সাবাশ!',
      'whos_next': 'এরপর কে?',
      'interval': 'ব্যবধান',
      'host': 'হোস্ট',
      'you': 'তুমি',
      'correct': 'সঠিক!',
      'good_job': 'ভালো করেছো!',
      'chat': 'চ্যাট',
      'send': 'পাঠান',
      'type_message': 'একটি বার্তা টাইপ করুন...',
      'answers_chat': 'উত্তর চ্যাট',
      'general_chat': 'সাধারণ চ্যাট',
      'team_chat': 'টিম চ্যাট',

      // Room Preferences Screen
      'room_preferences': 'রুম পছন্দসমূহ',
      'select_language': 'ভাষা নির্বাচন কর',
      'select_points': 'পয়েন্ট নির্বাচন করুন',
      'select_category': 'শ্রেণী নির্বাচন করুন',
      'voice_enabled': 'ভয়েস সক্ষম করা হয়েছে',
      'select_team': 'দল নির্বাচন করুন',
      'team_selection': 'দল নির্বাচন',
      'blue_team': 'নীল দল',
      'orange_team': 'কমলা দল',

      // Profile & Settings
      'edit_profile': 'প্রোফাইল সম্পাদনা করুন',
      'profile_and_accounts': 'প্রোফাইল এবং অ্যাকাউন্ট',
      'username': 'ব্যবহারকারীর নাম',
      'email': 'ইমেইল',
      'phone': 'ফোন',
      'logout': 'লগআউট',
      'delete_account': 'অ্যাকাউন্ট মুছুন',
      'version': 'সংস্করণ',
      'about': 'সম্পর্কে',
      'privacy_policy': 'গোপনীয়তা নীতি',
      'terms_and_conditions': 'শর্তাবলী',
      'sound': 'শব্দ',
      'privacy_and_safety': 'গোপনীয়তা এবং নিরাপত্তা',
      'contact': 'যোগাযোগ',
      'rate_app': 'অ্যাপ রেট করুন',
      'connect_us_at': 'আমাদের সাথে যোগাযোগ করুন এখানে',
      'are_you_sure_logout': 'আপনি কি নিশ্চিত যে আপনি লগআউট করতে চান?',
      'loading_ads': 'বিজ্ঞাপন লোড হচ্ছে...',

      // Sign In
      'ink_battle': 'কালি যুদ্ধ',
      'sign_in_with_google': 'গুগল দিয়ে সাইন ইন করুন',
      'sign_in_with_facebook': 'ফেসবুক দিয়ে সাইন ইন করুন',
      'signing_in': 'সাইন ইন করা হচ্ছে...',
      'or': 'অথবা',
      'play_as_guest': 'অতিথি হিসেবে খেলুন',
      'progress_not_saved': 'অগ্রগতি সংরক্ষণ নাও হতে পারে',

      // Home Screen
      'play_random': 'এলোমেলো খেলুন',

      // Instructions
      'instructions': 'নির্দেশনা',
      'tutorial_guide': 'টিউটোরিয়াল গাইড',
      'instructions_text':
          'আপনার গেম অ্যাডভেঞ্চার শুরু করতে স্ক্রিনে ট্যাপ করুন! লেভেলের মধ্য দিয়ে নেভিগেট করতে তীরচিহ্ন ব্যবহার করুন। চ্যালেঞ্জগুলি সম্পন্ন করে কয়েন সংগ্রহ করুন। আপনার স্কোর উচ্চ রাখতে বাধা এড়িয়ে চলুন। একটি ভিন্ন অভিজ্ঞতার জন্য মোড পরিবর্তন করুন।',

      // Common
      'ok': 'ঠিক আছে',
      'cancel': 'বাতিল করুন',
      'yes': 'হাঁ',
      'no': 'না',
      'confirm': 'নিশ্চিত করুন',
      'back': 'পিছনে',
      'close': 'বন্ধ করা',
      'loading': 'লোড হচ্ছে...',
      'error': 'ত্রুটি',
      'success': 'সাফল্য',
      'warning': 'সতর্কতা',
      'info': 'তথ্য',

      // Messages
      'insufficient_coins': 'অপর্যাপ্ত কয়েন',
      'room_full': 'ঘর পূর্ণ।',
      'room_not_found': 'রুম খুঁজে পাওয়া যায়নি',
      'already_in_room': 'ইতিমধ্যেই রুমে আছে',
      'connection_lost': 'সংযোগ বিচ্ছিন্ন',
      'reconnecting': 'পুনঃসংযোগ করা হচ্ছে...',
      'connected': 'সংযুক্ত',
      'disconnected': 'সংযোগ বিচ্ছিন্ন',

      // Languages
      'hindi': 'হিন্দি',
      'telugu': 'তেলেগু',
      'english': 'ইংরেজী',

      // Countries
      'india': 'ভারত',
      'usa': 'আমেরিকা',
      'uk': 'যুক্তরাজ্য',
      'japan': 'জাপান',
      'spain': 'স্পেন',
      'portugal': 'পোরুগাল',
      'france': 'ফ্রান্স',
      'germany': 'জার্মানি',
      'russia': 'রাশিয়া',

      // Create Room & Join Room
      'please_enter_room_name': 'দয়া করে রুমের নাম লিখুন',
      'failed_to_create_room': 'রুম তৈরি করতে ব্যর্থ হয়েছে',
      'code_copied_clipboard': 'কোড ক্লিপবোর্ডে কপি করা হয়েছে!',
      'room_created': 'রুম তৈরি হয়েছে!',
      'share_code_with_friends': 'এই কোডটি আপনার বন্ধুদের সাথে শেয়ার করুন:',
      'enter_room': 'রুমে প্রবেশ করুন',
      'create_room_configure_lobby':
          'রুম তৈরি করুন এবং লবিতে সেটিংস কনফিগার করুন',
      'enter_room_name_hint': 'রুমের নাম লিখুন',
      'room_code_share_info':
          'রুম তৈরি করার পরে আপনি বন্ধুদের সাথে রুম কোড শেয়ার করতে পারেন',
      'create_team_room': 'টিম রুম তৈরি করুন',
      'please_check_code':
          'দয়া করে কোডটি যাচাই করুন এবং আবার চেষ্টা করুন।',

      // Random Match Screen
      'random_match': 'র্যান্ডম ম্যাচ',
      'select_target_points': 'টার্গেট পয়েন্ট নির্বাচন করুন',
      'play_random_coins': 'র্যান্ডম খেলুন (২৫০ কয়েন)',
      'please_select_all_fields': 'দয়া করে টার্গেট পয়েন্ট সহ সমস্ত ফিল্ড নির্বাচন করুন',
      'failed_to_find_match': 'ম্যাচ খুঁজে পেতে ব্যর্থ হয়েছে',
      'watch_ads_coming_soon': 'বিজ্ঞাপন দেখার সুবিধা শীঘ্রই আসছে!',
      'buy_coins_coming_soon': 'কয়েন কেনার সুবিধা শীঘ্রই আসছে!',
      'insufficient_coins_title': 'পর্যাপ্ত কয়েন নেই',
      'insufficient_coins_message': 'গেমটিতে যোগদানের জন্য আপনার কাছে পর্যাপ্ত কয়েন নেই। চালিয়ে যেতে বিজ্ঞাপন দেখুন বা কয়েন কিনুন।',
      'watch_ads': 'বিজ্ঞাপন দেখুন',
      'buy_coins': 'কয়েন কিনুন',
      'no_matches_found': 'কোনো ম্যাচ পাওয়া যায়নি',
      'no_matches_message': 'আপনার পছন্দের সাথে কোনো পাবলিক রুম মিলছে না। ভিন্ন সেটিংস চেষ্টা করুন বা একটি নতুন রুম তৈরি করুন।',
      'try_again': 'আবার চেষ্টা করুন',
      'selected': 'নির্বাচিত',
      'team_a_is_full': 'টিম A পূর্ণ হয়ে গেছে',
      'team_b_is_full': 'টিম B পূর্ণ হয়ে গেছে',
      'please_select_the_other_team': 'অনুগ্রহ করে অন্য দলটি নির্বাচন করুন',

      'animals': 'পশু',
      'countries': 'দেশ',
      'food': 'খাবার',
      'everyday_objects': 'নিত্যব্যবহার্য বস্তু',
      'historical_events': 'ঐতিহাসিক ঘটনা',
      'movies': 'সিনেমা',
    },
    'ar': {
      // Guest Signup & Profile
      'enter_username': 'أدخل اسم المستخدم',
      'language': 'لغة',
      'country': 'دولة',
      'save': 'يحفظ',
      'skip': 'يتخطى',
      'next': 'التالي',
      'please_fill_all_fields': 'يرجى ملء جميع الحقول',
      'coins': 'عملات معدنية',
      'welcome': 'مرحباً',

      // Home Screen
      'home': 'بيت',
      'play': 'يلعب',
      'profile': 'حساب تعريفي',
      'settings': 'إعدادات',
      'leaderboard': 'لوحة المتصدرين',
      'friends': 'أصدقاء',
      'shop': 'محل',
      'daily_bonus': 'مكافأة يومية',
      'claim': 'مطالبة',
      'claimed': 'تم المطالبة به',

      // Multiplayer Screen
      'multiplayer': 'متعدد اللاعبين',
      'create_room': 'إنشاء غرفة',
      'join_room': 'انضم إلى الغرفة',
      'room_code': 'رمز الغرفة',
      'join': 'ينضم',
      'players': 'اللاعبون',
      'waiting_for_players': 'في انتظار اللاعبين...',
      'start_game': 'ابدأ اللعبة',
      'leave': 'يترك',
      'mode': 'وضع',
      'individual': 'فردي',
      'team': 'فريق',
      'language_filter': 'لغة',
      'points': 'نقاط',
      'category': 'فئة',
      'all': 'الجميع',

      // Game Room Screen
      'game_room': 'غرفة الألعاب',
      'gameplay': 'طريقة اللعب',
      'drawing': 'رسم',
      'guessing': 'التخمين',
      'selecting_drawer': 'اختيار الدرج...',
      'choosing_word': 'اختار كلمة!',
      'drawer_is_choosing': 'الدرج يختار...',
      'draw': 'يرسم',
      'guess_the_word': 'تخمين الكلمة',
      'word_was': 'الكلمة كانت',
      'next_round_starting': 'الجولة القادمة تبدأ...',
      'time_up': 'انتهى الوقت!',
      'well_done': 'أحسنت!',
      'whos_next': 'من التالي؟',
      'interval': 'فاصلة',
      'host': 'يستضيف',
      'you': 'أنت',
      'correct': 'صحيح!',
      'good_job': 'أحسنت!',
      'chat': 'محادثة',
      'send': 'يرسل',
      'type_message': 'اكتب رسالة...',
      'answers_chat': 'إجابات الدردشة',
      'general_chat': 'الدردشة العامة',
      'team_chat': 'دردشة الفريق',

      // Room Preferences Screen
      'room_preferences': 'تفضيلات الغرفة',
      'select_language': 'اختر اللغة',
      'select_points': 'حدد النقاط',
      'select_category': 'اختر الفئة',
      'voice_enabled': 'تمكين الصوت',
      'select_team': 'اختر الفريق',
      'team_selection': 'اختيار الفريق',
      'blue_team': 'الفريق الأزرق',
      'orange_team': 'الفريق البرتقالي',

      // Profile & Settings
      'edit_profile': 'تعديل الملف الشخصي',
      'profile_and_accounts': 'الملف الشخصي والحساب',
      'username': 'اسم المستخدم',
      'email': 'بريد إلكتروني',
      'phone': 'هاتف',
      'logout': 'تسجيل الخروج',
      'delete_account': 'حذف الحساب',
      'version': 'إصدار',
      'about': 'عن',
      'privacy_policy': 'سياسة الخصوصية',
      'terms_and_conditions': 'الشروط والأحكام',
      'sound': 'صوت',
      'privacy_and_safety': 'الخصوصية والأمان',
      'contact': 'اتصال',
      'rate_app': 'تقييم التطبيق',
      'connect_us_at': 'تواصل معنا على',
      'are_you_sure_logout': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'loading_ads': 'جاري تحميل الإعلانات...',

      // Sign In
      'ink_battle': 'معركة الحبر',
      'sign_in_with_google': 'تسجيل الدخول باستخدام جوجل',
      'sign_in_with_facebook': 'تسجيل الدخول باستخدام الفيسبوك',
      'signing_in': 'جاري تسجيل الدخول...',
      'or': 'أو',
      'play_as_guest': 'العب كضيف',
      'progress_not_saved': 'قد لا يتم حفظ التقدم',

      // Home Screen
      'play_random': 'لعب عشوائي',

      // Instructions
      'instructions': 'تعليمات',
      'tutorial_guide': 'دليل تعليمي',
      'instructions_text':
          'اضغط على الشاشة لبدء مغامرة اللعب! استخدم الأسهم للتنقل بين المستويات. اجمع العملات المعدنية بإكمال التحديات. تجنب العوائق للحفاظ على نتيجتك عالية. غيّر أوضاع اللعب لتجربة مختلفة.',

      // Common
      'ok': 'نعم',
      'cancel': 'يلغي',
      'yes': 'نعم',
      'no': 'لا',
      'confirm': 'يتأكد',
      'back': 'خلف',
      'close': 'يغلق',
      'loading': 'تحميل...',
      'error': 'خطأ',
      'success': 'نجاح',
      'warning': 'تحذير',
      'info': 'معلومات',

      // Messages
      'insufficient_coins': 'عملات معدنية غير كافية',
      'room_full': 'الغرفة ممتلئة',
      'room_not_found': 'لم يتم العثور على الغرفة',
      'already_in_room': 'موجود بالفعل في الغرفة',
      'connection_lost': 'تم فقدان الاتصال',
      'reconnecting': 'جاري إعادة الاتصال...',
      'connected': 'متصل',
      'disconnected': 'منقطع',

      // Languages
      'hindi': 'الهندية',
      'telugu': 'التيلجو',
      'english': 'إنجليزي',

      // Countries
      'india': 'الهند',
      'usa': 'الولايات المتحدة الأمريكية',
      'uk': 'المملكة المتحدة',
      'japan': 'اليابان',
      'spain': 'إسبانيا',
      'portugal': 'البرتغال',
      'france': 'فرنسا',
      'germany': 'ألمانيا',
      'russia': 'روسيا',

      // Create Room & Join Room
      'please_enter_room_name': 'الرجاء إدخال اسم الغرفة',
      'failed_to_create_room': 'فشل إنشاء الغرفة',
      'code_copied_clipboard': 'تم نسخ الرمز إلى الحافظة!',
      'room_created': 'تم إنشاء الغرفة!',
      'share_code_with_friends': 'شارك هذا الرمز مع أصدقائك:',
      'enter_room': 'دخول الغرفة',
      'create_room_configure_lobby':
          'إنشاء غرفة وتكوين الإعدادات في الردهة',
      'enter_room_name_hint': 'أدخل اسم الغرفة',
      'room_code_share_info':
          'يمكنك مشاركة رمز الغرفة مع الأصدقاء بعد الإنشاء',
      'create_team_room': 'إنشاء غرفة فريق',
      'please_check_code':
          'الرجاء التحقق من الرمز والمحاولة مرة أخرى.',

      // Random Match Screen
      'random_match': 'مباراة عشوائية',
      'select_target_points': 'حدد النقاط المستهدفة',
      'play_random_coins': 'لعب عشوائي (250 عملة)',
      'please_select_all_fields': 'الرجاء تحديد جميع الحقول بما في ذلك النقاط المستهدفة',
      'failed_to_find_match': 'فشل العثور على مباراة',
      'watch_ads_coming_soon': 'ميزة مشاهدة الإعلانات قادمة قريباً!',
      'buy_coins_coming_soon': 'ميزة شراء العملات قادمة قريباً!',
      'insufficient_coins_title': 'العملات غير كافية',
      'insufficient_coins_message': 'ليس لديك عملات كافية للانضمام. شاهد الإعلانات أو اشترِ العملات للمتابعة.',
      'watch_ads': 'شاهد الإعلانات',
      'buy_coins': 'شراء العملات',
      'no_matches_found': 'لم يتم العثور على مباريات',
      'no_matches_message': 'لا توجد غرف عامة تطابق تفضيلاتك. جرب إعدادات مختلفة أو أنشئ غرفة جديدة.',
      'try_again': 'حاول مرة أخرى',
      'selected': 'تم الاختيار',
      'team_a_is_full': 'الفريق A ممتلئ',
      'team_b_is_full': 'الفريق B ممتلئ',
      'please_select_the_other_team': 'يرجى اختيار الفريق الآخر',

      'animals': 'حيوانات',
      'countries': 'بلدان',
      'food': 'طعام',
      'everyday_objects': 'أشياء يومية',
      'historical_events': 'أحداث تاريخية',
      'movies': 'أفلام',
    },
    'es': {
      // Guest Signup & Profile
      'enter_username': 'Introducir nombre de usuario',
      'language': 'Idioma',
      'country': 'País',
      'save': 'Ahorrar',
      'skip': 'Saltar',
      'next': 'Próximo',
      'please_fill_all_fields': 'Por favor complete todos los campos',
      'coins': 'Monedas',
      'welcome': 'Bienvenido',

      // Home Screen
      'home': 'Hogar',
      'play': 'Jugar',
      'profile': 'Perfil',
      'settings': 'Ajustes',
      'leaderboard': 'Tabla de clasificación',
      'friends': 'Amigos',
      'shop': 'Comercio',
      'daily_bonus': 'Bono diario',
      'claim': 'Afirmar',
      'claimed': 'Reclamado',

      // Multiplayer Screen
      'multiplayer': 'Multijugador',
      'create_room': 'Crear sala',
      'join_room': 'Unirse a la sala',
      'room_code': 'Código de habitación',
      'join': 'Unirse',
      'players': 'Jugadores',
      'waiting_for_players': 'Esperando jugadores...',
      'start_game': 'Iniciar juego',
      'leave': 'Dejar',
      'mode': 'Modo',
      'individual': 'Individual',
      'team': 'Equipo',
      'language_filter': 'Idioma',
      'points': 'Agujas',
      'category': 'Categoría',
      'all': 'Todo',

      // Game Room Screen
      'game_room': 'Sala de juegos',
      'gameplay': 'Jugabilidad',
      'drawing': 'Dibujo',
      'guessing': 'Adivinación',
      'selecting_drawer': 'Seleccionando cajón...',
      'choosing_word': '¡Elige una palabra!',
      'drawer_is_choosing': 'El cajón está eligiendo...',
      'draw': 'Dibujar',
      'guess_the_word': 'Adivina la palabra',
      'word_was': 'Se decía que',
      'next_round_starting': 'Próxima ronda comenzando...',
      'time_up': '¡Se acabó el tiempo!',
      'well_done': '¡Bien hecho!',
      'whos_next': '¿Quién sigue?',
      'interval': 'Intervalo',
      'host': 'Anfitrión',
      'you': 'Tú',
      'correct': '¡Correcto!',
      'good_job': '¡Buen trabajo!',
      'chat': 'Charlar',
      'send': 'Enviar',
      'type_message': 'Escribe un mensaje...',
      'answers_chat': 'Respuestas Chat',
      'general_chat': 'Chat general',
      'team_chat': 'Chat de equipo',

      // Room Preferences Screen
      'room_preferences': 'Preferencias de habitación',
      'select_language': 'Seleccionar idioma',
      'select_points': 'Seleccionar puntos',
      'select_category': 'Seleccionar categoría',
      'voice_enabled': 'Habilitado por voz',
      'select_team': 'Equipo seleccionado',
      'team_selection': 'Selección de equipo',
      'blue_team': 'Equipo Azul',
      'orange_team': 'Equipo naranja',

      // Profile & Settings
      'edit_profile': 'Editar perfil',
      'profile_and_accounts': 'Perfil y cuenta',
      'username': 'Nombre de usuario',
      'email': 'Correo electrónico',
      'phone': 'Teléfono',
      'logout': 'Cerrar sesión',
      'delete_account': 'Eliminar cuenta',
      'version': 'Versión',
      'about': 'Acerca de',
      'privacy_policy': 'política de privacidad',
      'terms_and_conditions': 'Términos y condiciones',
      'sound': 'Sonido',
      'privacy_and_safety': 'Privacidad y seguridad',
      'contact': 'Contacto',
      'rate_app': 'Califica la aplicación',
      'connect_us_at': 'CONECTA CON NOSOTROS EN',
      'are_you_sure_logout': '¿Seguro que quieres cerrar sesión?',
      'loading_ads': 'Cargando anuncios...',

      // Sign In
      'ink_battle': 'Batalla de tinta',
      'sign_in_with_google': 'Iniciar sesión con Google',
      'sign_in_with_facebook': 'Inicia sesión con Facebook',
      'signing_in': 'Iniciando sesión...',
      'or': 'O',
      'play_as_guest': 'Juega como invitado',
      'progress_not_saved': 'Es posible que no se guarde el progreso',

      // Home Screen
      'play_random': 'Jugar al azar',

      // Instructions
      'instructions': 'Instrucciones',
      'tutorial_guide': 'Guía del tutorial',
      'instructions_text':
          '¡Toca la pantalla para comenzar tu aventura! Usa las flechas para navegar por los niveles. Recoge monedas completando desafíos. Evita obstáculos para mantener tu puntuación alta. Cambia de modo para una experiencia diferente.',

      // Common
      'ok': 'DE ACUERDO',
      'cancel': 'Cancelar',
      'yes': 'Sí',
      'no': 'No',
      'confirm': 'Confirmar',
      'back': 'Atrás',
      'close': 'Cerca',
      'loading': 'Cargando...',
      'error': 'Error',
      'success': 'Éxito',
      'warning': 'Advertencia',
      'info': 'Información',

      // Messages
      'insufficient_coins': 'Monedas insuficientes',
      'room_full': 'La habitación está llena',
      'room_not_found': 'Habitación no encontrada',
      'already_in_room': 'Ya en la habitación',
      'connection_lost': 'Conexión perdida',
      'reconnecting': 'Reconectando...',
      'connected': 'Conectado',
      'disconnected': 'Desconectado',

      // Languages
      'hindi': 'hindi',
      'telugu': 'Telugu',
      'english': 'Inglés',

      // Countries
      'india': 'India',
      'usa': 'EE.UU',
      'uk': 'Reino Unido',
      'japan': 'Japón',
      'spain': 'España',
      'portugal': 'Portugal',
      'france': 'Francia',
      'germany': 'Alemania',
      'russia': 'Rusia',

      // Create Room & Join Room
      'please_enter_room_name': 'Por favor, introduce el nombre de la sala',
      'failed_to_create_room': 'Error al crear la sala',
      'code_copied_clipboard': '¡Código copiado al portapapeles!',
      'room_created': '¡Sala creada!',
      'share_code_with_friends': 'Comparte este código con tus amigos:',
      'enter_room': 'Entrar a la sala',
      'create_room_configure_lobby':
          'Crea una sala y configura los ajustes en el vestíbulo',
      'enter_room_name_hint': 'Introduce el nombre de la sala',
      'room_code_share_info':
          'Puedes compartir el código de la sala con amigos después de crearla',
      'create_team_room': 'Crear sala de equipo',
      'please_check_code':
          'Por favor, verifica el código e inténtalo de nuevo.',

      // Random Match Screen
      'random_match': 'Partida aleatoria',
      'select_target_points': 'Seleccionar puntos objetivo',
      'play_random_coins': 'Jugar aleatorio (250 monedas)',
      'please_select_all_fields': 'Por favor, selecciona todos los campos',
      'failed_to_find_match': 'Error al encontrar partida',
      'watch_ads_coming_soon': '¡La función de ver anuncios llegará pronto!',
      'buy_coins_coming_soon': '¡La función de comprar monedas llegará pronto!',
      'insufficient_coins_title': 'Monedas insuficientes',
      'insufficient_coins_message': 'No tienes suficientes monedas para unirte. Mira anuncios o compra monedas para continuar.',
      'watch_ads': 'Ver anuncios',
      'buy_coins': 'Comprar monedas',
      'no_matches_found': 'No se encontraron partidas',
      'no_matches_message': 'Ninguna sala pública coincide con tus preferencias. Prueba con una configuración diferente o crea una nueva sala.',
      'try_again': 'Intentar de nuevo',
      'selected': 'Seleccionado',
      'team_a_is_full': 'El equipo A está completo',
      'team_b_is_full': 'El equipo B está completo',
      'please_select_the_other_team': 'Por favor seleccione el otro equipo',

      'animals': 'Animales',
      'countries': 'Países',
      'food': 'Comida',
      'everyday_objects': 'Objetos cotidianos',
      'historical_events': 'Eventos históricos',
      'movies': 'Películas',
    },
    'pt': {
      // Guest Signup & Profile
      'enter_username': 'Digite o nome de usuário',
      'language': 'Linguagem',
      'country': 'País',
      'save': 'Salvar',
      'skip': 'Pular',
      'next': 'Próximo',
      'please_fill_all_fields': 'Por favor, preencha todos os campos',
      'coins': 'Moedas',
      'welcome': 'Bem-vindo',

      // Home Screen
      'home': 'Lar',
      'play': 'Jogar',
      'profile': 'Perfil',
      'settings': 'Configurações',
      'leaderboard': 'Classificação',
      'friends': 'Amigos',
      'shop': 'Comprar',
      'daily_bonus': 'Bônus diário',
      'claim': 'Alegar',
      'claimed': 'Reivindicado',

      // Multiplayer Screen
      'multiplayer': 'Multijogador',
      'create_room': 'Criar espaço',
      'join_room': 'Entre na sala',
      'room_code': 'Código do quarto',
      'join': 'Juntar',
      'players': 'Jogadores',
      'waiting_for_players': 'Aguardando jogadores...',
      'start_game': 'Iniciar jogo',
      'leave': 'Deixar',
      'mode': 'Modo',
      'individual': 'Individual',
      'team': 'Equipe',
      'language_filter': 'Linguagem',
      'points': 'Pontos',
      'category': 'Categoria',
      'all': 'Todos',

      // Game Room Screen
      'game_room': 'Sala de jogos',
      'gameplay': 'Jogabilidade',
      'drawing': 'Desenho',
      'guessing': 'Adivinhação',
      'selecting_drawer': 'Selecionando a gaveta...',
      'choosing_word': 'Escolha uma palavra!',
      'drawer_is_choosing': 'A gaveta está escolhendo...',
      'draw': 'Empate',
      'guess_the_word': 'Adivinhe a palavra',
      'word_was': 'A palavra era',
      'next_round_starting': 'Próxima rodada começa...',
      'time_up': 'Tempo esgotado!',
      'well_done': 'Bom trabalho!',
      'whos_next': 'Quem será o próximo?',
      'interval': 'Intervalo',
      'host': 'Hospedar',
      'you': 'Você',
      'correct': 'Correto!',
      'good_job': 'Bom trabalho!',
      'chat': 'Bater papo',
      'send': 'Enviar',
      'type_message': 'Digite uma mensagem...',
      'answers_chat': 'Chat de respostas',
      'general_chat': 'Bate-papo geral',
      'team_chat': 'Bate-papo em equipe',

      // Room Preferences Screen
      'room_preferences': 'Preferências de quarto',
      'select_language': 'Selecione o idioma',
      'select_points': 'Selecione os pontos',
      'select_category': 'Selecione a categoria',
      'voice_enabled': 'Habilitado por voz',
      'select_team': 'Selecione a equipe',
      'team_selection': 'Seleção da Equipe',
      'blue_team': 'Equipe Azul',
      'orange_team': 'Equipe Laranja',

      // Profile & Settings
      'edit_profile': 'Editar perfil',
      'profile_and_accounts': 'Perfil e conta',
      'username': 'Nome de usuário',
      'email': 'E-mail',
      'phone': 'Telefone',
      'logout': 'Sair',
      'delete_account': 'Excluir conta',
      'version': 'Versão',
      'about': 'Sobre',
      'privacy_policy': 'política de Privacidade',
      'terms_and_conditions': 'Termos e Condições',
      'sound': 'Som',
      'privacy_and_safety': 'Privacidade',
      'contact': 'Contato',
      'rate_app': 'Avalie o aplicativo',
      'connect_us_at': 'CONECTE-SE CONOSCO EM',
      'are_you_sure_logout': 'Tem certeza de que deseja sair?',
      'loading_ads': 'Carregando anúncios...',

      // Sign In
      'ink_battle': 'Batalha de Tinta',
      'sign_in_with_google': 'Iniciar sessão com o Google',
      'sign_in_with_facebook': 'Entrar com o Facebook',
      'signing_in': 'Entrando...',
      'or': 'Ou',
      'play_as_guest': 'Jogar como convidado',
      'progress_not_saved': 'O progresso pode não ser salvo.',

      // Home Screen
      'play_random': 'Jogar Aleatoriamente',

      // Instructions
      'instructions': 'Instruções',
      'tutorial_guide': 'Guia de tutoriais',
      'instructions_text':
          'Toque na tela para começar sua aventura! Use as setas para navegar pelos níveis. Colete moedas completando desafios. Desvie dos obstáculos para manter sua pontuação alta. Alterne entre os modos para uma experiência diferente.',

      // Common
      'ok': 'OK',
      'cancel': 'Cancelar',
      'yes': 'Sim',
      'no': 'Não',
      'confirm': 'Confirmar',
      'back': 'Voltar',
      'close': 'Fechar',
      'loading': 'Carregando...',
      'error': 'Erro',
      'success': 'Sucesso',
      'warning': 'Aviso',
      'info': 'Informações',

      // Messages
      'insufficient_coins': 'Moedas insuficientes',
      'room_full': 'O quarto está lotado.',
      'room_not_found': 'Quarto não encontrado',
      'already_in_room': 'Já estou no quarto.',
      'connection_lost': 'Conexão perdida',
      'reconnecting': 'Reconectando...',
      'connected': 'Conectado',
      'disconnected': 'Desconectado',

      // Languages
      'hindi': 'hindi',
      'telugu': 'Telugu',
      'english': 'Inglês',

      // Countries
      'india': 'Índia',
      'usa': 'EUA',
      'uk': 'Reino Unido',
      'japan': 'Japão',
      'spain': 'Espanha',
      'portugal': 'Portugal',
      'france': 'França',
      'germany': 'Alemanha',
      'russia': 'Rússia',

      // Create Room & Join Room
      'please_enter_room_name': 'Por favor, insira o nome da sala',
      'failed_to_create_room': 'Falha ao criar sala',
      'code_copied_clipboard': 'Código copiado para a área de transferência!',
      'room_created': 'Sala criada!',
      'share_code_with_friends': 'Compartilhe este código com seus amigos:',
      'enter_room': 'Entrar na sala',
      'create_room_configure_lobby':
          'Crie uma sala e configure as definições no lobby',
      'enter_room_name_hint': 'Insira o nome da sala',
      'room_code_share_info':
          'Você pode compartilhar o código da sala com amigos após criá-la',
      'create_team_room': 'Criar sala de equipe',
      'please_check_code':
          'Por favor, verifique o código e tente novamente.',

      // Random Match Screen
      'random_match': 'Partida Aleatória',
      'select_target_points': 'Selecione os pontos alvo',
      'play_random_coins': 'Jogar Aleatório (250 moedas)',
      'please_select_all_fields': 'Por favor, selecione todos os campos',
      'failed_to_find_match': 'Falha ao encontrar partida',
      'watch_ads_coming_soon': 'Recurso de assistir anúncios em breve!',
      'buy_coins_coming_soon': 'Recurso de comprar moedas em breve!',
      'insufficient_coins_title': 'Moedas insuficientes',
      'insufficient_coins_message': 'Você não tem moedas suficientes para entrar. Assista a anúncios ou compre moedas para continuar.',
      'watch_ads': 'Assistir anúncios',
      'buy_coins': 'Comprar moedas',
      'no_matches_found': 'Nenhuma partida encontrada',
      'no_matches_message': 'Nenhuma sala pública corresponde às suas preferências. Tente configurações diferentes ou crie uma nova sala.',
      'try_again': 'Tente novamente',
      'selected': 'Selecionado',
      'team_a_is_full': 'A equipe A está cheia',
      'team_b_is_full': 'A equipe B está cheia',
      'please_select_the_other_team': 'Por favor selecione a outra equipe',

      'animals': 'Animais',
      'countries': 'Países',
      'food': 'Comida',
      'everyday_objects': 'Objetos do dia a dia',
      'historical_events': 'Eventos históricos',
      'movies': 'Filmes',
    },
    'fr': {
      // Guest Signup & Profile
      'enter_username': 'Saisissez votre nom d\'utilisateur',
      'language': 'Langue',
      'country': 'Pays',
      'save': 'Sauvegarder',
      'skip': 'Sauter',
      'next': 'Suivant',
      'please_fill_all_fields': 'Veuillez remplir tous les champs',
      'coins': 'Pièces',
      'welcome': 'Accueillir',

      // Home Screen
      'home': 'Maison',
      'play': 'Jouer',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'leaderboard': 'Classement',
      'friends': 'Amis',
      'shop': 'Boutique',
      'daily_bonus': 'Bonus quotidien',
      'claim': 'Réclamer',
      'claimed': 'Réclamé',

      // Multiplayer Screen
      'multiplayer': 'Multijoueur',
      'create_room': 'Créer de la place',
      'join_room': 'Rejoindre la salle',
      'room_code': 'Code de la chambre',
      'join': 'Rejoindre',
      'players': 'Joueurs',
      'waiting_for_players': 'En attente de joueurs...',
      'start_game': 'Démarrer la partie',
      'leave': 'Partir',
      'mode': 'Mode',
      'individual': 'Individuel',
      'team': 'Équipe',
      'language_filter': 'Langue',
      'points': 'Points',
      'category': 'Catégorie',
      'all': 'Tous',

      // Game Room Screen
      'game_room': 'Salle de jeux',
      'gameplay': 'Gameplay',
      'drawing': 'Dessin',
      'guessing': 'Deviner',
      'selecting_drawer': 'Sélection du tiroir...',
      'choosing_word': 'Choisissez un mot !',
      'drawer_is_choosing': 'Le tiroir choisit...',
      'draw': 'Dessiner',
      'guess_the_word': 'Devinez le mot',
      'word_was': 'Le mot était',
      'next_round_starting': 'Prochain tour à partir de...',
      'time_up': 'C\'est terminé !',
      'well_done': 'Bien joué!',
      'whos_next': 'Qui est le prochain ?',
      'interval': 'Intervalle',
      'host': 'Hôte',
      'you': 'Toi',
      'correct': 'Correct!',
      'good_job': 'Bon travail!',
      'chat': 'Chat',
      'send': 'Envoyer',
      'type_message': 'Saisissez un message...',
      'answers_chat': 'Réponses au chat',
      'general_chat': 'Discussion générale',
      'team_chat': 'Discussion d\'équipe',

      // Room Preferences Screen
      'room_preferences': 'Préférences de chambre',
      'select_language': 'Sélectionner la langue',
      'select_points': 'Sélectionner des points',
      'select_category': 'Sélectionner une catégorie',
      'voice_enabled': 'Activation vocale',
      'select_team': 'Équipe de sélection',
      'team_selection': 'Sélection de l\'équipe',
      'blue_team': 'Équipe bleue',
      'orange_team': 'Équipe Orange',

      // Profile & Settings
      'edit_profile': 'Modifier le profil',
      'profile_and_accounts': 'Profil et compte',
      'username': 'Nom d\'utilisateur',
      'email': 'E-mail',
      'phone': 'Téléphone',
      'logout': 'Déconnexion',
      'delete_account': 'Supprimer le compte',
      'version': 'Version',
      'about': 'À propos',
      'privacy_policy': 'politique de confidentialité',
      'terms_and_conditions': 'Conditions générales',
      'sound': 'Son',
      'privacy_and_safety': 'Confidentialité et sécurité',
      'contact': 'Contact',
      'rate_app': 'Évaluez l\'application',
      'connect_us_at': 'CONTACTEZ-NOUS SUR',
      'are_you_sure_logout': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'loading_ads': 'Chargement des annonces...',

      // Sign In
      'ink_battle': 'Bataille d\'encre',
      'sign_in_with_google': 'Se connecter avec Google',
      'sign_in_with_facebook': 'Se connecter avec Facebook',
      'signing_in': 'Connexion...',
      'or': 'Ou',
      'play_as_guest': 'Jouer en tant qu\'invité',
      'progress_not_saved':
          'Les progrès réalisés ne seront peut-être pas sauvegardés.',

      // Home Screen
      'play_random': 'Jouer au hasard',

      // Instructions
      'instructions': 'Instructions',
      'tutorial_guide': 'Guide d\'utilisation',
      'instructions_text':
          'Touchez l\'écran pour commencer votre aventure ! Utilisez les flèches pour naviguer dans les niveaux. Collectez des pièces en relevant des défis. Évitez les obstacles pour obtenir un score élevé. Changez de mode pour une expérience différente.',

      // Common
      'ok': 'D\'ACCORD',
      'cancel': 'Annuler',
      'yes': 'Oui',
      'no': 'Non',
      'confirm': 'Confirmer',
      'back': 'Dos',
      'close': 'Fermer',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'warning': 'Avertissement',
      'info': 'Info',

      // Messages
      'insufficient_coins': 'Pièces insuffisantes',
      'room_full': 'La chambre est pleine.',
      'room_not_found': 'Chambre introuvable',
      'already_in_room': 'Déjà dans la chambre',
      'connection_lost': 'Connexion perdue',
      'reconnecting': 'Se reconnecter...',
      'connected': 'Connecté',
      'disconnected': 'Déconnecté',

      // Languages
      'hindi': 'hindi',
      'telugu': 'Telugu',
      'english': 'Anglais',

      // Countries
      'india': 'Inde',
      'usa': 'USA',
      'uk': 'ROYAUME-UNI',
      'japan': 'Japon',
      'spain': 'Espanha',
      'portugal': 'Portugal',
      'france': 'França',
      'germany': 'Alemanha',
      'russia': 'Rússia',

      // Create Room & Join Room
      'please_enter_room_name': 'Veuillez entrer le nom de la salle',
      'failed_to_create_room': 'Échec de la création de la salle',
      'code_copied_clipboard': 'Code copié dans le presse-papiers !',
      'room_created': 'Salle créée !',
      'share_code_with_friends': 'Partagez ce code avec vos amis :',
      'enter_room': 'Entrer dans la salle',
      'create_room_configure_lobby':
          'Créer une salle et configurer les paramètres dans le lobby',
      'enter_room_name_hint': 'Entrez le nom de la salle',
      'room_code_share_info':
          'Vous pouvez partager le code de la salle avec des amis après la création',
      'create_team_room': 'Créer une salle d\'équipe',
      'please_check_code':
          'Veuillez vérifier le code et réessayer.',

      // Random Match Screen
      'random_match': 'Match aléatoire',
      'select_target_points': 'Sélectionner les points cibles',
      'play_random_coins': 'Jouer en aléatoire (250 pièces)',
      'please_select_all_fields': 'Veuillez sélectionner tous les champs',
      'failed_to_find_match': 'Aucun match trouvé',
      'watch_ads_coming_soon': 'Les publicités arrivent bientôt !',
      'buy_coins_coming_soon': 'L\'achat de pièces arrive bientôt !',
      'insufficient_coins_title': 'Pièces insuffisantes',
      'insufficient_coins_message': 'Vous n\'avez pas assez de pièces pour rejoindre. Regardez des publicités ou achetez des pièces pour continuer.',
      'watch_ads': 'Regarder des pubs',
      'buy_coins': 'Acheter des pièces',
      'no_matches_found': 'Aucun match trouvé',
      'no_matches_message': 'Aucune salle publique ne correspond à vos préférences. Essayez d\'autres paramètres ou créez une nouvelle salle.',
      'try_again': 'Réessayer',
      'selected': 'Sélectionné',
      'team_a_is_full': 'L\'équipe A est complète',
      'team_b_is_full': 'L\'équipe B est complète',
      'please_select_the_other_team': 'Veuillez sélectionner l\'autre équipe',

      'animals': 'Animaux',
      'countries': 'Pays',
      'food': 'Nourriture',
      'everyday_objects': 'Objets du quotidien',
      'historical_events': 'Événements historiques',
      'movies': 'Films',
    },
    'de': {
      // Guest Signup & Profile
      'enter_username': 'Benutzernamen eingeben',
      'language': 'Sprache',
      'country': 'Land',
      'save': 'Speichern',
      'skip': 'Überspringen',
      'next': 'Nächste',
      'please_fill_all_fields': 'Bitte füllen Sie alle Felder aus',
      'coins': 'Münzen',
      'welcome': 'Willkommen',

      // Home Screen
      'home': 'Heim',
      'play': 'Spielen',
      'profile': 'Profil',
      'settings': 'Einstellungen',
      'leaderboard': 'Rangliste',
      'friends': 'Freunde',
      'shop': 'Geschäft',
      'daily_bonus': 'Tagesbonus',
      'claim': 'Beanspruchen',
      'claimed': 'Behauptet',

      // Multiplayer Screen
      'multiplayer': 'Mehrspieler',
      'create_room': 'Raum erstellen',
      'join_room': 'Beitrittsraum',
      'room_code': 'Zimmercode',
      'join': 'Verbinden',
      'players': 'Spieler',
      'waiting_for_players': 'Warten auf Spieler...',
      'start_game': 'Spiel starten',
      'leave': 'Verlassen',
      'mode': 'Modus',
      'individual': 'Person',
      'team': 'Team',
      'language_filter': 'Sprache',
      'points': 'Punkte',
      'category': 'Kategorie',
      'all': 'Alle',

      // Game Room Screen
      'game_room': 'Spielzimmer',
      'gameplay': 'Gameplay',
      'drawing': 'Zeichnung',
      'guessing': 'Raten',
      'selecting_drawer': 'Schublade wird ausgewählt...',
      'choosing_word': 'Wähle ein Wort!',
      'drawer_is_choosing': 'Die Schublade wählt aus...',
      'draw': 'Ziehen',
      'guess_the_word': 'Errate das Wort',
      'word_was': 'Es hieß',
      'next_round_starting': 'Nächste Runde beginnt...',
      'time_up': 'Zeit abgelaufen!',
      'well_done': 'Gut gemacht!',
      'whos_next': 'Wer ist der Nächste?',
      'interval': 'Intervall',
      'host': 'Gastgeber',
      'you': 'Du',
      'correct': 'Richtig!',
      'good_job': 'Gute Arbeit!',
      'chat': 'Chat',
      'send': 'Schicken',
      'type_message': 'Geben Sie eine Nachricht ein...',
      'answers_chat': 'Antworten-Chat',
      'general_chat': 'Allgemeiner Chat',
      'team_chat': 'Team-Chat',

      // Room Preferences Screen
      'room_preferences': 'Zimmerpräferenzen',
      'select_language': 'Sprache auswählen',
      'select_points': 'Punkte auswählen',
      'select_category': 'Kategorie auswählen',
      'voice_enabled': 'Sprachfähig',
      'select_team': 'Team auswählen',
      'team_selection': 'Teamauswahl',
      'blue_team': 'Blaues Team',
      'orange_team': 'Orange Team',

      // Profile & Settings
      'edit_profile': 'Profil bearbeiten',
      'profile_and_accounts': 'Profil & Konto',
      'username': 'Benutzername',
      'email': 'E-Mail',
      'phone': 'Telefon',
      'logout': 'Abmelden',
      'delete_account': 'Konto löschen',
      'version': 'Version',
      'about': 'Um',
      'privacy_policy': 'Datenschutzrichtlinie',
      'terms_and_conditions': 'Allgemeine Geschäftsbedingungen',
      'sound': 'Klang',
      'privacy_and_safety': 'Datenschutz und Sicherheit',
      'contact': 'Kontakt',
      'rate_app': 'App bewerten',
      'connect_us_at': 'VERBINDEN SIE SICH MIT UNS UNTER',
      'are_you_sure_logout': 'Möchten Sie sich wirklich abmelden?',
      'loading_ads': 'Werbung wird geladen...',

      // Sign In
      'ink_battle': 'Tintenschlacht',
      'sign_in_with_google': 'Mit Google anmelden',
      'sign_in_with_facebook': 'Mit Facebook anmelden',
      'signing_in': 'Anmelden...',
      'or': 'Oder',
      'play_as_guest': 'Als Gast spielen',
      'progress_not_saved':
          'Der Fortschritt wird möglicherweise nicht gespeichert.',

      // Home Screen
      'play_random': 'Zufällige Auswahl',

      // Instructions
      'instructions': 'Anweisungen',
      'tutorial_guide': 'Tutorial-Anleitung',
      'instructions_text':
          'Tippe auf den Bildschirm, um dein Spielabenteuer zu starten! Benutze die Pfeile, um durch die Level zu navigieren. Sammle Münzen, indem du Herausforderungen meisterst. Weiche Hindernissen aus, um deinen Punktestand hoch zu halten. Wechsle den Modus für ein anderes Spielerlebnis.',

      // Common
      'ok': 'OK',
      'cancel': 'Stornieren',
      'yes': 'Ja',
      'no': 'NEIN',
      'confirm': 'Bestätigen',
      'back': 'Zurück',
      'close': 'Schließen',
      'loading': 'Laden...',
      'error': 'Fehler',
      'success': 'Erfolg',
      'warning': 'Warnung',
      'info': 'Info',

      // Messages
      'insufficient_coins': 'Unzureichende Münzen',
      'room_full': 'Das Zimmer ist voll',
      'room_not_found': 'Zimmer nicht gefunden',
      'already_in_room': 'Bereits im Zimmer',
      'connection_lost': 'Verbindung unterbrochen',
      'reconnecting': 'Verbindung wird wiederhergestellt...',
      'connected': 'Verbunden',
      'disconnected': 'Getrennt',

      // Languages
      'hindi': 'Hindi',
      'telugu': 'Telugu',
      'english': 'Englisch',

      // Countries
      'india': 'Indien',
      'usa': 'USA',
      'uk': 'Vereinigtes Königreich',
      'japan': 'Japan',
      'spain': 'Espanha',
      'portugal': 'Portugal',
      'france': 'França',
      'germany': 'Alemanha',
      'russia': 'Rússia',

      // Create Room & Join Room
      'please_enter_room_name': 'Bitte geben Sie den Raumnamen ein',
      'failed_to_create_room': 'Erstellung des Raumes fehlgeschlagen',
      'code_copied_clipboard': 'Code in die Zwischenablage kopiert!',
      'room_created': 'Raum erstellt!',
      'share_code_with_friends': 'Teilen Sie diesen Code mit Ihren Freunden:',
      'enter_room': 'Raum betreten',
      'create_room_configure_lobby':
          'Erstellen Sie einen Raum und konfigurieren Sie die Einstellungen in der Lobby',
      'enter_room_name_hint': 'Geben Sie den Raumnamen ein',
      'room_code_share_info':
          'Sie können den Raumcode nach der Erstellung mit Freunden teilen',
      'create_team_room': 'Teamraum erstellen',
      'please_check_code':
          'Bitte überprüfen Sie den Code und versuchen Sie es erneut.',

      // Random Match Screen
      'random_match': 'Zufälliges Spiel',
      'select_target_points': 'Zielpunkte auswählen',
      'play_random_coins': 'Zufällig spielen (250 Münzen)',
      'please_select_all_fields': 'Bitte wählen Sie alle Felder aus',
      'failed_to_find_match': 'Kein Spiel gefunden',
      'watch_ads_coming_soon': 'Werbung ansehen kommt bald!',
      'buy_coins_coming_soon': 'Münzkauf kommt bald!',
      'insufficient_coins_title': 'Nicht genügend Münzen',
      'insufficient_coins_message': 'Sie haben nicht genügend Münzen, um beizutreten. Sehen Sie Werbung oder kaufen Sie Münzen, um fortzufahren.',
      'watch_ads': 'Werbung ansehen',
      'buy_coins': 'Münzen kaufen',
      'no_matches_found': 'Keine Spiele gefunden',
      'no_matches_message': 'Keine öffentlichen Räume entsprechen Ihren Einstellungen. Versuchen Sie andere Einstellungen oder erstellen Sie einen neuen Raum.',
      'try_again': 'Erneut versuchen',
      'selected': 'Ausgewählt',
      'team_a_is_full': 'Team A ist voll',
      'team_b_is_full': 'Team B ist voll',
      'please_select_the_other_team': 'Bitte wählen Sie das andere Team aus',

      'animals': 'Tiere',
      'countries': 'Länder',
      'food': 'Essen',
      'everyday_objects': 'Alltagsgegenstände',
      'historical_events': 'Historische Ereignisse',
      'movies': 'Filme',
    },
    'ru': {
      // Guest Signup & Profile
      'enter_username': 'Введите имя пользователя',
      'language': 'Язык',
      'country': 'Страна',
      'save': 'Сохранять',
      'skip': 'Пропускать',
      'next': 'Следующий',
      'please_fill_all_fields': 'Пожалуйста, заполните все поля',
      'coins': 'Монеты',
      'welcome': 'Добро пожаловать',

      // Home Screen
      'home': 'Дом',
      'play': 'Играть',
      'profile': 'Профиль',
      'settings': 'Настройки',
      'leaderboard': 'Таблица лидеров',
      'friends': 'Друзья',
      'shop': 'Магазин',
      'daily_bonus': 'Ежедневный бонус',
      'claim': 'Требовать',
      'claimed': 'Заявлено',

      // Multiplayer Screen
      'multiplayer': 'Многопользовательский режим',
      'create_room': 'Создать комнату',
      'join_room': 'Присоединиться к комнате',
      'room_code': 'Код комнаты',
      'join': 'Присоединиться',
      'players': 'Игроки',
      'waiting_for_players': 'Ждем игроков...',
      'start_game': 'Начать игру',
      'leave': 'Оставлять',
      'mode': 'Режим',
      'individual': 'Индивидуальный',
      'team': 'Команда',
      'language_filter': 'Язык',
      'points': 'Очки',
      'category': 'Категория',
      'all': 'Все',

      // Game Room Screen
      'game_room': 'Игровая комната',
      'gameplay': 'Геймплей',
      'drawing': 'Рисунок',
      'guessing': 'Угадывание',
      'selecting_drawer': 'Выбор ящика...',
      'choosing_word': 'Выберите слово!',
      'drawer_is_choosing': 'Ящик выбирает...',
      'draw': 'Рисовать',
      'guess_the_word': 'Угадай слово',
      'word_was': 'Слово было',
      'next_round_starting': 'Следующий раунд начинается...',
      'time_up': 'Время вышло!',
      'well_done': 'Отличная работа!',
      'whos_next': 'Кто следующий?',
      'interval': 'Интервал',
      'host': 'Хозяин',
      'you': 'Ты',
      'correct': 'Правильный!',
      'good_job': 'Хорошая работа!',
      'chat': 'Чат',
      'send': 'Отправлять',
      'type_message': 'Введите сообщение...',
      'answers_chat': 'Ответы Чат',
      'general_chat': 'Общий чат',
      'team_chat': 'Командный чат',

      // Room Preferences Screen
      'room_preferences': 'Предпочтения по номеру',
      'select_language': 'Выберите язык',
      'select_points': 'Выберите точки',
      'select_category': 'Выберите категорию',
      'voice_enabled': 'С поддержкой голоса',
      'select_team': 'Выбрать команду',
      'team_selection': 'Выбор команды',
      'blue_team': 'Синяя команда',
      'orange_team': 'Оранжевая команда',

      // Profile & Settings
      'edit_profile': 'Редактировать профиль',
      'profile_and_accounts': 'Профиль и аккаунт',
      'username': 'Имя пользователя',
      'email': 'Электронная почта',
      'phone': 'Телефон',
      'logout': 'Выйти',
      'delete_account': 'Удалить аккаунт',
      'version': 'Версия',
      'about': 'О',
      'privacy_policy': 'политика конфиденциальности',
      'terms_and_conditions': 'Условия и положения',
      'sound': 'Звук',
      'privacy_and_safety': 'Конфиденциальность и безопасность',
      'contact': 'Контакт',
      'rate_app': 'Оценить приложение',
      'connect_us_at': 'Свяжитесь с нами по адресу',
      'are_you_sure_logout': 'Вы уверены, что хотите выйти?',
      'loading_ads': 'Загрузка рекламы...',

      // Sign In
      'ink_battle': 'Чернильная битва',
      'sign_in_with_google': 'Войти через Google',
      'sign_in_with_facebook': 'Войти через Facebook',
      'signing_in': 'Вход в систему...',
      'or': 'Или',
      'play_as_guest': 'Играть как гость',
      'progress_not_saved': 'Прогресс не может быть сохранен',

      // Home Screen
      'play_random': 'Играть в случайном порядке',

      // Instructions
      'instructions': 'Инструкции',
      'tutorial_guide': 'Учебное руководство',
      'instructions_text':
          'Коснитесь экрана, чтобы начать своё игровое приключение! Используйте стрелки для перемещения по уровням. Собирайте монеты, выполняя задания. Избегайте препятствий, чтобы набирать очки. Переключайтесь между режимами для разнообразия.',

      // Common
      'ok': 'ХОРОШО',
      'cancel': 'Отмена',
      'yes': 'Да',
      'no': 'Нет',
      'confirm': 'Подтверждать',
      'back': 'Назад',
      'close': 'Закрывать',
      'loading': 'Загрузка...',
      'error': 'Ошибка',
      'success': 'Успех',
      'warning': 'Предупреждение',
      'info': 'Информация',

      // Messages
      'insufficient_coins': 'Недостаточно монет',
      'room_full': 'Комната полна',
      'room_not_found': 'Комната не найдена',
      'already_in_room': 'Уже в комнате',
      'connection_lost': 'Соединение потеряно',
      'reconnecting': 'Повторное подключение...',
      'connected': 'Подключен',
      'disconnected': 'Отключен',

      // Languages
      'hindi': 'хинди',
      'telugu': 'телугу',
      'english': 'Английский',

      // Countries
      'india': 'Индия',
      'usa': 'США',
      'uk': 'Великобритания',
      'japan': 'Япония',
      'spain': 'Испания',
      'portugal': 'Португалия',
      'france': 'Франция',
      'germany': 'Германия',
      'russia': 'Россия',

      // Create Room & Join Room
      'please_enter_room_name': 'Пожалуйста, введите название комнаты',
      'failed_to_create_room': 'Не удалось создать комнату',
      'code_copied_clipboard': 'Код скопирован в буфер обмена!',
      'room_created': 'Комната создана!',
      'share_code_with_friends': 'Поделитесь этим кодом с друзьями:',
      'enter_room': 'Войти в комнату',
      'create_room_configure_lobby':
          'Создайте комнату и настройте параметры в лобби',
      'enter_room_name_hint': 'Введите название комнаты',
      'room_code_share_info':
          'Вы можете поделиться кодом комнаты с друзьями после создания',
      'create_team_room': 'Создать командную комнату',
      'please_check_code':
          'Пожалуйста, проверьте код и попробуйте снова.',

      // Random Match Screen
      'random_match': 'Случайный матч',
      'select_target_points': 'Выберите целевые очки',
      'play_random_coins': 'Случайная игра (250 монет)',
      'please_select_all_fields': 'Пожалуйста, заполните все поля',
      'failed_to_find_match': 'Не удалось найти матч',
      'watch_ads_coming_soon': 'Просмотр рекламы скоро будет доступен!',
      'buy_coins_coming_soon': 'Покупка монет скоро будет доступна!',
      'insufficient_coins_title': 'Недостаточно монет',
      'insufficient_coins_message': 'У вас недостаточно монет для входа. Посмотрите рекламу или купите монеты, чтобы продолжить.',
      'watch_ads': 'Смотреть рекламу',
      'buy_coins': 'Купить монеты',
      'no_matches_found': 'Матчи не найдены',
      'no_matches_message': 'Нет публичных комнат, соответствующих вашим предпочтениям. Попробуйте другие настройки или создайте новую комнату.',
      'try_again': 'Попробовать снова',
      'selected': 'Выбрано',
      'team_a_is_full': 'Команда A заполнена',
      'team_b_is_full': 'Команда B заполнена',
      'please_select_the_other_team': 'Пожалуйста, выберите другую команду',

      'animals': 'Животные',
      'countries': 'Страны',
      'food': 'Еда',
      'everyday_objects': 'Предметы быта',
      'historical_events': 'Исторические события',
      'movies': 'Фильмы',
    },
    'ja': {
      // Guest Signup & Profile
      'enter_username': 'ユーザー名を入力してください',
      'language': '言語',
      'country': '国',
      'save': '保存',
      'skip': 'スキップ',
      'next': '次',
      'please_fill_all_fields': 'すべてのフィールドに入力してください',
      'coins': 'コイン',
      'welcome': 'いらっしゃいませ',

      // Home Screen
      'home': '家',
      'play': '遊ぶ',
      'profile': 'プロフィール',
      'settings': '設定',
      'leaderboard': 'リーダーボード',
      'friends': '友達',
      'shop': '店',
      'daily_bonus': 'デイリーボーナス',
      'claim': '請求',
      'claimed': '主張した',

      // Multiplayer Screen
      'multiplayer': 'マルチプレイヤー',
      'create_room': 'ルームを作成',
      'join_room': 'ルームに参加する',
      'room_code': '部屋コード',
      'join': '参加する',
      'players': 'プレイヤー',
      'waiting_for_players': 'プレイヤーを待っています...',
      'start_game': 'ゲームを開始',
      'leave': '離れる',
      'mode': 'モード',
      'individual': '個人',
      'team': 'チーム',
      'language_filter': '言語',
      'points': 'ポイント',
      'category': 'カテゴリ',
      'all': '全て',

      // Game Room Screen
      'game_room': 'ゲームルーム',
      'gameplay': 'ゲームプレイ',
      'drawing': '描画',
      'guessing': '推測',
      'selecting_drawer': '引き出しを選択しています...',
      'choosing_word': '単語を選択してください!',
      'drawer_is_choosing': '引き出しを選択中です...',
      'draw': '描く',
      'guess_the_word': '単語を推測する',
      'word_was': '言葉は',
      'next_round_starting': '次のラウンドが始まります…',
      'time_up': '時間切れです！',
      'well_done': 'よくやった！',
      'whos_next': '次は誰？',
      'interval': '間隔',
      'host': 'ホスト',
      'you': 'あなた',
      'correct': '正しい！',
      'good_job': 'よくやった！',
      'chat': 'チャット',
      'send': '送信',
      'type_message': 'メッセージを入力してください...',
      'answers_chat': '回答チャット',
      'general_chat': '一般チャット',
      'team_chat': 'チームチャット',

      // Room Preferences Screen
      'room_preferences': '部屋の好み',
      'select_language': '言語を選択',
      'select_points': 'ポイントを選択',
      'select_category': 'カテゴリーを選択',
      'voice_enabled': '音声対応',
      'select_team': 'チームを選択',
      'team_selection': 'チーム選択',
      'blue_team': 'ブルーチーム',
      'orange_team': 'オレンジチーム',

      // Profile & Settings
      'edit_profile': 'プロフィールを編集',
      'profile_and_accounts': 'プロフィールとアカウント',
      'username': 'ユーザー名',
      'email': 'メール',
      'phone': '電話',
      'logout': 'ログアウト',
      'delete_account': 'アカウントを削除',
      'version': 'バージョン',
      'about': 'について',
      'privacy_policy': 'プライバシーポリシー',
      'terms_and_conditions': '利用規約',
      'sound': '音',
      'privacy_and_safety': 'プライバシーと安全性',
      'contact': '接触',
      'rate_app': 'アプリを評価する',
      'connect_us_at': '私たちとつながる',
      'are_you_sure_logout': 'ログアウトしてもよろしいですか?',
      'loading_ads': '広告を読み込んでいます...',

      // Sign In
      'ink_battle': 'インクバトル',
      'sign_in_with_google': 'Googleでログイン',
      'sign_in_with_facebook': 'Facebookでサインイン',
      'signing_in': 'サインインしています...',
      'or': 'または',
      'play_as_guest': 'ゲストとしてプレイ',
      'progress_not_saved': '進行状況は保存されない可能性があります',

      // Home Screen
      'play_random': 'ランダム再生',

      // Instructions
      'instructions': '説明書',
      'tutorial_guide': 'チュートリアルガイド',
      'instructions_text':
          '画面をタップしてゲームアドベンチャーを始めましょう！矢印を使ってレベルを進みましょう。チャレンジをクリアしてコインを集めましょう。障害物を避けて高スコアを維持しましょう。モードを切り替えて、様々な体験を楽しみましょう。',

      // Common
      'ok': 'わかりました',
      'cancel': 'キャンセル',
      'yes': 'はい',
      'no': 'いいえ',
      'confirm': '確認する',
      'back': '戻る',
      'close': '近い',
      'loading': '読み込み中...',
      'error': 'エラー',
      'success': '成功',
      'warning': '警告',
      'info': '情報',

      // Messages
      'insufficient_coins': 'コインが足りない',
      'room_full': '部屋は満室です',
      'room_not_found': '部屋が見つかりません',
      'already_in_room': 'すでに部屋にいる',
      'connection_lost': '接続が失われました',
      'reconnecting': '再接続しています...',
      'connected': '接続',
      'disconnected': '切断',

      // Languages
      'hindi': 'ヒンディー語',
      'telugu': 'テルグ語',
      'english': '英語',

      // Countries
      'india': 'インド',
      'usa': 'アメリカ合衆国',
      'uk': '英国',
      'japan': '日本',
      'spain': 'スペイン',
      'portugal': 'ポルトガル',
      'france': 'フランス',
      'germany': 'ドイツ',
      'russia': 'ロシア',

      // Create Room & Join Room
      'please_enter_room_name': 'ルーム名を入力してください',
      'failed_to_create_room': 'ルームの作成に失敗しました',
      'code_copied_clipboard': 'コードをクリップボードにコピーしました！',
      'room_created': 'ルームが作成されました！',
      'share_code_with_friends': '友達にこのコードを共有：',
      'enter_room': 'ルームに入室',
      'create_room_configure_lobby':
          'ルームを作成し、ロビーで設定を行ってください',
      'enter_room_name_hint': 'ルーム名を入力',
      'room_code_share_info':
          '作成後にルームコードを友達と共有できます',
      'create_team_room': 'チームルームを作成',
      'please_check_code':
          'コードを確認して再試行してください。',

      // Random Match Screen
      'random_match': 'ランダムマッチ',
      'select_target_points': '目標ポイントを選択',
      'play_random_coins': 'ランダムプレイ (250コイン)',
      'please_select_all_fields': 'すべての項目を選択してください',
      'failed_to_find_match': 'マッチが見つかりませんでした',
      'watch_ads_coming_soon': '広告視聴機能は近日公開！',
      'buy_coins_coming_soon': 'コイン購入機能は近日公開！',
      'insufficient_coins_title': 'コイン不足',
      'insufficient_coins_message': '参加に必要なコインが足りません。広告を見るかコインを購入して続けてください。',
      'watch_ads': '広告を見る',
      'buy_coins': 'コインを購入',
      'no_matches_found': 'マッチが見つかりません',
      'no_matches_message': '条件に合うパブリックルームがありません。設定を変更するか、新しいルームを作成してください。',
      'try_again': '再試行',
      'selected': '選択済み',
      'team_a_is_full': 'チームAは満員です',
      'team_b_is_full': 'チームBは満員です',
      'please_select_the_other_team': '他のチームを選択してください',

      'animals': '動物',
      'countries': '国',
      'food': '食べ物',
      'everyday_objects': '日用品',
      'historical_events': '歴史的な出来事',
      'movies': '映画',
    },
    'pa': {
      // Guest Signup & Profile
      'enter_username': 'ਯੂਜ਼ਰਨੇਮ ਦਰਜ ਕਰੋ',
      'language': 'ਭਾਸ਼ਾ',
      'country': 'ਦੇਸ਼',
      'save': 'ਸੇਵ ਕਰੋ',
      'skip': 'ਛੱਡੋ',
      'next': 'ਅਗਲਾ',
      'please_fill_all_fields': 'ਕਿਰਪਾ ਕਰਕੇ ਸਾਰੇ ਖੇਤਰ ਭਰੋ',
      'coins': 'ਸਿੱਕੇ',
      'welcome': 'ਸਵਾਗਤ ਹੈ',

      // Home Screen
      'home': 'ਮੁੱਖ ਪੇਜ',
      'play': 'ਖੇਡੋ',
      'profile': 'ਪ੍ਰੋਫਾਈਲ',
      'settings': 'ਸੈਟਿੰਗਾਂ',
      'leaderboard': 'ਲੀਡਰਬੋਰਡ',
      'friends': 'ਦੋਸਤੋ',
      'shop': 'ਦੁਕਾਨ',
      'daily_bonus': 'ਰੋਜ਼ਾਨਾ ਬੋਨਸ',
      'claim': 'ਦਾਅਵਾ',
      'claimed': 'ਦਾਅਵਾ ਕੀਤਾ ਗਿਆ',

      // Multiplayer Screen
      'multiplayer': 'ਮਲਟੀਪਲੇਅਰ',
      'create_room': 'ਕਮਰਾ ਬਣਾਓ',
      'join_room': 'ਰੂਮ ਵਿੱਚ ਸ਼ਾਮਲ ਹੋਵੋ',
      'room_code': 'ਕਮਰਾ ਕੋਡ',
      'join': 'ਸ਼ਾਮਲ ਹੋਵੋ',
      'players': 'ਖਿਡਾਰੀ',
      'waiting_for_players': 'ਖਿਡਾਰੀਆਂ ਦੀ ਉਡੀਕ...',
      'start_game': 'ਖੇਡ ਸ਼ੁਰੂ ਕਰੋ',
      'leave': 'ਛੱਡੋ',
      'mode': 'ਮੋਡ',
      'individual': 'ਵਿਅਕਤੀਗਤ',
      'team': 'ਟੀਮ',
      'language_filter': 'ਭਾਸ਼ਾ',
      'points': 'ਅੰਕ',
      'category': 'ਸ਼੍ਰੇਣੀ',
      'all': 'ਸਾਰੇ',

      // Game Room Screen
      'game_room': 'ਖੇਡ ਕਮਰਾ',
      'gameplay': 'ਗੇਮਪਲੇ',
      'drawing': 'ਡਰਾਇੰਗ',
      'guessing': 'ਅੰਦਾਜ਼ਾ ਲਗਾਉਣਾ',
      'selecting_drawer': 'ਦਰਾਜ਼ ਚੁਣ ਰਿਹਾ ਹੈ...',
      'choosing_word': 'ਕੋਈ ਸ਼ਬਦ ਚੁਣੋ!',
      'drawer_is_choosing': 'ਦਰਾਜ਼ ਚੁਣ ਰਿਹਾ ਹੈ...',
      'draw': 'ਡਰਾਅ ਕਰੋ',
      'guess_the_word': 'ਸ਼ਬਦ ਦਾ ਅੰਦਾਜ਼ਾ ਲਗਾਓ',
      'word_was': 'ਸ਼ਬਦ ਸੀ',
      'next_round_starting': 'ਅਗਲਾ ਦੌਰ ਸ਼ੁਰੂ...',
      'time_up': 'ਸਮਾਂ ਸਮਾਪਤ!',
      'well_done': 'ਬਹੁਤ ਖੂਬ!',
      'whos_next': 'ਅੱਗੇ ਕੌਣ ਹੈ?',
      'interval': 'ਅੰਤਰਾਲ',
      'host': 'ਮੇਜ਼ਬਾਨ',
      'you': 'ਤੁਸੀਂ',
      'correct': 'ਸਹੀ!',
      'good_job': 'ਅੱਛਾ ਕੰਮ!',
      'chat': 'ਚੈਟ',
      'send': 'ਭੇਜੋ',
      'type_message': 'ਸੁਨੇਹਾ ਟਾਈਪ ਕਰੋ...',
      'answers_chat': 'ਜਵਾਬ ਚੈਟ',
      'general_chat': 'ਆਮ ਗੱਲਬਾਤ',
      'team_chat': 'ਟੀਮ ਚੈਟ',

      // Room Preferences Screen
      'room_preferences': 'ਕਮਰੇ ਦੀਆਂ ਤਰਜੀਹਾਂ',
      'select_language': 'ਭਾਸ਼ਾ ਚੁਣੋ',
      'select_points': 'ਬਿੰਦੂ ਚੁਣੋ',
      'select_category': 'ਸ਼੍ਰੇਣੀ ਚੁਣੋ',
      'voice_enabled': 'ਵੌਇਸ ਯੋਗ ਬਣਾਇਆ ਗਿਆ',
      'select_team': 'ਟੀਮ ਚੁਣੋ',
      'team_selection': 'ਟੀਮ ਚੋਣ',
      'blue_team': 'ਬਲੂ ਟੀਮ',
      'orange_team': 'ਔਰੇਂਜ ਟੀਮ',

      // Profile & Settings
      'edit_profile': 'ਪ੍ਰੋਫਾਈਲ ਸੋਧੋ',
      'profile_and_accounts': 'ਪ੍ਰੋਫਾਈਲ ਅਤੇ ਖਾਤਾ',
      'username': 'ਯੂਜ਼ਰਨੇਮ',
      'email': 'ਈਮੇਲ',
      'phone': 'ਫ਼ੋਨ',
      'logout': 'ਲਾਗਆਉਟ',
      'delete_account': 'ਖਾਤਾ ਮਿਟਾਓ',
      'version': 'ਵਰਜਨ',
      'about': 'ਬਾਰੇ',
      'privacy_policy': 'ਪਰਾਈਵੇਟ ਨੀਤੀ',
      'terms_and_conditions': 'ਨਿਯਮ ਅਤੇ ਸ਼ਰਤਾਂ',
      'sound': 'ਆਵਾਜ਼',
      'privacy_and_safety': 'ਗੋਪਨੀਯਤਾ ਅਤੇ ਸੁਰੱਖਿਆ',
      'contact': 'ਸੰਪਰਕ',
      'rate_app': 'ਐਪ ਨੂੰ ਰੇਟ ਕਰੋ',
      'connect_us_at': 'ਸਾਡੇ ਨਾਲ ਇੱਥੇ ਜੁੜੋ',
      'are_you_sure_logout': 'ਕੀ ਤੁਸੀਂ ਪੱਕਾ ਲੌਗਆਉਟ ਕਰਨਾ ਚਾਹੁੰਦੇ ਹੋ?',
      'loading_ads': 'ਇਸ਼ਤਿਹਾਰ ਲੋਡ ਕੀਤੇ ਜਾ ਰਹੇ ਹਨ...',

      // Sign In
      'ink_battle': 'ਸਿਆਹੀ ਦੀ ਲੜਾਈ',
      'sign_in_with_google': 'ਗੂਗਲ ਨਾਲ ਸਾਈਨ ਇਨ ਕਰੋ',
      'sign_in_with_facebook': 'ਫੇਸਬੁੱਕ ਨਾਲ ਸਾਈਨ ਇਨ ਕਰੋ',
      'signing_in': 'ਸਾਈਨ ਇਨ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ...',
      'or': 'ਜਾਂ',
      'play_as_guest': 'ਮਹਿਮਾਨ ਵਜੋਂ ਖੇਡੋ',
      'progress_not_saved': 'ਪ੍ਰਗਤੀ ਨੂੰ ਰੱਖਿਅਤ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਦਾ ਹੈ',

      // Home Screen
      'play_random': 'ਬੇਤਰਤੀਬ ਖੇਡੋ',

      // Instructions
      'instructions': 'ਹਦਾਇਤਾਂ',
      'tutorial_guide': 'ਟਿਊਟੋਰਿਅਲ ਗਾਈਡ',
      'instructions_text':
          'ਆਪਣਾ ਗੇਮ ਐਡਵੈਂਚਰ ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਸਕ੍ਰੀਨ \'ਤੇ ਟੈਪ ਕਰੋ! ਪੱਧਰਾਂ \'ਤੇ ਨੈਵੀਗੇਟ ਕਰਨ ਲਈ ਤੀਰਾਂ ਦੀ ਵਰਤੋਂ ਕਰੋ। ਚੁਣੌਤੀਆਂ ਨੂੰ ਪੂਰਾ ਕਰਕੇ ਸਿੱਕੇ ਇਕੱਠੇ ਕਰੋ। ਆਪਣਾ ਸਕੋਰ ਉੱਚਾ ਰੱਖਣ ਲਈ ਰੁਕਾਵਟਾਂ ਤੋਂ ਬਚੋ। ਇੱਕ ਵੱਖਰੇ ਅਨੁਭਵ ਲਈ ਮੋਡ ਬਦਲੋ।',

      // Common
      'ok': 'ਠੀਕ ਹੈ',
      'cancel': 'ਰੱਦ ਕਰੋ',
      'yes': 'ਹਾਂ',
      'no': 'ਨਹੀਂ',
      'confirm': 'ਪੁਸ਼ਟੀ ਕਰੋ',
      'back': 'ਪਿੱਛੇ',
      'close': 'ਬੰਦ ਕਰੋ',
      'loading': 'ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ...',
      'error': 'ਗਲਤੀ',
      'success': 'ਸਫਲਤਾ',
      'warning': 'ਚੇਤਾਵਨੀ',
      'info': 'ਜਾਣਕਾਰੀ',

      // Messages
      'insufficient_coins': 'ਨਾਕਾਫ਼ੀ ਸਿੱਕੇ',
      'room_full': 'ਕਮਰਾ ਭਰ ਗਿਆ ਹੈ।',
      'room_not_found': 'ਕਮਰਾ ਨਹੀਂ ਮਿਲਿਆ',
      'already_in_room': 'ਪਹਿਲਾਂ ਹੀ ਕਮਰੇ ਵਿੱਚ ਹੈ',
      'connection_lost': 'ਕਨੈਕਸ਼ਨ ਟੁੱਟ ਗਿਆ',
      'reconnecting': 'ਮੁੜ-ਕਨੈਕਟ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ...',
      'connected': 'ਜੁੜਿਆ ਹੋਇਆ',
      'disconnected': 'ਡਿਸਕਨੈਕਟ ਕੀਤਾ ਗਿਆ',

      // Languages
      'hindi': 'ਹਿੰਦੀ',
      'telugu': 'ਤੇਲਗੂ',
      'english': 'ਅੰਗਰੇਜ਼ੀ',

      // Countries
      'india': 'ਭਾਰਤ',
      'usa': 'ਅਮਰੀਕਾ',
      'uk': 'ਯੂਕੇ',
      'japan': 'ਜਪਾਨ',
      'spain': 'ਸਪੇਨ',
      'portugal': 'ਪੋਰਚੁਗਾਲ',
      'france': 'ਫਰਾਂਸ',
      'germany': 'ਜਰਮਨੀ',
      'russia': 'ਰੂਸੀ',

      // Create Room & Join Room
      'please_enter_room_name': 'ਕਿਰਪਾ ਕਰਕੇ ਕਮਰੇ ਦਾ ਨਾਮ ਦਰਜ ਕਰੋ',
      'failed_to_create_room': 'ਕਮਰਾ ਬਣਾਉਣ ਵਿੱਚ ਅਸਫਲ',
      'code_copied_clipboard': 'ਕੋਡ ਕਲਿੱਪਬੋਰਡ \'ਤੇ ਕਾਪੀ ਕੀਤਾ ਗਿਆ!',
      'room_created': 'ਕਮਰਾ ਬਣਾਇਆ ਗਿਆ!',
      'share_code_with_friends': 'ਇਹ ਕੋਡ ਆਪਣੇ ਦੋਸਤਾਂ ਨਾਲ ਸਾਂਝਾ ਕਰੋ:',
      'enter_room': 'ਕਮਰੇ ਵਿੱਚ ਦਾਖਲ ਹੋਵੋ',
      'create_room_configure_lobby':
          'ਕਮਰਾ ਬਣਾਓ ਅਤੇ ਲਾਬੀ ਵਿੱਚ ਸੈਟਿੰਗਾਂ ਕੌਂਫਿਗਰ ਕਰੋ',
      'enter_room_name_hint': 'ਕਮਰੇ ਦਾ ਨਾਮ ਦਰਜ ਕਰੋ',
      'room_code_share_info':
          'ਤੁਸੀਂ ਬਣਾਉਣ ਤੋਂ ਬਾਅਦ ਦੋਸਤਾਂ ਨਾਲ ਕਮਰਾ ਕੋਡ ਸਾਂਝਾ ਕਰ ਸਕੋਗੇ',
      'create_team_room': 'ਟੀਮ ਰੂਮ ਬਣਾਓ',
      'please_check_code':
          'ਕਿਰਪਾ ਕਰਕੇ ਕੋਡ ਦੀ ਜਾਂਚ ਕਰੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।',

      // Random Match Screen
      'random_match': 'ਰੈਂਡਮ ਮੈਚ',
      'select_target_points': 'ਟੀਚਾ ਅੰਕ ਚੁਣੋ',
      'play_random_coins': 'ਰੈਂਡਮ ਖੇਡੋ (250 ਸਿੱਕੇ)',
      'please_select_all_fields': 'ਕਿਰਪਾ ਕਰਕੇ ਸਾਰੇ ਖੇਤਰ ਚੁਣੋ',
      'failed_to_find_match': 'ਮੈਚ ਲੱਭਣ ਵਿੱਚ ਅਸਫਲ',
      'watch_ads_coming_soon': 'ਵਿਗਿਆਪਨ ਦੇਖੋ ਵਿਸ਼ੇਸ਼ਤਾ ਜਲਦੀ ਆ ਰਹੀ ਹੈ!',
      'buy_coins_coming_soon': 'ਸਿੱਕੇ ਖਰੀਦੋ ਵਿਸ਼ੇਸ਼ਤਾ ਜਲਦੀ ਆ ਰਹੀ ਹੈ!',
      'insufficient_coins_title': 'ਨਾਕਾਫ਼ੀ ਸਿੱਕੇ',
      'insufficient_coins_message': 'ਤੁਹਾਡੇ ਕੋਲ ਸ਼ਾਮਲ ਹੋਣ ਲਈ ਲੋੜੀਂਦੇ ਸਿੱਕੇ ਨਹੀਂ ਹਨ। ਖੇਡਣਾ ਜਾਰੀ ਰੱਖਣ ਲਈ ਵਿਗਿਆਪਨ ਦੇਖੋ ਜਾਂ ਸਿੱਕੇ ਖਰੀਦੋ।',
      'watch_ads': 'ਵਿਗਿਆਪਨ ਦੇਖੋ',
      'buy_coins': 'ਸਿੱਕੇ ਖਰੀਦੋ',
      'no_matches_found': 'ਕੋਈ ਮੈਚ ਨਹੀਂ ਮਿਲਿਆ',
      'no_matches_message': 'ਤੁਹਾਡੀਆਂ ਤਰਜੀਹਾਂ ਨਾਲ ਕੋਈ ਜਨਤਕ ਕਮਰਾ ਮੇਲ ਨਹੀਂ ਖਾਂਦਾ। ਵੱਖਰੀਆਂ ਸੈਟਿੰਗਾਂ ਅਜ਼ਮਾਓ ਜਾਂ ਨਵਾਂ ਕਮਰਾ ਬਣਾਓ।',
      'try_again': 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ',
      'selected': 'ਚੁਣਿਆ ਗਿਆ',
      'team_a_is_full': 'ਟੀਮ A ਪੂਰ੍ਤਿਆਂਦਾ ਹੈ',
      'team_b_is_full': 'ਟੀਮ B ਪੂਰ੍ਤਿਆਂਦਾ ਹੈ',
      'please_select_the_other_team': 'ਦੇਖਾਉਂਦੇ ਹੋ ਜਾਂਦੇ ਹੈ',

      'animals': 'ਜਾਨਵਰ',
      'countries': 'ਦੇਸ਼',
      'food': 'ਭੋਜਨ',
      'everyday_objects': 'ਰੋਜ਼ਾਨਾ ਦੀਆਂ ਚੀਜ਼ਾਂ',
      'historical_events': 'ਇਤਿਹਾਸਕ ਘਟਨਾਵਾਂ',
      'movies': 'ਫਿਲਮਾਂ',
    },
    'gu': {
      // Guest Signup & Profile
      'enter_username': 'વપરાશકર્તા નામ દાખલ કરો',
      'language': 'ભાષા',
      'country': 'દેશ',
      'save': 'સાચવો',
      'skip': 'છોડી દો',
      'next': 'આગળ',
      'please_fill_all_fields': 'કૃપા કરીને બધા ક્ષેત્રો ભરો',
      'coins': 'સિક્કા',
      'welcome': 'સ્વાગત છે',

      // Home Screen
      'home': 'ઘર',
      'play': 'રમો',
      'profile': 'પ્રોફાઇલ',
      'settings': 'સેટિંગ્સ',
      'leaderboard': 'લીડરબોર્ડ',
      'friends': 'મિત્રો',
      'shop': 'દુકાન',
      'daily_bonus': 'દૈનિક બોનસ',
      'claim': 'દાવો',
      'claimed': 'દાવો કરેલ',

      // Multiplayer Screen
      'multiplayer': 'મલ્ટિપ્લેયર',
      'create_room': 'રૂમ બનાવો',
      'join_room': 'રૂમમાં જોડાઓ',
      'room_code': 'રૂમ કોડ',
      'join': 'જોડાઓ',
      'players': 'ખેલાડીઓ',
      'waiting_for_players': 'ખેલાડીઓની રાહ જોઈ રહ્યા છીએ...',
      'start_game': 'રમત શરૂ કરો',
      'leave': 'છોડી દો',
      'mode': 'મોડ',
      'individual': 'વ્યક્તિગત',
      'team': 'ટીમ',
      'language_filter': 'ભાષા',
      'points': 'પોઈન્ટ્સ',
      'category': 'શ્રેણી',
      'all': 'બધા',

      // Game Room Screen
      'game_room': 'ગેમ રૂમ',
      'gameplay': 'ગેમપ્લે',
      'drawing': 'ચિત્રકામ',
      'guessing': 'અનુમાન લગાવવું',
      'selecting_drawer': 'ડ્રોઅર પસંદ કરી રહ્યું છે...',
      'choosing_word': 'એક શબ્દ પસંદ કરો!',
      'drawer_is_choosing': 'ડ્રોઅર પસંદ કરી રહ્યું છે...',
      'draw': 'દોરો',
      'guess_the_word': 'શબ્દ ધારી લો',
      'word_was': 'શબ્દ હતો',
      'next_round_starting': 'આગળનો રાઉન્ડ શરૂ...',
      'time_up': 'સમય પૂરો!',
      'well_done': 'શાબાશ!',
      'whos_next': 'આગળ કોણ છે?',
      'interval': 'અંતરાલ',
      'host': 'યજમાન',
      'you': 'તમે',
      'correct': 'સાચું!',
      'good_job': 'સારું કામ!',
      'chat': 'ચેટ',
      'send': 'મોકલો',
      'type_message': 'સંદેશ લખો...',
      'answers_chat': 'જવાબો ચેટ',
      'general_chat': 'સામાન્ય ચેટ',
      'team_chat': 'ટીમ ચેટ',

      // Room Preferences Screen
      'room_preferences': 'રૂમ પસંદગીઓ',
      'select_language': 'ભાષા પસંદ કરો',
      'select_points': 'પોઈન્ટ પસંદ કરો',
      'select_category': 'શ્રેણી પસંદ કરો',
      'voice_enabled': 'વૉઇસ સક્ષમ',
      'select_team': 'ટીમ પસંદ કરો',
      'team_selection': 'ટીમ પસંદગી',
      'blue_team': 'બ્લુ ટીમ',
      'orange_team': 'ઓરેન્જ ટીમ',

      // Profile & Settings
      'edit_profile': 'પ્રોફાઇલ સંપાદિત કરો',
      'profile_and_accounts': 'પ્રોફાઇલ અને એકાઉન્ટ',
      'username': 'વપરાશકર્તા નામ',
      'email': 'ઇમેઇલ',
      'phone': 'ફોન',
      'logout': 'લોગઆઉટ',
      'delete_account': 'એકાઉન્ટ કાઢી નાખો',
      'version': 'આવૃત્તિ',
      'about': 'વિશે',
      'privacy_policy': 'ગોપનીયતા નીતિ',
      'terms_and_conditions': 'શરતો અને નિયમો',
      'sound': 'ધ્વનિ',
      'privacy_and_safety': 'ગોપનીયતા અને સલામતી',
      'contact': 'સંપર્ક કરો',
      'rate_app': 'એપ્લિકેશનને રેટ કરો',
      'connect_us_at': 'અમને અહીં કનેક્ટ કરો',
      'are_you_sure_logout': 'શું તમે ખરેખર લોગઆઉટ કરવા માંગો છો?',
      'loading_ads': 'જાહેરાતો લોડ કરી રહ્યું છે...',

      // Sign In
      'ink_battle': 'શાહી યુદ્ધ',
      'sign_in_with_google': 'ગુગલ સાથે સાઇન ઇન કરો',
      'sign_in_with_facebook': 'ફેસબુક સાથે સાઇન ઇન કરો',
      'signing_in': 'સાઇન ઇન કરી રહ્યું છે...',
      'or': 'અથવા',
      'play_as_guest': 'મહેમાન તરીકે રમો',
      'progress_not_saved': 'પ્રગતિ કદાચ સાચવી શકાશે નહીં',

      // Home Screen
      'play_random': 'રેન્ડમ રમો',

      // Instructions
      'instructions': 'સૂચનાઓ',
      'tutorial_guide': 'ટ્યુટોરીયલ માર્ગદર્શિકા',
      'instructions_text':
          'તમારા રમત સાહસ શરૂ કરવા માટે સ્ક્રીનને ટેપ કરો! સ્તરો પર નેવિગેટ કરવા માટે તીરનો ઉપયોગ કરો. પડકારો પૂર્ણ કરીને સિક્કા એકત્રિત કરો. તમારો સ્કોર ઊંચો રાખવા માટે અવરોધો ટાળો. એક અલગ અનુભવ માટે મોડ્સ સ્વિચ કરો.',

      // Common
      'ok': 'બરાબર',
      'cancel': 'રદ કરો',
      'yes': 'હા',
      'no': 'ના',
      'confirm': 'પુષ્ટિ કરો',
      'back': 'પાછળ',
      'close': 'બંધ કરો',
      'loading': 'લોડ કરી રહ્યું છે...',
      'error': 'ભૂલ',
      'success': 'સફળતા',
      'warning': 'ચેતવણી',
      'info': 'માહિતી',

      // Messages
      'insufficient_coins': 'અપૂરતા સિક્કા',
      'room_full': 'રૂમ ભરાઈ ગયો છે.',
      'room_not_found': 'રૂમ મળ્યો નથી',
      'already_in_room': 'પહેલેથી જ રૂમમાં છે',
      'connection_lost': 'કનેક્શન તૂટી ગયું',
      'reconnecting': 'ફરીથી કનેક્ટ કરી રહ્યું છે...',
      'connected': 'કનેક્ટેડ',
      'disconnected': 'ડિસ્કનેક્ટ થયું',

      // Languages
      'hindi': 'હિન્દી',
      'telugu': 'તેલુગુ',
      'english': 'અંગ્રેજી',

      // Countries
      'india': 'ભારત',
      'usa': 'યુનાઈટેડ સ્ટેટ્સ',
      'uk': 'યુકે',
      'japan': 'જાપાન',
      'spain': 'સਪੇન',
      'portugal': 'પੋરਚੁગાલ',
      'france': 'ફરાંસ',
      'germany': 'જરਮનિ',
      'russia': 'રੂસિયા',

      // Create Room & Join Room
      'please_enter_room_name': 'કૃપા કરીને રૂમનું નામ દાખલ કરો',
      'failed_to_create_room': 'રૂમ બનાવવામાં નિષ્ફળ',
      'code_copied_clipboard': 'ક્લિપબોર્ડ પર કોડ કોપી કર્યો!',
      'room_created': 'રૂમ બનાવ્યો!',
      'share_code_with_friends': 'આ કોડ તમારા મિત્રો સાથે શેર કરો:',
      'enter_room': 'રૂમમાં દાખલ થાઓ',
      'create_room_configure_lobby':
          'રૂમ બનાવો અને લોબીમાં સેટિંગ્સ ગોઠવો',
      'enter_room_name_hint': 'રૂમનું નામ દાખલ કરો',
      'room_code_share_info':
          'રૂમ બનાવ્યા પછી તમે મિત્રો સાથે કોડ શેર કરી શકશો',
      'create_team_room': 'ટીમ રૂમ બનાવો',
      'please_check_code':
          'કૃપા કરીને કોડ તપાસો અને ફરી પ્રયાસ કરો.',

      // Random Match Screen
      'random_match': 'રેન્ડમ મેચ',
      'select_target_points': 'લક્ષ્ય પોઈન્ટ પસંદ કરો',
      'play_random_coins': 'રેન્ડમ રમો (250 સિક્કા)',
      'please_select_all_fields': 'કૃપા કરીને બધા ક્ષેત્રો પસંદ કરો',
      'failed_to_find_match': 'મેચ શોધવામાં નિષ્ફળ',
      'watch_ads_coming_soon': 'જાહેરાતો જોવાની સુવિધા ટૂંક સમયમાં આવી રહી છે!',
      'buy_coins_coming_soon': 'સિક્કા ખરીદવાની સુવિધા ટૂંક સમયમાં આવી રહી છે!',
      'insufficient_coins_title': 'અપૂરતા સિક્કા',
      'insufficient_coins_message': 'જોડાવા માટે તમારી પાસે પૂરતા સિક્કા નથી. ચાલુ રાખવા માટે જાહેરાતો જુઓ અથવા સિક્કા ખરીદો.',
      'watch_ads': 'જાહેરાતો જુઓ',
      'buy_coins': 'સિક્કા ખરીદો',
      'no_matches_found': 'કોઈ મેચ મળી નથી',
      'no_matches_message': 'તમારી પસંદગીઓ સાથે કોઈ જાહેર રૂમ મેળ ખાતો નથી. અલગ સેટિંગ્સ અજમાવો અથવા નવો રૂમ બનાવો.',
      'try_again': 'ફરી પ્રયાસ કરો',
      'selected': 'પસંદ કરેલ',
      'team_a_is_full': 'ટీમ A પૂર్તી છે',
      'team_b_is_full': 'ટీમ B પૂર్તી છે',
      'please_select_the_other_team': 'દયસૂર પસંદ કરો',

      'animals': 'પ્રાણીઓ',
      'countries': 'દેશો',
      'food': 'ખોરાક',
      'everyday_objects': 'રોજિંદા વસ્તુઓ',
      'historical_events': 'ઐતિહાસિક ઘટનાઓ',
      'movies': 'ચલચિત્રો',
    },
    'it': {
      // Guest Signup & Profile
      'enter_username': 'Inserisci nome utente',
      'language': 'Lingua',
      'country': 'Paese',
      'save': 'Salva',
      'skip': 'Salta',
      'next': 'Avanti',
      'please_fill_all_fields': 'Si prega di compilare tutti i campi',
      'coins': 'Monete',
      'welcome': 'Benvenuto',

      // Home Screen
      'home': 'Home',
      'play': 'Gioca',
      'profile': 'Profilo',
      'settings': 'Impostazioni',
      'leaderboard': 'Classifica',
      'friends': 'Amici',
      'shop': 'Negozio',
      'daily_bonus': 'Bonus Giornaliero',
      'claim': 'Riscatta',
      'claimed': 'Riscattato',

      // Multiplayer Screen
      'multiplayer': 'Multigiocatore',
      'create_room': 'Crea Stanza',
      'join_room': 'Entra nella Stanza',
      'room_code': 'Codice Stanza',
      'join': 'Unisciti',
      'players': 'Giocatori',
      'waiting_for_players': 'In attesa di giocatori...',
      'start_game': 'Inizia Gioco',
      'leave': 'Esci',
      'mode': 'Modalità',
      'individual': 'Individuale',
      'team': 'Squadra',
      'language_filter': 'Lingua',
      'points': 'Punti',
      'category': 'Categoria',
      'all': 'Tutti',

      // Game Room Screen
      'game_room': 'Sala Giochi',
      'gameplay': 'Gameplay',
      'drawing': 'Disegno',
      'guessing': 'Indovinello',
      'selecting_drawer': 'Selezione disegnatore...',
      'choosing_word': 'Scegli una parola!',
      'drawer_is_choosing': 'Il disegnatore sta scegliendo...',
      'draw': 'Disegna',
      'guess_the_word': 'Indovina la parola',
      'word_was': 'La parola era',
      'next_round_starting': 'Il prossimo round inizia...',
      'time_up': 'Tempo scaduto!',
      'well_done': 'Ben fatto!',
      'whos_next': 'Chi è il prossimo?',
      'interval': 'Intervallo',
      'host': 'Host',
      'you': 'Tu',
      'correct': 'Corretto!',
      'good_job': 'Ottimo lavoro!',
      'chat': 'Chat',
      'send': 'Invia',
      'type_message': 'Scrivi un messaggio...',
      'answers_chat': 'Chat Risposte',
      'general_chat': 'Chat Generale',
      'team_chat': 'Chat Squadra',

      // Room Preferences Screen
      'room_preferences': 'Preferenze Stanza',
      'select_language': 'Seleziona Lingua',
      'select_points': 'Seleziona Punti',
      'select_category': 'Seleziona Categoria',
      'voice_enabled': 'Voce Abilitata',
      'select_team': 'Seleziona Squadra',
      'team_selection': 'Selezione Squadra',
      'blue_team': 'Squadra Blu',
      'orange_team': 'Squadra Arancione',

      // Profile & Settings
      'edit_profile': 'Modifica Profilo',
      'profile_and_accounts': 'Profilo & Account',
      'username': 'Nome utente',
      'email': 'Email',
      'phone': 'Telefono',
      'logout': 'Disconnetti',
      'delete_account': 'Elimina Account',
      'version': 'Versione',
      'about': 'Info',
      'privacy_policy': 'Privacy Policy',
      'terms_and_conditions': 'Termini e Condizioni',
      'sound': 'Suono',
      'privacy_and_safety': 'Privacy & Sicurezza',
      'contact': 'Contatti',
      'rate_app': 'Valuta App',
      'connect_us_at': 'CONNETTITI CON NOI A',
      'are_you_sure_logout': 'Sei sicuro di voler uscire?',
      'loading_ads': 'Caricamento pubblicità...',

      // Sign In
      'ink_battle': 'Ink Battle',
      'sign_in_with_google': 'Accedi con Google',
      'sign_in_with_facebook': 'Accedi con Facebook',
      'signing_in': 'Accesso in corso...',
      'or': 'O',
      'play_as_guest': 'Gioca come Ospite',
      'progress_not_saved': 'I progressi potrebbero non essere salvati',

      // Home Screen
      'play_random': 'Gioca Casuale',

      // Instructions
      'instructions': 'Istruzioni',
      'tutorial_guide': 'Guida Tutorial',
      'instructions_text':
          'Tocca lo schermo per iniziare la tua avventura! Usa le frecce per navigare tra i livelli. Raccogli monete completando le sfide. Evita gli ostacoli per mantenere alto il punteggio. Cambia modalità per un\'esperienza diversa.',

      // Common
      'ok': 'OK',
      'cancel': 'Annulla',
      'yes': 'Sì',
      'no': 'No',
      'confirm': 'Conferma',
      'back': 'Indietro',
      'close': 'Chiudi',
      'loading': 'Caricamento...',
      'error': 'Errore',
      'success': 'Successo',
      'warning': 'Attenzione',
      'info': 'Info',

      // Messages
      'insufficient_coins': 'Monete insufficienti',
      'room_full': 'Stanza piena',
      'room_not_found': 'Stanza non trovata',
      'already_in_room': 'Già nella stanza',
      'connection_lost': 'Connessione persa',
      'reconnecting': 'Riconnessione...',
      'connected': 'Connesso',
      'disconnected': 'Disconnesso',

      // Languages
      'hindi': 'Hindi',
      'telugu': 'Telugu',
      'english': 'Inglese',

      // Countries
      'india': 'India',
      'usa': 'USA',
      'uk': 'Regno Unito',
      'japan': 'Giappone',
      'spain': 'Spagna',
      'portugal': 'Portogallo',
      'france': 'Francia',
      'germany': 'Germania',
      'russia': 'Russia',

      // Create Room & Join Room
      'please_enter_room_name': 'Inserisci il nome della stanza',
      'failed_to_create_room': 'Impossibile creare la stanza',
      'code_copied_clipboard': 'Codice copiato negli appunti!',
      'room_created': 'Stanza Creata!',
      'share_code_with_friends': 'Condividi questo codice con i tuoi amici:',
      'enter_room': 'Entra nella Stanza',
      'create_room_configure_lobby':
          'Crea una stanza e configura le impostazioni nella lobby',
      'enter_room_name_hint': 'Inserisci nome stanza',
      'room_code_share_info':
          'Potrai condividere il codice della stanza con gli amici dopo la creazione',
      'create_team_room': 'Crea Stanza Squadra',
      'please_check_code': 'Controlla il codice e riprova.',

      // Random Match Screen
      'random_match': 'Partita Casuale',
      'select_target_points': 'Seleziona Punti Obiettivo',
      'play_random_coins': 'Gioca Casuale (250 Monete)',
      'please_select_all_fields': 'Seleziona tutti i campi inclusi i Punti Obiettivo',
      'failed_to_find_match': 'Impossibile trovare una partita',
      'watch_ads_coming_soon': 'Funzione guarda pubblicità in arrivo!',
      'buy_coins_coming_soon': 'Funzione acquista monete in arrivo!',
      'insufficient_coins_title': 'Monete Insufficienti',
      'insufficient_coins_message':
          'Non hai abbastanza monete per unirti. Guarda pubblicità o acquista monete per continuare a giocare.',
      'watch_ads': 'Guarda Pubblicità',
      'buy_coins': 'Acquista Monete',
      'no_matches_found': 'Nessuna Partita Trovata',
      'no_matches_message':
          'Nessuna stanza pubblica corrisponde alle tue preferenze. Prova impostazioni diverse o crea una nuova stanza.',
      'try_again': 'Riprova',
      'selected': 'selezionato',
      'team_a_is_full': 'Il team A è pieno',
      'team_b_is_full': 'Il team B è pieno',
      'please_select_the_other_team': 'Seleziona il team B',
      // Categories
      'animals': 'Animali',
      'countries': 'Paesi',
      'everyday_objects': 'Oggetti Quotidiani',
      'food': 'Cibo',
      'historical_events': 'Eventi Storici',
      'movies': 'Film',
    },
    'ko': {
      // Guest Signup & Profile
      'enter_username': '사용자 이름 입력',
      'language': '언어',
      'country': '국가',
      'save': '저장',
      'skip': '건너뛰기',
      'next': '다음',
      'please_fill_all_fields': '모든 필드를 채워주세요',
      'coins': '코인',
      'welcome': '환영합니다',

      // Home Screen
      'home': '홈',
      'play': '플레이',
      'profile': '프로필',
      'settings': '설정',
      'leaderboard': '순위표',
      'friends': '친구',
      'shop': '상점',
      'daily_bonus': '일일 보너스',
      'claim': '받기',
      'claimed': '받음',

      // Multiplayer Screen
      'multiplayer': '멀티플레이어',
      'create_room': '방 만들기',
      'join_room': '방 참가',
      'room_code': '방 코드',
      'join': '참가',
      'players': '플레이어',
      'waiting_for_players': '플레이어 대기 중...',
      'start_game': '게임 시작',
      'leave': '나가기',
      'mode': '모드',
      'individual': '개인',
      'team': '팀',
      'language_filter': '언어',
      'points': '포인트',
      'category': '카테고리',
      'all': '전체',

      // Game Room Screen
      'game_room': '게임 룸',
      'gameplay': '게임플레이',
      'drawing': '그리기',
      'guessing': '추측',
      'selecting_drawer': '그리는 사람 선택 중...',
      'choosing_word': '단어를 선택하세요!',
      'drawer_is_choosing': '그리는 사람이 선택 중입니다...',
      'draw': '그리기',
      'guess_the_word': '단어를 맞혀보세요',
      'word_was': '단어는',
      'next_round_starting': '다음 라운드 시작...',
      'time_up': '시간 종료!',
      'well_done': '잘했습니다!',
      'whos_next': '다음은 누구?',
      'interval': '인터벌',
      'host': '호스트',
      'you': '나',
      'correct': '정답!',
      'good_job': '잘했어요!',
      'chat': '채팅',
      'send': '전송',
      'type_message': '메시지 입력...',
      'answers_chat': '정답 채팅',
      'general_chat': '일반 채팅',
      'team_chat': '팀 채팅',

      // Room Preferences Screen
      'room_preferences': '방 환경설정',
      'select_language': '언어 선택',
      'select_points': '포인트 선택',
      'select_category': '카테고리 선택',
      'voice_enabled': '음성 사용',
      'select_team': '팀 선택',
      'team_selection': '팀 선택',
      'blue_team': '블루 팀',
      'orange_team': '오렌지 팀',

      // Profile & Settings
      'edit_profile': '프로필 편집',
      'profile_and_accounts': '프로필 및 계정',
      'username': '사용자 이름',
      'email': '이메일',
      'phone': '전화번호',
      'logout': '로그아웃',
      'delete_account': '계정 삭제',
      'version': '버전',
      'about': '정보',
      'privacy_policy': '개인정보 처리방침',
      'terms_and_conditions': '이용 약관',
      'sound': '소리',
      'privacy_and_safety': '개인정보 및 보안',
      'contact': '연락처',
      'rate_app': '앱 평가',
      'connect_us_at': '다음에서 연결',
      'are_you_sure_logout': '로그아웃하시겠습니까?',
      'loading_ads': '광고 로딩 중...',

      // Sign In
      'ink_battle': '잉크 배틀',
      'sign_in_with_google': 'Google로 로그인',
      'sign_in_with_facebook': 'Facebook으로 로그인',
      'signing_in': '로그인 중...',
      'or': '또는',
      'play_as_guest': '게스트로 플레이',
      'progress_not_saved': '진행 상황이 저장되지 않을 수 있습니다',

      // Home Screen
      'play_random': '랜덤 플레이',

      // Instructions
      'instructions': '설명',
      'tutorial_guide': '튜토리얼 가이드',
      'instructions_text':
          '화면을 탭하여 게임 모험을 시작하세요! 화살표를 사용하여 레벨을 이동하세요. 도전을 완료하여 코인을 모으세요. 장애물을 피하여 높은 점수를 유지하세요. 다른 경험을 위해 모드를 변경하세요.',

      // Common
      'ok': '확인',
      'cancel': '취소',
      'yes': '예',
      'no': '아니요',
      'confirm': '확인',
      'back': '뒤로',
      'close': '닫기',
      'loading': '로딩 중...',
      'error': '오류',
      'success': '성공',
      'warning': '경고',
      'info': '정보',

      // Messages
      'insufficient_coins': '코인 부족',
      'room_full': '방이 꽉 찼습니다',
      'room_not_found': '방을 찾을 수 없습니다',
      'already_in_room': '이미 방에 있습니다',
      'connection_lost': '연결 끊김',
      'reconnecting': '재연결 중...',
      'connected': '연결됨',
      'disconnected': '연결 끊김',

      // Languages
      'hindi': '힌디어',
      'telugu': '텔루구어',
      'english': '영어',

      // Countries
      'india': '인도',
      'usa': '미국',
      'uk': '영국',
      'japan': '일본',
      'spain': '스페인',
      'portugal': '포르투갈',
      'france': '프랑스',
      'germany': '독일',
      'russia': '러시아',

      // Create Room & Join Room
      'please_enter_room_name': '방 이름을 입력하세요',
      'failed_to_create_room': '방 생성 실패',
      'code_copied_clipboard': '코드가 클립보드에 복사되었습니다!',
      'room_created': '방이 생성되었습니다!',
      'share_code_with_friends': '친구들과 이 코드를 공유하세요:',
      'enter_room': '방 입장',
      'create_room_configure_lobby':
          '방을 만들고 로비에서 설정을 구성하세요',
      'enter_room_name_hint': '방 이름 입력',
      'room_code_share_info':
          '생성 후 친구들과 방 코드를 공유할 수 있습니다',
      'create_team_room': '팀 방 만들기',
      'please_check_code': '코드를 확인하고 다시 시도하세요.',

      // Random Match Screen
      'random_match': '랜덤 매치',
      'select_target_points': '목표 포인트 선택',
      'play_random_coins': '랜덤 플레이 (250 코인)',
      'please_select_all_fields': '목표 포인트를 포함한 모든 필드를 선택하세요',
      'failed_to_find_match': '매치를 찾지 못했습니다',
      'watch_ads_coming_soon': '광고 보기 기능이 곧 제공됩니다!',
      'buy_coins_coming_soon': '코인 구매 기능이 곧 제공됩니다!',
      'insufficient_coins_title': '코인 부족',
      'insufficient_coins_message':
          '참가할 코인이 부족합니다. 광고를 보거나 코인을 구매하여 계속하세요.',
      'watch_ads': '광고 보기',
      'buy_coins': '코인 구매',
      'no_matches_found': '매치 없음',
      'no_matches_message':
          '선호하는 설정과 일치하는 공개 방이 없습니다. 다른 설정을 시도하거나 새 방을 만드세요.',
      'try_again': '다시 시도',
      'selected': '선택됨',
      'team_a_is_full': '팀 A 가득 찼습니다',
      'team_b_is_full': '팀 B 가득 찼습니다',
      'please_select_the_other_team': '다른 팀을 선택하세요',
      // Categories
      'animals': '동물',
      'countries': '국가',
      'everyday_objects': '일상 용품',
      'food': '음식',
      'historical_events': '역사적 사건',
      'movies': '영화',
    },
    'zh': {
      // Guest Signup & Profile
      'enter_username': '输入用户名',
      'language': '语言',
      'country': '国家',
      'save': '保存',
      'skip': '跳过',
      'next': '下一步',
      'please_fill_all_fields': '请填写所有字段',
      'coins': '金币',
      'welcome': '欢迎',

      // Home Screen
      'home': '首页',
      'play': '开始游戏',
      'profile': '个人资料',
      'settings': '设置',
      'leaderboard': '排行榜',
      'friends': '好友',
      'shop': '商店',
      'daily_bonus': '每日奖励',
      'claim': '领取',
      'claimed': '已领取',

      // Multiplayer Screen
      'multiplayer': '多人游戏',
      'create_room': '创建房间',
      'join_room': '加入房间',
      'room_code': '房间代码',
      'join': '加入',
      'players': '玩家',
      'waiting_for_players': '等待玩家...',
      'start_game': '开始游戏',
      'leave': '离开',
      'mode': '模式',
      'individual': '个人',
      'team': '团队',
      'language_filter': '语言',
      'points': '分数',
      'category': '类别',
      'all': '全部',

      // Game Room Screen
      'game_room': '游戏房间',
      'gameplay': '游戏进行中',
      'drawing': '绘画',
      'guessing': '猜词',
      'selecting_drawer': '正在选人绘画...',
      'choosing_word': '选择一个词！',
      'drawer_is_choosing': '绘画者正在选择...',
      'draw': '画',
      'guess_the_word': '猜这个词',
      'word_was': '词语是',
      'next_round_starting': '下一轮即将开始...',
      'time_up': '时间到！',
      'well_done': '干得好！',
      'whos_next': '下一个是谁？',
      'interval': '休息',
      'host': '房主',
      'you': '你',
      'correct': '正确！',
      'good_job': '做得好！',
      'chat': '聊天',
      'send': '发送',
      'type_message': '输入消息...',
      'answers_chat': '答案聊天',
      'general_chat': '综合聊天',
      'team_chat': '团队聊天',

      // Room Preferences Screen
      'room_preferences': '房间偏好',
      'select_language': '选择语言',
      'select_points': '选择分数',
      'select_category': '选择类别',
      'voice_enabled': '启用语音',
      'select_team': '选择团队',
      'team_selection': '团队选择',
      'blue_team': '蓝队',
      'orange_team': '橙队',

      // Profile & Settings
      'edit_profile': '编辑资料',
      'profile_and_accounts': '资料与账户',
      'username': '用户名',
      'email': '电子邮箱',
      'phone': '电话',
      'logout': '登出',
      'delete_account': '删除账户',
      'version': '版本',
      'about': '关于',
      'privacy_policy': '隐私政策',
      'terms_and_conditions': '条款和条件',
      'sound': '声音',
      'privacy_and_safety': '隐私与安全',
      'contact': '联系我们',
      'rate_app': '评价应用',
      'connect_us_at': '联系方式',
      'are_you_sure_logout': '确定要登出吗？',
      'loading_ads': '加载广告中...',

      // Sign In
      'ink_battle': '墨水大作战',
      'sign_in_with_google': '使用 Google 登录',
      'sign_in_with_facebook': '使用 Facebook 登录',
      'signing_in': '登录中...',
      'or': '或',
      'play_as_guest': '游客登录',
      'progress_not_saved': '进度可能不会保存',

      // Home Screen
      'play_random': '随机匹配',

      // Instructions
      'instructions': '说明',
      'tutorial_guide': '新手指南',
      'instructions_text':
          '点击屏幕开始你的游戏冒险！使用箭头在关卡中导航。通过完成挑战收集金币。避开障碍物以保持高分。切换模式体验不同的玩法。',

      // Common
      'ok': '确定',
      'cancel': '取消',
      'yes': '是',
      'no': '否',
      'confirm': '确认',
      'back': '返回',
      'close': '关闭',
      'loading': '加载中...',
      'error': '错误',
      'success': '成功',
      'warning': '警告',
      'info': '信息',

      // Messages
      'insufficient_coins': '金币不足',
      'room_full': '房间已满',
      'room_not_found': '未找到房间',
      'already_in_room': '已在房间中',
      'connection_lost': '连接丢失',
      'reconnecting': '正在重新连接...',
      'connected': '已连接',
      'disconnected': '已断开',

      // Languages
      'hindi': '印地语',
      'telugu': '泰卢固语',
      'english': '英语',

      // Countries
      'india': '印度',
      'usa': '美国',
      'uk': '英国',
      'japan': '日本',
      'spain': '西班牙',
      'portugal': '葡萄牙',
      'france': '法国',
      'germany': '德国',
      'russia': '俄罗斯',

      // Create Room & Join Room
      'please_enter_room_name': '请输入房间名',
      'failed_to_create_room': '创建房间失败',
      'code_copied_clipboard': '代码已复制到剪贴板！',
      'room_created': '房间已创建！',
      'share_code_with_friends': '与朋友分享此代码：',
      'enter_room': '进入房间',
      'create_room_configure_lobby':
          '创建房间并在大厅配置设置',
      'enter_room_name_hint': '输入房间名',
      'room_code_share_info':
          '创建后您可以与朋友分享房间代码',
      'create_team_room': '创建团队房间',
      'please_check_code': '请检查代码并重试。',

      // Random Match Screen
      'random_match': '随机匹配',
      'select_target_points': '选择目标分数',
      'play_random_coins': '随机游玩 (250 金币)',
      'please_select_all_fields': '请选择包括目标分数在内的所有字段',
      'failed_to_find_match': '未找到比赛',
      'watch_ads_coming_soon': '观看广告功能即将推出！',
      'buy_coins_coming_soon': '购买金币功能即将推出！',
      'insufficient_coins_title': '金币不足',
      'insufficient_coins_message': '您的金币不足以加入。请观看广告或购买金币以继续游玩。',
      'watch_ads': '观看广告',
      'buy_coins': '购买金币',
      'no_matches_found': '未找到匹配',
      'no_matches_message': '没有符合您偏好的公共房间。请尝试不同的设置或创建一个新房间。',
      'try_again': '重试',
      'selected': '已选',
      'team_a_is_full': '团队 A 已满',
      'team_b_is_full': '团队 B 已满',
      'please_select_the_other_team': '请选择其他团队',
      // Categories
      'animals': '动物',
      'countries': '国家',
      'everyday_objects': '日常用品',
      'food': '食物',
      'historical_events': '历史事件',
      'movies': '电影',
    },
  };

  static String? _currentLanguage;

  static String getCurrentLanguage() {
    return _currentLanguage ?? 'en';
  }

  static void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    // Notify listeners that language has changed
    if (_onLanguageChanged != null) {
      _onLanguageChanged!();
    }
  }

  static String translate(String key) {
    final languageCode = getCurrentLanguage();
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static String get enterUsername => translate('enter_username');
  static String get language => translate('language');
  static String get country => translate('country');
  static String get save => translate('save');
  static String get skip => translate('skip');
  static String get next => translate('next');
  static String get coins => translate('coins');
  static String get welcome => translate('welcome');
  static String get pleaseFillAllFields => translate('please_fill_all_fields');

  static String get home => translate('home');
  static String get play => translate('play');
  static String get profile => translate('profile');
  static String get settings => translate('settings');
  static String get leaderboard => translate('leaderboard');
  static String get friends => translate('friends');
  static String get shop => translate('shop');
  static String get dailyBonus => translate('daily_bonus');
  static String get claim => translate('claim');
  static String get claimed => translate('claimed');

  static String get multiplayer => translate('multiplayer');
  static String get createRoom => translate('create_room');
  static String get joinRoom => translate('join_room');
  static String get roomCode => translate('room_code');
  static String get join => translate('join');
  static String get players => translate('players');
  static String get waitingForPlayers => translate('waiting_for_players');
  static String get startGame => translate('start_game');
  static String get leave => translate('leave');
  static String get mode => translate('mode');
  static String get individual => translate('individual');
  static String get team => translate('team');
  static String get languageFilter => translate('language_filter');
  static String get points => translate('points');
  static String get category => translate('category');
  static String get all => translate('all');

  static String get gameRoom => translate('game_room');
  static String get gameplay => translate('gameplay');
  static String get drawing => translate('drawing');
  static String get guessing => translate('guessing');
  static String get selectingDrawer => translate('selecting_drawer');
  static String get choosingWord => translate('choosing_word');
  static String get drawerIsChoosing => translate('drawer_is_choosing');
  static String get draw => translate('draw');
  static String get guessTheWord => translate('guess_the_word');
  static String get wordWas => translate('word_was');
  static String get nextRoundStarting => translate('next_round_starting');
  static String get timeUp => translate('time_up');
  static String get wellDone => translate('well_done');
  static String get whosNext => translate('whos_next');
  static String get interval => translate('interval');
  static String get host => translate('host');
  static String get you => translate('you');
  static String get correct => translate('correct');
  static String get goodJob => translate('good_job');
  static String get chat => translate('chat');
  static String get send => translate('send');
  static String get typeMessage => translate('type_message');
  static String get answersChat => translate('answers_chat');
  static String get generalChat => translate('general_chat');
  static String get teamChat => translate('team_chat');

  static String get roomPreferences => translate('room_preferences');
  static String get selectLanguage => translate('select_language');
  static String get selectPoints => translate('select_points');
  static String get selectCategory => translate('select_category');
  static String get voiceEnabled => translate('voice_enabled');
  static String get selectTeam => translate('select_team');
  static String get teamSelection => translate('team_selection');
  static String get blueTeam => translate('blue_team');
  static String get orangeTeam => translate('orange_team');

  static String get editProfile => translate('edit_profile');
  static String get profileAndAccounts => translate('profile_and_accounts');
  static String get username => translate('username');
  static String get email => translate('email');
  static String get phone => translate('phone');
  static String get logout => translate('logout');
  static String get deleteAccount => translate('delete_account');
  static String get version => translate('version');
  static String get about => translate('about');
  static String get privacyPolicy => translate('privacy_policy');
  static String get termsAndConditions => translate('terms_and_conditions');

  static String get ok => translate('ok');
  static String get cancel => translate('cancel');
  static String get yes => translate('yes');
  static String get no => translate('no');
  static String get confirm => translate('confirm');
  static String get back => translate('back');
  static String get close => translate('close');
  static String get loading => translate('loading');
  static String get error => translate('error');
  static String get success => translate('success');
  static String get warning => translate('warning');
  static String get info => translate('info');

  static String get insufficientCoins => translate('insufficient_coins');
  static String get roomFull => translate('room_full');
  static String get roomNotFound => translate('room_not_found');
  static String get alreadyInRoom => translate('already_in_room');
  static String get connectionLost => translate('connection_lost');
  static String get reconnecting => translate('reconnecting');
  static String get connected => translate('connected');
  static String get disconnected => translate('disconnected');

  static String get hindi => translate('hindi');
  static String get telugu => translate('telugu');
  static String get english => translate('english');

  static String get india => translate('india');
  static String get usa => translate('usa');
  static String get uk => translate('uk');
  static String get japan => translate('japan');

  static String get sound => translate('sound');
  static String get privacyAndSafety => translate('privacy_and_safety');
  static String get contact => translate('contact');
  static String get rateApp => translate('rate_app');
  static String get connectUsAt => translate('connect_us_at');
  static String get areYouSureLogout => translate('are_you_sure_logout');
  static String get loadingAds => translate('loading_ads');

  static String get inkBattle => translate('ink_battle');
  static String get signInWithGoogle => translate('sign_in_with_google');
  static String get signInWithFacebook => translate('sign_in_with_facebook');
  static String get signingIn => translate('signing_in');
  static String get or => translate('or');
  static String get playAsGuest => translate('play_as_guest');
  static String get progressNotSaved => translate('progress_not_saved');

  static String get playRandom => translate('play_random');

  static String get instructions => translate('instructions');
  static String get tutorialGuide => translate('tutorial_guide');
  static String get instructionsText => translate('instructions_text');

  static String get usernameRequired => translate('username_required');
  static String get googleSignInFailed => translate('google_sign_in_failed');
  static String get facebookSignInFailed =>
      translate('facebook_sign_in_failed');
  static String get signInError => translate('sign_in_error');
  static String get wordTheme => translate('word_theme');
  static String get wordScript => translate('word_script');
  static String get gamePlay => translate('game_play');
  static String get voice => translate('voice');
  static String get public => translate('public');
  static String get copied => translate('copied');
  static String get pleaseFillAllDetails =>
      translate('please_fill_all_details');
  static String get letsGoRoomLive => translate('lets_go_room_live');
  static String get enterRoomCode => translate('enter_room_code');
  static String get selectYourTeam => translate('select_your_team');
  static String get teamA => translate('team_a');
  static String get teamB => translate('team_b');
  static String get insufficientCoinsJoin =>
      translate('insufficient_coins_join');
  static String get failedToJoinRoom => translate('failed_to_join_room');
  static String get successfullyJoinedRoom =>
      translate('successfully_joined_room');
  static String get wrong => translate('wrong');
  static String get breakWord => translate('break_word');
  static String get alternate => translate('alternate');
  static String get itsDrawingTime => translate('its_drawing_time');
  static String get missedTheirTurn => translate('missed_their_turn');
  static String get leaderboardUpdates => translate('leaderboard_updates');
  static String get noPlayersYet => translate('no_players_yet');
  static String get private => translate('private');
  static String get skipTurn => translate('skip_turn');
  static String get areYouSureSkip => translate('are_you_sure_skip');
  static String get yesSad => translate('yes_sad');
  static String get noCool => translate('no_cool');
  static String get oopsTimeUp => translate('oops_time_up');
  static String get goodJobClap => translate('good_job_clap');
  static String get wellDoneParty => translate('well_done_party');
  static String get teammatesGuessed => translate('teammates_guessed');
  static String get participantsGuessed => translate('participants_guessed');
  static String get oops => translate('oops');
  static String get almostHadIt => translate('almost_had_it');
  static String get toughRound => translate('tough_round');
  static String get noOneCrackedIt => translate('no_one_cracked_it');
  static String get letsTryNext => translate('lets_try_next');
  static String get closeCall => translate('close_call');
  static String get fewSharpEyes => translate('few_sharp_eyes');
  static String get almostThereTeam => translate('almost_there_team');
  static String get keepItUp => translate('keep_it_up');
  static String get artistOfTheTeam => translate('artist_of_the_team');
  static String get voiceChatNotEnabled => translate('voice_chat_not_enabled');
  static String get onlyDrawerCanSend => translate('only_drawer_can_send');
  static String get messageLabel => translate('message_label');
  static String get select => translate('select');
  static String get answersChatInstruction =>
      translate('answers_chat_instruction');
  static String get correctLower => translate('correct_lower');
  static String get typeAnswersHere => translate('type_answers_here');
  static String get correctAnswerParty => translate('correct_answer_party');
  static String get generalChatWelcome => translate('general_chat_welcome');
  static String get typeAnything => translate('type_anything');
  static String get script => translate('script');
  static String get noRoomsAvailable => translate('no_rooms_available');
  static String get selectAllFiltersToViewRooms => translate('select_all_filters_to_view_rooms');
  static String get oneCategorySelected => translate('one_category_selected');
  static String get categoriesSelected => translate('categories_selected');
  static String get noMatchesFound => translate('no_matches_found');
  static String get noMatchesMessage => translate('no_matches_message');
  static String get tryAgain => translate('try_again');

  // Create Room & Join Room
  static String get pleaseEnterRoomName => translate('please_enter_room_name');
  static String get failedToCreateRoom => translate('failed_to_create_room');
  static String get codeCopiedClipboard => translate('code_copied_clipboard');
  static String get roomCreated => translate('room_created');
  static String get shareCodeWithFriends =>
      translate('share_code_with_friends');
  static String get enterRoom => translate('enter_room');
  static String get createRoomConfigureLobby =>
      translate('create_room_configure_lobby');
  static String get enterRoomNameHint => translate('enter_room_name_hint');
  static String get roomCodeShareInfo => translate('room_code_share_info');
  static String get createTeamRoom => translate('create_team_room');
  static String get pleaseCheckCode => translate('please_check_code');

  // Random Match Screen
  static String get randomMatch => translate('random_match');
  static String get selectTargetPoints => translate('select_target_points');
  static String get playRandomCoins => translate('play_random_coins');
  static String get pleaseSelectAllFields =>
      translate('please_select_all_fields');
  static String get failedToFindMatch => translate('failed_to_find_match');
  static String get watchAdsComingSoon => translate('watch_ads_coming_soon');
  static String get buyCoinsComingSoon => translate('buy_coins_coming_soon');
  static String get insufficientCoinsTitle =>
      translate('insufficient_coins_title');
  static String get insufficientCoinsMessage =>
      translate('insufficient_coins_message');
  static String get watchAds => translate('watch_ads');
  static String get buy => translate('buy');
  static String get buyCoins => translate('buy_coins');
  static String get teamAIsFull => translate('team_a_is_full');
  static String get teamBIsFull => translate('team_b_is_full'); 
  static String get pleaseSelectTheOtherTeam => translate('please_select_the_other_team');

  static String get animals => translate('animals');
  static String get countries => translate('countries');
  static String get food => translate('food');
  static String get everydayObjects => translate('everyday_objects');
  static String get historicalEvents => translate('historical_events');
  static String get movies => translate('movies');
}
