import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i('Request: ${options.method} ${options.path}');
    logger.i('Headers: ${options.headers}');
    logger.i('Data: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i('Response: ${response.statusCode} ${response.requestOptions.path}');
    logger.i('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e('Error: ${err.message}');
    logger.e('Error Details: ${err.error}');
    logger.e("Response is: ${err.response}");
    super.onError(err, handler);
  }
}