part of geng;

/**
 * いわゆるスプライト
 * Mouseイベントもやる必要あるかもねー
 */
class Sprite {
  
  num _x=0,_y=0;
  num _w=0,_h=0;
  
  num offsetx = 0,
      offsety = 0;
  
  ImageElement _img;
  
  Sprite( { String src:null, num width:10, num height:10 } ) {
    _img = new ImageElement();
    if( src !=null )
      _img.src = src;
    _w = width;
    _h = height;
    offsetx = _w / 2;
    offsety = _h / 2;
  }
  
  void render( CanvasElement canvas ) {
    if( isShow ) {
      var c = canvas.context2D;
      var x = _x - offsetx;
      var y = _y - offsety;
      c.drawImageScaled(_img, x, y, _w, _h);
    }
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
      num x = _x - offsetx;
      num y = _y - offsety;
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

class Color {
  
  num red,green,blue;
  
  int get r => red;
  int get g => green;
  int get b => blue;
  
  Color.fromString( String rgb ) {
    if( rgb.startsWith("#") ) {
      switch( rgb.length ) {
        case 7:
          red  = int.parse( rgb.substring(1,3), radix:16 );
          green= int.parse( rgb.substring(3,5), radix:16 );
          blue = int.parse( rgb.substring(5,7), radix:16 );
          break;
      }
    }
  }
}

