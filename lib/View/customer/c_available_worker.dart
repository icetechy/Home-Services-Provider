import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:home_well/Model/AddJobRequest.dart';
import 'c_wait_for_response.dart';
import 'package:home_well/Controller/CustomerController/rigesterCustomerCtrl.dart';
import 'package:home_well/Controller/CustomerController/customerProfileCtrl.dart';

CustomerDataFromFireStore updateDataFromFireStore =
    new CustomerDataFromFireStore();
AddJobRequest _jobRequest = new AddJobRequest();

class AvailableWorker extends StatefulWidget {
  final CustomerData user;

  const AvailableWorker({Key key, this.user}) : super(key: key);

  _MyWorkerPageState createState() => _MyWorkerPageState(user);
}

CustomerDataFromFireStore customerDataFromFireStore =
    new CustomerDataFromFireStore();

class _MyWorkerPageState extends State<AvailableWorker> {
  final CustomerData user;

  _MyWorkerPageState(this.user);

  Widget _buildWorkerList() {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection("Worker")
              .where("City", isEqualTo: user.city)
              .where("Area", isEqualTo: user.area)
              .where("Job", isEqualTo: user.job)
              .where("SubJobs", arrayContains: user.subJob)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("Loading...");
            } else {
              final doc = snapshot.data.documents;
              List<Worker> worker = new List();
              int workerCount = snapshot.data.documents.length;
              for (var msg in doc) {
                worker.add(Worker(
                  msg.data['Id'],
                  msg.data['Name'],
                  msg.data['Phone'],
                  msg.data['Rating'],
                  msg.data['Image'],
                ));
              }
              return Container(
                child: workerCount > 0
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: workerCount,
                        itemBuilder: (BuildContext context, int index) {
                          return WorkerCard(worker: worker[index]);
                        })
                    : Center(child: Text('No Related Worker Avalible yet')),
              );
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
                Navigator.pop(context);
            }),
        title: new Text(
          "Available Worker",
          style: new TextStyle(
              fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildWorkerList(),
    );
  }
}

class Worker {
  final String workerId;
  final String workerName;
  final String workerContact;
  final int rating;
  final String imageUrl;

  Worker(
    this.workerId,
    this.workerName,
    this.workerContact,
    this.rating,
    this.imageUrl,
  );
}

class WorkerCard extends StatelessWidget {
  final Worker worker;

  const WorkerCard({this.worker});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.black12),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Container(
                  width: 60.0,
                  height: 100.0,
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                      fit: BoxFit.fill,
                      image: new NetworkImage(worker.imageUrl != null
                          ? worker.imageUrl
                          : "https://previews.123rf.com/images/tuktukdesign/tuktukdesign1606/tuktukdesign160600105/59070189-user-icon-man-profile-businessman-avatar-person-icon-in-vector-illustration.jpg"),
                    ),
                  ),
                ),
                title: Text(
                  worker.workerName,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                subtitle: Row(children: <Widget>[
                  Text(worker.rating.toString(),
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w600)),
                  Icon(
                    Icons.star,
                    size: 15,
                  )
                ]),
                trailing: RequestButton(worker: worker),
              )
            ],
          ),
        ));
  }
}

class RequestButton extends StatelessWidget {
  final Worker worker;

  const RequestButton({Key key, this.worker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.0,
      height: 30.0,
      child: RaisedButton(
        elevation: 1.0,
        textColor: Colors.black,
        color: Colors.lightGreen,
        child: Text(
          "Request",
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: 9.0,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          userData.workerId = worker.workerId;
          userData.workerName = worker.workerName;
          userData.workerImg = worker.imageUrl;
          userData.workerContact = worker.workerContact;
          _jobRequest.updateCustomerData(userData);
          userData.jobCount += 1;
          updateDataFromFireStore.updateJobCount(
              userData.userId, 'JobCount', (userData.jobCount));
//clear data for next worker request
          userData.workerId = null;
          userData.workerName = null;
          userData.workerImg = null;
          userData.workerContact = null;
          userData.job = null;
          userData.subJob = null;
          userData.time = null;
          userData.date = null;
          userData.subJobFields = null;

          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ResponseWait(job: userData.job, worker: worker.workerName)));
        },
      ),
    );
  }
}
