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
  CanvasElement  canvas = null;
  
  void initField( int w, int h ) {
    canvas = new CanvasElement(width: w, height: h);
  }
  
  /** フィールドの大きさ */
  Rect get rect {
    if( _rect==null ) {
      var w = canvas.clientWidth;
      var h = canvas.clientHeight;
      _rect = new Rect(0,0,w,h);
    }
    return _rect;
  }
  Rect  _rect;
  
  /**
   * スプライトをrender
   */
  void render( Sprite spr ) {
    spr.render(canvas);
  }
  
  /**
   * 全てをrenderする
   */
  void renderAll() {
    canvas.context2D.clearRect(0,0, rect.width, rect.height);
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


