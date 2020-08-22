import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/photofilters.dart';
import 'package:provider/provider.dart';
import 'package:stuxplay/constants/strings.dart';
import 'package:stuxplay/models/user.dart';
import 'package:stuxplay/provider/image_upload_provider.dart';
import 'package:stuxplay/provider/user_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:stuxplay/utils/palette.dart';
import 'package:uuid/uuid.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File file;
  bool uploading = false;
  String rand = Uuid().v4();
  int _page = 0;

  UserProvider _userProvider;

  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  final StorageReference storageReference =
      FirebaseStorage.instance.ref().child("Posts Pictures");
  final postsReference = Firestore.instance.collection(POSTS_COLLECTION);

  final DateTime timestamp = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return file == null
        ? displayUploadScreen(context)
        : displayUploadFormScreen(context);
  }

  captureImageWithCamera() async {
    Navigator.pop(context);
    ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.getImage(
        source: ImageSource.camera, maxHeight: 680, maxWidth: 970);

    File image = File(pickedFile.path);
    setState(() {
      this.file = image;
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);

    File image = File(pickedFile.path);
    setState(() {
      this.file = image;
    });
  }

  filterImage(image) async {
    var imageFile = Im.decodeImage(image.readAsBytesSync());
    Map imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new PhotoFilterSelector(
          title: Text("Stux Play Filters"),
          image: imageFile,
          filters: presetFiltersList,
          filename: 'StuxPlay.jpg',
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        this.file = imagefile['image_filtered'];
      });
    } else {
      print('You can\'t do it!');
    }
  }

  cropImage(File image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: image.path,
      compressQuality: 40,
    );
    setState(() {
      this.file = croppedImage;
    });
  }

  takeImage(mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              'New Post',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  'Capture Image with Camera',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () => captureImageWithCamera(),
              ),
              SizedBox(
                height: 10.0,
              ),
              SimpleDialogOption(
                child: Text(
                  'Select Image from Gallery',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () => pickImageFromGallery(),
              ),
              SizedBox(
                height: 10.0,
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  displayUploadScreen(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.add_photo_alternate,
            color: Colors.grey,
            size: 200.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0),
              ),
              child: Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              color: Colors.green,
              onPressed: () => takeImage(context),
            ),
          )
        ],
      ),
    );
  }

  clearPostInfo() {
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();

    setState(() {
      file = null;
    });
  }

  getCurrentUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlaceMark = placeMarks[0];
    String completeAddressInfo =
        '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, ${mPlaceMark.subLocality} ${mPlaceMark.locality}, ${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, ${mPlaceMark.postalCode} ${mPlaceMark.country} ';
    String specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
    locationTextEditingController.text = specificAddress;
  }

  compressingPhoto() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    Im.Image image = Im.decodeImage(file.readAsBytesSync());
    // Im.copyResize(image, width: 500, height: 500);

    final comressedImageFile = File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 50));

    setState(() {
      file = comressedImageFile;
    });
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });

    // await compressingPhoto();
    String downloadUrl = await uploadPhoto(file);

    savePostInfoToFirestore(
        url: downloadUrl,
        location: locationTextEditingController.text,
        description: descriptionTextEditingController.text);

    descriptionTextEditingController.clear();
    locationTextEditingController.clear();

    setState(() {
      file = null;
      uploading = false;
      rand = (Random().nextInt(10000).toString());
    });
  }

  savePostInfoToFirestore({String url, String location, String description}) {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    postsReference
        .document(_userProvider.getUser.uid)
        .collection('userPosts')
        .document(rand)
        .setData({
      'postId': rand,
      'ownerId': _userProvider.getUser.uid,
      'timestamp': timestamp,
      'likes': {},
      'description': description,
      'location': location,
      'url': url,
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask mStrorageUploadTask =
        storageReference.child("post_$rand.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await mStrorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  ListView share() {
    //TODO: add linear progressbar in this page
    // uploading ? Center(child: LinearProgressIndicator()) : share()
    return ListView(
      children: <Widget>[
        Container(
          height: 230.0,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Center(
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(file),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12.0),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(_userProvider.getUser.profilePhoto),
          ),
          title: Container(
            width: 250.0,
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: descriptionTextEditingController,
              decoration: InputDecoration(
                  hintText: 'Say something about image.',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none),
            ),
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(
            Icons.person_pin_circle,
            color: Colors.white,
            size: 36.0,
          ),
          title: Container(
            width: 250.0,
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: locationTextEditingController,
              decoration: InputDecoration(
                  hintText: 'Write the location here.',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none),
            ),
          ),
        ),
        Container(
          width: 220.0,
          height: 110.0,
          alignment: Alignment.center,
          child: RaisedButton.icon(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35.0),
            ),
            color: Colors.green,
            icon: Icon(
              Icons.location_on,
              color: Colors.white,
            ),
            label: Text(
              'Get my current location',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => getCurrentUserLocation(),
          ),
        )
      ],
    );
  }

  void navigationTapped(int page) {
    print(page);
    switch (page) {
      case 0:
        cropImage(file);
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        filterImage(file);
        break;
      default:
        break;
    }
  }

  Column editIcon({String title, IconData icon}) {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Positioned(
              left: 1.0,
              top: 2.0,
              child: Icon(icon, size: 35.0, color: Colors.black54),
            ),
            Icon(icon, size: 35.0, color: Colors.white),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 2.0),
          child: Text(title,
              style: TextStyle(
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 8.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12.0)),
        ),
      ],
    );
  }

  displayUploadFormScreen(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => clearPostInfo(),
        ),
        title: Text(
          'New Post',
          style: TextStyle(
            fontSize: 24.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => uploading ? null : controlUploadAndSave(),
            child: Text(
              'Share',
              style: TextStyle(
                color: Colors.lightGreenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      width: 100.0,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        GestureDetector(
                          onTap: () => cropImage(file),
                          child: editIcon(icon: Icons.crop, title: 'Crop'),
                        ),
                        SizedBox(height: 10.0),
                        GestureDetector(
                          onTap: () => filterImage(file),
                          child: editIcon(icon: Icons.filter, title: 'Filters'),
                        ),
                        SizedBox(height: 10.0),
                        GestureDetector(
                          onTap: () => print('Stickers'),
                          child: editIcon(
                              icon: Icons.settings_backup_restore,
                              title: 'Stickers'),
                        ),
                        SizedBox(height: 10.0),
                        GestureDetector(
                          onTap: () => print('Effects'),
                          child: editIcon(icon: Icons.edit, title: 'Effects'),
                        ),
                        SizedBox(height: 10.0),
                      ]),
                    ),
                    SizedBox(
                      height: 0.0,
                    )
                  ]),
              SizedBox(
                height: 50.0,
              )
            ],
          ),
          uploading ? LinearProgressIndicator() : Text(''),
        ],
      ),
    );
  }
}
