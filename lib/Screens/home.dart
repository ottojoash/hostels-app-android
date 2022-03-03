import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostels_app/api.dart';
import 'package:hostels_app/models/StudentModel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_dialog_box.dart';
import '../models/RoomModel.dart';
import '../utils.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Student> futureStudent;
  late Future<List<Room>> futureRooms;
  late Future<List<PreviousRoom>> futurePreviousRooms;
  late List<Room> futureActiveRooms;
  late List<Room> futureInactiveRooms;
  late List<Room> previousRooms;
  late Student student;
  bool _loading = false;
  late SharedPreferences preferences;

  List<String> images = [
    "assets/images/bottom1.png",
    "assets/images/bottom2.png",
    "assets/images/main.png",
    "assets/images/top1.png",
    "assets/images/top2.png",
  ];

  @override
  void initState() {
    super.initState();
    asyncMethod();
  }

  void asyncMethod() async {
    futureStudent =
        fetchCurrentUser(setStudent: true, updateStudent: setStudent);
    futureRooms = fetchRooms(updateLoading: updateLoading);

    preferences = await SharedPreferences.getInstance();
    // preferences.clear();
    futurePreviousRooms = fetchPreviousRooms(
        regNo: preferences.getString("regNo"), updateLoading: updateLoading);
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void setStudent(value) => student = value;

  void asyncFetchUpdatesStudentData(studentId) async {
    var student = fetchStudent(
        id: studentId, updateLoading: updateLoading, context: context);
    setState(() {
      futureStudent = student;
    });
  }

  fullRefresh(studentId, regNo) async {
    asyncMethod();
    asyncFetchUpdatesStudentData(studentId);
    // asyncFetchRooms(regNo);
  }

  void updateLoading(bool isLoading) {
    setState(() {
      _loading = isLoading;
    });
  }

  void bookRoom(Room room) {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return CustomDialogBox(
                title: "Confirm booking",
                descriptions:
                    "Do you want to book room ${room.roomId} for Kshs. ${room.roomCost} per semester?",
                text: "Yes",
                student: new Student(
                    id: student.id,
                    name: student.name,
                    regNo: student.regNo,
                    email: student.email,
                    studyYear: student.studyYear,
                    studySemester: student.studySemester,
                    roomId: room.roomId,
                    roomName: room.roomName,
                    hostelId: room.hostelId,
                    hostelName: room.hostelName,
                    roomCost: room.roomCost,
                    paid: student.paid),
                okAction: () => fullRefresh(student.id, student.regNo),
              );
            },
          );
        });
  }

  void handlePay(Room room) {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return CustomDialogBox(
                title: "Confirm payment",
                descriptions:
                    "This will simulate a payment. In a real system, you will"
                    " be prompted to enter the confirmation code "
                    "of you transaction. \n\n"
                    "Pay Kshs. ${room.roomCost} to cater for the room for"
                    " one semester?",
                text: "Yes",
                paying: true,
                student: new Student(
                    id: student.id,
                    name: student.name,
                    regNo: student.regNo,
                    email: student.email,
                    studyYear: student.studyYear,
                    studySemester: student.studySemester,
                    roomId: room.roomId,
                    roomName: room.roomName,
                    hostelId: room.hostelId,
                    hostelName: room.hostelName,
                    roomCost: student.roomCost,
                    paid: student.paid),
                okAction: () => fullRefresh(student.id, student.regNo),
              );
            },
          );
        });
  }

  void requestClearance(Room room) {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return CustomDialogBox(
                title: "Request clearance?",
                descriptions:
                    "This will most probably remove you from your current room. "
                    "Do you want to proceed?",
                text: "Yes",
                requestingClearance: true,
                student: new Student(
                    id: student.id,
                    name: student.name,
                    regNo: student.regNo,
                    email: student.email,
                    studyYear: student.studyYear,
                    studySemester: student.studySemester,
                    roomId: room.roomId,
                    roomName: room.roomName,
                    hostelId: room.hostelId,
                    hostelName: room.hostelName,
                    roomCost: student.roomCost,
                    paid: student.paid),
                okAction: () => fullRefresh(student.id, student.regNo),
              );
            },
          );
        });
  }

  void showReceipt(Room room) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
    final String dateTime = formatter.format(now);

    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return CustomDialogBox(
            title: "Receipt of payment",
            descriptions: "This is to acknowledge that ${student.name} of "
                "registration number ${student.regNo}, has completed their payment "
                "for the next semester.",
            text: "OKAY",
            paymentReceipt: true,
            student: new Student(
                id: student.id,
                name: student.name,
                regNo: student.regNo,
                email: student.email,
                studyYear: student.studyYear,
                studySemester: student.studySemester,
                roomId: room.roomId,
                roomName: room.roomName,
                hostelId: room.hostelId,
                hostelName: room.hostelName,
                roomCost: student.roomCost,
                paid: student.paid),
            okAction: asyncMethod,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return DefaultTabController(
      length: 3,
      child: FutureBuilder<Student>(
        future: futureStudent,
        builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.none &&
              !snapshot.hasData) {
            return Center(child: Text("Error. ${snapshot.error.toString()}"));
          } else if ((snapshot.data != null) && (snapshot.data.id != 0)) {
            return Scaffold(
              appBar: AppBar(
                  // backgroundColor: Color(0xfffafafa),
                  leading: Icon(
                    Icons.home,
                    size: 20,
                  ),
                  titleSpacing: 0,
                  title: Text(
                    "JKUAT Hostels Booking",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                        onPressed: () => fullRefresh(preferences.getInt("id"),
                            preferences.getString("regNo")),
                        icon: Icon(Icons.refresh)),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                      child: PopupMenuButton<String>(
                        // color: Theme.of(context).primaryColor,
                        child: Icon(
                          Icons.more_vert,
                        ),
                        onSelected: handleMenuClick,
                        itemBuilder: (BuildContext context) {
                          return {'Logout', 'Exit app'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ],
                  bottom: const TabBar(
                    tabs: [
                      Tab(
                          icon: Icon(Icons.event_available),
                          text: "Available rooms"),
                      Tab(icon: Icon(Icons.event), text: "All rooms"),
                      Tab(icon: Icon(Icons.account_box), text: "My rooms"),
                    ],
                  )),
              // body: Text("Body"),
              body: FutureBuilder<List<Room>?>(
                  future: futureRooms,
                  builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.none &&
                        !snapshot.hasData) {
                      return Center(
                          child: Text("Error. ${snapshot.error.toString()}"));
                    } else if ((snapshot.data != null) &&
                        (snapshot.data.length > -1)) {
                      futureActiveRooms = snapshot.data
                          .where((room) => room.active == true)
                          .toList();
                      futureInactiveRooms = snapshot.data
                          .where((room) => !room.active == false)
                          .toList();
                      return TabBarView(
                        children: [
                          futureActiveRooms.length > 0
                              ? (ListView.builder(
                                  itemBuilder: (listBuildContext, index) {
                                    return Card(
                                      child: ListTile(
                                        // leading: CircleAvatar(
                                        //   backgroundImage: AssetImage(
                                        //       images[index % images.length]),
                                        // ),
                                        title: Text(
                                          futureActiveRooms[index].roomName,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        // subtitle: Text(
                                        //     "${futureActiveRooms[index].hostelName} "),
                                        subtitle: RichText(
                                          text: TextSpan(children: <TextSpan>[
                                            TextSpan(
                                              text:
                                                  '${futureActiveRooms[index].hostelName} ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black54),
                                            ),
                                            TextSpan(
                                                text:
                                                    'Kshs. ${futureActiveRooms[index].roomCost.toString()} /sem',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                )),
                                          ]),
                                        ),
                                        trailing: student.roomName == ""
                                            ? ElevatedButton(
                                                onPressed: () => {
                                                      bookRoom(
                                                          futureActiveRooms[
                                                              index])
                                                    },
                                                child: Text("Book this room"))
                                            : null,
                                      ),
                                    );
                                  },
                                  itemCount: futureInactiveRooms.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(5),
                                  scrollDirection: Axis.vertical,
                                ))
                              : Center(
                                  child: Text(
                                      "It seems like there are no active rooms at the moment.")),
                          snapshot.data.length > 0
                              ? (ListView.builder(
                                  itemBuilder: (listBuildContext, index) {
                                    return Card(
                                      child: ListTile(
                                        title: Text(
                                          snapshot.data[index].roomName,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        subtitle: RichText(
                                          text: TextSpan(children: <TextSpan>[
                                            TextSpan(
                                              text:
                                                  '${snapshot.data[index].hostelName} ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black54),
                                            ),
                                            TextSpan(
                                                text:
                                                    'Kshs. ${snapshot.data[index].roomCost.toString()} /sem',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                )),
                                          ]),
                                        ),
                                        trailing: Badge(
                                          toAnimate: false,
                                          shape: BadgeShape.square,
                                          badgeColor:
                                              snapshot.data[index].active ==
                                                      true
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          badgeContent: Text(
                                              student.roomId ==
                                                      snapshot
                                                          .data[index].roomId
                                                  ? "My room"
                                                  : (snapshot.data[index]
                                                              .active ==
                                                          true)
                                                      ? "Available"
                                                      : "Unavailable",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                        selected: student.roomId ==
                                            snapshot.data[index].roomId,
                                        selectedTileColor: Colors.greenAccent,
                                      ),
                                    );
                                  },
                                  itemCount: snapshot.data.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(5),
                                  scrollDirection: Axis.vertical,
                                ))
                              : Center(
                                  child: Text(
                                      "It seems like there are no rooms at the moment.")),
                          ListView(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                widthFactor: 1,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 16, 16, 0),
                                  child: Icon(
                                    Icons.account_circle,
                                    size: 64,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 8, 2),
                                    child: Text(
                                      "${student.name == "" ? "Your name" : student.name} ",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                subtitle: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 2, 8, 2),
                                    child: Text(
                                      "${student.regNo} | ${student.email} \n"
                                      "Year ${student.studyYear} sem ${student.studySemester}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                isThreeLine: true,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 24, 16, 4),
                                  child: Text(
                                    "Your booked spaces",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              (student.roomName != null &&
                                      student.roomName != "")
                                  ? ListTile(
                                      title: Text(
                                        student.roomName ??
                                            "Could not load name",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      subtitle: RichText(
                                        text: TextSpan(children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                '${student.hostelName ?? ""} ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black54),
                                          ),
                                          TextSpan(
                                              text:
                                                  'Kshs. ${student.roomCost.toString()} /sem',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                              )),
                                        ]),
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () => {
                                          if (student.paid != null &&
                                              student.paid != true)
                                            handlePay(new Room(
                                                roomId: student.roomId ?? 0,
                                                hostelId: student.hostelId ?? 0,
                                                roomName:
                                                    student.roomName ?? "",
                                                roomCost: student.roomCost ?? 0,
                                                hostelName:
                                                    student.hostelName ?? "",
                                                active: false))
                                          else
                                            showReceipt(new Room(
                                                roomId: student.roomId ?? 0,
                                                hostelId: student.hostelId ?? 0,
                                                roomName:
                                                    student.roomName ?? "",
                                                roomCost: student.roomCost ?? 0,
                                                hostelName:
                                                    student.hostelName ?? "",
                                                active: false))
                                        },
                                        child: Text(
                                            (student.paid != null &&
                                                    student.paid == true)
                                                ? "View receipt"
                                                : "Pay now",
                                            textAlign: TextAlign.center),
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.green,
                                            textStyle: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal)),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 16.0),
                                      child: Text(
                                        "You have not booked a room.",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                              (student.roomName != null &&
                                      student.roomName != "" &&
                                      student.paid == true
                                  ? Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 24, 16, 4),
                                            child: Text(
                                              "Clearance status:",
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.normal,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => {
                                            if (student.awaitingClearance ==
                                                    -1 &&
                                                student.paid == true)
                                              requestClearance(new Room(
                                                  roomId: student.roomId ?? 0,
                                                  hostelId:
                                                      student.hostelId ?? 0,
                                                  roomName:
                                                      student.roomName ?? "",
                                                  roomCost:
                                                      student.roomCost ?? 0,
                                                  hostelName:
                                                      student.hostelName ?? "",
                                                  active: false))
                                          },
                                          child: Text(
                                              (student.awaitingClearance == -1
                                                  ? "Request clearance"
                                                  : student.awaitingClearance ==
                                                          0
                                                      ? "Cleared"
                                                      : "Clearance awaiting approval by admin"),
                                              textAlign: TextAlign.center),
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.green,
                                              textStyle: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.normal)),
                                        )
                                      ],
                                    )
                                  : Container()),
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 24, 16, 4),
                                  child: Text(
                                    "Previously booked rooms",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              FutureBuilder<List<PreviousRoom>?>(
                                  future: futurePreviousRooms,
                                  builder: (BuildContext bContect,
                                      AsyncSnapshot aSnapshop) {
                                    if ((aSnapshop.data != null) &&
                                        (aSnapshop.data.length > -1)) {
                                      return ListView.builder(
                                        itemBuilder: (listBuildContext, index) {
                                          return ListTile(
                                            title: Text(
                                              aSnapshop.data[index].roomName,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            subtitle: RichText(
                                              text:
                                                  TextSpan(children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${aSnapshop.data[index].hostelName} ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black54),
                                                ),
                                              ]),
                                            ),
                                            trailing: Badge(
                                              toAnimate: false,
                                              shape: BadgeShape.square,
                                              badgeColor: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              badgeContent: Text("Cleared",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                            selected: student.roomId ==
                                                snapshot.data[index].roomId,
                                            selectedTileColor:
                                                Colors.greenAccent,
                                          );
                                        },
                                        itemCount: aSnapshop.data.length ?? 0,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(5),
                                        scrollDirection: Axis.vertical,
                                      );
                                    }
                                    if (aSnapshop.hasError) {
                                      return Center(
                                          child: Text("Could not load rooms"));
                                    }
                                    return Center(
                                        child: CircularProgressIndicator(
                                      semanticsLabel: 'Loading rooms',
                                    ));
                                  })
                            ],
                          )
                        ],
                      );
                    } else if ((snapshot.data != null) &&
                        snapshot.data.id == 0) {
                      Center(
                          child: Text(
                              "Could not load rooms. ${snapshot.error.toString()}"));
                    } else if (snapshot.connectionState ==
                        ConnectionState.active) {
                      return Center(
                          child: CircularProgressIndicator(
                        semanticsLabel: 'Loading rooms',
                      ));
                    }
                    return Center(child: Text("Waiting to load"));
                  }),
            );
          } else if ((snapshot.data != null) && snapshot.data.id == 0) {
            SchedulerBinding.instance?.addPostFrameCallback((_) {
              Fluttertoast.showToast(
                  msg: "You are not not logged in.",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              Navigator.popAndPushNamed(context, '/login');
            });
          } else if (snapshot.connectionState == ConnectionState.active) {
            return Center(
                child: CircularProgressIndicator(
              semanticsLabel: 'Loading',
            ));
          }
          return Scaffold(
              body: Center(
            child: ListView(
                children: [Text("Waiting to load home ${snapshot.error}")]),
          ));
        },
      ),
    );
  }

  void clearData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    Fluttertoast.showToast(
        msg: 'Logged out successfully.',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green);
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      Navigator.popAndPushNamed(context, '/login');
    });
  }

  handleMenuClick(String value) {
    switch (value) {
      case 'Logout':
        clearData();
        break;
      case 'Exit app':
        Fluttertoast.showToast(
            msg: 'This close the app',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.green);
        break;
    }
  }
}
