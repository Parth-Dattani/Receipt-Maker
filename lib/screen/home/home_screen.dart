import 'package:GetYourInvoice/controller/controller.dart';
import 'package:GetYourInvoice/widgets/common_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController>{
 static const pageId = "/HomeScreen";

  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body:
      Center(
        child: controller.isLoading.value ? CommonLoader() :
        Expanded(
          child: ListView.builder(
            itemCount: controller.commentList.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(controller.commentList[index].email.toString()),);
          },),
        ),
      ),
    );
  }
}