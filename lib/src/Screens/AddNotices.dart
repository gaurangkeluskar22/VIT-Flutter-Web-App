import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vitappflutterweb/src/Widgets/loading.dart';
import 'HomeScreen.dart';
import 'package:vitappflutterweb/src/Widgets/SnackBar.dart';
import 'package:vitappflutterweb/src//Widgets/header.dart';
import 'package:image/image.dart' as im;
import 'package:path/path.dart' as path;
import '../constants.dart';

class AddNotice extends StatefulWidget {
  @override
  _AddNoticeState createState() => _AddNoticeState();
}

class _AddNoticeState extends State<AddNotice> {
  TextEditingController _noticeController = TextEditingController();
  TextEditingController _fromController = TextEditingController();
  bool noticeError = false;
  bool fromError = false;
  bool _loading = false;
  bool isNoticeSelected = false;
  File imgFile;
  File pdfFile;
  String fileName = '';
  String postId = Uuid().v4();
  String ownerId = Uuid().v4();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
        context,
        isAppTitle: false,
        titleText: 'Add Notice',
        isCenterTitle: true,
        bold: true,
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                color: _loading
                    ? Colors.black12.withOpacity(0.1)
                    : Colors.black12.withOpacity(0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 15.0, right: 15.0),
                      child: TextFormField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        controller: _noticeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Add Notice Here....',
                          labelText: 'Notice',
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 20.0),
                      child: Text(
                        'Adding notice text is Optional',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    GestureDetector(
                      onTap: () => {handleSelectNotice(context)},
                      child: Container(
                        height: 180.0,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                image: imgFile != null
                                    ? DecorationImage(image: FileImage(imgFile))
                                    : fileName.isNotEmpty
                                        ? DecorationImage(
                                            image: AssetImage(
                                                'assets/images/pdf.png'))
                                        : DecorationImage(
                                            image: AssetImage(
                                                'assets/images/upload.jpg')),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    fileName.isNotEmpty
                        ? Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              fileName,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 10.0,
                    ),
                    isNoticeSelected
                        ? Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 30.0),
                            child: Text(
                              '*Please select notice',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.red,
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 40.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, bottom: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: _fromController,
                        decoration: InputDecoration(
                          hintText: 'ex. David Assistant Professor',
                          labelText: 'From:',
                          errorText:
                              fromError ? 'This field is required' : null,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                    Container(
                      height: 50.0,
                      width: 350.0,
                      child: Material(
                        borderRadius: BorderRadius.circular(5.0),
                        elevation: 2.0,
                        color: kPrimaryColor,
                        child: InkWell(
                          onTap: onSubmit,
                          child: Center(
                            child: Text(
                              'Confirm',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                  ],
                ),
              ),
              _loading
                  ? Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height - 170,
                        child: loadingScreen(),
                      ),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  handleSelectNotice(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Select Notice'),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  selectImage(parentContext);
                },
                child: Text('Image'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  selectFile(parentContext);
                },
                child: Text('PDF'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              )
            ],
          );
        });
  }

  Future selectFile(BuildContext parentContext) async {
    try {
      pdfFile = await FilePicker.getFile(
          type: FileType.custom, allowedExtensions: ['pdf']);

      setState(() {
        imgFile = null;
        fileName = path.basename(pdfFile.path);
      });
    } on PlatformException catch (e) {
      showDialog(
          context: parentContext,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Unsupported exception: $e'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  selectImage(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  'Open a Camera',
                  style: TextStyle(
                    fontFamily: 'mont',
                    fontSize: 17.0,
                  ),
                ),
                onPressed: () => handleTakePhoto(context),
              ),
              SimpleDialogOption(
                child: Text(
                  'Open a Gallery',
                  style: TextStyle(
                    fontFamily: 'mont',
                    fontSize: 17.0,
                  ),
                ),
                onPressed: () => handleChooseFromGallery(context),
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'mont',
                    fontSize: 17.0,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  handleTakePhoto(BuildContext context) async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.imgFile = File(pickedFile.path);
    });
  }

  handleChooseFromGallery(BuildContext context) async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.imgFile = File(pickedFile.path);
    });
  }

  clearImage() {
    setState(() {
      imgFile = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    im.Image imageFile = im.decodeImage(imgFile.readAsBytesSync());

    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(
        im.encodeJpg(imageFile, quality: 80),
      );

    setState(() {
      imgFile = compressedImageFile;
    });
  }

  void onSubmit() async {
    if (_fromController.text.trim().isEmpty) {
      setState(() {
        fromError = true;
      });
    } else {
      setState(() {
        fromError = false;
      });

      if (fileName.isEmpty && imgFile == null) {
        setState(() {
          isNoticeSelected = true;
        });
      } else {
        isNoticeSelected = false;
      }
    }

    if (_fromController.text.trim().isNotEmpty) {
      String notice = _noticeController.text.trim();
      String from = _fromController.text.trim();

      if (imgFile == null && pdfFile == null) {
        SnackBar snackBar = SnackBar(
          content: Text(
            'Please select notice!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
        return;
      }

      if (imgFile != null) {
        await compressImage();
      }

      if (imgFile == null) {
        sendNotice(notice, from, pdfFile, 'pdf');
      } else {
        sendNotice(notice, from, imgFile, 'image');
      }
    }
  }

  Future<String> uploadFile(File file, String type) async {
    setState(() {
      _loading = true;
    });

    if (type == 'pdf') {
      StorageReference storageReference =
          storageRef.child('Notices').child(postId);

      final StorageUploadTask uploadTask = storageReference.putFile(pdfFile);
      final StorageTaskSnapshot storageTaskSnapshot =
          (await uploadTask.onComplete);
      final String downloadUrl =
          (await storageTaskSnapshot.ref.getDownloadURL());
      return downloadUrl;
    } else {
      StorageUploadTask uploadTask =
          storageRef.child('posts').child('post_$postId.jpg').putFile(file);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    }
  }

  Future<void> sendNotice(notice, from, file, type) async {
    try {
      String mediaUrl = '';
      if (file != null) {
        mediaUrl = await uploadFile(file, type);
      }

      Map<String, dynamic> data = {
        'postId': postId,
        'from': from,
        'mediaUrl': mediaUrl,
        'notice': notice,
        'type': type,
        'fileName': fileName,
        'timestamp': DateTime.now()
      };
      await timelineRef
          .doc('all')
          .collection('timelinePost')
          .doc(postId)
          .set(data)
          .then((value) {
        _scaffoldKey.currentState.showSnackBar(snackBar(
          context,
          isErrorSnackbar: false,
          successText: 'Notice sent Successfully',
        ));
        Timer.periodic(new Duration(seconds: 2), (time) {
          Navigator.pop(context);
          time.cancel();
        });
      });
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(snackBar(context,
          isErrorSnackbar: true, errorText: 'Something went wrong'));
    }
    setState(() {
      _loading = false;
    });
  }
}
