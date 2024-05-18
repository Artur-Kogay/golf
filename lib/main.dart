import 'package:flutter/material.dart';
import 'package:golf/game.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200.0,
                decoration: BoxDecoration(
                  color: Color(0xFF164a88),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    'assets/images/card.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Text(
                  'SPORT',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.49,
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFdb4944),
                            Color(0xFFab1a39),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                        image: DecorationImage(
                          image: AssetImage('assets/images/card2.png'),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.48,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFa8b3c5),
                                Color(0xFF616d7e),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                            image: DecorationImage(
                              image: AssetImage('assets/images/card3.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.48,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF43c59f),
                                Color(0xFF78a635),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                            image: DecorationImage(
                              image: AssetImage('assets/images/card4.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 20.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFEFF5EB),
                        border: Border(
                          top: BorderSide(
                            color: Color(0xFFDFE4EA),
                            width: 1.0,
                          ),
                          left: BorderSide(
                            color: Color(0xFFDFE4EA),
                            width: 1.0,
                          ),
                          bottom: BorderSide(
                            color: Color(0xFFDFE4EA),
                            width: 1.0,
                          ),
                          right: BorderSide(
                            color: Color(0xFFDFE4EA),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '№',
                          style: TextStyle(
                            color: Color(0xFF9FA2A7),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 30.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFEFF5EB),
                          border: Border(
                            top: BorderSide(
                              color: Color(0xFFDFE4EA),
                              width: 1.0,
                            ),
                            right: BorderSide(
                              color: Color(0xFFDFE4EA),
                              width: 3.0,
                            ),
                            bottom: BorderSide(
                              color: Color(0xFFDFE4EA),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'GAMES 2023',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomBlock(num: "1", firstText: "Izrael", secondText: "Bulgaria"),
              CustomBlock(num: "2", firstText: "Hungary", secondText: "Georgia"),
              CustomBlock(num: "3", firstText: "Cyprus", secondText: "Scotland"),
              CustomBlock(num: "4", firstText: "Spain", secondText: "Azerbaijan"),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBlock extends StatelessWidget {
  final String num;
  final String firstText;
  final String secondText;

  CustomBlock({required this.num, required this.firstText, required this.secondText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 100,
          decoration: BoxDecoration(
            color: Color(0xFFF8F8F8),
            border: Border(
              right: BorderSide(color: Color(0xFFDFE4EA), width: 1),
              bottom: BorderSide(color: Color(0xFFDFE4EA), width: 1),
            ),
          ),
          child: Center(
            child: Text(
              num,
              style: TextStyle(fontSize: 24, color: Color(0xFF9FA2A7)),
            ),
          ),
        ),
        Container(
          height: 100,
          width: 200,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFDFE4EA), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                firstText,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
              ),
              Text(
                secondText,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24),
              ),
              Text('Go to play!'),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 50,
          decoration: BoxDecoration(
            color: Color(0xFFF8F8F8),
            border: Border(
              bottom: BorderSide(color: Color(0xFFDFE4EA), width: 1),
              left: BorderSide(color: Color(0xFFDFE4EA), width: 1),
            ),
          ),
          child: Center(
            child:
            Text(
              "0",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
            ),
          ),
        ),
        Container(
          height: 100,
          width: 50,
          decoration: BoxDecoration(
            color: Color(0xFFF8F8F8),
            border: Border(
              bottom: BorderSide(color: Color(0xFFDFE4EA), width: 1),
              left: BorderSide(color: Color(0xFFDFE4EA), width: 1),
            ),
          ),
          child: Center(
            child:
            Text(
              "1",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Color(0xFFF8F8F8),
              border: Border(
                bottom: BorderSide(color: Color(0xFFDFE4EA), width: 1),
                left: BorderSide(color: Color(0xFFDFE4EA), width: 1),
              ),
            ),
            child: Center(
              child: ElevatedButton(
                onPressed: () => {
                  Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MainGame(),
                      )
                  )
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  side: BorderSide(color: Color(0xFFDFE4EA)),
                ),
                child: Text(
                  'PLAY',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
