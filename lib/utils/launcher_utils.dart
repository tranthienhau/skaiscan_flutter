class UrlUtils {
  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  static String getCallLauncher({required String phoneNumber}){
    final Uri callLauncher = Uri(scheme: 'tel',
        path: phoneNumber);
    return callLauncher.toString();
  }

  static String getSmsLauncher({required String phoneNumber, String? bodySms}){
    final Uri smsLaunch = Uri(scheme: 'sms',
        path: phoneNumber,
        query: encodeQueryParameters(<String, String>{
          'body': '$bodySms'
        }));
    return smsLaunch.toString();
  }

  static String getMailLauncher({required String emailAddress, String? subject, String? body}){
    final Uri mailLauncher = Uri(scheme: 'mailto',
        path: emailAddress,
        query: encodeQueryParameters(<String, String>{
          'subject': 'subject',
          'body': '$body'
        }));
    return mailLauncher.toString();
  }
}