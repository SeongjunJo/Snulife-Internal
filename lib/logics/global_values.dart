import '../ui/styles/colors.dart';
import '../ui/styles/fonts.dart';

AppColors get appColors => AppColors();

AppFonts get appFonts => AppFonts();

enum FirebaseAuthErrors {
  invalidEmail,
  channelError,
  invalidCredential,
  userDisabled,
  networkRequestFailed,
  unknownError,
  none,
}
