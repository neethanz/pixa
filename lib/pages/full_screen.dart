import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pixa/utils/keys.dart';

class FullScreen extends StatefulWidget {
  final Map image;

  const FullScreen({super.key, required this.image});
  @override
  _FullScreenState createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  bool isDownloading = false;

  _save(imageUrl) async {
    setState(() {
      isDownloading = true;
    });

    var response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: widget.image['id'].toString());

    setState(() {
      isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xff6a6a6a),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: Image.network(
                    widget.image['src']['large2x'],
                    width: double.infinity,
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(widget.image['photographer']),
                //       Text(widget.image['alt']),
                //     ],
                //   ),
                // ),
              ],
            ),
            isDownloading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff167869),
                      strokeWidth: 2,
                      backgroundColor: Colors.white,
                    ),
                  )
                : const SizedBox(),
            // Positioned(
            //   top: 8,
            //   left: 16,
            //   child:
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xfff2f2f2), width: 2),
        ),
        onPressed: () {
          _save(widget.image['src']['large2x']);
        },
        icon: const Icon(Icons.download_rounded, color: Color(0xff6a6a6a)),
        label: const Text(
          'Download',
          style: TextStyle(
            color: Color(0xff4d4d57),
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
