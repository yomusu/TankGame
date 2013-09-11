part of geng;



class TextRender {
  
  TextRender();
  
  TextRender.from( TextRender src ) {
    set( src );
  }
  
  void set( TextRender src ) {
    _fontSize = src._fontSize;
    _fontFamily = src._fontFamily;
    _font = src._font;
    
    strokeColor = src.strokeColor;
    fillColor = src.fillColor;
    shadowColor = src.shadowColor;
    shadowOffsetX = src.shadowOffsetX;
    shadowOffsetY = src.shadowOffsetY;
    shadowBlur = src.shadowBlur;
    lineWidth = src.lineWidth;
    lineHeight = src.lineHeight;
    textAlign = src.textAlign;
    textBaseline = src.textBaseline;
  }
  
  // private member -------------
  
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

const R0 = 0.0;
const R1 = math.PI / 180.0;
const R45 = math.PI * 0.5 * 0.5;
const R90 = math.PI * 0.5;
const R180 = math.PI;
const R360 = math.PI * 2.0;


final GCanvas2D g2d = new GCanvas2D();


class GCanvas2D {
  
  CanvasElement _canvas;
  CanvasRenderingContext2D  c;
  
  set canvas( CanvasElement canvas ) {
    _canvas = canvas;
    c = (canvas!=null) ? canvas.context2D : null;
  }
  
  set fillColor( Color cl ) => c.setFillColorRgb( cl.r, cl.g, cl.b, cl.a );
  set strokeColor( Color cl ) => c.setStrokeColorRgb( cl.r, cl.g, cl.b, cl.a );
  
  void fill( [Color color] ) {
    if( color!=null )
      fillColor = color;
    c.fill();
  }
  void stroke( [Color color] ) {
    if( color!=null )
      strokeColor = color;
    c.stroke();
  }
  void save() => c.save();
  void restore() => c.restore();
  void beginPath() => c.beginPath();
  void closePath() => c.closePath();
  
  void roundRect( num left, num top, num w, num h, num radius) {
    
    var l = left + radius;
    var t = top + radius;
    var r = left + w - radius;
    var b = top + h - radius;
    
    c.arc( l, t, radius, -R180, -R90 );
    c.arc( r, t, radius,  -R90,    0 );
    c.arc( r, b, radius,     0,  R90 );
    c.arc( l, b, radius,   R90, R180 );
  }
  
  void circle( num left, num top, num radius ) => c.arc( left, top, radius, R0, R360 );
  
  void pizza( num cx, num cy, num radius, num startAngle, num endAngle ) {
    c.moveTo(cx,cy);
    c.arc( cx, cy, radius, startAngle, endAngle );
    c.moveTo(cx,cy);
  }
  
  /**
   * 複数行のテキストを描画する
   */
  void drawTexts( TextRender tren, List<String> strs, num x, num y, { num maxWidth:null } ) {
    
    c.lineWidth = tren.lineWidth;
    
    c.font = tren._font;
    c.textAlign = tren.textAlign;
    c.textBaseline = tren.textBaseline;
    
    if( tren.fillColor!=null ) {
      
      c.save();
      
      if( tren.shadowColor!=null ) {
        c.shadowColor = tren.shadowColor.rgba;
        c.shadowOffsetX = tren.shadowOffsetX;
        c.shadowOffsetY = tren.shadowOffsetY;
        c.shadowBlur = tren.shadowBlur;
      }
      
      c.setFillColorRgb(tren.fillColor.r, tren.fillColor.g, tren.fillColor.b, 1);
      var _y = y;
      strs.forEach( (s) {
        c.fillText( s, x, _y, maxWidth );
        _y += tren.lineHeight;
      });
      
      c.restore();
    }
    
    if( tren.strokeColor!=null ) {
      c.setStrokeColorRgb(tren.strokeColor.r, tren.strokeColor.g, tren.strokeColor.b, tren.strokeColor.a);
      var _y = y;
      strs.forEach( (s) {
        c.strokeText( s, x, _y, maxWidth );
        _y += tren.lineHeight;
      });
    }
  }
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
  
  void render( GCanvas2D canvas, GButton btn ) {
    
    var status = btn.status;
    var left = btn.left;
    var top = btn.top;
    var width = btn.width;
    var height= btn.height;
    
    var c = canvas.c;
    
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
    canvas.fillColor = shadow;
    canvas.roundRect( left, top+5, width, height, 20 );
    c.closePath();
    c.fill();
    
    
    // 表面
    if( status==GButton.PRESSED )
      c.translate(0,4);
    
    c.beginPath();
    // 背景
    canvas.roundRect( left+2, top+2, width-4, height-4, 18 );
    c.closePath();
    canvas.fillColor = bg;
    c.fill();
    // ボーダー
    canvas.strokeColor = border;
    c.lineWidth = 4;
    c.stroke();
    
    if( btn.text!=null ) {
      tren.fillColor = textCl;
      canvas.drawTexts( tren, [btn.text], btn.x, btn.y);
    }
    
    c.restore();
  }
  
}



