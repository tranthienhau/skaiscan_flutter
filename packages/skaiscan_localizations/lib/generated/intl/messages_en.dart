// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(param) => "Enter ${param}";

  static String m1(statusCode) =>
      "An error occurred while sending request to the server. Code ${statusCode}";

  static String m2(name) => "Please enter your ${name}";

  static String m3(name) => "Please select your ${name}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accountNotAssociate":
            MessageLookupByLibrary.simpleMessage("Account not linked"),
        "backToMainScreen":
            MessageLookupByLibrary.simpleMessage("Back To The Main Screen"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chooseAnswer": MessageLookupByLibrary.simpleMessage("Choose answer"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "country": MessageLookupByLibrary.simpleMessage("Country"),
        "dataEmpty": MessageLookupByLibrary.simpleMessage("Data is empty"),
        "dataErrorMessage": MessageLookupByLibrary.simpleMessage(
            "Can not get data from server."),
        "dateOfBirth": MessageLookupByLibrary.simpleMessage("Date of birth"),
        "doNotReceiveOtp":
            MessageLookupByLibrary.simpleMessage("Didn’t receive the code?"),
        "enterParam": m0,
        "enterVerificationCode": MessageLookupByLibrary.simpleMessage(
            "Enter your\nVerification Code"),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "fullInfo": MessageLookupByLibrary.simpleMessage("Full information"),
        "gender": MessageLookupByLibrary.simpleMessage("Gender"),
        "languages": MessageLookupByLibrary.simpleMessage("Languages"),
        "listEmpty": MessageLookupByLibrary.simpleMessage("List is empty"),
        "listEmptyMessage": MessageLookupByLibrary.simpleMessage(
            "Please check filter condition and search keyword."),
        "loadDataError":
            MessageLookupByLibrary.simpleMessage("Load data error"),
        "location": MessageLookupByLibrary.simpleMessage("Location"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "network_authorisedRequest": MessageLookupByLibrary.simpleMessage(
            "401. Authentication required"),
        "network_badRequest":
            MessageLookupByLibrary.simpleMessage("400. Bad request"),
        "network_cannotConnectServer": MessageLookupByLibrary.simpleMessage(
            "Can\'t connect to the server."),
        "network_connectTakeALongTime": MessageLookupByLibrary.simpleMessage(
            "The server took too long to respond"),
        "network_default": m1,
        "network_internalServerError": MessageLookupByLibrary.simpleMessage(
            "Can not connect to the server"),
        "network_noInternetConnection":
            MessageLookupByLibrary.simpleMessage("No internet connection"),
        "network_notFound":
            MessageLookupByLibrary.simpleMessage("404. Not found"),
        "network_requestCancelled":
            MessageLookupByLibrary.simpleMessage("The request cancelled"),
        "network_requestTimeout":
            MessageLookupByLibrary.simpleMessage("Request time out"),
        "network_sendTimeout":
            MessageLookupByLibrary.simpleMessage("Send request time out"),
        "network_serviceUnavailable":
            MessageLookupByLibrary.simpleMessage("Service unavailable"),
        "network_unknownError": MessageLookupByLibrary.simpleMessage(
            "Can\'t connect to the server. The device does not have internet or the server is not available at this time."),
        "ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "otherInfoTitle":
            MessageLookupByLibrary.simpleMessage("Write your profile answers"),
        "otpCanNotRetry":
            MessageLookupByLibrary.simpleMessage("otp can not retry"),
        "otpExpired": MessageLookupByLibrary.simpleMessage("OTP Expired"),
        "otpExpires": MessageLookupByLibrary.simpleMessage("OTP Expires in"),
        "otpLockDueToRetry":
            MessageLookupByLibrary.simpleMessage("Your phone is locked"),
        "otpLocked":
            MessageLookupByLibrary.simpleMessage("Your phone is locked"),
        "otpNotFound": MessageLookupByLibrary.simpleMessage("OTP not found"),
        "otpWrong": MessageLookupByLibrary.simpleMessage("OTP wrong"),
        "pleaseEnterParam": m2,
        "pleaseEnterYourAnswer":
            MessageLookupByLibrary.simpleMessage("Please enter your answer"),
        "pleaseSelectParam": m3,
        "refreshPage": MessageLookupByLibrary.simpleMessage("Refresh page"),
        "requestAgain": MessageLookupByLibrary.simpleMessage("Request again"),
        "selectAPrompt":
            MessageLookupByLibrary.simpleMessage("Select a Prompt"),
        "typeDegreeLevel":
            MessageLookupByLibrary.simpleMessage("Type your degree level"),
        "unKnownError": MessageLookupByLibrary.simpleMessage("unKnownError"),
        "university": MessageLookupByLibrary.simpleMessage("University"),
        "verificationCode_description": MessageLookupByLibrary.simpleMessage(
            "Verification code was sent to"),
        "verifyAndCreateAccount":
            MessageLookupByLibrary.simpleMessage("Verify & Create Account"),
        "writeAnswer":
            MessageLookupByLibrary.simpleMessage("And write your answer"),
        "yourAnswer": MessageLookupByLibrary.simpleMessage("Your Answer"),
        "yourFullName": MessageLookupByLibrary.simpleMessage("Your full name")
      };
}
