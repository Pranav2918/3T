import 'package:flutter/material.dart';
import 'package:tic_tac_toe/tile_state.dart';
import 'package:tic_tac_toe/utils/images.dart';
import 'package:tic_tac_toe/utils/strings.dart';

import 'board_tile.dart';

void main() {
  runApp(TicTacToe());
}

class TicTacToe extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  final navigatorKey = GlobalKey<NavigatorState>();
  var _boardState = List.filled(9, TileState.EMPTY);
  var _currentTurn = TileState.CROSS;
  int _totalFilledIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IconButton(
                    tooltip: AppStrings.restart,
                    icon: Icon(
                      Icons.refresh,
                      size: 28,
                    ),
                    color: Color.fromRGBO(255, 0, 21, 0.9),
                    onPressed: _resetGame,
                  ),
                )
              ],
              elevation: 0.0,
              backgroundColor: Colors.white,
              title: Text(
                AppStrings.title,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )),
          body: Center(
            child: SingleChildScrollView(
              child: Stack(children: [
                Image.asset(Images.board),
                _boardTiles(),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  //For Each Tile
  Widget _boardTiles() {
    return Builder(builder: (context) {
      final boardDimension = MediaQuery.of(context).size.width;
      final tileDimension = boardDimension / 3;

      return Container(
          width: boardDimension,
          height: boardDimension,
          child: Column(
              children: chunk(_boardState, 3).asMap().entries.map((entry) {
            final chunkIndex = entry.key;
            final tileStateChunk = entry.value;

            return Row(
              children: tileStateChunk.asMap().entries.map((innerEntry) {
                final innerIndex = innerEntry.key;
                final tileState = innerEntry.value;
                final tileIndex = (chunkIndex * 3) + innerIndex;

                return BoardTile(
                  
                  tileState: tileState,
                  dimension: tileDimension,
                  onPressed: () => _updateTileStateForIndex(tileIndex),
                );
              }).toList(),
            );
          }).toList()));
    });
  }

  //To Perform Clicks
  void _updateTileStateForIndex(int selectedIndex) {
    if (_boardState[selectedIndex] == TileState.EMPTY) {
      setState(() {
        _boardState[selectedIndex] = _currentTurn;
        _currentTurn = _currentTurn == TileState.CROSS
            ? TileState.CIRCLE
            : TileState.CROSS;
        _totalFilledIndex++;    
      });

      final winner = _findWinner();
      if (winner != null) {
        _showWinnerDialog(winner);
      }else if(winner == null && _totalFilledIndex == 9){
        _showDrawDialog();
      }
    }
  }

  //Find Winner
  TileState? _findWinner() {
    TileState? Function(int, int, int) winnerForMatch = (a, b, c) {
      if (_boardState[a] != TileState.EMPTY) {
        if ((_boardState[a] == _boardState[b]) &&
            (_boardState[b] == _boardState[c])) {
          return _boardState[a];
        }
      }

      return null;
    };

    //Winning Possibilities
    final checks = [
      winnerForMatch(0, 1, 2),
      winnerForMatch(3, 4, 5),
      winnerForMatch(6, 7, 8),
      winnerForMatch(0, 3, 6),
      winnerForMatch(1, 4, 7),
      winnerForMatch(2, 5, 8),
      winnerForMatch(0, 4, 8),
      winnerForMatch(2, 4, 6),
    ];

    TileState? winner;

    for (int i = 0; i < checks.length; i++) {
      if (checks[i] != null) {
        winner = checks[i]!;
        break;
      }
    }

    return winner;
  }

  //Dialog
  void _showWinnerDialog(TileState tileState) {
    final context = navigatorKey.currentState?.overlay?.context;
    showDialog(
        context: context!,
        builder: (_) {
          return AlertDialog(
            title: Text(AppStrings.winner),
            content: Image.asset(tileState == TileState.CROSS
                ? Images.crossImage
                : Images.circleImage),
            actions: [
              // ignore: deprecated_member_use
              TextButton(
                  onPressed: () {
                    _resetGame();
                    Navigator.of(context).pop();
                  },
                  child: Text(AppStrings.newGame))
            ],
          );
        });
  }

  //Draw Dialog
  void _showDrawDialog() {
    final context = navigatorKey.currentState?.overlay?.context;
    showDialog(
        context: context!,
        builder: (_) {
          return AlertDialog(
            title: Text(AppStrings.matchTie),
            content: Image.asset(Images.tie),
            actions: [
              TextButton(
                  onPressed: () {
                    _resetGame();
                    Navigator.of(context).pop();
                  },
                  child: Text(AppStrings.newGame))
            ],
          );
        });
  }

  //Reset Game
  void _resetGame() {
    setState(() {
      _boardState = List.filled(9, TileState.EMPTY);
      _currentTurn = TileState.CROSS;
      _totalFilledIndex = 0;
    });
  }
}
