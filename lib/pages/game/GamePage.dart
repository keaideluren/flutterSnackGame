import 'package:flutter/material.dart';
import 'package:my_first_flutter/widgets/BlocProvider.dart';
import 'GameBloc.dart';

class SnackPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SnackState();
  }
}

class SnackState extends State<SnackPage> {
  GameBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = GameBloc(context);
  }

  @override
  void dispose() {
    super.dispose();
    _bloc?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("贪吃蛇"),
        centerTitle: true,
      ),
      body: BlocProvider<GameBloc>(
        bloc: _bloc,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: AspectRatio(
                aspectRatio: 1,
                child: SnackGameWidget(),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Stack(
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 180,
                    constraints: BoxConstraints(maxHeight: 180, maxWidth: 180),
                    alignment: Alignment.topCenter,
                    child: RawMaterialButton(
                      onPressed: () {
                        _bloc.inSnackData.add(GameBloc.direction_up);
                      },
                      constraints: BoxConstraints(minWidth: 60, minHeight: 60),
                      shape: CircleBorder(),
                      fillColor: Colors.blueGrey,
                      child: Text("上"),
                    ),
                  ),
                  Container(
                    width: 180,
                    height: 180,
                    constraints: BoxConstraints(maxHeight: 180, maxWidth: 180),
                    alignment: Alignment.bottomCenter,
                    child: RawMaterialButton(
                      onPressed: () {
                        _bloc.inSnackData.add(GameBloc.direction_down);
                      },
                      constraints: BoxConstraints(minWidth: 60, minHeight: 60),
                      shape: CircleBorder(),
                      fillColor: Colors.blueGrey,
                      child: Text("下"),
                    ),
                  ),
                  Container(
                    width: 180,
                    height: 180,
                    constraints: BoxConstraints(maxHeight: 180, maxWidth: 180),
                    alignment: Alignment.centerLeft,
                    child: RawMaterialButton(
                      onPressed: () {
                        _bloc.inSnackData.add(GameBloc.direction_left);
                      },
                      constraints: BoxConstraints(minWidth: 60, minHeight: 60),
                      shape: CircleBorder(),
                      fillColor: Colors.blueGrey,
                      child: Text("左"),
                    ),
                  ),
                  Container(
                    width: 180,
                    height: 180,
                    constraints: BoxConstraints(maxHeight: 180, maxWidth: 180),
                    alignment: Alignment.centerRight,
                    child: RawMaterialButton(
                      onPressed: () {
                        _bloc.inSnackData.add(GameBloc.direction_right);
                      },
                      constraints: BoxConstraints(minWidth: 60, minHeight: 60),
                      fillColor: Colors.blueGrey,
                      shape: CircleBorder(),
                      child: Text("右"),
                    ),
                  ),
                  Container(
                    width: 330,
                    height: 180,
                    alignment: Alignment.centerRight,
                    child: RawMaterialButton(
                      onPressed: () {
//                        _snackGameState.startOrStop();
                        _bloc.startData.add(true);
                      },
                      constraints: BoxConstraints(minWidth: 60, minHeight: 60),
                      fillColor: Colors.blueGrey,
                      shape: CircleBorder(),
                      child: Text("开始"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SnackGameWidget extends StatefulWidget {
  SnackGameWidget();

  @override
  State<StatefulWidget> createState() {
    return SnackGameState();
  }
}

class SnackGameState extends State<StatefulWidget> {
  DOT _snackBody, _food;
  GameBloc _bloc;

  @override
  Widget build(BuildContext context) {
    if(_bloc == null) {
      _bloc = BlocProvider.of<GameBloc>(context);
      _bloc.outSnackData.listen((SnackData snackData){
        setState(() {
          _snackBody = snackData.snackBody;
          _food = snackData.food;
        });
      });
    }
    return Listener(
      child: CustomPaint(
        painter: SnackGamePainter(_snackBody, _food),
      ),
      onPointerDown: (e) {
        print("事件，按下$e");
      },
      onPointerMove: (e) {
        print("事件，移动$e");
      },
    );
  }
}

class SnackGamePainter extends CustomPainter {
  Paint _p;
  Paint _bgPaint;
  Paint _foodPaint;
  final DOT _dotChain;
  final DOT _food;

  SnackGamePainter(this._dotChain, this._food) {
    _p = new Paint();
    _bgPaint = new Paint();
    _foodPaint = new Paint();
    _p
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    _bgPaint
      ..color = Colors.black12
      ..style = PaintingStyle.fill;
    _foodPaint
      ..color = Colors.lightBlue
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size == Size.zero) {
      size = Size(360, 360);
    }
    _drawBg(canvas, size);
    _drawSnack(canvas, size);
    _drawFood(canvas, size);
  }

  @override
  bool shouldRepaint(SnackGamePainter oldDelegate) {
    return !(_dotChain?.x == oldDelegate._dotChain?.x &&
        _dotChain?.y == oldDelegate._dotChain?.y);
  }

  void _drawBg(Canvas c, Size size) {
    //20行20列
    var spaceWidthSize = (size.width - 1) / 20;
    var spaceHeightSize = (size.height - 1) / 20;
    for (int i = 0; i <= 20; i++) {
      c.drawLine(Offset(0, i * spaceHeightSize),
          Offset(size.width, i * spaceHeightSize), _bgPaint);
      c.drawLine(Offset(i * spaceWidthSize, 0),
          Offset(i * spaceWidthSize, size.height), _bgPaint);
    }
  }

  void _drawSnack(Canvas canvas, Size size) {
    var spaceWidthSize = (size.width - 1) / 20;
    var spaceHeightSize = (size.height - 1) / 20;
    var currentDot = _dotChain;
    while (currentDot != null) {
      canvas.drawRect(
          Rect.fromLTWH(
            currentDot.x * spaceWidthSize + 1,
            currentDot.y * spaceHeightSize + 1,
            spaceWidthSize - 2,
            spaceHeightSize - 2,
          ),
          _p);
      currentDot = currentDot.next;
    }
  }

  void _drawFood(Canvas canvas, Size size) {
    var spaceWidthSize = (size.width - 1) / 20;
    var spaceHeightSize = (size.height - 1) / 20;
    canvas.drawRect(
        Rect.fromLTWH(
          _food.x * spaceWidthSize + 1,
          _food.y * spaceHeightSize + 1,
          spaceWidthSize - 2,
          spaceHeightSize - 2,
        ),
        _foodPaint);
  }
}
