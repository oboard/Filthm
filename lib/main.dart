import 'package:animated_background/animated_background.dart';
import 'package:filthm/effect/rain_behavior.dart';
import 'package:filthm/widgets/button.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Game());
}

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filthm',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

var menu = [
  Icons.music_note,
  Icons.cloud,
  Icons.edit_document,
  Icons.settings,
];

int pageIndex = 0;

class _HomeState extends State<Home> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.fromSize(
            size: size,
            child: const Image(
              image: AssetImage('images/songselect3.png'),
              fit: BoxFit.cover,
            ),
          ),
          AnimatedBackground(
            behaviour: RainBehavior(direction: LineDirection.Ttb),
            vsync: this,
            child: const SizedBox(),
          ),
          Row(
            children: [
              SizedBox(
                width: 128,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      for (IconData item in menu)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: LazyButtonS(
                            padding: EdgeInsets.zero,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: (pageIndex != menu.indexOf(item))
                                  ? null
                                  : const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xffe8effd),
                                          Color(0xffede8fc),
                                        ],
                                        begin: Alignment(0, 0),
                                        end: Alignment(1, 1),
                                      ),
                                      boxShadow: [
                                          BoxShadow(
                                            color: Color.fromARGB(
                                                255, 231, 222, 255),
                                            blurRadius: 10,
                                          )
                                        ]),
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Icon(
                                  item,
                                  size: 32,
                                ),
                              ),
                            ),
                            onPressed: () {
                              pageIndex = menu.indexOf(item);
                              setState(() {});
                            },
                          ),
                        )
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: ListView(
                    children: [
                      Container(
                        height: size.height / 2,
                        child: const Text('2'),
                      )
                    ],
                  )),
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, size.height / 5),
                  child: const Image(
                    image: AssetImage('images/person.png'),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
