import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../Entities/user_profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http_parser/http_parser.dart';

final dio = Dio();

class CategoryCountData {
  final String category;
  final int count;

  CategoryCountData({required this.category, required this.count});

  factory CategoryCountData.fromJson(Map<String, dynamic> json) {
    return CategoryCountData(
      category: json['category'],
      count: json['count'],
    );
  }

  static List<CategoryCountData> fromJsonToList(List<dynamic> json) {
    return json.map((e) => CategoryCountData.fromJson(e)).toList();
  }
}

class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  const ProfileScreen({super.key, required this.userProfile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CategoryCountData> categoryCountData = [];

  void _getCategories() async {
    // get categories
    var response = await dio.get(
        '${dotenv.env["API_URL"]}/karya/categories?user_id=${widget.userProfile.userId}&count=true&limit=-1&q=');

    if (response.statusCode == 200) {
      setState(() {
        categoryCountData = CategoryCountData.fromJsonToList(response.data);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _tabController = TabController(length: 2, vsync: this);
    });
    _getCategories();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
  // tab controller

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, value) => [
        SliverToBoxAdapter(
            child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  // create border to the circle avatar
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                        ),
                      ],
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(widget.userProfile.image ??
                          "https://petapixel.com/assets/uploads/2022/12/what-is-unsplash.jpg"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.userProfile.username,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  Text(
                    widget.userProfile.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        )),
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverSafeArea(
            top: false,
            sliver: SliverAppBar(
              expandedHeight: 0,
              pinned: true,
              floating: true,
              snap: true,
              forceElevated: value,
              bottom: TabBar(controller: _tabController, tabs: const [
                Tab(
                  icon: Icon(Icons.bar_chart),
                ),
                Tab(
                  icon: Icon(Icons.settings),
                )
              ]),
            ),
          ),
        ),
      ],
      body: TabBarView(controller: _tabController, children: [
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoryCountData.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(categoryCountData[index].category),
                trailing: Text(categoryCountData[index].count.toString()),
              );
            }),
        // create form edit profile firstname, middlename, lastname, username, email, password
        EditProfile(userProfile: widget.userProfile)
      ]),
    );
  }
}

class EditProfile extends StatefulWidget {
  final UserProfile userProfile;
  const EditProfile({
    super.key,
    required this.userProfile,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  PlatformFile? image;
  String? imageUrl;
  FilePickerStatus status = FilePickerStatus.done;

  @override
  void initState() {
    super.initState();

    dio
        .get('${dotenv.env["API_URL"]}/profile',
            options: Options(
              headers: <String, String>{
                "Cookie": "user_id=${widget.userProfile.userId}"
              },
            ))
        .then((value) {
      final data = value.data;

      firstNameController.text = data['first_name'];
      middleNameController.text = data['middle_name'];
      lastNameController.text = data['last_name'];
      usernameController.text = data['username'];
      emailController.text = data['email'];
      setState(() {
        imageUrl = data['image'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
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
                    minimumSize: WidgetStateProperty.all(
                        const Size(double.infinity, 60)),
                  ),
                  icon: const Icon(Icons.upload_file),
                  label: Text(image != null ? "Update Cover" : "Upload Cover")),
          if (imageUrl != null)
            Column(
              children: [
                const SizedBox(height: 10),
                ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                    ))
              ],
            ),
          const SizedBox(height: 10),
          TextFormField(
            controller: firstNameController,
            decoration: InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: middleNameController,
            decoration: InputDecoration(
                labelText: "Middle Name",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: lastNameController,
            decoration: InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: usernameController,
            decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: ButtonStyle(
              maximumSize:
                  WidgetStateProperty.all(const Size(double.infinity, 50)),
              minimumSize:
                  WidgetStateProperty.all(const Size(double.infinity, 50)),
            ),
            onPressed: () async {
              final data = {};

              if (firstNameController.text.isNotEmpty) {
                data['first_name'] = firstNameController.text;
              }
              if (middleNameController.text.isNotEmpty) {
                data['middle_name'] = middleNameController.text;
              }
              if (lastNameController.text.isNotEmpty) {
                data['last_name'] = lastNameController.text;
              }
              if (usernameController.text.isNotEmpty) {
                data['username'] = usernameController.text;
              }
              if (emailController.text.isNotEmpty) {
                data['email'] = emailController.text;
              }
              if (passwordController.text.isNotEmpty) {
                data['password'] = passwordController.text;
              }
              if (imageUrl != null) {
                data['image'] = imageUrl;
              }

              var response = await dio.put('${dotenv.env["API_URL"]}/profile',
                  data: data,
                  options: Options(
                    headers: <String, String>{
                      "Cookie": "user_id=${widget.userProfile.userId}"
                    },
                  ));
              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Profil berhasil diperbarui")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profil gagal diperbarui")));
              }

              context.go('/intro');
            },
            child: const Text("Perbarui Profil"),
          ),
          // logout button
          const SizedBox(height: 10),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              maximumSize:
                  WidgetStateProperty.all(const Size(double.infinity, 50)),
              minimumSize:
                  WidgetStateProperty.all(const Size(double.infinity, 50)),
            ),
            onPressed: () async {
              final secureStorage = FlutterSecureStorage();
              await secureStorage.delete(key: 'user_id');
              context.go('/intro');
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
