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
  
  void render() => onRender();
  
  /** 廃棄する */
  void dispose() {
    onDispose();
    // 次回のrenderで削除
    _isDisposed = true;
  }
}

abstract class GScreen {
  
  void onStart();
  void onPress( PressEvent e );
  void onTimer();
  void onFrontRender( CanvasElement c );
  
}

/**
 * フィールドのPressイベント
 */
class PressEvent {
  MouseEvent  event;
  int x,y;
}


class GEng {
  
  
  final List<GObj>  objlist = new List();
  
  set screen( GScreen s ) {
    Timer.run( () {
      if( s!=null ) {
        onPress = s.onPress;
        onTimer = s.onTimer;
        onFrontRender = s.onFrontRender;
        s.onStart();
      } else {
        onPress = null;
        onTimer = null;
        onFrontRender = null;
      }
    });
  }
  
  var onPress = null;
  var onTimer = null;
  var onFrontRender = null;
  
  // フィールド管理は別クラスにすべきかも
  CanvasElement  canvas = null;
  
  /**
   * フィールドを初期化する
   */
  void initField( { int width:200, int height:200, CanvasElement canvas:null }) {
    
    if( canvas==null )
      canvas = new CanvasElement(width:width, height:height);
    
    // MouseDownからPressイベントを転送
    canvas.onMouseDown.listen( (MouseEvent e) {
      e.preventDefault();
      if( onPress!=null ) {
        var event = new PressEvent()
        ..event = e
        ..x = e.client.x - canvas.offsetLeft
        ..y = e.client.y - canvas.offsetTop;
        onPress(event);
      }
    });
    
    geng.canvas = canvas;
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
  
  void add( GObj obj ) {
    objlist.add(obj);
    obj.onInit();
  }
  
  /**
   * Objを全て破棄する
   */
  void disposeAll() {
    gcObj();
    objlist.forEach( (o)=>o.dispose() );
    gcObj();
    objlist.clear();
  }
  
  Timer _timer;
  
  void startTimer() {
    if( _timer!=null )
      stopTimer();
    
    _timer = new Timer.periodic( const Duration(milliseconds:50), (Timer t) {
      
      if( onTimer!=null ) 
        onTimer();
      
      renderAll();
      gcObj();
      
      if( onFrontRender!=null )
        onFrontRender(canvas);
    });
  }
  
  void stopTimer() {
    if( _timer!=null ) {
      _timer.cancel();
      _timer = null;
    }
  }
}

GEng geng = new GEng();


