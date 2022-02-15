// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `400. Bad request`
  String get network_badRequest {
    return Intl.message(
      '400. Bad request',
      name: 'network_badRequest',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while sending request to the server. Code {statusCode}`
  String network_default(Object statusCode) {
    return Intl.message(
      'An error occurred while sending request to the server. Code $statusCode',
      name: 'network_default',
      desc: '',
      args: [statusCode],
    );
  }

  /// `No internet connection`
  String get network_noInternetConnection {
    return Intl.message(
      'No internet connection',
      name: 'network_noInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Can't connect to the server.`
  String get network_cannotConnectServer {
    return Intl.message(
      'Can\'t connect to the server.',
      name: 'network_cannotConnectServer',
      desc: '',
      args: [],
    );
  }

  /// `The server took too long to respond`
  String get network_connectTakeALongTime {
    return Intl.message(
      'The server took too long to respond',
      name: 'network_connectTakeALongTime',
      desc: '',
      args: [],
    );
  }

  /// `Can't connect to the server. The device does not have internet or the server is not available at this time.`
  String get network_unknownError {
    return Intl.message(
      'Can\'t connect to the server. The device does not have internet or the server is not available at this time.',
      name: 'network_unknownError',
      desc: '',
      args: [],
    );
  }

  /// `Request time out`
  String get network_requestTimeout {
    return Intl.message(
      'Request time out',
      name: 'network_requestTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Send request time out`
  String get network_sendTimeout {
    return Intl.message(
      'Send request time out',
      name: 'network_sendTimeout',
      desc: '',
      args: [],
    );
  }

  /// `401. Authentication required`
  String get network_authorisedRequest {
    return Intl.message(
      '401. Authentication required',
      name: 'network_authorisedRequest',
      desc: '',
      args: [],
    );
  }

  /// `404. Not found`
  String get network_notFound {
    return Intl.message(
      '404. Not found',
      name: 'network_notFound',
      desc: '',
      args: [],
    );
  }

  /// `Can not connect to the server`
  String get network_internalServerError {
    return Intl.message(
      'Can not connect to the server',
      name: 'network_internalServerError',
      desc: '',
      args: [],
    );
  }

  /// `Service unavailable`
  String get network_serviceUnavailable {
    return Intl.message(
      'Service unavailable',
      name: 'network_serviceUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `The request cancelled`
  String get network_requestCancelled {
    return Intl.message(
      'The request cancelled',
      name: 'network_requestCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Account not linked`
  String get accountNotAssociate {
    return Intl.message(
      'Account not linked',
      name: 'accountNotAssociate',
      desc: '',
      args: [],
    );
  }

  /// `Refresh page`
  String get refreshPage {
    return Intl.message(
      'Refresh page',
      name: 'refreshPage',
      desc: '',
      args: [],
    );
  }

  /// `Load data error`
  String get loadDataError {
    return Intl.message(
      'Load data error',
      name: 'loadDataError',
      desc: '',
      args: [],
    );
  }

  /// `Data is empty`
  String get dataEmpty {
    return Intl.message(
      'Data is empty',
      name: 'dataEmpty',
      desc: '',
      args: [],
    );
  }

  /// `List is empty`
  String get listEmpty {
    return Intl.message(
      'List is empty',
      name: 'listEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please check filter condition and search keyword.`
  String get listEmptyMessage {
    return Intl.message(
      'Please check filter condition and search keyword.',
      name: 'listEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Can not get data from server.`
  String get dataErrorMessage {
    return Intl.message(
      'Can not get data from server.',
      name: 'dataErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Enter your\nVerification Code`
  String get enterVerificationCode {
    return Intl.message(
      'Enter your\nVerification Code',
      name: 'enterVerificationCode',
      desc: '',
      args: [],
    );
  }

  /// `Verification code was sent to`
  String get verificationCode_description {
    return Intl.message(
      'Verification code was sent to',
      name: 'verificationCode_description',
      desc: '',
      args: [],
    );
  }

  /// `Didn’t receive the code?`
  String get doNotReceiveOtp {
    return Intl.message(
      'Didn’t receive the code?',
      name: 'doNotReceiveOtp',
      desc: '',
      args: [],
    );
  }

  /// `Request again`
  String get requestAgain {
    return Intl.message(
      'Request again',
      name: 'requestAgain',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `unKnownError`
  String get unKnownError {
    return Intl.message(
      'unKnownError',
      name: 'unKnownError',
      desc: '',
      args: [],
    );
  }

  /// `Verify & Create Account`
  String get verifyAndCreateAccount {
    return Intl.message(
      'Verify & Create Account',
      name: 'verifyAndCreateAccount',
      desc: '',
      args: [],
    );
  }

  /// `OTP Expires in`
  String get otpExpires {
    return Intl.message(
      'OTP Expires in',
      name: 'otpExpires',
      desc: '',
      args: [],
    );
  }

  /// `OTP Expired`
  String get otpExpired {
    return Intl.message(
      'OTP Expired',
      name: 'otpExpired',
      desc: '',
      args: [],
    );
  }

  /// `otp can not retry`
  String get otpCanNotRetry {
    return Intl.message(
      'otp can not retry',
      name: 'otpCanNotRetry',
      desc: '',
      args: [],
    );
  }

  /// `Your phone is locked`
  String get otpLockDueToRetry {
    return Intl.message(
      'Your phone is locked',
      name: 'otpLockDueToRetry',
      desc: '',
      args: [],
    );
  }

  /// `Your phone is locked`
  String get otpLocked {
    return Intl.message(
      'Your phone is locked',
      name: 'otpLocked',
      desc: '',
      args: [],
    );
  }

  /// `OTP not found`
  String get otpNotFound {
    return Intl.message(
      'OTP not found',
      name: 'otpNotFound',
      desc: '',
      args: [],
    );
  }

  /// `OTP wrong`
  String get otpWrong {
    return Intl.message(
      'OTP wrong',
      name: 'otpWrong',
      desc: '',
      args: [],
    );
  }

  /// `Back To The Main Screen`
  String get backToMainScreen {
    return Intl.message(
      'Back To The Main Screen',
      name: 'backToMainScreen',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your {name}`
  String pleaseEnterParam(Object name) {
    return Intl.message(
      'Please enter your $name',
      name: 'pleaseEnterParam',
      desc: '',
      args: [name],
    );
  }

  /// `Please select your {name}`
  String pleaseSelectParam(Object name) {
    return Intl.message(
      'Please select your $name',
      name: 'pleaseSelectParam',
      desc: '',
      args: [name],
    );
  }

  /// `Date of birth`
  String get dateOfBirth {
    return Intl.message(
      'Date of birth',
      name: 'dateOfBirth',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  /// `Languages`
  String get languages {
    return Intl.message(
      'Languages',
      name: 'languages',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get country {
    return Intl.message(
      'Country',
      name: 'country',
      desc: '',
      args: [],
    );
  }

  /// `Full information`
  String get fullInfo {
    return Intl.message(
      'Full information',
      name: 'fullInfo',
      desc: '',
      args: [],
    );
  }

  /// `Choose answer`
  String get chooseAnswer {
    return Intl.message(
      'Choose answer',
      name: 'chooseAnswer',
      desc: '',
      args: [],
    );
  }

  /// `University`
  String get university {
    return Intl.message(
      'University',
      name: 'university',
      desc: '',
      args: [],
    );
  }

  /// `Enter {param}`
  String enterParam(Object param) {
    return Intl.message(
      'Enter $param',
      name: 'enterParam',
      desc: '',
      args: [param],
    );
  }

  /// `Your full name`
  String get yourFullName {
    return Intl.message(
      'Your full name',
      name: 'yourFullName',
      desc: '',
      args: [],
    );
  }

  /// `Type your degree level`
  String get typeDegreeLevel {
    return Intl.message(
      'Type your degree level',
      name: 'typeDegreeLevel',
      desc: '',
      args: [],
    );
  }

  /// `Write your profile answers`
  String get otherInfoTitle {
    return Intl.message(
      'Write your profile answers',
      name: 'otherInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select a Prompt`
  String get selectAPrompt {
    return Intl.message(
      'Select a Prompt',
      name: 'selectAPrompt',
      desc: '',
      args: [],
    );
  }

  /// `And write your answer`
  String get writeAnswer {
    return Intl.message(
      'And write your answer',
      name: 'writeAnswer',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your answer`
  String get pleaseEnterYourAnswer {
    return Intl.message(
      'Please enter your answer',
      name: 'pleaseEnterYourAnswer',
      desc: '',
      args: [],
    );
  }

  /// `Your Answer`
  String get yourAnswer {
    return Intl.message(
      'Your Answer',
      name: 'yourAnswer',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
