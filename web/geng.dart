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

abstract class BtnObj extends GObj {
  
  num x = 320;
  num y = 180;
  num width = 100;
  num height= 50;
  
  num get left => x - (width/2);
  num get top  => y - (height/2);
  
  var onPress = null;
  
  bool  isOn = false;
  bool  isPress = false;
  

  bool isIn( num mx, num my ) {
    var xx = mx - left;
    var yy = my - top;
    bool  inH = ( xx>=0 && xx<width );
    bool  inV = ( yy>=0 && yy<height);
    
    return ( inH && inV );
  }
  
  void handleMoveEvent( var e ) {
    isOn = isIn( e.x, e.y );
  }

}

abstract class GScreen {
  
  // メンバ変数 ---
  
  /** 毎フレームの処理 */
  var onProcess = null;
  /** 最前面描画 */
  var onFrontRender = null;
  /** 入力デバイスのプレスイベント */
  var onPress = null;
  
  // オーバーライドすべきメソッド ---

  /** スタート処理:You can override this method. */
  void onStart();
  
  /** List of Buttons */ 
  List<BtnObj>  btnList = null;
  
  /** entry button to list */ 
  void entryButton( BtnObj btn ) {
    if( btnList==null )
      btnList = new List();
    btnList.add(btn);
    // update press handler!!
    onPress = _onPressForBtn;
  }
  
  void _onPressForBtn(PressEvent e) {
    btnList.forEach( (BtnObj b) {
      if( b.isIn( e.x, e.y ) ) {
        b.isPress = true;
        if( b.onPress!=null )
          b.onPress();
      }
    });
  }
  
  // Gengとのやりとり ---

  /** マウスボタンのハンドル */
  void onMouseDown(MouseEvent e) {
    e.preventDefault();
    if( onPress!=null ) {
      var event = new PressEvent()
      ..event = e
      ..x = e.client.x - geng.canvas.offsetLeft
      ..y = e.client.y - geng.canvas.offsetTop;
      onPress(event);
    }
  }
  
  /** フレームのTimerハンドル */
  void onTimer() {
    // 毎フレームの処理
    if( onProcess!=null )
      onProcess();
    // 全てレンダー
    geng.renderAll();
    geng.gcObj();
    // 最前面の描画
    if( onFrontRender!=null )
      onFrontRender(geng.canvas);
  }
  
}

/**
 * フィールドのPressイベント
 */
class PressEvent {
  MouseEvent  event;
  int x,y;
}


/**************
 * 
 * Game Engine
 * 
 */
class GEng {
  
  
  final List<GObj>  objlist = new List();
  GScreen _screen = null;
  
  /** 使用するScreenのセット */
  set screen( GScreen s ) {
    Timer.run( () {
      _screen = s;
      if( s!=null )
        s.onStart();
    });
  }
  
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
      if( _screen!=null )
        _screen.onMouseDown(e);
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
  
  /**
   * Objの追加
   */
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
  
  /**
   * フレームタイマーをスタートする
   */
  void startTimer() {
    
    if( _timer!=null )
      stopTimer();
    
    _timer = new Timer.periodic( const Duration(milliseconds:50), (Timer t) {
      if( _screen!=null ) 
        _screen.onTimer();
    });
  }
  
  /**
   * フレームタイマーを停止する
   */
  void stopTimer() {
    if( _timer!=null ) {
      _timer.cancel();
      _timer = null;
    }
  }
}

GEng geng = new GEng();


