import 'package:async/async.dart';
import 'package:snulife_internal/logics/firestore_read.dart';
import 'package:snulife_internal/logics/utils/date_util.dart';
import 'package:snulife_internal/logics/utils/firebase_util.dart';

import '../ui/styles/colors.dart';
import '../ui/styles/fonts.dart';
import 'firestore_write.dart';
import 'http_logic.dart';

// make only one instance like singleton

AppColors get appColors => AppColors();
AppFonts get appFonts => AppFonts();
FirebaseInstance get firebaseInstance => FirebaseInstance();
FirestoreReader get firestoreReader => FirestoreReader();
FirestoreWriter get firestoreWriter => FirestoreWriter();
AsyncMemoizer get memoizer => AsyncMemoizer();
HttpLogic get httpLogic => HttpLogic();
String get localToday => DateUtil.getLocalToday();
