import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:e_commerce1/models/category.dart';
import 'package:e_commerce1/screens/user_screens/more_screens/login.dart';
import 'package:e_commerce1/services/auth_service.dart';
import 'package:e_commerce1/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../loader.dart';
import '../globals.dart' as globals;
import '../../../services/auth_service.dart';
import 'package:file_picker/file_picker.dart';

import 'package:google_ml_kit/google_ml_kit.dart';

class AddProduct extends StatefulWidget {
  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _LoaderDialog = new GlobalKey<State>();
  late var filename = '';
  late var path = '';
  String dropdownValue = "One";
  final onDeviceTranslator = GoogleMlKit.nlp.onDeviceTranslator(sourceLanguage: "en",targetLanguage: "ar");
  final translateLanguageModelManager = GoogleMlKit.nlp.translateLanguageModelManager();

  String? translatedName;
  String? translatedDesc;

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new product"),
      ),
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: context.read<AuthenticationService>().getAllCategories(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Category>? categories = snapshot.data as List<Category>?;
                List<String> titles = [];
                categories!.forEach((element) {
                  titles.add(element.title);
                });
                String selected = titles[0];
                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 80),
                      Center(
                          child: Column(
                            children: const [
                              Icon(
                                Icons.shopping_basket,
                                size: 65.0,
                                color: Color(0xff0088ff),
                              ),
                              Text(
                                "Ecommerce",
                                style: TextStyle(
                                    color: Color(0xff0088ff), fontSize: 35.0),
                              ),
                            ],
                          )),
                      const SizedBox(
                        height: 60,
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width - 50,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter name";
                            }
                            return null;
                          },
                          controller: nameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.supervised_user_circle),
                            border: OutlineInputBorder(),
                            hintText: 'Enter your name here',
                          ),
                        ),
                      ),translatedName == null  ?  Text('place holder'):Text(translatedName!,style: TextStyle(fontSize: 20),) ,
                      SizedBox(height: 20),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width - 50,
                        child: DropdownSearch<String>(
                            mode: Mode.BOTTOM_SHEET,
                            items: titles,
                            label: "Category",
                            popupItemDisabled: (String s) => s.startsWith('I'),
                            onChanged: (v) {
                              selected = v!;
                            },
                            selectedItem: titles[0]),
                      ),
                      SizedBox(height: 20),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width - 50,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter price";
                            }
                            return null;
                          },
                          controller: priceController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.supervised_user_circle),
                            border: OutlineInputBorder(),
                            hintText: 'Enter your price here',
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width - 50,
                        child: TextFormField(
                          maxLines: 8,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter description";
                            }
                            return null;
                          },
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            hintText: "Enter description",
                            prefixIcon: Icon(Icons.email_rounded),
                            border: OutlineInputBorder(),
                          ),
                        ),

                      ),
                      translatedDesc == null  ?  Text('place holder'):Text(translatedDesc!,) ,
                      SizedBox(height: 20),
                      ButtonBar(
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                final results = await FilePicker.platform
                                    .pickFiles(
                                  allowMultiple: false,
                                  type: FileType.custom,
                                  allowedExtensions: ['png', 'jpg', 'jpeg'],
                                );
                                if (results == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("no image selected"),
                                    ),
                                  );
                                  return null;
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("image is selected"),
                                    ),
                                  );
                                }
                                path = results.files.single.path!;
                                filename = results.files.single.name;
                              },
                              child: Text("Add images")),
                          ElevatedButton(onPressed: () async {


                            //final bool response = await translateLanguageModelManager.downloadModel(modelTag);
                            //final String response = await translateLanguageModelManager.isModelDownloaded(modelTag);
                            //final String response = await translateLanguageModelManager.deleteModel(modelTag);
                            //final List<String> availableModels = await translateLanguageModelManager.getAvailableModels();
                            if (_formKey.currentState!.validate()) {
                              storage.uploadFile(path, filename).then((value) =>
                                  print("done"));
                              String? value = await context.read<
                                  AuthenticationService>().AddProduct(
                                  name: nameController.text.trim(),
                                  desc: descriptionController.text.trim(),
                                  type: selected,
                                  path: filename,
                                  price: priceController.text.trim());
                              if (value != null) {
                                showMyDialogError();
                              } else {
                                showMyDialogSuccess();
                              }
                            }
                          }, child: Text("Save Product")),
                          ElevatedButton(onPressed: () async {

                            final String downloadResponseEN = await translateLanguageModelManager.downloadModel("en");
                            final String downloadResponseAR = await translateLanguageModelManager.downloadModel("ar");
                            print(downloadResponseAR);
                            //final String response = await onDeviceTranslator.translateText("test");

                            //print(response);
                            if (_formKey.currentState!.validate()) {


                                String name =  nameController.text.trim();
                                String description =  descriptionController.text.trim();
                                translatedName = await onDeviceTranslator.translateText(name);
                                translatedDesc = await onDeviceTranslator.translateText(description);
                                setState(()  {

                                });
                                print(name);
                                //print(response);
                            }

                            onDeviceTranslator.close();
                          }, child: Text("translate text"))
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator(),);
              }
            }
          ),
        )
    );
  }

  Future<void> showMyDialogError() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Product not added'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showMyDialogSuccess() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Product added succesfully'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(context).pop();
                clearText();
              },
            ),
          ],
        );
      },
    );
  }

  void clearText() {
    nameController.clear();
    descriptionController.clear();
    typeController.clear();
    priceController.clear();
  }

}