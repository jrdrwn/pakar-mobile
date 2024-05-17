import 'package:flutter/material.dart';
import '../Entities/category.dart';
import '../Entities/karya.dart';
import '../Entities/user_profile.dart';
import '../widgets/karya_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ExploreWidget extends StatefulWidget {
  final UserProfile? userProfile;

  const ExploreWidget({
    super.key,
    this.userProfile,
  });

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget> {
  final _pageSize = 10;
  final PagingController<int, Karya> _pagingController =
      PagingController(firstPageKey: 0);
  var selectedCategory = "Semua";
  List<Category> categories = [];
  List<Karya> karya = [];
  String? q = '';
  void _karyaInit(pagekey) async {
    try {
      await dotenv.load(fileName: ".env");

      var response = await http.get(
        Uri.parse(
            '${dotenv.env["API_URL"]}/karya?q=$q&tag=${Uri.encodeComponent(selectedCategory)}&limit=10&offset=$pagekey'),
        headers: <String, String>{
          "Cookie": "user_id=${widget.userProfile?.userId}"
        },
      );

      if (mounted) {
        List<Karya> karya = karyaFromJson(response.body);
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
    _pagingController.addPageRequestListener((pageKey) {
      return _karyaInit(pageKey);
    });
    super.initState();
    _categoriesInit();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() => _pagingController.refresh()),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
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
                        onChanged: (value) {
                          _pagingController.refresh();
                        },
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
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Text(
                //     "Top Kategori",
                //     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                //           fontWeight: FontWeight.bold,
                //           color: Theme.of(context).colorScheme.onSurface,
                //         ),
                //   ),
                // ),
                // const SizedBox(height: 8),
                // CarouselSlider(
                //     items: const [
                //       TopCategoryCard(),
                //       TopCategoryCard(),
                //       TopCategoryCard(),
                //     ],
                //     options: CarouselOptions(
                //         height: 100,
                //         viewportFraction: 0.8,
                //         enlargeCenterPage: false,
                //         enlargeFactor: 1)),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Text(
                //     "Explore",
                //     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                //           fontWeight: FontWeight.bold,
                //           color: Theme.of(context).colorScheme.onSurface,
                //         ),
                //   ),
                // ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          PagedSliverList<int, Karya>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) {
                return KaryaCard(
                  karya: item,
                  pagingController: _pagingController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
