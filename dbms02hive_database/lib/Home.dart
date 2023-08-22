import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var titleController = TextEditingController();
  var descController = TextEditingController();

  var taskBox = Hive.box("taskBox");
  List<Map<String, dynamic>> ouralldata = [];

  createData(Map<String, dynamic> data) async {
    await taskBox.add(data);
    readata();
    print("List my ${taskBox.length}");
  }

  readata() async {
    var data = taskBox.keys.map((key) {
      final item = taskBox.get(key);

      return {"key": key, "title": item["title"], "desc": item["desc"]};
    }).toList();

    setState(() {
      ouralldata = data.reversed.toList();
      print(ouralldata);
      print(ouralldata.length);
    });
  }

// update Data

  updatedata(int? key, Map<String, dynamic> data) async {
    await taskBox.put(key, data);
    readata();
  }

// delete data

  deletedata(int? key) async {
    await taskBox.delete(key);
    readata();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readata();
  }

  showformmodel(context, int? key) async {
    titleController.clear();
    descController.clear();

    if (key != null) {
      final item = ouralldata.firstWhere((element) => element["key"] == key);

      titleController.text = item["title"];
      descController.text = item["desc"];
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              32, 32, 32, MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: "Enter Your Title"),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(hintText: "Enter Your Description"),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    var data = {
                      "title": titleController.text,
                      "desc": descController.text
                    };
                    if (key == null) {
                      createData(data);
                    } else {
                      updatedata(key, data);
                    }

                    Navigator.pop(context);
                  },
                  child: Text(key == null ? "Add Task" : "Update Task"))
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showformmodel(context, null);
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Hive Crud App"),
      ),
      body: ListView.builder(
        itemCount: ouralldata.length,
        itemBuilder: (context, index) {
          var currentItem = ouralldata[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.brown[900],
              child: Padding(
                padding: const EdgeInsets.all(.0),
                child: ListTile(
                  // tileColor: Colors.brown,
                  textColor: Colors.white,
                  title: Text(currentItem["title"]),
                  subtitle: Text(currentItem["desc"]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            showformmodel(context, currentItem["key"]);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          )),
                      IconButton(
                          onPressed: () {
                            deletedata(currentItem["key"]);
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
