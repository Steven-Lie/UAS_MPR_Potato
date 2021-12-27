import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

List countryList = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map of Countries',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Map of Countries'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });

    Response countryResponse = await get(Uri.parse("https://gist.githubusercontent.com/erdem/8c7d26765831d0f9a8c62f02782ae00d/raw/248037cd701af0a4957cce340dabb0fd04e38f4c/countries.json"));

    if (countryResponse.statusCode == 200){
      setState(() {
        isLoading = false;
      });
      countryList = json.decode(countryResponse.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading? const Center(
        child: CircularProgressIndicator(),
      ) : ListView.builder(itemCount: countryList.length, itemBuilder: (BuildContext context, int index){
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 7.0,
                bottom: 7.0,
              ),
              title: Text(
                countryList[index]['name'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Kode Negara: " + countryList[index]['country_code'].toString() +
                  "\nIbukota: " + countryList[index]['capital'].toString()
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailCountry(countryIndex: index)),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

class DetailCountry extends StatefulWidget {
  const DetailCountry({Key? key, required this.countryIndex}) : super(key: key);
  final int countryIndex;

  @override
  State<StatefulWidget> createState() => _DetailCountryState();
}

class _DetailCountryState extends State<DetailCountry>{
  Set<Marker> markers = HashSet<Marker>();

  void onMapCreated(GoogleMapController controller){
    setState(() {
      markers.add(
        Marker(
          markerId: const MarkerId("0"),
          position: LatLng(
            double.parse(countryList[widget.countryIndex]['latlng'][0].toString()),
            double.parse(countryList[widget.countryIndex]['latlng'][1].toString())
          ),
          infoWindow: InfoWindow(
            title: countryList[widget.countryIndex]['name'].toString(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Country Detail"),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 10.0, top: 10.0,),
            child: Text(
              countryList[widget.countryIndex]['name'].toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: Text(
                    "Kode Negara: " + countryList[widget.countryIndex]['country_code'].toString(),
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: Text(
                    "Ibukota: " + countryList[widget.countryIndex]['capital'].toString(),
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: Text(
                    "\nLatitude: " + countryList[widget.countryIndex]['latlng'][0].toString(),
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: Text(
                    "Longitude: " + countryList[widget.countryIndex]['latlng'][1].toString(),
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 7.0, left: 10.0, right: 10.0),
            child: const Text(
              "\nPosition on Map: ",
              style: TextStyle(fontSize: 17),
            ),
          ),
          Container(
            width: double.infinity,
            height: 300,
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: GoogleMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  double.parse(countryList[widget.countryIndex]['latlng'][0].toString()),
                  double.parse(countryList[widget.countryIndex]['latlng'][1].toString())
                ),
                zoom: 3
              ),
              markers: markers,
            ),
          )
        ],
      ),
    );
  }
}


