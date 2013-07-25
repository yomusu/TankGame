library geng;

import 'dart:html';
import 'dart:async';



class GObj {
  
  static const int  ST_INIT = 0;
  static const int  ST_RUN = 1;
  static const int  ST_END = 2;
  
  /** staus of this obj */
  int status = ST_INIT;
  
  // オーバーライドすべきメソッド ---
  
  /** 最初に呼ばれる */
  void onInit() {}
  
  /** 毎回呼ばれる */
  void onFrame( FrameInfo frame ) {}
  
  // 操作するためのメソッド ---
  
  /** 自分を終了する */
  void finish() {
    status = ST_END;
  }
}

class GEng {
  
  final List<GObj>  objlist = new List();
  Element  topElement = null;
  
  FrameInfo frameInfo = new FrameInfo();
  
  void frame_all() {
    
    for( GObj o in objlist ) {
      if( o.status==GObj.ST_INIT ) {
        o.onInit();
        o.status = GObj.ST_RUN;
      }
      if( o.status==GObj.ST_RUN )
        o.onFrame( frameInfo );
    }
  }
}

class FrameInfo {
  
}

GEng geng = new GEng();
