import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:core';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:math';

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/config.json');
}

/*//jjjj
// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2019, 1, 1): ['New Year\'s Day'],
  DateTime(2019, 1, 6): ['Epiphany'],
  DateTime(2019, 2, 14): ['Valentine\'s Day'],
  DateTime(2019, 4, 21): ['Easter Sunday'],
  DateTime(2019, 4, 22): ['Easter Monday'],
};
*/
void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

var data = {
  //格式  Key: Value
  '支出': 0.0,
  '收入': 0.0,
  '飲食': 0.0,
  '服飾': 0.0,
  '居家': 0.0,
  '交通': 0.0,
  '娛樂': 0.0,
  '電話': 0.0,
  '交際': 0.0
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '記帳',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: MyHomePage(title: '記帳小幫手'),
    );
  }

  Widget add(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {},
    ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;

  get initialCalendarFormat => null;

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();

    _events = {
      _selectedDay.subtract(Duration(days: 30)): [
        'Event A0',
        'Event B0',
        'Event C0'
      ],
      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
      _selectedDay.subtract(Duration(days: 20)): [
        'Event A2',
        'Event B2',
        'Event C2',
        'Event D2'
      ],
      _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
      _selectedDay.subtract(Duration(days: 10)): [
        'Event A4',
        'Event B4',
        'Event C4'
      ],
      _selectedDay.subtract(Duration(days: 4)): [
        'Event A5',
        'Event B5',
        'Event C5'
      ],
      _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
      _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
      _selectedDay.add(Duration(days: 1)): [
        'Event A8',
        'Event B8',
        'Event C8',
        'Event D8'
      ],
      _selectedDay.add(Duration(days: 3)):
          Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
      _selectedDay.add(Duration(days: 7)): [
        'Event A10',
        'Event B10',
        'Event C10'
      ],
      _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
      _selectedDay.add(Duration(days: 17)): [
        'Event A12',
        'Event B12',
        'Event C12',
        'Event D12'
      ],
      _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
      _selectedDay.add(Duration(days: 26)): [
        'Event A14',
        'Event B14',
        'Event C14'
      ],
    };
    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  int _selectedIndex = 0;
  final pages = [MyHomePage(), Information()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          //_buildTableCalendar(),

          _buildTableCalendarWithBuilders(),
          const SizedBox(height: 0.0),
          _buildButtons(),
          const SizedBox(height: 0.0),
          Expanded(child: _buildEventList()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        // 底部导航
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.archive), title: Text('記帳資料')),
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment), title: Text('資料分析')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Simple TableCalendar configuration (using Styles)
  /*Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }
*/
  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'zh_CN',
      calendarController: _calendarController,
      events: _events,
      //holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.scale,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        //CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.purple[200]),
        holidayStyle: TextStyle().copyWith(color: Colors.red),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.pink[200]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 5.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, events) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.today,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildButtons() {
    /*final dateTime = _events.keys.elementAt(_events.length - 2);*/

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('收入: '),
            Text(data['收入'].toString()),
            Text('    '),
            Text('支出: '),
            Text(data['支出'].toString()),
            Text('                                '),
            RaisedButton(
              child: Text('+'),
              onPressed: () {
                setState(() {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FirstScreen()));
                });
              },
            ),
            /*RaisedButton(
              child: Text('2 weeks'),
              onPressed: () {
                setState(() {
                  _calendarController
                      .setCalendarFormat(CalendarFormat.twoWeeks);
                });
              },
            ),
            RaisedButton(
              child: Text('Week'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.week);
                });
              },
            ),*/
          ],
        ),
        const SizedBox(height: 0.0),
        /*RaisedButton(
          child: Text(
              'Set day ${dateTime.day}-${dateTime.month}-${dateTime.year}'),
          onPressed: () {
            _calendarController.setSelectedDay(
              DateTime(dateTime.year, dateTime.month, dateTime.day),
              runCallback: true,
            );
          },
        ),*/
      ],
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.toString()),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }
}

class Information extends StatefulWidget {
  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  var index = 2;
  bool toggle = false;

  Map<String, double> dataMap = Map();
  List<Color> colorList = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.white70
  ];

  @override
  void initState() {
    super.initState();
    dataMap.putIfAbsent("飲食", () => data['飲食']);
    dataMap.putIfAbsent("服飾", () => data['服飾']);
    dataMap.putIfAbsent("居家", () => data['居家']);
    dataMap.putIfAbsent("交通", () => data['交通']);
    dataMap.putIfAbsent("娛樂", () => data['娛樂']);
    dataMap.putIfAbsent("電話", () => data['電話']);
    dataMap.putIfAbsent("交際", () => data['交際']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("資料分析"),
      ),
      body: Container(
        child: Center(
          child: toggle
              ? PieChart(
                  dataMap: dataMap,
                  animationDuration: Duration(milliseconds: 800),
                  chartLegendSpacing: 32.0,
                  chartRadius: MediaQuery.of(context).size.width / 2.7,
                  showChartValuesInPercentage: true,
                  showChartValues: true,
                  showChartValuesOutside: true,
                  chartValueBackgroundColor: Colors.grey[200],
                  colorList: colorList,
                  showLegends: true,
                  legendPosition: LegendPosition.right,
                  decimalPlaces: 1,
                  showChartValueLabel: true,
                  initialAngle: 0,
                  chartValueStyle: defaultChartValueStyle.copyWith(
                    color: Colors.blueGrey[900].withOpacity(0.9),
                  ),
                  chartType: ChartType.disc,
                )
              : Text("Press FAB to show chart"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: togglePieChart,
        child: Icon(Icons.insert_chart),
      ),
    );
  }

  void togglePieChart() {
    setState(() {
      toggle = !toggle;
    });
  }
}

class FirstScreen extends StatefulWidget {
  FirstScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First page'),
      ),
    );
  }

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

Future<void> showAlert1(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('警告'),
        content: const Text('錯誤，請再輸入一次'),
        actions: <Widget>[
          FlatButton(
            child: Text('好的'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class Item2 {
  const Item2(this.inout, this.icon);
  final String inout;
  final Icon icon;
}

class Item {
  const Item(this.name, this.icon);
  final String name;
  final Icon icon;
}

SharedPreferences sharedPreferences;

Future<String> token(String hit) async {
  sharedPreferences = await SharedPreferences.getInstance();
  return hit;
}

/// State for [FirstScreen] widgets.
class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController _controller = TextEditingController();
  String hit1;
  String hit2;
  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ],
    // );
    hit1 = "收入或支出";
    hit2 = "選擇類別";
  }

  @override
  Widget build(BuildContext context) {
    List<Item2> users2 = <Item2>[
      const Item2(
          '收入',
          Icon(
            Icons.arrow_forward,
            color: const Color(0xFF167F67),
          )),
      const Item2(
          '支出',
          Icon(
            Icons.arrow_back,
            color: const Color(0xFF167F67),
          )),
    ];

    List<Item> users = <Item>[
      const Item(
          '飲食',
          Icon(
            Icons.fastfood,
            color: const Color(0xFF167F67),
          )),
      const Item(
          '服飾',
          Icon(
            Icons.perm_identity,
            color: const Color(0xFF167F67),
          )),
      const Item(
          '居家',
          Icon(
            Icons.home,
            color: const Color(0xFF167F67),
          )),
      const Item(
          '交通',
          Icon(
            Icons.directions_bus,
            color: const Color(0xFF167F67),
          )),
      const Item(
          '娛樂',
          Icon(
            Icons.favorite,
            color: const Color(0xFF167F67),
          )),
      const Item(
          '電話',
          Icon(
            Icons.phone_android,
            color: const Color(0xFF167F67),
          )),
      const Item(
          '交際',
          Icon(
            Icons.music_note,
            color: const Color(0xFF167F67),
          )),
    ];
    var selectedUser;
    var selectedUser2;

    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        //title: Text('${date.day}'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Text(
            '收入或支出',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          DropdownButton<Item2>(
            hint: Text(hit1),
            value: selectedUser2,
            onChanged: (Item2 value) {
              setState(() {
                hit1 = value.inout;

                selectedUser2 = value;
                print(hit1);
                //print('$selectedUser2');
              });
            },
            items: users2.map((Item2 user2) {
              return DropdownMenuItem<Item2>(
                value: user2,
                child: Row(
                  children: <Widget>[
                    user2.icon,
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      user2.inout,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Text(
            '類別',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          DropdownButton<Item>(
            hint: Text(hit2),
            value: selectedUser,
            onChanged: (Item value) {
              setState(() {
                hit2 = value.name;

                selectedUser = value;
                print(hit2);
              });
            },
            items: users.map((Item user) {
              return DropdownMenuItem<Item>(
                value: user,
                child: Row(
                  children: <Widget>[
                    user.icon,
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      user.name,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Text(
            '金額',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 70.0, right: 70.0),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: _controller,
              decoration: InputDecoration(
                  hintText: '輸入金額', contentPadding: const EdgeInsets.all(5.0)),
            ),
          ),
          RaisedButton(
            onPressed: () async {
              //SharedPreferences prefs = await SharedPreferences.getInstance();
              if (hit1 == '收入或支出' || hit2 == '選擇類別') {
                showAlert1(context);
              } else {
                if (hit1 == '支出') {
                  data['支出'] += int.parse(_controller.text);
                  print(data['支出']);
                } else if (hit1 == '收入') {
                  data['收入'] += int.parse(_controller.text);
                  print(data['收入']);
                } else if (hit2 == '飲食') {
                  print(data['飲食']);
                  data['飲食'] += int.parse(_controller.text);
                  print(data['飲食']);
                } else if (hit2 == '服飾') {
                  data['服飾'] += int.parse(_controller.text);
                  print(data['服飾']);
                } else if (hit2 == '居家') {
                  data['居家'] += int.parse(_controller.text);
                  print(data['居家']);
                } else if (hit2 == '交通') {
                  data['交通'] += int.parse(_controller.text);
                  print(data['交通']);
                } else if (hit2 == '娛樂') {
                  data['娛樂'] += int.parse(_controller.text);
                  print(data['娛樂']);
                } else if (hit2 == '電話') {
                  data['電話'] += int.parse(_controller.text);
                  print(data['電話']);
                } else if (hit2 == '交際') {
                  data['交際'] += int.parse(_controller.text);
                  print(data['交際']);
                }
                Navigator.of(context).pop();
                // await prefs.setInt('服飾', int.parse(_controller.text));
                // await prefs.setInt('居家', int.parse(_controller.text));
                // await prefs.setInt('交通', int.parse(_controller.text));
                // await prefs.setInt('娛樂', int.parse(_controller.text));
                // await prefs.setInt('電話', int.parse(_controller.text));
                // await prefs.setInt('交際', int.parse(_controller.text));
                // await prefs.setInt('收入', int.parse(_controller.text));
                // await prefs.setInt('支出', int.parse(_controller.text));
              }
            },
            /*{
              showDialog(
                context: context,
                child: AlertDialog(
                  title: Text('What you typed'),
                  content: Text(_controller.text),
                ),
              );
            },*/
            child: Text('送出'),
          ),
        ],
      ),
    );
  }
}

class Todo {
  final int date;
  //final String description;

  Todo(this.date);
}
