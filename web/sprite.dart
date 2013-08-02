part of geng;

/**
 * いわゆるスプライト
 * Mouseイベントもやる必要あるかもねー
 */
abstract class BaseSprite {
  
  num _x=0,_y=0;
  num _w=0,_h=0;
  num _offx=0,_offy=0;
  
  Element _el;
  
  /** 横幅 */
  num get width => _w;
      set width( num w ) {
        _w = w;
        _el.style.width = "${w}px";
        _rect=null;
      }
  
  /** 高さ */
  num get height=> _h;
      set height( num h ) {
        _h = h;
        _el.style.height = "${h}px";
        _rect=null;
      }
  
  
  /** x座標 */
  num get x => _x;
      set x( num n ) {
        _x = n;
        _el.style.left = "${n-_offx}px";
        _rect=null;
      }
      
  /** y座標 */
  num get y => _y;
      set y( num n ) {
        _y = n;
        _el.style.top = "${n-_offy}px";
        _rect=null;
      }
  
  /** as Element */
  Element get element => _el;
  
  /** get as Rect */
  Rect get rect {
    if( _rect==null ) {
      num x = _x - _offx;
      num y = _y - _offy;
      _rect = new Rect( x,y, width, height );
    }
    return _rect;
  }
  Rect  _rect = null;
  
  void show() {
    _el.style.visibility = "visible";
  }
  
  void hide() {
    _el.style.visibility = "hidden";
  }
}

/**
 * いわゆるスプライト
 * Mouseイベントもやる必要あるかもねー
 */
class Sprite extends BaseSprite {
  
  Sprite( { String src:null, num width:10, num height:10 } ) {
    
    _el = new ImageElement();
    _el.style.position = "absolute";
    
    this.width = width;
    this.height = height;
    
    // オフセット
    _offx = (width / 2).toInt();
    _offy = (height / 2).toInt();

    if( src !=null )
      _imgel.src = src;
  }
  
  ImageElement get _imgel => _el as ImageElement;
  
  /** 画像のsrcを設定 */
  set src( String url ) => _imgel.src = url;
  
}

class TextSprite extends BaseSprite {
  
  TextSprite() {
    _el = new DivElement();
    _el.style.position = "absolute";
    _el.style.color = "RED";
  }
  
  set text( String text ) {
    _el.text = text;
    Timer.run( () {
      _rect = null;
      _offx = _el.clientWidth / 2;
      _offy = _el.clientHeight / 2;
    });
  }
}


class PressHandler {
  
  var _onMouseDown = null;
  var _onPress;
  
  
  PressHandler( void onPress(int x, int y) ) {
    _onPress = onPress;
  }
  
  /** Elementに接続する */
  void connectTo( Element el ) {
    
    disconnect();
    
    // マウスイベント
    _onMouseDown = el.onMouseDown.listen( (MouseEvent e) {
      e.preventDefault();
      var x = e.client.x - el.offsetLeft;
      var y = e.client.y - el.offsetTop;
      _onPress( x, y );
    });
    el.onDrag.listen((e) {
      print("drag??");
    });
  }
  
  /** Elementから切断する */
  void disconnect() {
    if( _onMouseDown!=null )
      _onMouseDown.cancel();
  }
  
}

class MoveHandler {
  
  var _onMouseMove = null;
  var _onMove;
  var _onOut;
  
  MoveHandler( void onMove(int x, int y),{ void onOut() }) {
    _onMove = onMove;
    _onOut = onOut;
  }
  
  /** Elementに接続する */
  void connect( Element el ) {
    
    disconnect();
    
    // マウスイベント
    _onMouseMove = el.onMouseMove.listen( (MouseEvent e) {
      var x = e.client.x - el.offsetLeft;
      var y = e.client.y - el.offsetTop;
      _onMove( x, y );  
    });
    el.onMouseOut.listen( (MouseEvent e) {
      if( _onOut!=null )
        _onOut();
    });
  }
  
  /** Elementから切断する */
  void disconnect() {
    if( _onMouseMove!=null )
      _onMouseMove.cancel();
  }
}
