part of geng;

/**
 * いわゆるスプライト
 * Mouseイベントもやる必要あるかもねー
 */
class Sprite {
  
  int _x=0,_y=0;
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
        _el.style.left = "${n}px";
      }
      
  /** y座標 */
  int get y => _y;
      set y( int n ) {
        _y = n;
        _el.style.top = "${n}px";
      }
  
  /** as Element */
  Element get element => _el;

}
