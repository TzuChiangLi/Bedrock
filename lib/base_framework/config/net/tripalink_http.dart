

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bedrock/base_framework/config/net/base_http.dart';
import 'package:flutter_bedrock/base_framework/exception/un_authorized_exception.dart';
import 'package:flutter_bedrock/base_framework/exception/un_caught_exception.dart';
import 'package:flutter_bedrock/base_framework/exception/user_unbind_exception.dart';


final TripaLinkHttp tripaLinkHttp = TripaLinkHttp();


class TripaLinkHttp extends BaseHttp{


  @override
  void init() {

    options.baseUrl = "https://www.baidu.com";
    interceptors
      ..add(CookieManager(PersistCookieJar()))
      ..add(ApiInterceptor());
  }

}



class ApiInterceptor extends InterceptorsWrapper{

  @override
  Future onRequest(RequestOptions options) async{

    debugPrint('---api-request--->url--> ${options.baseUrl}${options.path}' +
        ' queryParameters: ${options.queryParameters}'
        ' formdata  : ${options.data.toString()}' );
    String params="";
    String mark = "&";
    options.queryParameters.forEach((k,v){
      if(v == null) return;
      params = "$params${params.isEmpty?"":mark}$k=$v";
    });
    debugPrint("---api-request--->url--> ${options.baseUrl}${options.path}?$params");

    //debugPrint("request header  :  ${options.headers.toString()}");
    return options;
  }


  @override
  Future onResponse(Response response) {

    ResponseData responseData = ResponseData.fromJson(response.data);
    if(responseData.success){
      return tripaLinkHttp.resolve(responseData);
    }else{
      ///这里可以根据不同的业务代码 扔出不同的异常
      ///具体要根据后台进行协商
      if(responseData.code ==  30001){
        throw new UnAuthorizedException();
      }
      if(responseData.code == 30003){
        //用户需要绑定
        throw new UserUnbindException();
      }
      throw new UnCaughtException();
      //return null;

    }

    return tripaLinkHttp.resolve(response);

  }


}





class ResponseData extends BaseResponseData {
  bool get success => (code == 1 || code == 200);

  ResponseData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'];
  }
}