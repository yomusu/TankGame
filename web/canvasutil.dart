part of geng;



class TextRender {

  // private member -------------
  
  CanvasElement _canvas;
  CanvasRenderingContext2D  _con;
  
  String  _fontSize = '24pt';
  String  _fontFamily = "serif";
  String  _font = "24pt serif";
  
  // Property -------------
  
  /** color of stroke. nullの場合、描画しない */
  Color strokeColor = null;
  /** color of fill. nullの場合、描画しない */
  Color fillColor = Color.Black;
  
  /** About shadow */
  Color shadowColor = null;
  num shadowOffsetX = 2;
  num shadowOffsetY = 2;
  num shadowBlur = 2;
  
  /** strokeの線の太さ */
  num   lineWidth = 1.0;
  /** 行の高さ(px) */
  num   lineHeight= 10;
  
  String  textAlign = "left";
  String  textBaseline = "ideographic";
  
  // Property with setter -------------
  
  set shadowOffset( num offset ) {
    shadowOffsetX = offset;
    shadowOffsetY = offset;
  }
  
  set canvas( CanvasElement c ) {
    _canvas = c;
    _con = ( c!=null ) ? c.context2D : null;
  }
  
  /** フォントサイズ  ex)"20px"等 */
  set fontSize( String size ) {
    _fontSize = size;
    _font = "${_fontSize} ${_fontFamily}";
  }
  
  /** フォントファミリ  ex)"serif"等 */
  set fontFamily( String family ) {
    _fontFamily = family;
    _font = "${_fontSize} ${_fontFamily}";
  }
  
  // Methods -------------
  
  /**
   * 複数行のテキストを描画する
   */
  void drawTexts( List<String> strs, num x, num y ) {
    
    _con.lineWidth = lineWidth;
    
    _con.font = _font;
    _con.textAlign = textAlign;
    _con.textBaseline = textBaseline;
    
    if( fillColor!=null ) {
      
      _con.save();
      
      if( shadowColor!=null ) {
        _con.shadowColor = shadowColor.rgba;
        _con.shadowOffsetX = shadowOffsetX;
        _con.shadowOffsetY = shadowOffsetY;
        _con.shadowBlur = shadowBlur;
      }
      
      _con.setFillColorRgb(fillColor.r, fillColor.g, fillColor.b, 1);
      var _y = y;
      strs.forEach( (s) {
        _con.fillText( s, x, _y );
        _y += lineHeight;
      });
      
      _con.restore();
    }
    
    if( strokeColor!=null ) {
      _con.setStrokeColorRgb(strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a);
      var _y = y;
      strs.forEach( (s) {
        _con.strokeText( s, x, _y );
        _y += lineHeight;
      });
    }
  }
}

class Color {
  
  static Color  White = new Color.fromString("#FFFFFF");
  static Color  Red   = new Color.fromString("#FF0000");
  static Color  Black = new Color.fromString("#000000");
  static Color  Yellow= new Color.fromString("#FFFF00");
  static Color  Blue  = new Color.fromString("#0000FF");
  static Color  Gray  = new Color.fromString("#808080");
  
  num red,green,blue;
  num alpha=1.0;
  
  int get r => red;
  int get g => green;
  int get b => blue;
  num get a => alpha;
  
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
  
  Color.fromAlpha(num a ) {
    red = 0;
    green = 0;
    blue = 0;
    alpha = a;
  }
  
  String get rgba => "rgba($red,$green,$blue,$alpha)";
}

const R90 = math.PI * 0.5;
const R180 = math.PI;

void roundRect( CanvasRenderingContext2D c, num left, num top, num w, num h, num radius) {
  
  var l = left + radius;
  var t = top + radius;
  var r = left + w - radius;
  var b = top + h - radius;
  
  c.arc( l, t, radius, -R180, -R90 );
  c.arc( r, t, radius,  -R90,    0 );
  c.arc( r, b, radius,     0,  R90 );
  c.arc( l, b, radius,   R90, R180 );
}  


class DefaultButtonRender {
  
  Color shadow    = new Color.fromString("#bbbbbb");
  Color bg_normal = new Color.fromString("#ffffff");
  Color border_normal = new Color.fromString("#fdba1d");
  Color border_on = new Color.fromString("#ff0000");
  Color border_disable = new Color.fromString("#ffeaba");
  
  var tren = new TextRender()
  ..fontFamily = fontFamily
  ..fontSize = "14pt"
  ..textAlign = "center"
  ..textBaseline = "middle"
  ..fillColor = Color.Black
  ..strokeColor = null;
  
  void render( CanvasElement canvas, GButton btn ) {
    
    var status = btn.status;
    var left = btn.left;
    var top = btn.top;
    var width = btn.width;
    var height= btn.height;
    
    var c = canvas.context2D;
    
    var textCl = Color.Black;
    var bg     = bg_normal;
    var border = border_normal;
    
    switch( status ) {
      case GButton.DISABLE:
        textCl = Color.Gray;
        border = border_disable;
        break;
      case GButton.ROLLON:
        border = border_on;
        break;
    }
    
    c.save();
    
    // 影
    c.beginPath();
    c.setFillColorRgb( shadow.r, shadow.g, shadow.b );
    roundRect( c, left, top+5, width, height, 20 );
    c.closePath();
    c.fill();
    
    
    // 表面
    if( status==GButton.PRESSED )
      c.translate(0,4);
    
    c.beginPath();
    // 背景
    roundRect( c, left+2, top+2, width-4, height-4, 18 );
    c.closePath();
    c.setFillColorRgb( bg.r, bg.g, bg.b );
    c.fill();
    // ボーダー
    c.setStrokeColorRgb( border.r, border.g, border.b );
    c.lineWidth = 4;
    c.stroke();
    
    if( btn.text!=null ) {
      tren.canvas = canvas;
      tren.fillColor = textCl;
      tren.drawTexts([btn.text], btn.x, btn.y);
      tren.canvas = null;
    }
    
    c.restore();
  }
  
}



