import 'dart:convert';

import 'package:GetYourInvoice/controller/bash_controller.dart';
import 'package:GetYourInvoice/model/comment_model.dart';
import 'package:GetYourInvoice/services/service.dart';
import 'package:get/get.dart';

class HomeController extends BaseController{

  RxList<CommentResponse> commentList = <CommentResponse>[].obs;
  var page = 1;                // Current page
  final int limit = 10;        // Items per page
  var hasMore = true.obs;      // Flag to check if more data exists



  // void getComment() async {
  //   if(!hasMore.value) return;
  //   isLoading.value = true;
  //
  //   try {
  //     var response = await RemoteService.getComment(); // await added
  //
  //     if (response.statusCode == 200) {
  //       final List data = json.decode(response.body);
  //       print("Dattta: ----- ${data}");
  //       commentList.value =
  //           data.map((e) => CommentResponse.fromJson(e)).toList();
  //    print("Lennnnn:--------${commentList.length}");
  //     } else {
  //       print("Error In Comment Api: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error-Comment Api: ${e.toString()}");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  ///
  // void getComment2(){
  //   isLoading.value = true;
  //
  //   final response = RemoteService.getComment();
  //   try{
  //     if(response == 200){
  //       // final data = json.decode(response);
  //
  //       commentList.value = response;
  //     }
  //     else{
  //       print("Error In Comment Api: ${response}")
  //     }
  //   }
  //   catch(e){
  //     print("Error-Comment Api: ${e.toString()}");
  //   }
  // }
}