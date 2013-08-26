library geng;

import 'dart:html';
import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

part 'sprite.dart';
part 'canvasutil.dart';

final String  fontFamily = '"ヒラギノ角ゴ Pro W3", "Hiragino Kaku Gothic Pro", Meiryo, "メイリオ", "ＭＳ Ｐゴシック", Verdana, Geneva, Arial, Helvetica';

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
  void onProcess( RenderList renderList );
  
  /** 最後に呼ばれる */
  void onDispose();
  
  // 操作するためのメソッド ---
  
  void process( RenderList renderList ) => onProcess( renderList );
  
  /** 廃棄する */
  void dispose() {
    onDispose();
    // 次回のrenderで削除
    _isDisposed = true;
  }
}

abstract class BtnObj extends GObj {
  
  static const int  HIDDEN = -1;
  static const int  DISABLE= 0;
  static const int  ACTIVE = 1;
  static const int  ROLLON = 3;
  static const int  PRESSED= 7;
  
  num x = 320;
  num y = 180;
  num width = 100;
  num height= 50;
  
  num get left => x - (width/2);
  num get top  => y - (height/2);
  
  /** Z値 */
  num z = 1000;
  
  var onPress = null;
  
  bool  isOn = false;
  bool  isPress = false;
  bool  isVisible = true;
  bool  isEnable = true;

  bool isIn( num mx, num my ) {
    
    if( isVisible==false )
      return false;
    if( isEnable==false )
      return false;
    
    var xx = mx - left;
    var yy = my - top;
    bool  inH = ( xx>=0 && xx<width );
    bool  inV = ( yy>=0 && yy<height);
    
    return ( inH && inV );
  }
  
  void onProcess( RenderList renderList ) {
    var s = status;
    if( s!=HIDDEN )
      renderList.add(z, (c)=>render(c,s) );
  }
  
  int get status {
    
    if( isVisible==false )
      return HIDDEN;
    if( isEnable==false )
      return DISABLE;
    
    if( isPress )
      return PRESSED;
    if( isOn )
      return ROLLON;
    
    return ACTIVE;
  }
  
  void render( CanvasElement canvas, int status ) {
  }
}

class PlayButton extends BtnObj {
  
  String  text;
  
  Color bgCl_normal = new Color.fromString("#eeeeee");
  Color bgCl_on     = new Color.fromString("#00ee00");
  Color bgCl_press  = new Color.fromString("#ee0000");
  
  var tren = new TextRender()
  ..fontFamily = fontFamily
  ..fontSize = "14pt"
  ..textAlign = "center"
  ..textBaseline = "middle"
  ..fillColor = Color.Black
  ..strokeColor = null;
  
  void onInit() { }
  
  void render( CanvasElement canvas, int status ) {
    var c = canvas.context2D;
    
    var textCl = Color.Black;
    var bgcl = bgCl_normal;
    switch( status ) {
      case BtnObj.DISABLE:
        textCl = Color.Gray;
        break;
      case BtnObj.ACTIVE:
        break;
      case BtnObj.PRESSED:
        bgcl = bgCl_press;
        break;
      case BtnObj.ROLLON:
        bgcl = bgCl_on;
        break;
    }
    
    c.beginPath();
    c.setFillColorRgb( bgcl.r, bgcl.g, bgcl.b );
    c.rect(left, top, width, height);
    c.fill();
    
    if( text!=null ) {
      tren.canvas = canvas;
      tren.fillColor = textCl;
      tren.drawTexts([text], x, y);
      tren.canvas = null;
    }
  }
  
  void onDispose() { }
  
}

/**
 * 画面の基本クラス
 */
abstract class GScreen {
  
  // メンバ変数 ---
  
  /** 毎フレームの処理 */
  var onProcess = null;
  /** 最前面描画 */
  var onFrontRender = null;
  /** 入力デバイスのプレスイベント */
  var onPress = null;
  var onMove = null;
  var onMoveOut = null;
  
  // オーバーライドすべきメソッド ---

  /** スタート処理:You can override this method. */
  void onStart();
  
  // ボタン処理 -------------------
  
  /** List of Buttons */ 
  List<BtnObj>  btnList = null;
  
  /** entry button to list */ 
  void entryButton( BtnObj btn ) {
    if( btnList==null )
      btnList = new List();
    btnList.add(btn);
    // update press handler!!
    onPress = _onPressForBtn;
    onMove = _onMouseMoveForBtn;
  }
  
  // entryされたボタンすべてに対しPress処理をする
  void _onPressForBtn(PressEvent e) {
    btnList.where( (b) => b.isPress==false )
    .forEach( (BtnObj b) {
      if( b.isIn( e.x, e.y ) ) {
        b.isPress = true;
        if( b.onPress!=null )
          b.onPress();
      }
    });
  }
  // entryされたボタンすべてに対しMove処理をする
  void _onMouseMoveForBtn( int x, int y ) {
    btnList.where( (b) => b.isPress==false )
    .forEach( (BtnObj b) {
      b.isOn = b.isIn( x, y );
    });
  }
  
  // Gengとのやりとり ---

  /** フレームのTimerハンドル */
  void onTimer() {
    // 毎フレームの処理
    if( onProcess!=null )
      onProcess();
    // 全てレンダー
    geng.processAll();
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
  int x,y;
}

/** 最終的にレンダリングするFunction */
typedef void Render( CanvasElement canvas );

/**
 * レンダリングのオーダリングリスト
 */
class RenderList {
  
  final SplayTreeMap<num,Render>  _list;
  
  RenderList() :
    _list = new SplayTreeMap( (k1,k2) {
      var r = k1.compareTo(k2);
      return ( r==0 ) ? 1 : r;
    });
  
  void clear() {
    _list.clear();
  }
  void add( num z, Render r ) {
    _list[z] = r;
  }
  
  void renderAll( CanvasElement canvas ) {
    _list.values.forEach( (r)=> r(canvas) );
  }
}

/****
 * 
 * Imageを読み込み、格納する
 * 
 */
class ImageMap {
  
  final Map<String,ImageElement>  map = new Map();
  
  void put( String key, String src ) {
    var img = new ImageElement()
    ..src = src;
    
    map[key] = img;
    
    // onLoadは効くのか？読み込み完了を待つ必要があるかどうか
    img.onLoad.listen( (v)=>print("loaded image : $key") ); 
  }
  
  ImageElement operator [](Object key) => map[key];
  
  void operator []=(String k, ImageElement v) {
    map[k] = v;
  }
  
}


/**************
 * 
 * Game Engine
 * 
 */
class GEng {
  
  // Private Member --------
  
  GScreen _screen = null;
  /** 追加オブジェクトのバッファ */
  final List<GObj>  _addObjlist = new List();
  
  // Property --------
  
  /** オブジェクトのリスト */
  final List<GObj>  objlist = new List();
  // フィールド管理は別クラスにすべきかも
  CanvasElement  canvas = null;
  
  final ImageMap  imageMap = new ImageMap();
  
  // setter/getter --------
  
  /** 使用するScreenのセット */
  set screen( GScreen s ) {
    Timer.run( () {
      _screen = s;
      if( s!=null )
        s.onStart();
    });
  }
  
  /**
   * フィールドを初期化する
   */
  void initField( { int width:200, int height:200, CanvasElement canvas:null }) {
    
    if( canvas==null )
      canvas = new CanvasElement(width:width, height:height);
    
    // MouseDownからPressイベントを転送
    canvas.onMouseDown.listen( (MouseEvent e) {
      if( _screen!=null && _screen.onPress!=null ) {
        e.preventDefault();
        var event = new PressEvent()
        ..x = e.client.x - geng.canvas.offsetLeft
        ..y = e.client.y - geng.canvas.offsetTop;
        _screen.onPress(event);
      }
    });
    canvas.onMouseMove.listen( (MouseEvent e) {
      if( _screen!=null && _screen.onMove!=null ) {
        var x = e.client.x - geng.canvas.offsetLeft;
        var y = e.client.y - geng.canvas.offsetTop;
        _screen.onMove( x, y );
      }
    });
    canvas.onMouseOut.listen( (MouseEvent e) {
      if( _screen!=null && _screen.onMoveOut!=null )
        _screen.onMoveOut();
    });
    canvas.onTouchStart.listen( (TouchEvent e) {
      if( _screen!=null && _screen.onPress!=null ) {
        e.preventDefault();
        var event = new PressEvent()
        ..x = e.touches[0].client.x - geng.canvas.offsetLeft
        ..y = e.touches[0].client.y - geng.canvas.offsetTop;
        _screen.onPress(event);
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
  
  final RenderList  _renderList = new RenderList();
  
  /**
   * 全てのオブジェクトをProcessしてrenderする
   */
  void processAll() {
    
    // 追加オブジェクトリストを本物のリストに追加
    objlist.addAll( _addObjlist );
    _addObjlist.clear();
    
    // Do Processing every object
    objlist.where( (v) => v.isDisposed==false )
    .forEach( (GObj v)=> v.process(_renderList) );
    
    // Do Rendering
    canvas.context2D.clearRect(0,0, rect.width, rect.height);
    _renderList.renderAll( canvas );
    // 終わったら削除
    _renderList.clear();
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
    _addObjlist.add(obj);
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


