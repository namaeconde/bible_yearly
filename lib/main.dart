import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bible_yearly/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return MaterialApp(
      title: 'Bible Yearly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        platform: TargetPlatform.iOS,
      ),
      home: const MyHomePage(title: 'Bible Yearly'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final double infoHeight = 364.0;
  List _readings = [];
  String _oldTestament = "";
  String _newTestament = "";
  late Timer _everDay;
  late Timer _everyMonth;

  // Fetch content from the json file
  Future<void> readJson() async {
    debugPrint("Reading JSON");
    final currentMonth = DateFormat.MMMM().format(DateTime.now()).toLowerCase();
    final String response = await rootBundle.loadString('assets/files/$currentMonth.json');
    final data = await json.decode(response);
    setState(() {
      _readings = data;
      getReadings();
    });
  }

  Future<void> getReadings() async {
    debugPrint("Get Readings");
    final currentDay = DateTime.now().day - 1;
    final currentReading = _readings.isNotEmpty ? _readings[currentDay] : { "Old Testament" : "", "New Testament": ""};
    setState(() {
      _oldTestament = currentReading["Old Testament"];
      _newTestament = currentReading["New Testament"];
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();

    _everyMonth = Timer.periodic(const Duration(days: 20), (Timer t) async {
      readJson();
    });

    _everDay = Timer.periodic(const Duration(minutes: 30), (Timer t) async {
      getReadings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.2) +
        24.0;
    return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: <Widget>[
            Column(children: <Widget>[
              AspectRatio(
                aspectRatio: 1.2,
                child: SvgPicture.asset(
                    'assets/home/welcome_image.svg',
                    semanticsLabel: 'Welcome Image'
                ),
              ),
            ]),
            Positioned(
              top: (MediaQuery.of(context).size.width / 1.2) - 24.0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(
                          minHeight: infoHeight,
                          maxHeight: tempHeight > infoHeight
                              ? tempHeight
                              : infoHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(
                                top: 32.0, left: 18, right: 16),
                            child: Text(
                              "Today's reading is in",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 21,
                                color: AppTheme.textColor,
                              ),
                            ),
                          ),
                          _readings.isNotEmpty ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 8, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      _oldTestament,
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 30,
                                        letterSpacing: 0.27,
                                        color: AppTheme.textColor,
                                      )
                                  ),
                                  Text(
                                      _newTestament,
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 30,
                                        letterSpacing: 0.27,
                                        color: AppTheme.textColor,
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ) : Container(),
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: (MediaQuery.of(context).size.width / 1.2) - 24.0 - 35,
              right: 35,
              child: Card(
                color: AppTheme.buttonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0)),
                elevation: 10.0,
                child: const SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            )
          ]
        )
    );
  }
}
