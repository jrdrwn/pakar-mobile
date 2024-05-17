import 'dart:convert';
import 'dart:io';
import '../Entities/karya.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:remove_markdown/remove_markdown.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import '../Entities/category.dart';

import 'package:http/http.dart' as http;

class EditKarya extends StatefulWidget {
  final Karya karya;
  final PagingController<int, Karya> pagingController;
  const EditKarya({
    super.key,
    required this.karya,
    required this.pagingController,
  });

  @override
  State<EditKarya> createState() => _EditKaryaState();
}

class _EditKaryaState extends State<EditKarya> {
  final judulController = TextEditingController();
  final deskripsiController = TextEditingController();
  bool isGenerating = false;
  bool onSaving = false;

  PlatformFile? image;
  String? imageUrl;

  FilePickerStatus status = FilePickerStatus.done;

  final categoryController = TextEditingController();
  List<Category> categories = [];
  var test = "";

  void _categoriesInit() async {
    const secureStorage = FlutterSecureStorage();
    var userId = await secureStorage.read(key: "user_id");
    await dotenv.load(fileName: ".env");

    var response = await http.get(
      Uri.parse('${dotenv.env["API_URL"]}/karya/categories?q='),
      headers: <String, String>{"Cookie": "user_id=$userId"},
    );
    if (mounted) {
      setState(() {
        categories = categoryFromJson(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _categoriesInit();
    judulController.text = widget.karya.title;
    deskripsiController.text = widget.karya.about;
    categoryController.text = widget.karya.category;
    imageUrl = widget.karya.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Karya"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            TextFormField(
              controller: judulController,
              decoration: InputDecoration(
                labelText: "Judul Karya",
                hintText: "Masukkan judul karya",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            status == FilePickerStatus.picking
                ? const CircularProgressIndicator()
                : OutlinedButton.icon(
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                              allowCompression: false,
                              onFileLoading: (FilePickerStatus status) {
                                setState(() {
                                  this.status = status;
                                  imageUrl = null;
                                });
                              });
                      if (result != null) {
                        setState(() {
                          status = FilePickerStatus.picking;
                        });
                        PlatformFile file = result.files.first;

                        File f = File.fromUri(Uri.file(file.path as String));
                        final dio = Dio();
                        final data = <String, dynamic>{
                          "image": await MultipartFile.fromFile(
                            f.path,
                            contentType: MediaType("image", file.extension!),
                          ),
                        };
                        final formData = FormData.fromMap(data);
                        final response = await dio.post(
                            '${dotenv.env["API_URL"]}/imagekit',
                            data: formData);
                        setState(() {
                          imageUrl = response.data['url'];
                          image = file;
                          status = FilePickerStatus.done;
                        });
                      }
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 60)),
                    ),
                    icon: const Icon(Icons.upload_file),
                    label:
                        Text(image != null ? "Update Cover" : "Upload Cover")),
            if (imageUrl != null)
              Column(
                children: [
                  const SizedBox(height: 16),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                      ))
                ],
              ),
            const SizedBox(height: 16),
            MenuAnchor(
                alignmentOffset: const Offset(0, 10),
                style: MenuStyle(
                  maximumSize: const MaterialStatePropertyAll(
                      Size(double.maxFinite, 225)),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                menuChildren: [
                  MenuItemButton(
                    onPressed: () {
                      setState(() {
                        categoryController.text = test;
                      });
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 32,
                      child: Text(
                        "Tambah Kategori - $test",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ...categories.map((e) {
                    if (e.name.toLowerCase().contains(test.toLowerCase())) {
                      return MenuItemButton(
                        onPressed: () {
                          setState(() {
                            categoryController.text = e.name;
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 32,
                            child: Text(e.name, textAlign: TextAlign.center),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                ],
                builder: (BuildContext context, MenuController controller,
                    Widget? child) {
                  return TextFormField(
                    onTap: () {
                      controller.open();
                    },
                    onChanged: (value) {
                      if (!controller.isOpen) {
                        controller.open();
                      }

                      setState(() {
                        test = value;
                      });
                    },
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: "Masukkan Kategori",
                      hintText: "Masukkan kategori",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  );
                }),
            const SizedBox(height: 16),
            TextFormField(
              controller: deskripsiController,
              decoration: InputDecoration(
                labelText: "Deskripsi Karya",
                hintText: "Masukkan deskripsi karya",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            isGenerating
                ? const CircularProgressIndicator()
                : FilledButton.tonalIcon(
                    onPressed: () async {
                      setState(() {
                        isGenerating = true;
                      });

                      final dio = Dio();
                      final data = <String, dynamic>{
                        "title": judulController.text,
                        "category": categoryController.text,
                      };

                      if (image!.path!.isNotEmpty) {
                        data['image'] = await MultipartFile.fromFile(
                          image!.path!,
                          contentType: MediaType("image", 'jpeg'),
                        );
                      }

                      final formData = FormData.fromMap(data);

                      final response = await dio.post(
                          '${dotenv.env["API_URL"]}/caption-generator',
                          data: formData);

                      deskripsiController.text = response.data["description"]
                          .toString()
                          .removeMarkdown();

                      setState(() {
                        isGenerating = false;
                      });
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 60)),
                    ),
                    icon: const Icon(Icons.generating_tokens_outlined),
                    label: const Text("Generate Description")),
            const SizedBox(height: 16),
            onSaving
                ? const CircularProgressIndicator()
                : FilledButton.icon(
                    onPressed: () async {
                      setState(() {
                        onSaving = true;
                      });
                      var data = {
                        "title": judulController.text,
                        "category": categoryController.text,
                        "image": imageUrl,
                        "about": deskripsiController.text,
                      };

                      const secureStorage = FlutterSecureStorage();
                      var userId = await secureStorage.read(key: "user_id");
                      var response = await http.put(
                        Uri.parse(
                            '${dotenv.env["API_URL"]}/karya/${widget.karya.karyaId}'),
                        headers: <String, String>{
                          "Content-Type": "application/json",
                          "Cookie": "user_id=$userId"
                        },
                        body: jsonEncode(data),
                      );
                      setState(() {
                        onSaving = false;
                      });
                      if (response.statusCode != 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Karya gagal diperbarui"),
                          ),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Karya berhasil diperbarui"),
                        ),
                      );

                      Navigator.of(context).pop();
                      widget.pagingController.refresh();
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 60)),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan")),
          ]),
        ),
      ),
    );
  }
}
