import 'package:snulife_internal/logics/commons/firebase_classes.dart';
import 'package:snulife_internal/logics/firestore_read.dart';

import '../../ui/styles/colors.dart';
import '../../ui/styles/fonts.dart';

// make only one instance like singleton

AppColors get appColors => AppColors();
AppFonts get appFonts => AppFonts();
FirebaseInstance get firebaseInstance => FirebaseInstance();
FirestoreReader get firestoreReader => FirestoreReader();
