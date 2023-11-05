import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:widget_mask/widget_mask.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isNormal = false;
  List<String> masks = [
    "assets/user_image_frame_1.png",
    "assets/user_image_frame_2.png",
    "assets/user_image_frame_3.png",
    "assets/user_image_frame_4.png",
  ];
  XFile? _file;
  CroppedFile? _croppedFile;
  int idx = 0;
  bool isVisible = false;
  cropImage() async {
    if (_file != null) {
      final cropImage = await ImageCropper().cropImage(
        sourcePath: _file!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        cropStyle: CropStyle.rectangle,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: Colors.white,
            toolbarTitle: 'Crop',
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ],
      );
      if (cropImage != null) {
        setState(() {
          _croppedFile = cropImage;
        });
      }
    }
  }

  pickImage() async {
    if (_file != null) {
      _file = null;
      _croppedFile = null;
    }
    final imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      _file = file;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            exit(0);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
        ),
        title: const Text('Add Image / Icon'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isNormal = true;
              });
            },
            child: const Text(
              'Clear Overlay',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: pickImage,
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                    side: const BorderSide(
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                ),
                child: Text(_file != null
                    ? 'Choose another Image'
                    : 'Choose Image from device'),
              ),
              _file != null
                  ? SizedBox(
                      height: size.height * 0.5,
                      width: size.width * 0.95,
                      child: isNormal
                          ? Image.file(
                              File(
                                _croppedFile != null
                                    ? _croppedFile!.path
                                    : _file!.path,
                              ),
                              fit: BoxFit.cover,
                            )
                          : WidgetMask(
                              childSaveLayer: true,
                              blendMode: BlendMode.srcATop,
                              mask: Image.file(
                                File(
                                  _croppedFile != null
                                      ? _croppedFile!.path
                                      : _file!.path,
                                ),
                                fit: BoxFit.cover,
                              ),
                              child: Image.asset(
                                masks[idx],
                              ),
                            ),
                    )
                  : const SizedBox(),
              _file != null
                  ? Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                cropImage();
                              },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                  side: const BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              child: const Text('Crop'),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                  side: const BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              child: Text(
                                  isVisible ? 'Hide overlay' : 'Show overlay'),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              Visibility(
                visible: isVisible,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _file != null
                        ? SizedBox(
                            height: size.height * 0.2,
                            width: double.maxFinite,
                            child: ListView.builder(
                              itemCount: masks.length,
                              scrollDirection: Axis.horizontal,
                              controller: ScrollController(),
                              itemBuilder: (_, ind) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    idx = ind;
                                    isNormal = false;
                                  });
                                },
                                child: WidgetMask(
                                  childSaveLayer: true,
                                  blendMode: BlendMode.srcATop,
                                  mask: Image.file(
                                    File(
                                      _croppedFile != null
                                          ? _croppedFile!.path
                                          : _file!.path,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Image.asset(
                                      masks[ind],
                                      width: 150,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
