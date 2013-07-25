import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';

import 'geng.dart';


void main() {
  
  Element player = query("#player");
  
  geng.objlist.add( new Tank() );
  
  Timer.run( () {
    player.text = "test";
    new Timer.periodic( const Duration(milliseconds:200), (t) {
      geng.frame_all();
    });
  });
}

class Tank extends GObj {
  Element p;
  int y = 0;
  void onInit() {
    p = query("#player");
  }
  void onFrame( FrameInfo info ) {
    y++;
    p.style.top = "${y}px";
  }
}
