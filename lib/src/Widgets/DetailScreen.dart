import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vitappflutterweb/src/Widgets/header.dart';

class DetailScreen extends StatefulWidget {
  final String mediaUrl, from, notice;
  DetailScreen({this.mediaUrl, this.from, this.notice});
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: header(context, isAppTitle: false, titleText: widget.from),
        body: buildImage(widget.mediaUrl));
  }

  Widget buildImage(image) {
    return Container(
      color: Colors.white,
      child: PhotoView(
        backgroundDecoration: BoxDecoration(color: Colors.white),
        imageProvider: NetworkImage(image),
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: 4.0,
      ),
    );
  }
}
