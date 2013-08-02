part of geng;

/**
 * いわゆるスプライト
 * Mouseイベントもやる必要あるかもねー
 */
class Sprite {
  
  num _x=0,_y=0;
  num _w=0,_h=0;
  
  Point offset = new Point(0,0);
  
  ImageElement _img;
  
  Sprite( { String src:null, num width:10, num height:10 } ) {
    _img = new ImageElement();
    if( src !=null )
      _img.src = src;
    _w = width;
    _h = height;
  }
  
  void render( CanvasElement canvas ) {
    var c = canvas.context2D;
    var x = _x - offset.x;
    var y = _y - offset.y;
    c.drawImageScaled(_img, x, y, _w, _h);
  }
  
  /** 横幅 */
  num get width => _w;
      set width( num w ) {
        _w = w;
        _rect=null;
      }
  
  /** 高さ */
  num get height=> _h;
      set height( num h ) {
        _h = h;
        _rect=null;
      }
  
  
  /** x座標 */
  num get x => _x;
      set x( num n ) {
        _x = n;
        _rect=null;
      }
      
  /** y座標 */
  num get y => _y;
      set y( num n ) {
        _y = n;
        _rect=null;
      }
  
  /** get as Rect */
  Rect get rect {
    if( _rect==null ) {
      num x = _x - offset.x;
      num y = _y - offset.y;
      _rect = new Rect( x,y, width, height );
    }
    return _rect;
  }
  Rect  _rect = null;
  
  bool  isShow = true;
  
  void show() {
    isShow = true;
  }
  
  void hide() {
    isShow = false;
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
      print("offsetLeft=${el.offsetLeft} e.client=${e.client}");
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
