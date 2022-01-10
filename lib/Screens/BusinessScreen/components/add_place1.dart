import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easark/Screens/BusinessScreen/components/introduction.dart';
import 'package:easark/Widgets/loading_screen.dart';
import 'package:easark/Widgets/rounded_button.dart';
import 'package:easark/Widgets/slide_right_route_animation.dart';
import 'package:easark/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({
    Key? key,
  }) : super(key: key);
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String? name, description;
  bool needsVer = false;
  String error = '';
  File? i1, i2, i3, i4, i5, i6;

  Future _getImage(int i) async {
    var picker = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (picker != null) {
        switch (i) {
          case 1:
            i1 = File(picker.path);
            break;
          case 2:
            i2 = File(picker.path);
            break;
          case 3:
            i3 = File(picker.path);
            break;
          case 4:
            i4 = File(picker.path);
            break;
          case 5:
            i5 = File(picker.path);
            break;
          case 6:
            i6 = File(picker.path);
            break;
          default:
            i1 = File(picker.path);
        }
        error = '';
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? const LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: darkPrimaryColor,
              iconTheme: const IconThemeData(
                color: whiteColor,
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Text(
                          'Add new place',
                          style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: size.width * 0.8,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              Text(
                                'General',
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const Divider(),
                              const SizedBox(height: 20),
                              TextFormField(
                                validator: (val) => val!.length >= 2
                                    ? null
                                    : 'Minimum 2 characters',
                                style: const TextStyle(color: darkDarkColor),
                                keyboardType: TextInputType.text,
                                onChanged: (val) {
                                  name = val;
                                },
                                decoration: InputDecoration(
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkColor, width: 1.0),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkColor, width: 1.0),
                                  ),
                                  hintStyle: TextStyle(
                                      color: darkColor.withOpacity(0.7)),
                                  hintText: 'Name',
                                  border: InputBorder.none,
                                ),
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                validator: (val) => val!.length >= 5
                                    ? null
                                    : 'Minimum 5 characters',
                                style: const TextStyle(color: darkDarkColor),
                                keyboardType: TextInputType.multiline,
                                onChanged: (val) {
                                  description = val;
                                },
                                decoration: InputDecoration(
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkColor, width: 1.0),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkColor, width: 1.0),
                                  ),
                                  hintStyle: TextStyle(
                                      color: darkColor.withOpacity(0.7)),
                                  hintText: 'Description',
                                  border: InputBorder.none,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // IMPORTANT

                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.start,
                              //   children: [
                              //     Icon(
                              //       CupertinoIcons.info_circle,
                              //       color: darkPrimaryColor,
                              //       size: 30,
                              //     ),
                              //     SizedBox(
                              //       width: 10,
                              //     ),
                              //     Expanded(
                              //       child: Column(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           Text(
                              //             'If you turn on VERIFICATION, when client wants to make booking, your agreement is needed to complete booking. if you turn verification OFF, then clients will be able to make bookings automatically, without your agreement.',
                              //             overflow: TextOverflow.ellipsis,
                              //             maxLines: 200,
                              //             textAlign: TextAlign.center,
                              //             style: GoogleFonts.montserrat(
                              //               textStyle: TextStyle(
                              //                 color: darkPrimaryColor,
                              //                 fontSize: 15,
                              //               ),
                              //             ),
                              //           )
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(
                              //   height: 5,
                              // ),
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       flex: 7,
                              //       child: Text(
                              //         'Turn on verification?',
                              //         overflow: TextOverflow.ellipsis,
                              //         style: GoogleFonts.montserrat(
                              //           textStyle: TextStyle(
                              //             color: darkColor,
                              //             fontSize: 17,
                              //             fontWeight: FontWeight.w400,
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //     SizedBox(width: 5),
                              //     Align(
                              //       alignment: Alignment.centerRight,
                              //       child: Switch(
                              //         activeColor: primaryColor,
                              //         value: needsVer,
                              //         onChanged: (val) {
                              //           if (this.mounted) {
                              //             setState(() {
                              //               this.needsVer = val;
                              //             });
                              //           }
                              //         },
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: size.width * 0.8,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 30),
                                Text(
                                  'Pictures',
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 20),
                                GridView.count(
                                  shrinkWrap: true,
                                  primary: false,
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(1);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i1 == null
                                            ? const Icon(
                                                Icons.add,
                                                color: whiteColor,
                                              )
                                            : Image.file(i1!),
                                        color: darkColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(2);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i2 == null
                                            ? const Icon(
                                                Icons.add,
                                                color: whiteColor,
                                              )
                                            : Image.file(i2!),
                                        color: darkColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(3);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i3 == null
                                            ? const Icon(
                                                Icons.add,
                                                color: whiteColor,
                                              )
                                            : Image.file(i3!),
                                        color: darkColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(4);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i4 == null
                                            ? const Icon(
                                                Icons.add,
                                                color: whiteColor,
                                              )
                                            : Image.file(i4!),
                                        color: darkColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(5);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i5 == null
                                            ? const Icon(
                                                Icons.add,
                                                color: whiteColor,
                                              )
                                            : Image.file(i5!),
                                        color: darkColor,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _getImage(6);
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: i6 == null
                                            ? const Icon(
                                                Icons.add,
                                                color: whiteColor,
                                              )
                                            : Image.file(i6!),
                                        color: darkColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RoundedButton(
                      width: 0.7,
                      ph: 55,
                      text: 'CONTINUE',
                      press: () async {
                        if (_formKey.currentState!.validate()) {
                          if (i1 != null ||
                              i2 != null ||
                              i3 != null ||
                              i4 != null ||
                              i5 != null ||
                              i6 != null) {
                            setState(() {
                              loading = true;
                            });
                            TaskSnapshot? a1;
                            TaskSnapshot? a2;
                            TaskSnapshot? a3;
                            TaskSnapshot? a4;
                            TaskSnapshot? a5;
                            TaskSnapshot? a6;
                            String id = FirebaseAuth.instance.currentUser!.uid;

                            if (i1 != null) {
                              a1 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i1/')
                                  .putFile(i1!);
                            }
                            if (i2 != null) {
                              a2 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i2/')
                                  .putFile(i2!);
                            }
                            if (i3 != null) {
                              a3 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i3/')
                                  .putFile(i3!);
                            }
                            if (i4 != null) {
                              a4 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i4/')
                                  .putFile(i4!);
                            }
                            if (i5 != null) {
                              a5 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i5/')
                                  .putFile(i5!);
                            }
                            if (i6 != null) {
                              a6 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i5/')
                                  .putFile(i6!);
                            }
                            Navigator.push(
                              context,
                              SlideRightRoute(
                                page: IntroductionScreen(
                                    // data: {
                                    //   'name': name,
                                    //   'description': description,
                                    //   'type': needsVer,
                                    //   'images': [
                                    //       await a1!.ref.getDownloadURL(),
                                    //       await a2!.ref.getDownloadURL(),
                                    //       await a3!.ref.getDownloadURL(),
                                    //       await a4!.ref.getDownloadURL(),
                                    //       await a5!.ref.getDownloadURL(),
                                    //       await a6!.ref.getDownloadURL(),
                                    //   ],
                                    //   'owner':
                                    //       FirebaseAuth.instance.currentUser!.uid,
                                    // },
                                    ),
                              ),
                            );
                            setState(() {
                              loading = false;
                              name = '';
                              description = '';
                              needsVer = true;
                            });
                          } else {
                            setState(() {
                              error = 'Choose at least 1 photo';
                            });
                          }
                        }
                      },
                      color: darkPrimaryColor,
                      textColor: whiteColor,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        error,
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
