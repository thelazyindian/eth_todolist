import 'dart:async';

import 'package:flutter/material.dart';
import 'package:eth_todolist/eth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final newTaskController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamController<double> controller = StreamController.broadcast();
  final dismissKey = GlobalKey();
  EthereumC ethC;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ethC = EthereumC(context);

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: FutureBuilder(
          future: ethC.fetchAllTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return LinearProgressIndicator();
            List data = snapshot.data;
            if (data == null) return Center(child: Text('Gahh Err'));
            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  title: Text(
                    widget.title,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30.0,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w300),
                  ),
                  backgroundColor: Colors.white,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return Slidable(
                      key: ValueKey(index),
                      dismissal: SlidableDismissal(
                        child: SlidableDrawerDismissal(),
                        onDismissed: (actionType) async {
                          await ethC.taskCompleted(index);
                          setState(() {});
                        },
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Colors.grey))),
                            width: double.infinity,
                            height: 60.0,
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Image.asset(
                                    data[index][2]
                                        ? 'assets/icons/icons8-checked-100.png'
                                        : 'assets/icons/icons8-circle-100.png',
                                    width: 20.0,
                                    height: 20.0,
                                  ),
                                  onPressed: () async {
                                    await ethC.taskCompleted(index);
                                    setState(() {});
                                  },
                                ),
                                Text(
                                  data[index][1],
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    letterSpacing: 1.0,
                                    decoration: data[index][2]
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ],
                            )),
                      ),
                      actionPane: SlidableDrawerActionPane(),
                      actions: <Widget>[
                        IconSlideAction(
                          color: Colors.grey,
                          iconWidget: Icon(Icons.delete, color: Colors.white),
                          onTap: () => {},
                        ),
                      ],
                    );
                  }, childCount: data.length),
                ),
              ],
            );
          }),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.grey))),
            height: 50.0,
            width: MediaQuery.of(context).size.width - 16.0,
            child: Text('Lmfao'),
          ),
          FloatingActionButton(
            onPressed: () {
              _newTaskMenu();
            },
            tooltip: 'Add Task',
            child: Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _newTaskMenu() {
    double position = 0.0, temp;
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: controller.stream,
          builder: (context, snapshot) => GestureDetector(
              onVerticalDragUpdate: (DragUpdateDetails details) {
                temp = MediaQuery.of(context).size.height -
                    MediaQuery.of(context).viewInsets.bottom -
                    details.globalPosition.dy;

                if (temp > position)
                  temp.isNegative
                      ? Navigator.pop(context)
                      : controller.add(temp);
              },
              onVerticalDragEnd: (DragEndDetails ded) {
                position = temp;
              },
              behavior: HitTestBehavior.translucent,
              child: Wrap(
                children: <Widget>[
                  Container(
                    height: snapshot.hasData ? snapshot.data : 80.0,
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            controller: newTaskController,
                            decoration:
                                InputDecoration(hintText: 'Enter a Task'),
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Colors.lightBlue,
                            ),
                            onPressed: () async {
                              if (newTaskController.text != "") {
                                await ethC.createTasks(newTaskController.text);
                                newTaskController.clear();
                                Navigator.pop(context);
                                setState(() {});
                              } else
                                Fluttertoast.showToast(
                                    msg: "Please enter a task",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIos: 1,
                                    backgroundColor: Colors.lightBlue,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                            })
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    height: MediaQuery.of(context).viewInsets.bottom,
                    duration: Duration(
                      milliseconds: 100,
                    ),
                  ),
                ],
              )),
        );
      },
      context: context,
    );
  }
}
