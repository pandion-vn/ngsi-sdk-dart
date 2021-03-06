import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'common.dart';

const _dioMethod = <DioMethodType, String>{
  DioMethodType.POST: 'POST',
  DioMethodType.GET: 'GET',
  DioMethodType.PATCH: 'PATCH',
  DioMethodType.DELETE: 'DELETE',
};

class DioRequest {
  final String baseurl;
  late Dio _dio;

  DioRequest(this.baseurl) {
    _dio = Dio(BaseOptions(baseUrl: baseurl));
  }

  Future<dynamic> request(
    String host, {
    DioMethodType method = DioMethodType.GET,
    dynamic data,
    dynamic queryParameters,
    bool cached = false,
    Map<String, dynamic>? headers,
    Duration cacheDuration = const Duration(days: 1),
    Duration maxStale = const Duration(days: 5),
  }) async {
    try {
      final _method = _dioMethod[method];

      if (cached) {
        _dio.interceptors.add(DioCacheManager(
          CacheConfig(baseUrl: baseurl, defaultRequestMethod: _method!),
        ).interceptor);
      }

      _dio.options.headers = headers;
      _dio.options.method = _method!;

      if (method == DioMethodType.DELETE) {
        _dio.options.contentType = null;
      }

      final Response<dynamic> response = await _dio.request(
        host,
        data: data,
        queryParameters: queryParameters,
        options: cached
            ? buildCacheOptions(
                cacheDuration,
                maxStale: maxStale,
              )
            : null,
      );

      return response;
    } on DioError catch (_) {
      if (_.response != null) {
        throw <String, dynamic>{
          'statusCode': _.response?.statusCode ?? _.type.index,
          'headers': _.response?.headers,
          'message': _.response?.statusMessage,
          'requestOptions': _.response?.requestOptions,
        };
      }

      throw <String, dynamic>{
        'statusCode': _.type.index,
        'headers': null,
        'message': _.message,
        'requestOptions': _.requestOptions,
      };
    }
  }
}
