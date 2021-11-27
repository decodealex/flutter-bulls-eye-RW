import 'package:bulls_eye/prompt.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'prompt.dart';
import 'control.dart';
import 'scoreRow.dart';
import 'gameModel.dart';
import 'textStyles.dart';
import 'styledButton.dart';
import 'hitMeButton.dart';

void main() => runApp(BullsEyeApp());

class BullsEyeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    return MaterialApp(
      title: 'BullsEye',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GamePage(title: 'BullsEye'),
    );
  }
}

class GamePage extends StatefulWidget {
  GamePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _alertsIsVisible = false;
  GameModel _model;

  @override
  void initState() {
    super.initState();
    _model = GameModel(Random().nextInt(101));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage("images/background.png"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 48.0, bottom: 32.0),
                child: Prompt(targetValue: _model.target),
              ),
              Control(model: _model),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: HitMeButton(
                  text: 'HIT ME!',
                  onPressed: () {
                    this._showAlert(context);
                    setState(() {
                      this._alertsIsVisible = true;
                    });
                    print(_model.totalScore);
                    print("Button pressed");
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ScoreRow(
                    totalScore: _model.totalScore,
                    round: _model.round,
                    onStartOver: _startNewGame),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _sliderValue() => _model.current;
  int _newTargetValue() => Random().nextInt(10) + 1;

  void _startNewGame() {
    setState(() {
      _model.totalScore = GameModel.SCORE_START;
      _model.round = GameModel.ROUND_START;
      _model.current = GameModel.SLIDER_START;
      _model.target = _newTargetValue();
    });
  }

  int _pointsForCurrentRound() {
    return 100 - (_model.target - _sliderValue()).abs();
  }

  void _showAlert(BuildContext context) {
    Widget okButton = StyledButton(
        icon: Icons.close,
        onPressed: () {
          Navigator.of(context).pop();
          setState(() {
            this._alertsIsVisible = false;
            _model.totalScore += _pointsForCurrentRound();
            _model.round += 1;
            _model.target = _newTargetValue();
          });
          print("Awesome pressed! $_alertsIsVisible");
        });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hello there!",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("THE SLIDER`S VALUE IS", textAlign: TextAlign.center),
              Text("${_sliderValue()}",
                  style: TargetTextStyle.bodyText1(context),
                  textAlign: TextAlign.center),
              Text(
                  "\n You scored ${_pointsForCurrentRound()} points this round.",
                  textAlign: TextAlign.center),
            ],
          ),
          actions: <Widget>[
            okButton,
          ],
          elevation: 5,
        );
      },
    );
  }
}
