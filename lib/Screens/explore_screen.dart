import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_3/Entities/category.dart';
import 'package:flutter_application_3/Entities/karya.dart';
import 'package:flutter_application_3/Entities/user_profile.dart';
import 'package:flutter_application_3/Screens/introduction_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int currentPageIndex = 0;
  String? userId;
  UserPofile? userPofile;

  void _userInit() async {
    const secureStorage = FlutterSecureStorage();
    userId = await secureStorage.read(key: "user_id");

    await dotenv.load(fileName: ".env");

    var response = await http.get(
      Uri.parse('${dotenv.env["API_URL"]}/profile'),
      headers: <String, String>{"Cookie": "user_id=$userId"},
    );
    if (mounted) {
      setState(() {
        userPofile = UserPofile.fromJson(jsonDecode(response.body));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _userInit();
    return SafeArea(
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.background,
          statusBarIconBrightness: Brightness.light,
        ),
        child: userPofile == null
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : Scaffold(
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(70),
                    child: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              backgroundImage: NetworkImage(userPofile?.image ??
                                  "https://petapixel.com/assets/uploads/2022/12/what-is-unsplash.jpg"),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hai, ${userPofile?.firstName}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                                Text(
                                  "Apa yang ingin kamu temukan hari ini?",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton.filledTonal(
                                onPressed: () {},
                                icon: const Icon(Icons.arrow_back)),
                            const SizedBox(width: 16),
                            Text(
                              "Tambah Karya",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const Spacer(),
                            FilledButton.icon(
                                onPressed: () {},
                                label: const Text("Simpan"),
                                icon: const Icon(Icons.save)),
                          ],
                        ),
                      ),
                      const Placeholder(),
                    ][currentPageIndex]),
                body: <Widget>[
                  ExploreWidget(userProfile: userPofile),
                  CreateKaryaWidget(),
                  FilledButton(
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const IntroductionScreen(),
                            ));
                        if (!mounted) Navigator.pop(context);
                      },
                      child: Text("Logout")),
                ][currentPageIndex],
                bottomNavigationBar: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(243, 237, 247, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: NavigationBar(
                    onDestinationSelected: (int index) {
                      setState(() {
                        currentPageIndex = index;
                      });
                    },
                    elevation: 0,
                    selectedIndex: currentPageIndex,
                    backgroundColor: Colors.transparent,
                    destinations: const [
                      NavigationDestination(
                        selectedIcon: Icon(Icons.explore),
                        icon: Icon(Icons.explore_outlined),
                        label: "Explore",
                      ),
                      NavigationDestination(
                        selectedIcon: Icon(Icons.add_circle),
                        icon: Icon(Icons.add_circle_outline),
                        label: "Create",
                      ),
                      NavigationDestination(
                        selectedIcon: Icon(Icons.settings),
                        icon: Icon(Icons.settings_outlined),
                        label: "Settings",
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class CreateKaryaWidget extends StatefulWidget {
  const CreateKaryaWidget({
    super.key,
  });

  @override
  State<CreateKaryaWidget> createState() => _CreateKaryaWidgetState();
}

class _CreateKaryaWidgetState extends State<CreateKaryaWidget> {
  Uint8List? bytes;
  FilePickerStatus status = FilePickerStatus.picking;

  final categoryController = TextEditingController();
  var test = "";

  @override
  Widget build(BuildContext context) {
    var categories = ["test 1", "test 2", "test 3", "test 4"];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: "Judul Karya",
            hintText: "Masukkan judul karya",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(height: 16),
        FilledButton.icon(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                  readSequential: true,
                  onFileLoading: (FilePickerStatus status) {
                    setState(() {
                      this.status = status;
                    });
                  });
              setState(() {
                bytes = result!.files.single.bytes!;
              });
            },
            style: ButtonStyle(
              minimumSize:
                  MaterialStateProperty.all(const Size(double.infinity, 60)),
            ),
            icon: const Icon(Icons.upload_file),
            label: Text("Upload Cover")),
        bytes != null
            ? Image.memory(bytes!)
            : status == FilePickerStatus.picking
                ? Container()
                : CircularProgressIndicator(),
        SizedBox(height: 16),
        MenuAnchor(
            alignmentOffset: Offset(0, 10),
            style: MenuStyle(
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
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  child: Text(
                    "Tambah Kategori - " + test,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ...categories.map((e) => MenuItemButton(
                    onPressed: () {
                      setState(() {
                        categoryController.text = e;
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 32,
                        child: Text(e, textAlign: TextAlign.center),
                      ),
                    ),
                  )),
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
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: "Deskripsi Karya",
            hintText: "Masukkan deskripsi karya",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
        ),
        SizedBox(height: 16),
        OutlinedButton.icon(
            onPressed: () {},
            style: ButtonStyle(
              minimumSize:
                  MaterialStateProperty.all(const Size(double.infinity, 60)),
            ),
            icon: Icon(Icons.generating_tokens_outlined),
            label: Text("Generate Description")),
        SizedBox(height: 16),
        FilledButton.icon(
            onPressed: () {},
            style: ButtonStyle(
              minimumSize:
                  MaterialStateProperty.all(const Size(double.infinity, 60)),
            ),
            icon: Icon(Icons.save),
            label: Text("Simpan")),
      ]),
    );
  }
}

class ExploreWidget extends StatefulWidget {
  final UserPofile? userProfile;

  const ExploreWidget({
    super.key,
    this.userProfile,
  });

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget> {
  var _pageSize = 10;
  final PagingController<int, Karya> _pagingController =
      PagingController(firstPageKey: 0);
  var selectedCategory = "Semua";
  List<Category> categories = [];
  List<Karya> karya = [];

  void _karyaInit(pagekey) async {
    try {
      await dotenv.load(fileName: ".env");

      var response = await http.get(
        Uri.parse(
            '${dotenv.env["API_URL"]}/karya?tag=${Uri.encodeComponent(selectedCategory)}&limit=10&offset=$pagekey'),
        headers: <String, String>{
          "Cookie": "user_id=${widget.userProfile?.userId}"
        },
      );

      if (mounted) {
        List<Karya> karya = karyaFromJson(response.body);
        print(karya);
        final isLastPage = karya.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(karya);
        } else {
          final nextPageKey = pagekey + karya.length;
          _pagingController.appendPage(karya, nextPageKey);
        }
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  void _categoriesInit() async {
    await dotenv.load(fileName: ".env");

    var response = await http.get(
      Uri.parse('${dotenv.env["API_URL"]}/karya/categories?q='),
      headers: <String, String>{
        "Cookie": "user_id=${widget.userProfile?.userId}"
      },
    );

    if (mounted) {
      setState(() {
        categories = categoryFromJson(response.body);
        categories.insert(0, Category(categoryId: 0, name: "Semua"));
      });
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _pagingController.addPageRequestListener((pageKey) {
      return _karyaInit(pageKey);
    });
    super.initState();
    _categoriesInit();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SearchBar(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor: const MaterialStatePropertyAll(
                          Color.fromRGBO(236, 230, 240, 1)),
                      padding: const MaterialStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 16)),
                      leading: const Icon(Icons.search),
                      hintText: "Cari karya",
                      constraints: BoxConstraints(
                          minWidth: 10.0,
                          maxWidth: MediaQuery.of(context).size.width - 82,
                          minHeight: 56.0),
                    ),
                    MenuAnchor(
                      builder: (context, controller, child) {
                        return Badge(
                          isLabelVisible: selectedCategory != "Semua",
                          largeSize: 20,
                          smallSize: 16,
                          child: IconButton.filled(
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            iconSize: 32,
                            padding: const EdgeInsets.all(12),
                            icon: const Icon(Icons.filter_alt_outlined),
                            tooltip: 'Show Categories',
                          ),
                        );
                      },
                      menuChildren: categories
                          .map((e) => MenuItemButton(
                              onPressed: () {
                                setState(() {
                                  selectedCategory = e.name;
                                });
                                _pagingController.refresh();
                              },
                              child: Text(e.name)))
                          .toList(),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Top Kategori",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              CarouselSlider(
                  items: const [
                    TopCategoryCard(),
                    TopCategoryCard(),
                    TopCategoryCard(),
                  ],
                  options: CarouselOptions(
                      height: 100,
                      viewportFraction: 0.8,
                      enlargeCenterPage: false,
                      enlargeFactor: 1)),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Explore",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: MediaQuery.of(context).size.height - 250,
                child: PagedListView<int, Karya>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) {
                      return KaryaCard(
                        karya: item,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class KaryaCard extends StatefulWidget {
  final Karya? karya;
  final PagingController<int, Karya>? pagingController;

  const KaryaCard({super.key, this.karya, this.pagingController});

  @override
  State<KaryaCard> createState() => _KaryaCardState();
}

class _KaryaCardState extends State<KaryaCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(widget.karya?.userImage ??
                  "https://petapixel.com/assets/uploads/2022/12/what-is-unsplash.jpg"),
            ),
            title: Text(widget.karya?.username ?? "Nama Pengguna"),
            subtitle: Text(widget.karya?.category ?? "Kategori"),
            trailing: PopUpMenuKaryaCard(
              karya: widget.karya,
              pagingController: widget.pagingController,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.karya?.image ??
                    "https://petapixel.com/assets/uploads/2022/12/what-is-unsplash.jpg",
                fit: BoxFit.cover,
                repeat: ImageRepeat.noRepeat,
                alignment: Alignment.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.karya?.title ??
                  "Deskripsi Karya Deskripsi KaryaDeskripsi KaryaDeskripsi KaryaDeskripsi KaryaDeskripsi KaryaDeskripsi KaryaDeskripsi KaryaDeskripsi Karya",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await dotenv.load(fileName: ".env");

                    const secureStorage = FlutterSecureStorage();

                    var response = await http.put(
                      Uri.parse(
                          '${dotenv.env["API_URL"]}/karya/${widget.karya?.karyaId}/like'),
                      headers: <String, String>{
                        'Cookie':
                            'user_id=${await secureStorage.read(key: "user_id")}',
                      },
                    );

                    if (response.statusCode != 200) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("Operasi gagal, silahkan coba lagi nanti")));
                      return;
                    }
                    setState(() {
                      widget.karya?.isUserLike =
                          widget.karya?.isUserLike == 1 ? 0 : 1;
                      widget.karya?.likesCount = widget.karya?.isUserLike == 1
                          ? widget.karya!.likesCount + 1
                          : widget.karya!.likesCount - 1;
                    });
                  },
                  icon: Icon(widget.karya?.isUserLike == 1
                      ? Icons.favorite
                      : Icons.favorite_outline),
                  label: Text(widget.karya?.likesCount.toString() ?? "0"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopCategoryCard extends StatelessWidget {
  const TopCategoryCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 300,
              child: Image.network(
                "https://petapixel.com/assets/uploads/2022/12/what-is-unsplash.jpg",
                fit: BoxFit.cover,
                repeat: ImageRepeat.noRepeat,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withAlpha(0),
                    Colors.black12,
                    Colors.black45
                  ],
                ),
              ),
              child: const Text(
                'Foreground Text',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopUpMenuKaryaCard extends StatefulWidget {
  final Karya? karya;

  final PagingController<int, Karya>? pagingController;

  const PopUpMenuKaryaCard({super.key, this.karya, this.pagingController});

  @override
  State<PopUpMenuKaryaCard> createState() => _PopUpMenuKaryaCardState();
}

class _PopUpMenuKaryaCardState extends State<PopUpMenuKaryaCard> {
  var selectedItem;

  var isLoading = false;

  var isOwner = false;

  void _checkOwner() async {
    const secureStorage = FlutterSecureStorage();

    if (widget.karya?.userId.toString() ==
        await secureStorage.read(key: "user_id")) {
      setState(() {
        isOwner = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkOwner();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(Icons.more_vert_outlined),
            tooltip: 'Show menu',
          );
        },
        menuChildren: [
          if (isOwner)
            MenuItemButton(
              onPressed: () {
                setState(() {
                  selectedItem = 1;
                });
              },
              child: Text("Edit"),
            ),
          if (isOwner)
            MenuItemButton(
              onPressed: () async {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Hapus Karya'),
                      content: const SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Apakah anda yakin menghapus karya ini?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Batal'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FilledButton(
                          child: isLoading
                              ? CircularProgressIndicator()
                              : const Text('Hapus'),
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await dotenv.load(fileName: ".env");
                            const secureStorage = FlutterSecureStorage();

                            http.Response? response;
                            try {
                              response = await http.delete(
                                Uri.parse(
                                    '${dotenv.env["API_URL"]}/karya/${widget.karya?.karyaId}'),
                                headers: <String, String>{
                                  'Cookie':
                                      'user_id=${await secureStorage.read(key: "user_id")}',
                                },
                              );
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Terjadi kesalahan, coba lagi nanti")));
                              return;
                            }

                            setState(() {
                              isLoading = false;
                            });
                            if (response.statusCode != 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Email atau password salah")));
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Karya berhasil dihapus")));
                            Navigator.of(context).pop();
                            widget.pagingController!.refresh();
                          },
                        ),
                      ],
                    );
                  },
                );

                setState(() {
                  selectedItem = 2;
                });
              },
              child: Text("Hapus"),
            ),
          MenuItemButton(
            onPressed: () {
              setState(() {
                selectedItem = 3;
              });
            },
            child: Text("Detail"),
          ),
        ]);
  }
}
