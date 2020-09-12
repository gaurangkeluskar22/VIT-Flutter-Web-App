import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:vitappflutterweb/src/Screens/HomeScreen.dart';
import 'package:vitappflutterweb/src/Widgets/DetailScreen.dart';
import 'package:vitappflutterweb/src/Screens/PDFViewer.dart';

import '../constants.dart';

Widget buildNoticeItem(
    BuildContext context, DocumentSnapshot documentSnapshot) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: () {
        if (documentSnapshot.data()['type'] == 'pdf') {
          openPdf(context, documentSnapshot);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailScreen(
                      mediaUrl: documentSnapshot.data()['mediaUrl'],
                      from: documentSnapshot.data()['from'],
                      notice: documentSnapshot.data()['notice'],
                    )),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: kPrimaryColor.withOpacity(0.6),
              width: 0.7,
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPostHeader(documentSnapshot, context),
            Divider(
              color: Colors.grey.withOpacity(0.5),
              height: 0.5,
            ),
            buildPostImage(documentSnapshot),
            buildNotice(documentSnapshot),
            documentSnapshot.data()['type'] == 'pdf'
                ? buildPDFFooter(documentSnapshot)
                : Container(),
          ],
        ),
      ),
    ),
  );
}

Widget buildPostHeader(
    DocumentSnapshot documentSnapshot, BuildContext context) {
  return ListTile(
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Notice by ',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            Text(
              documentSnapshot.data()['from'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            )
          ],
        ),
        SizedBox(
          height: 4.0,
        ),
        Text(
          timeago.format(documentSnapshot.data()['timestamp'].toDate()),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12.0,
          ),
        ),
      ],
    ),
    trailing: FirebaseAuth.instance.currentUser != null
        ? IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => handleDeletePost(
                context, documentSnapshot.data()['postId'], documentSnapshot),
          )
        : null,
  );
}

deletePost(BuildContext context, String postId,
    DocumentSnapshot documentSnapshot) async {
  timelineRef
      .doc('all')
      .collection('timelinePost')
      .doc(postId)
      .get()
      .then((doc) {
    if (doc.exists) {
      doc.reference.delete();
    }
  });
  if (documentSnapshot.data()['type'] == 'image') {
    if (documentSnapshot.data()['mediaUrl'] != '') {
      storageRef.child('posts').child('post_$postId.jpg').delete();
    }
  } else {
    storageRef.child('Notices').child(postId).delete();
  }
  Navigator.pop(context);
}

handleDeletePost(BuildContext parentContext, String postId,
    DocumentSnapshot documentSnapshot) {
  return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(title: Text("Remove this post"), children: <Widget>[
          SimpleDialogOption(
            onPressed: () => deletePost(context, postId, documentSnapshot),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
          SimpleDialogOption(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          )
        ]);
      });
}

Widget buildPostImage(DocumentSnapshot documentSnapshot) {
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        child: Center(
          child: CachedNetworkImage(
            height: documentSnapshot.data()['type'] == 'pdf' ? 110.0 : null,
            imageUrl: documentSnapshot.data()['type'] == 'image'
                ? documentSnapshot.data()['mediaUrl']
                : kPdfImage,
            placeholder: (context, url) {
              return Container(
                height: 200.0,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              );
            },
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
  );
}

Widget buildNotice(DocumentSnapshot documentSnapshot) {
  return documentSnapshot.data()['notice'].toString().length == 0
      ? Container()
      : Container(
          padding:
              EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
          child: Text(
            documentSnapshot.data()['notice'],
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        );
}

Widget buildPDFFooter(DocumentSnapshot documentSnapshot) {
  return Column(
    children: [
      Divider(),
      ListTile(
        title: Text(
          documentSnapshot.data()['fileName'],
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          onPressed: () => {downloadPdf(documentSnapshot)},
          icon: Icon(
            Icons.file_download,
            color: kPrimaryColor,
          ),
        ),
      )
    ],
  );
}

openPdf(BuildContext context, DocumentSnapshot documentSnapshot) async {
  PDFDocument doc =
      await PDFDocument.fromURL(documentSnapshot.data()['mediaUrl']);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PdfViewer(
        document: doc,
      ),
    ),
  );
}

downloadPdf(DocumentSnapshot documentSnapshot) async {
  String url = documentSnapshot.data()['mediaUrl'];
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
