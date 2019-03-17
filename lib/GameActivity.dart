import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/classes/BoardSquare.dart';

enum ImageType {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  bomb,
  bombStepped,
  facingDown,
  flagged,
  flaggedWrong,
}

class GameActivity extends StatefulWidget {
  @override
  _GameActivityState createState() => _GameActivityState();
}

class _GameActivityState extends State<GameActivity> {
  int rowCount = 14;
  int columnCount = 10;
  int bombProbability = 3;
  int maxProbability = 21;
  int bombsCount = 0;
  List<bool> openedSquares;
  List<bool> flaggedSquares;
  int squaresLeft = 0;
  int steppedMine = 0;

  List<List<BoardSquare>> board;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("MineSweeper"),
        ),
        body: ListView(children: <Widget>[
          Container(
            color: Colors.grey,
            height: 60.0,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text((bombsCount - flaggedSquares.where((f) => f).length).toString() + " bombs remaining"),
                InkWell(
                  onTap: () {
                    _initializeGame();
                  },
                  child: CircleAvatar(
                    child: Icon(
                      Icons.tag_faces,
                      color: Colors.black,
                      size: 40.0,
                    ),
                    backgroundColor: Colors.yellowAccent,
                  ),
                )
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            primary: true,
            physics: new NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
            ),
            itemBuilder: (context, position) {
              // Get row and column number of square
              int rowNumber = (position / columnCount).floor();
              int columnNumber = (position % columnCount);

              Image image;

              if (flaggedSquares[position] == true) {
                image = getImage(ImageType.flagged);
                if (openedSquares[position] == true &&
                    !board[rowNumber][columnNumber].hasBomb) {
                  image = getImage(ImageType.flaggedWrong);
                }
              } else {
                if (openedSquares[position] == false) {
                  image = getImage(ImageType.facingDown);
                } else {
                  if (board[rowNumber][columnNumber].hasBomb) {
                    if (steppedMine == position) {
                      image = getImage(ImageType.bombStepped);
                    } else {
                      image = getImage(ImageType.bomb);
                    }
                  } else {
                    image = getImage(
                      getImageTypeFromNumber(
                          board[rowNumber][columnNumber].bombsAround),
                    );
                  }
                }
              }

              return InkWell(
                // Opens square
                onTap: () {
                  if (board[rowNumber][columnNumber].hasBomb) {
                    steppedMine = position;
                    _handleLose();
                  }
                  if (board[rowNumber][columnNumber].bombsAround == 0) {
                    _handleTap(rowNumber, columnNumber);
                  } else {
                    setState(() {
                      openedSquares[position] = true;
                      squaresLeft = squaresLeft - 1;
                    });
                  }

                  if (squaresLeft <= bombsCount) {
                    _handleWin();
                  }
                },
                // Flags square
                onLongPress: () {
                  if (openedSquares[position] == false) {
                    setState(() {
                      flaggedSquares[position] = !flaggedSquares[position];
                    });
                  }
                },
                splashColor: Colors.grey,
                child: Container(
                  color: Colors.grey,
                  child: image,
                ),
              );
            },
            itemCount: rowCount * columnCount,
          )
        ]));
  }

  void _initializeGame() {
    bombsCount = 0;
    steppedMine = 0;

    board = List.generate(rowCount, (i) {
      return List.generate(columnCount, (j) {
        return BoardSquare();
      });
    });

    squaresLeft = rowCount * columnCount;

    Random random = new Random();

    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < columnCount; j++) {
        int randomNumber = random.nextInt(maxProbability);

        if (randomNumber < bombProbability) {
          board[i][j].hasBomb = true;
          bombsCount++;
        }
      }
    }

    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < columnCount; j++) {
        if (i > 0 && j > 0) {
          if (board[i - 1][j - 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i > 0) {
          if (board[i - 1][j].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i > 0 && j < columnCount - 1) {
          if (board[i - 1][j + 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (j > 0) {
          if (board[i][j - 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (j < columnCount - 1) {
          if (board[i][j + 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i < rowCount - 1 && j > 0) {
          if (board[i + 1][j - 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i < rowCount - 1) {
          if (board[i + 1][j].hasBomb) {
            board[i][j].bombsAround++;
          }
        }

        if (i < rowCount - 1 && j < columnCount - 1) {
          if (board[i + 1][j + 1].hasBomb) {
            board[i][j].bombsAround++;
          }
        }
      }
    }

    openedSquares = List.generate(rowCount * columnCount, (i) => false);
    flaggedSquares = List.generate(rowCount * columnCount, (i) => false);

    setState(() {});
  }

  void _handleTap(int i, int j) {
    int position = (i * columnCount) + j;
    openedSquares[position] = true;
    squaresLeft--;

    if (i > 0 &&
        !board[i - 1][j].hasBomb &&
        openedSquares[((i - 1) * columnCount) + j] != true &&
        board[i][j].bombsAround == 0) {
      _handleTap(i - 1, j);
    }

    if (j > 0 &&
        !board[i][j - 1].hasBomb &&
        openedSquares[(i * columnCount) + j - 1] != true &&
        board[i][j].bombsAround == 0) {
      _handleTap(i, j - 1);
    }

    if (j < columnCount - 1 &&
        !board[i][j + 1].hasBomb &&
        openedSquares[(i * columnCount) + j + 1] != true &&
        board[i][j].bombsAround == 0) {
      _handleTap(i, j + 1);
    }

    if (i < rowCount - 1 &&
        !board[i + 1][j].hasBomb &&
        openedSquares[((i + 1) * columnCount) + j] != true &&
        board[i][j].bombsAround == 0) {
      _handleTap(i + 1, j);
    }

    if (i > 0 &&
        j > 0 &&
        !board[i - 1][j - 1].hasBomb &&
        openedSquares[((i - 1) * columnCount) + j - 1] != true &&
        board[i][j].bombsAround == 0) {
      _handleTap(i - 1, j - 1);
    }

    if (i > 0 &&
        j < columnCount - 1 &&
        !board[i - 1][j + 1].hasBomb &&
        openedSquares[((i - 1) * columnCount) + j + 1] != true &&
        board[i][j].bombsAround == 0) {
      _handleTap(i - 1, j + 1);
    }

    if (i < rowCount - 1 &&
        j < columnCount - 1 &&
        !board[i + 1][j + 1].hasBomb &&
        openedSquares[((i + 1) * columnCount) + j + 1] != true &&
        board[i][j].bombsAround == 0) {
      _handleTap(i + 1, j + 1);
    }

    if (i < rowCount - 1 &&
        j > 0 &&
        !board[i + 1][j - 1].hasBomb &&
        openedSquares[((i + 1) * columnCount) + j - 1] != true &&
        board[i][j].bombsAround == 0) {
      _handleTap(i + 1, j - 1);
    }

    setState(() {});
  }

  void _handleWin() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Congratulations!"),
          content: Text("You Win!"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _initializeGame();
                Navigator.pop(context);
              },
              child: Text("Play again"),
            ),
          ],
        );
      },
    );
  }

  void _handleLose() {
    openedSquares = List.generate(columnCount * rowCount, (i) => true);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over!"),
          content: Text("You stepped on a mine!"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _initializeGame();
                Navigator.pop(context);
              },
              child: Text("Play again"),
            ),
          ],
        );
      },
    );
  }

  Image getImage(ImageType type) {
    switch (type) {
      case ImageType.zero:
        return Image.asset('images/0.png');
      case ImageType.one:
        return Image.asset('images/1.png');
      case ImageType.two:
        return Image.asset('images/2.png');
      case ImageType.three:
        return Image.asset('images/3.png');
      case ImageType.four:
        return Image.asset('images/4.png');
      case ImageType.five:
        return Image.asset('images/5.png');
      case ImageType.six:
        return Image.asset('images/6.png');
      case ImageType.seven:
        return Image.asset('images/7.png');
      case ImageType.eight:
        return Image.asset('images/8.png');
      case ImageType.bomb:
        return Image.asset('images/bomb.png');
      case ImageType.bombStepped:
        return Image.asset('images/bombStepped.png');
      case ImageType.facingDown:
        return Image.asset('images/facingDown.png');
      case ImageType.flagged:
        return Image.asset('images/flagged.png');
      case ImageType.flaggedWrong:
        return Image.asset('images/flaggedWrong.png');
      default:
        return null;
    }
  }

  ImageType getImageTypeFromNumber(int number) {
    switch (number) {
      case 0:
        return ImageType.zero;
      case 1:
        return ImageType.one;
      case 2:
        return ImageType.two;
      case 3:
        return ImageType.three;
      case 4:
        return ImageType.four;
      case 5:
        return ImageType.five;
      case 6:
        return ImageType.six;
      case 7:
        return ImageType.seven;
      case 8:
        return ImageType.eight;
      default:
        return null;
    }
  }
}
