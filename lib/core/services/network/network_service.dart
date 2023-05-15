import 'dart:developer';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/network/response_model.dart';
import 'package:goldenerp/core/services/theme/custom_colors.dart';
import 'package:goldenerp/product/constants/app_constants.dart';

abstract class NetworkService {
  static late Dio _dio;
  static const debug = true;
  static const debugDetailed = true;

  static int? _requestTime;

  static void init() {
    _requestTime = 30000;

    _dio = Dio(BaseOptions(
        connectTimeout: _requestTime,
        receiveTimeout: _requestTime,
        contentType: Headers.jsonContentType,
        baseUrl: AppConstants.APP_API!));

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return null;
    };
  }

  static void setUser(
      {required String username, required String password}) async {
    _dio.options.headers["Username"] = username;
    _dio.options.headers["Password"] = password;
  }

  static Future<ResponseModel<T>> get<T>(String url,
      {Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers}) async {
    String fullUrl = url;
    try {
      EasyLoading.instance.backgroundColor = Colors.yellow;
      EasyLoading.instance.indicatorColor = Colors.white;
      EasyLoading.instance.maskColor = Colors.black.withOpacity(0.7);
      EasyLoading.show(
          maskType: EasyLoadingMaskType.custom,
          dismissOnTap: true,
          indicator: const CircularProgressIndicator(
              color: CustomColors.primaryColor));

      Map<String, dynamic> newHeaders = _dio.options.headers;
      if (headers != null) {
        newHeaders.addAll(headers);
      }
      if (debug) {
        log("GET : $fullUrl");
        // log("baseUrl: ${_dio.options.baseUrl}");
        // log("headers of dio: ${_dio.options.headers}");
        // log("headers of request: $headers");
        // log("new headers: $newHeaders");
      }

      final Response<Map<String, dynamic>> data =
          await _dio.get<Map<String, dynamic>>(
        fullUrl,
        queryParameters: queryParameters,
        options: Options(headers: newHeaders),
      );
      if (debugDetailed) {
        log("GET DATA: ${data.data}");
      }
      return ResponseModel<T>.fromJson(data.data!);
    } catch (e) {
      log("Hata: $e", name: "NetworkService");
      int? statusCode = (e as DioError).response!.statusCode;
      EasyLoading.dismiss();

      // show alert dialog
      bool? tryAgain = await showDialog(
          context: NavigationService.instance.context,
          builder: (context) => AlertDialog(
                title: Text(
                    statusCode == 500 ? "Sunucu hatası" : "Bağlantı hatası"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("İptal")),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Tekrar dene")),
                ],
              ));
      if (tryAgain == true) {
        return await get<T>(url, queryParameters: queryParameters);
      } else {
        return ResponseModel<T>.networkError();
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  static Future<ResponseModel<T>> post<T>(String url,
      {Map<String, dynamic>? queryParameters,
      dynamic body,
      Map<String, dynamic>? headers}) async {
    String fullUrl = url;
    try {
      EasyLoading.instance.backgroundColor =
          CustomColors.primaryColor.withOpacity(0.7);
      EasyLoading.instance.indicatorColor = Colors.white;
      EasyLoading.instance.maskColor = Colors.black.withOpacity(0.7);
      EasyLoading.show(
          dismissOnTap: true,
          maskType: EasyLoadingMaskType.custom,
          indicator: const CircularProgressIndicator(
              color: CustomColors.primaryColor));
      if (debug) {
        log("POST: $fullUrl");
        log("POST BODY: $body");
      }

      Response<Map<String, dynamic>> response =
          await _dio.post<Map<String, dynamic>>(
        fullUrl,
        queryParameters: queryParameters,
        data: body,
        options: headers != null ? Options(headers: headers) : null,
      );
      if (debugDetailed) {
        log("POST DATA: ${response.data}");
      }
      return ResponseModel<T>.fromJson(response.data!);
    } catch (e) {
      log("Hata: $e");
      // token expired
      int? statusCode = (e as DioError).response!.statusCode;
      EasyLoading.dismiss();

      // show alert dialog
      bool? tryAgain = await showDialog(
          context: NavigationService.instance.context,
          builder: (context) => AlertDialog(
                title: Text(
                    statusCode == 500 ? "Sunucu hatası" : "Bağlantı hatası"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("İptal")),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Tekrar dene")),
                ],
              ));
      if (tryAgain == true) {
        return await post<T>(url, queryParameters: queryParameters, body: body);
      } else {
        return ResponseModel<T>.networkError();
      }
    } finally {
      EasyLoading.dismiss();
    }
  }
}
