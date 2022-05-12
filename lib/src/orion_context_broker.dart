/*
 * NGSI-V2 Orion Context Broker SDK 
 * Created by Pandion Team
 * Base on doc: https://fiware-tutorials.readthedocs.io/en/latest/crud-operations.html
 */

import 'package:dio/dio.dart';

import 'common.dart';
import 'dio_config.dart';

/// [OrionContext]
class OrionContext {
  OrionContext({required String baseUrl}) : _http = DioRequest(baseUrl);

  final DioRequest _http;

  Future<bool> createEntity({required Map<String, dynamic> payload}) async {
    const String _url = '/v2/entities';

    try {
      final _response = await _http.request(
        _url,
        method: DioMethodType.POST,
        data: payload,
      ) as Response;

      if (_response.statusCode != 201) {
        return false;
      }

      return true;
    } catch (err) {
      throw err as dynamic;
    }
  }

  Future<bool> updateEntity({
    required String type,
    required String entityId,
    required Map<String, dynamic> payload,
  }) async {
    String _url = '/v2/entities/$entityId/attrs?type=$type';

    try {
      final _response = await _http.request(
        _url,
        method: DioMethodType.PATCH,
        data: payload,
      ) as Response;

      if (_response.statusCode != 204) {
        return false;
      }

      return true;
    } catch (err) {
      throw err as dynamic;
    }
  }

  Future<Map<String, dynamic>> fetchEntity({
    required String type,
    required String entityId,
  }) async {
    String _url = '/v2/entities/$entityId/?type=$type&options=keyValues';

    try {
      final _response = await _http.request(
        _url,
        method: DioMethodType.GET,
      ) as Response;

      final _rawData = _response.data;

      if (_response.statusCode != 200 || _rawData == null) {
        return {};
      }

      final _parsed = Map<String, dynamic>.from(_rawData);

      return _parsed;
    } catch (err) {
      throw err as dynamic;
    }
  }

  Future<List<Map<String, dynamic>>> fetchEntitiesWithRef({
    required String type,
    required String refEntityId,
    required String refEntity,
  }) async {
    String _url =
        '/v2/entities/?q=$refEntity==$refEntityId&type=$type&options=keyValues';

    try {
      final _response = await _http.request(
        _url,
        method: DioMethodType.GET,
      ) as Response;

      final _rawData = _response.data as List<dynamic>;

      if (_response.statusCode != 200 || _rawData.isEmpty) {
        return [];
      }

      final _parsed = _rawData.map((raw) => Map<String, dynamic>.from(raw)).toList();

      return _parsed;
    } catch (err) {
      throw err as dynamic;
    }
  }

  // TOOD: need check Relationships here
  Future<bool> deleteEntity({required String entityId}) async {
    String _url = '/v2/entities/$entityId';

    try {
      final _response = await _http.request(
        _url,
        method: DioMethodType.DELETE,
      ) as Response;

      if (_response.statusCode != 204) {
        return false;
      }

      return true;
    } catch (err) {
      throw err as dynamic;
    }
  }
}
