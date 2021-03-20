import 'package:in_app_review/in_app_review.dart';

final InAppReview inAppReview = InAppReview.instance;

Future<bool> askForReview () async {
  if (await inAppReview.isAvailable()) {
    inAppReview.requestReview();
    return true;
  }
  return false;
}
