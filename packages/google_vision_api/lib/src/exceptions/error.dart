class ApiExceptionError {
  ApiExceptionError({ this.message, this.data, this.details});

  ApiExceptionError.fromData(Map<String, dynamic> json) {
    message = json['message'];
    details = json['detail'];
    data = json['data'];
  }

  ApiExceptionError.fromError(Map<String, dynamic> json) {
    message = json['detail'];
    details = json['detail'];
    data = json['error'];
  }

  String? message;
  String? details;
  Map<String, dynamic>? data;

  @override
  String toString() {
    return message ?? 'Server error';
  }
}
