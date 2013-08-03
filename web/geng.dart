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

/**
 * フィールドのPressイベント
 */
class PressEvent {
  MouseEvent  event;
  int x,y;
}

class GEng {
  
  /** ClickもしくはTouchのイベント */
  Stream<PressEvent>  onPress;

  final List<GObj>  objlist = new List();
  
  // フィールド管理は別クラスにすべきかも
  CanvasElement  canvas = null;
  
  // 
  StreamController<PressEvent> _onPressCont = new StreamController();
  
  GEng() {
    onPress = _onPressCont.stream.asBroadcastStream();
  }
  
  /**
   * フィールドを初期化する
   */
  void initField( int w, int h ) {
    
    canvas = new CanvasElement(width: w, height: h);
    
    // MouseDownからPressイベントを転送
    canvas.onMouseDown.listen( (MouseEvent e) {
      e.preventDefault();
      var event = new PressEvent()
      ..event = e
      ..x = e.client.x - canvas.offsetLeft
      ..y = e.client.y - canvas.offsetTop;
      _onPressCont.add(event);
//      print("offsetLeft=${el.offsetLeft} e.client=${e.client}");
    });
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


