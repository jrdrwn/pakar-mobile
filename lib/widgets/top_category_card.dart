import 'package:flutter/material.dart';

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
