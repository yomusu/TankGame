part of geng;

/**
 * いわゆるスプライト
 * Mouseイベントもやる必要あるかもねー
 */
class Sprite {
  
  int _x=0,_y=0;
  
  Point offset = new Point(0,0);
  
  ImageElement _el;
  
  Sprite( { String src:null, int width:10, int height:10 } ) {
    
    _el = new ImageElement();
    _el.style.position = "absolute";
    
    if( src !=null )
      _el.src = src;
    
    _el.width = width;
    _el.height= height;
  }
  
  /** 画像のsrcを設定 */
  set src( String url ) => _el.src = url;
  
  /** 横幅 */
  int get width => _el.width;
      set width( int w ) => _el.width = w;
  
  /** 高さ */
  int get height=> _el.height;
      set height( int h ) => _el.height = h;
  
  
  /** x座標 */
  int get x => _x;
      set x( int n ) {
        _x = n;
        _el.style.left = "${n-offset.x}px";
      }
      
  /** y座標 */
  int get y => _y;
      set y( int n ) {
        _y = n;
        _el.style.top = "${n-offset.y}px";
      }
  
  /** as Element */
  Element get element => _el;

  void show() {
    _el.style.visibility = "visible";
  }
  
  void hide() {
    _el.style.visibility = "hidden";
  }
}


class PressHandler {
  
  var _onMouseDown = null;
  var _onPress;
  
  
  PressHandler( void onPress(int x, int y) ) {
    _onPress = onPress;
  }
  
  /** Elementに接続する */
  void connect( Element el ) {
    
    disconnect();
    
    // マウスイベント
    _onMouseDown = el.onMouseDown.listen( (MouseEvent e) {
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
