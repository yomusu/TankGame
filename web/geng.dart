library geng;

import 'dart:html';
import 'dart:async';

part 'sprite.dart';


/**
 * 物体ひとつ
 * 定義は…
 */
abstract class GObj {
  
  // オーバーライドすべきメソッド ---
  
  /** 最初に呼ばれる */
  void onInit();
  
  /** 最後に呼ばれる */
  void onDispose();
  
  // 操作するためのメソッド ---
  
  void init() => onInit();
  
  void dispose() => onDispose();
  
}

class GEng {
  
  final List<GObj>  objlist = new List();
  
  Element  _element = null;
  
  void initField( int w, int h ) {
    var el = new DivElement();
    el.style.width = "${w}px";
    el.style.height= "${h}px";
    el.style.position="relative";
    el.style.overflow="hidden";
    
    _element = el;
  }
  
  Element get element => _element;
  
  Rect get rect {
    if( _rect==null ) {
      var w = _element.clientWidth;
      var h = _element.clientHeight;
      _rect = new Rect(0,0,w,h);
    }
    return _rect;
  }
  Rect  _rect;
}

GEng geng = new GEng();


