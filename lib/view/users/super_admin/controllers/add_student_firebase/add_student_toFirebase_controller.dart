import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vidyaveechi_website/view/constant/const.dart';

import '../../model/add_student_model/add_student_model.dart';
import '../../model/parent_model/parent_model.dart';

class AddStudentToFirebaseController extends GetxController {
  RxString batchYear = ''.obs;
  RxString classID = ''.obs;

  addStudentToServerINAutomatic(
      BuildContext context,
      String batchYear,
      String classId,
      String schoolID,
      List<AddStudentModel> studentModelList) async {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        log("message${studentModelList.length}");
        return AlertDialog(
          title: const Text('Alert'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                    'Are you shure for adding student from server to Automic ? ')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ok'),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    TextEditingController schoolName = TextEditingController();
                    return AlertDialog(
                      title: const Text('Enter SchoolName in ShortForm'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            TextFormField(
                              controller: schoolName,
                              decoration:
                                  const InputDecoration(hintText: 'Enter Name'),
                            ),
                            TextButton.icon(
                                onPressed: () async {
                                  for (var i = 0;
                                      i < studentModelList.length;
                                      i++) {
                                    // log(studentModelList[i].docid.toString());
                                    final parentEmail =
                                        '${studentModelList[i].parentName?.toLowerCase().replaceAll(' ', '')}${schoolName.text.trim()}${studentModelList[i].admissionNumber}@gmail.com';

                                    final studentemail =
                                        '${studentModelList[i].studentName?.toLowerCase().replaceAll(' ', '')}${schoolName.text.trim()}${studentModelList[i].admissionNumber}@gmail.com';
                                    log(studentemail);
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: studentemail,
                                            password: '123456')
                                        .then((value) async {
                                      String parentName = '';
                                      String parentID = '';
                                      String studentID = '';
                                      String parentDataEMail = '';

                                      studentID = value.user!.uid;
                                      final studentDetail = AddStudentModel(
                                        docid: value.user!.uid,
                                        uid: value.user!.uid,
                                        studentName:
                                            studentModelList[i].studentName,
                                        studentemail: studentemail,
                                        admissionNumber:
                                            studentModelList[i].admissionNumber,
                                        createDate: DateTime.now().toString(),
                                        classID: classId,
                                      );
                                      parentName =
                                          studentModelList[i].parentName!;

                                      //Creating student account >>>>>>>>>

                                      await FirebaseFirestore.instance
                                          .collection('SchoolListCollection')
                                          .doc(schoolID)
                                          .collection('AllStudents')
                                          .doc(studentID)
                                          .set(studentDetail.toMap(),
                                              SetOptions(merge: true))
                                          .then((value) async {
                                        await FirebaseFirestore.instance
                                            .collection('SchoolListCollection')
                                            .doc(schoolID)
                                            .collection(batchYear)
                                            .doc(batchYear)
                                            .collection('classes')
                                            .doc(classId)
                                            .collection('Students')
                                            .doc(studentID)
                                            .set(studentDetail.toMap(),
                                                SetOptions(merge: true))
                                            .then((value) async {
                                          await FirebaseFirestore.instance
                                              .collection(
                                                  'SchoolListCollection')
                                              .doc(schoolID)
                                              .collection('AllStudents')
                                              .doc(studentID)
                                              .set(studentDetail.toMap(),
                                                  SetOptions(merge: true));
                                        }).then((value) async {
                                          await FirebaseAuth.instance
                                              .createUserWithEmailAndPassword(
                                                  email: parentEmail,
                                                  password: '123456')
                                              .then((value) async {
                                            parentID = value.user!.uid;
                                            parentDataEMail =
                                                value.user!.email ?? "";

                                            await FirebaseFirestore.instance
                                                .collection(
                                                    'SchoolListCollection')
                                                .doc(schoolID)
                                                .collection(batchYear)
                                                .doc(batchYear)
                                                .collection('classes')
                                                .doc(classId)
                                                .collection('Students')
                                                .doc(studentID)
                                                .set({
                                              'parentID': parentID,
                                              'parentName': parentDataEMail,
                                            }, SetOptions(merge: true)).then(
                                                    (value) async {
                                              await FirebaseFirestore.instance
                                                  .collection(
                                                      'SchoolListCollection')
                                                  .doc(schoolID)
                                                  .collection('AllStudents')
                                                  .doc(studentID)
                                                  .set({
                                                'parentID': parentID,
                                                'parentName': parentDataEMail,
                                              }, SetOptions(merge: true));
                                            }).then((value) async {
                                              final parentDetails = ParentModel(
                                                  parentName: parentName,
                                                  parentEmail: parentDataEMail,
                                                  studentID: studentID,
                                                  docid: parentID);

                                              //creating parent profile >>>>>>>>>>>

                                              await FirebaseFirestore.instance
                                                  .collection(
                                                      'SchoolListCollection')
                                                  .doc(schoolID)
                                                  .collection(batchYear)
                                                  .doc(batchYear)
                                                  .collection('classes')
                                                  .doc(classId)
                                                  .collection(
                                                      'ParentCollection')
                                                  .doc(parentID)
                                                  .set(parentDetails.toMap(),
                                                      SetOptions(merge: true))
                                                  .then((value) async {
                                                log('StudentId${studentModelList[i].docid.toString()}');
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        'SchoolListCollection')
                                                    .doc(schoolID)
                                                    .collection(batchYear)
                                                    .doc(batchYear)
                                                    .collection('classes')
                                                    .doc(classId)
                                                    .collection('TempStudents')
                                                    .doc(studentModelList[i]
                                                        .docid)
                                                    .delete()
                                                    .then((value) {
                                                  showToast(
                                                      msg:
                                                          'Added successfully');
                                                });
                                              });
                                            });
                                          });
                                        });
                                      });
                                    });
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Add student"))
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('ok'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
