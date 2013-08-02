library geng;

import 'dart:html';
import 'dart:async';

part 'sprite.dart';


/**
 * 物体ひとつ
 * 定義は…
 */
abstract class GObj {
  
  /** 廃棄済みフラグ */
  bool  _isDisposed = false;
  
  /** Disposeされたかどうか */
  bool get isDisposed => _isDisposed;
  
  // オーバーライドすべきメソッド ---
  
  /** 最初に呼ばれる */
  void onInit();
  
  /** レンダリング */
  void onRender();
  
  /** 最後に呼ばれる */
  void onDispose();
  
  // 操作するためのメソッド ---
  
  /** 初期化する */
  void init() {
    geng.objlist.add(this);
    onInit();
  }
  
  void render() => onRender();
  
  /** 廃棄する */
  void dispose() {
    onDispose();
    // 次回のrenderで削除
    _isDisposed = true;
  }
}

class GEng {
  
  final List<GObj>  objlist = new List();
  
  // フィールド管理は別クラスにすべきかも
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
  
  /** フィールドの大きさ */
  Rect get rect {
    if( _rect==null ) {
      var w = _element.clientWidth;
      var h = _element.clientHeight;
      _rect = new Rect(0,0,w,h);
    }
    return _rect;
  }
  Rect  _rect;
  
  
  /**
   * 全てをrenderする
   */
  void renderAll() {
    objlist
    .where( (v) => v.isDisposed==false )
    .forEach( (GObj v)=> v.render() );
  }
  
  /**
   * DisposeされたGObjを廃棄する
   */
  void gcObj() {
    objlist.removeWhere( (v) => v.isDisposed );
  }
}

GEng geng = new GEng();


