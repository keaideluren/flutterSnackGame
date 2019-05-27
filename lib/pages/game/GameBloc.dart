import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_first_flutter/widgets/BlocProvider.dart';
import 'package:my_first_flutter/widgets/Toast.dart';

class GameBloc extends BlocBase {
  static const int direction_up = 0;
  static const int direction_down = 1;
  static const int direction_left = 2;
  static const int direction_right = 3;
  SnackData _snackData = SnackData();
  final Random _random = Random();
  bool _started = false;
  int _direction = direction_up;
  int direction;
  int score = 0;
  int speed = 1000;
  bool start = false;
  bool _gameOverState = false;
  BuildContext context;


  GameBloc(this.context){
    _initSnack();
    _directionActionController.stream.listen((int dir) {
      _setDirection(dir);
    });
    _startActionController.stream.listen((bool start) {
      _startOrStop();
    });
  } // ignore: close_sinks

  StreamController<SnackData> _directionController =
      StreamController<SnackData>();

  StreamSink<SnackData> get _outSnackDataSink => _directionController.sink;

  Stream<SnackData> get outSnackData => _directionController.stream;

  //
  // Stream to handle the action on the counter，第二组stream
  //
  // ignore: close_sinks
  StreamController<int> _directionActionController = StreamController();

  // ignore: close_sinks
  StreamController<bool> _startActionController = StreamController();

  StreamSink<int> get inSnackData =>
      _directionActionController.sink; //这个暴露给外部，用户接受ui事件

  StreamSink<bool> get startData =>
      _startActionController.sink; //这个暴露给外部，用户接受ui事件

  void _initSnack() {
    _snackData.food = _createFood();
    _snackData.snackBody = DOT(10, 10, next: DOT(10, 11, next: DOT(10, 12)));
    _direction = direction_up;
    _outSnackDataSink.add(_snackData);
  }

  DOT _createFood() {
    var x = _random.nextInt(20);
    var y = _random.nextInt(20);
    var _current = _snackData.snackBody;
    var containsSnackBody = false;
    while (_current != null) {
      if (x == _current.x && y == _current.y) {
        containsSnackBody = true;
        break;
      }
      _current = _current.next;
    }
    if (containsSnackBody) {
      return _createFood();
    }
    return DOT(x, y);
  }

  void _setDirection(int direction) {
    if (!_started) {
      return;
    }
    switch (direction) {
      case direction_up:
        if (_snackData.snackBody.y > 0) {
          _up();
        }
        break;
      case direction_down:
        if (_snackData.snackBody.y < 20) {
          _down();
        }
        break;
      case direction_left:
        if (_snackData.snackBody.x > 0) {
          _left();
        }
        break;
      case direction_right:
        if (_snackData.snackBody.y < 20) {
          _right();
        }
        break;
    }
  }

  void _up() {
    if (_direction == direction_left || _direction == direction_right) {
      _direction = direction_up;
    }
  }

  void _down() {
    if (_direction == direction_left || _direction == direction_right) {
      _direction = direction_down;
    }
  }

  void _left() {
    if (_direction == direction_up || _direction == direction_down) {
      _direction = direction_left;
    }
  }

  void _right() {
    if (_direction == direction_up || _direction == direction_down) {
      _direction = direction_right;
    }
  }

  void _startOrStop() {
    _started = !_started;
    if (_started) {
      //启动一个线程
      if (_gameOverState) {
        _gameOverState = false;
        _initSnack();
      }
      _nextSnackStep();
    }
  }

  void _nextSnackStep() async {
    switch (_direction) {
      case direction_up:
        if (_snackData.snackBody.y > 0) {
          DOT nextDot = DOT(_snackData.snackBody.x, _snackData.snackBody.y - 1);
          if (nextDot == _snackData.food) {
            _snackData.snackBody = _snackData.snackBody.eat(nextDot);
            _snackData.food = _createFood();
          } else if (!_snackData.snackBody.isBody(nextDot)) {
            _snackData.snackBody = _snackData.snackBody.addUp();
          } else {
            _gameOver();
          }
        } else {
          _gameOver();
        }
        break;
      case direction_down:
        if (_snackData.snackBody.y < 19) {
          DOT nextDot = DOT(_snackData.snackBody.x, _snackData.snackBody.y + 1);
          if (nextDot.x == _snackData.food.x &&
              nextDot.y == _snackData.food.y) {
            _snackData.snackBody = _snackData.snackBody.eat(nextDot);
            _snackData.food = _createFood();
          } else if (!_snackData.snackBody.isBody(nextDot)) {
            _snackData.snackBody = _snackData.snackBody.addDown();
          } else {
            _gameOver();
          }
        } else {
          _gameOver();
        }
        break;
      case direction_left:
        if (_snackData.snackBody.x > 0) {
          DOT nextDot = DOT(_snackData.snackBody.x - 1, _snackData.snackBody.y);
          if (nextDot.x == _snackData.food.x &&
              nextDot.y == _snackData.food.y) {
            _snackData.snackBody = _snackData.snackBody.eat(_snackData.food);
            _snackData.food = _createFood();
          } else if (!_snackData.snackBody.isBody(nextDot)) {
            _snackData.snackBody = _snackData.snackBody.addLeft();
          } else {
            _gameOver();
          }
        } else {
          _gameOver();
        }
        break;
      case direction_right:
        if (_snackData.snackBody.x < 19) {
          DOT nextDot = DOT(_snackData.snackBody.x + 1, _snackData.snackBody.y);
          if (nextDot.x == _snackData.food.x &&
              nextDot.y == _snackData.food.y) {
            _snackData.snackBody = _snackData.snackBody.eat(_snackData.food);
            _snackData.food = _createFood();
          } else if (!_snackData.snackBody.isBody(nextDot)) {
            _snackData.snackBody = _snackData.snackBody.addRight();
          } else {
            _gameOver();
          }
        } else {
          _gameOver();
        }
        break;
    }
    _outSnackDataSink.add(_snackData);
    if (_started) {
      await Future.delayed(Duration(milliseconds: 200));
      _nextSnackStep();
    }
  }

  void _gameOver() {
    _started = false;
    _gameOverState = true;
    Toast.toast(context, "游戏结束");
  }

  @override
  void dispose() {
    _startActionController.close();
    _directionController.close();
    _directionController.close();
    _outSnackDataSink.close();
  }
}

class SnackData {
  DOT snackBody, food;
}

class DOT {
  int x;
  int y;
  DOT next;

  bool isBody(DOT newDot) {
    var current = this;
    while (current != null) {
      if (current == newDot) {
        return true;
      }
      current = current.next;
    }
    return false;
  }

  DOT(this.x, this.y, {this.next}) {
    assert(x >= 0 && y >= 0);
  }

  DOT eat(DOT food) {
    food.next = this;
    return food;
  }

  DOT addUp() {
    removeLast();
    return DOT(x, y - 1, next: this);
  }

  DOT addDown() {
    removeLast();
    return DOT(x, y + 1, next: this);
  }

  DOT addLeft() {
    removeLast();
    return DOT(x - 1, y, next: this);
  }

  DOT addRight() {
    removeLast();
    return DOT(x + 1, y, next: this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DOT &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  void removeLast() {
    var current = this;
    while (current.next?.next != null) {
      current = current.next;
    }
    current.next = null;
  }
}
