import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';


class ReferralHelper{

  static const String APP_DOWNLOAD_LINK = 'https://drive.google.com/open?id=1bM-_BIxzDVYRwiPzU0z5iPtHvErD-SoN';
  static const String URI_PREFIX = 'https://anweshanquiz.page.link';

  Future<Uri> retrieveDynamicLink(String mailId) async {
    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.retrieveDynamicLink();
    final Uri deepLink = data?.link;
    return deepLink;
  }

  Future<Uri> generateReferralLink(String referrerMailId) async {
    try{
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: URI_PREFIX,
        link: Uri.parse('$URI_PREFIX?referrer=$referrerMailId'),
        androidParameters: AndroidParameters(
          packageName: 'com.az.quiz',
          minimumVersion: 1,
          fallbackUrl: Uri.parse(APP_DOWNLOAD_LINK),
        ),
      );
      final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
      final Uri referralLink = shortDynamicLink.shortUrl;
      return referralLink;
    }catch(e){
      throw ReferralHelperException("Failed to generate link: $e");
    }
    
  }
}

class ReferralHelperException implements Exception {
  String cause;
  ReferralHelperException(this.cause);
}
