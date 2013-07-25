import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';

/**
 * Learn about the Web UI package by visiting
 * http://www.dartlang.org/articles/dart-web-components/.
 */
void main() {
  
  Element player = query("#player");
  
  Timer.run( () {
    player.text = "test";
    new Timer.periodic( const Duration(milliseconds:200), (t) {
      down(player);
    });
  });
}

int y = 0;
void down( Element e ) {
  y += 1;
  e.style.top = "${y}px";
  
}