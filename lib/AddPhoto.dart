import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Img;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddPhoto extends StatefulWidget {
  @override
  _AddPhotoState createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  TextEditingController _titleController = TextEditingController();
  static final String uploadEndPoint =
      'http://testemaxleco.atwebpages.com/addImage.php';
 Future<File> file;
  String status = "";
  String base64Image;
  File tmpFile;
  String errMessage = "Error Uploading Image";

  chooseImage() async {
    File auxFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    // Future<File> aux =  auxFile;
    // File auxFile = aux; 
    Directory tempDir = await getTemporaryDirectory();
    String path = tempDir.path;
    //? String title = _titleController.text;
    String rand = Random().nextInt(100000).toString();
    
    Img.Image image = Img.decodeImage(auxFile.readAsBytesSync());
    Img.Image smallerImg = Img.copyResize(image, width: 500);

    File compressImg = new File("$path/image_$rand.jpg")
    ..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 8));

    setState(() {
      file = Future.sync(() => compressImg) ;
    });
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  startUpload() {
    setStatus("Uploading Image...");
    if (tmpFile == null) {
      setStatus(errMessage);
      return;
    }
    String fileName = tmpFile.path.split("/").last;
    upload(fileName);
  }

  upload(String fileName) async {
    //*----------------------------------------------------
    Stream stream = http.ByteStream(Stream.castFrom(tmpFile.openRead()));
    int length = await tmpFile.length();
    Uri uri = Uri.parse(uploadEndPoint);
    http.MultipartRequest request = http.MultipartRequest("POST", uri);
    http.MultipartFile partFile = http.MultipartFile(
      "image",
      stream,
      length,
      filename: basename(tmpFile.path),
    );
    request.fields['title'] = _titleController.text;
    request.files.add(partFile);
    http.StreamedResponse response = await request.send(); 
    if(response.statusCode == 200){
      print(response.request.toString());
      print(response.reasonPhrase.toString());
      setStatus("File Uploaded Successfully.");
    }
    else{
      setStatus("Upload failed.");
    }
    // // .then((result) {
    // //   setStatus(result.statusCode == 200 ? result.body : errMessage);
    // // }).catchError((error) {
    // //   setStatus(error.toString());
    // // });
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (context, snapshot) {
        Widget defaultWidget;
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData) {
              tmpFile = snapshot.data;              
              print("-------*****-------");
              defaultWidget = Container(
                height: 300,
                child: Image.file(
                  snapshot.data,
                  fit: BoxFit.fill,
                ),
              );
            } else if (snapshot.hasError) {
              defaultWidget = const Text(
                "Error Picking Image",
                textAlign: TextAlign.center,
              );
            }
            break;
          default:
            defaultWidget = const Text(
              "No Image Selected",
              textAlign: TextAlign.center,
            );
        }
        return defaultWidget;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Title",
                ),
              ),
              OutlineButton(
                onPressed: chooseImage,
                child: Text("Choose Image"),
              ),
              SizedBox(height: 20.0),
              showImage(),
              SizedBox(height: 20.0),
              OutlineButton(
                onPressed: startUpload,
                child: Text("UploadImage"),
              ),
              SizedBox(height: 20.0),
              Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
