// Exception classes for handling API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);
}

class OfflineException implements Exception {
  final String message = 'No internet connection';
}

class BadRequestException implements Exception {
  final String message = 'Bad request';
}

class UnauthorizedException implements Exception {
  final String message = 'Unauthorized';
}

class ForbiddenException implements Exception {
  final String message = 'Forbidden';
}

class NotFoundException implements Exception {
  final String message = 'Not found';
}

class InternalServerErrorException implements Exception {
  final String message = 'Internal server error';
}