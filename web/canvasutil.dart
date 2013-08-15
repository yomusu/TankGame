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
  Color strokeColor = Color.Black;
  /** color of fill. nullの場合、描画しない */
  Color fillColor = Color.Yellow;
  /** strokeの線の太さ */
  num   lineWidth = 1.0;
  /** 行の高さ(px) */
  num   lineHeight= 10;
  
  String  textAlign = "left";
  String  textBaseline = "ideographic";
  
  // Property with setter -------------
  
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
  void drawTexts( List strs, num x, num y ) {
    
    _con.lineWidth = lineWidth;
    
    _con.font = _font;
    _con.textAlign = textAlign;
    _con.textBaseline = textBaseline;
    
    if( strokeColor!=null )
      _con.setStrokeColorRgb(strokeColor.r, strokeColor.g, strokeColor.b, 1);
    if( fillColor!=null )
      _con.setFillColorRgb(fillColor.r, fillColor.g, fillColor.b, 1);
    
    strs.forEach( (s) {
      if( fillColor!=null )
        _con.fillText( s, x, y );
      if( strokeColor!=null )
        _con.strokeText( s, x, y );
      
      y += lineHeight;
    });
  }
}

class Color {
  
  static Color  Red   = new Color.fromString("#FF0000");
  static Color  Black = new Color.fromString("#000000");
  static Color  Yellow= new Color.fromString("#FFFF00");
  static Color  Blue  = new Color.fromString("#0000FF");
  static Color  Gray  = new Color.fromString("#808080");
  
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

