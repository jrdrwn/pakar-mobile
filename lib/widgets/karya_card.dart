import 'package:flutter/material.dart';
import 'package:pakar_mobile/Entities/karya.dart';
import 'package:pakar_mobile/widgets/detail_karya_pop_up.dart';
import 'package:pakar_mobile/widgets/edit_karya.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class KaryaCard extends StatefulWidget {
  final Karya? karya;
  final PagingController<int, Karya> pagingController;
  const KaryaCard({super.key, this.karya, required this.pagingController});

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
              widget.karya?.title ?? "",
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

class PopUpMenuKaryaCard extends StatefulWidget {
  final Karya? karya;

  final PagingController<int, Karya> pagingController;

  const PopUpMenuKaryaCard(
      {super.key, this.karya, required this.pagingController});

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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditKarya(
                            karya: widget.karya!,
                            pagingController: widget.pagingController,
                          )));
                });
              },
              child: const Text("Edit"),
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
                          child: const Text('Hapus'),
                          onPressed: () async {
                            await dotenv.load(fileName: ".env");
                            const secureStorage = FlutterSecureStorage();

                            http.Response? response;
                            try {
                              setState(() {
                                isLoading = true;
                              });
                              response = await http.delete(
                                Uri.parse(
                                    '${dotenv.env["API_URL"]}/karya/${widget.karya?.karyaId}'),
                                headers: <String, String>{
                                  'Cookie':
                                      'user_id=${await secureStorage.read(key: "user_id")}',
                                },
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Terjadi kesalahan, coba lagi nanti")));
                              return;
                            }

                            setState(() {
                              isLoading = false;
                            });
                            if (response.statusCode != 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Email atau password salah")));
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Karya berhasil dihapus")));

                            widget.pagingController.refresh();
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
              child: const Text("Hapus"),
            ),
          MenuItemButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text("Detail Karya"),
                        ),
                        body: SingleChildScrollView(
                          child: DetailKaryaPopUp(
                            karya: widget.karya,
                          ),
                        ),
                      )));
              setState(() {
                selectedItem = 3;
              });
            },
            child: const Text("Detail"),
          ),
        ]);
  }
}
