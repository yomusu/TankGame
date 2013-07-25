import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';

import 'geng.dart';


Tank  tank;

void main() {
  
  geng.topElement = query("#field");
  
  tank = new Tank();
  
  geng.objlist.add( tank );
  geng.objlist.add( new Button() );
  
  Timer.run( () {
    new Timer.periodic( const Duration(milliseconds:200), (t) {
      geng.frame_all();
    });
  });
}


class Tank extends GObj {
  
  Sprite p;
  
  void onInit() {
    p = new Sprite( src:"../octocat.png" );
    p.width = 100;
    p.height = 100;
    geng.topElement.append( p.element );
  }
  
  void onFrame( FrameInfo info ) {
    p.x += 1;
    p.y += 1;
  }
}

class Button extends GObj {
  
  Element p;
  bool  isPress;
  
  void onInit() {
    p = query("#btn_right");
    p.onMouseDown.listen( (MouseEvent e) {
      tank.p.x += 2;
    });
  }
  
}
