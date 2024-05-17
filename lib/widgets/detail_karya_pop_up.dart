import 'package:flutter/material.dart';
import '../Entities/karya.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DetailKaryaPopUp extends StatefulWidget {
  final Karya? karya;
  const DetailKaryaPopUp({
    super.key,
    this.karya,
  });

  @override
  State<DetailKaryaPopUp> createState() => _DetailKaryaPopUpState();
}

class _DetailKaryaPopUpState extends State<DetailKaryaPopUp> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
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
            trailing: OutlinedButton.icon(
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
            child: Text(
              widget.karya?.about ?? "",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
