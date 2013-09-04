part of geng;


typedef void SpriteRender( GCanvas2D c, Sprite sp );


class ImageSprite extends Sprite {
  
  ImageElement  image;
  
  ImageSprite( { ImageElement img, String imgKey:null, num width:10, num height:10 } ) : super.empty() {
    if( imgKey!=null )
      image = geng.imageMap[imgKey];
    if( img!=null )
      image = img;
    
    sprenderer = (c,sp) {
      c.c.drawImageScaled(image, -offsetx, -offsety, _w, _h);
    };
    
    _w = width;
    _h = height;
    offsetx = _w / 2;
    offsety = _h / 2;
  }
  
}

/**
 * いわゆるスプライト
 * Mouseイベントもやる必要あるかもねー
 */
class Sprite {
  
  num _x=0,_y=0;
  num _w=0,_h=0;
  Rect  _rect = null;
  
  num _alpha = null;
  num _scale = null;
  
  num offsetx = 0,
      offsety = 0;
  num rotate = null;
  
  bool  isShow = true;
  
  SpriteRender  sprenderer;
  
  factory Sprite.withImage( String imgKey , { num width:10, num height:10 } ) {
    return new ImageSprite( imgKey:imgKey, width:width, height:height );
  }
  
  Sprite.withRender( SpriteRender render, { num width:10, num height:10 } ) {
    sprenderer = render;
    _w = width;
    _h = height;
    offsetx = _w / 2;
    offsety = _h / 2;
  }
  
  Sprite.empty();
  
  void render( GCanvas2D c ) {
    if( isShow ) {
      c.c.save();
      
      if( rotate!=null ) {
        c.c.translate(_x,_y);
        c.c.rotate( rotate );
      } else {
        c.c.translate(_x,_y);
      }
      
      if( _alpha!=null ) {
        var a = _alpha;
        a = math.max( a, 0.0 );
        a = math.min( a, 1.0 );
        c.c.globalAlpha = a;
      }
      
      if( _scale!=null )
        c.c.scale( _scale, _scale );
      
      sprenderer( c, this );
      c.c.restore();
    }
  }
  
  /** スケール */
  num get scale => (_scale!=null) ? _scale : 1.0 ;
      set scale( num sc ) {
        _scale = (sc==1.0) ? null : sc;
      }
  
  /** 透明度 */
  num get opacity => (_alpha!=null) ? _alpha : 1.0;
      set opacity( num op ) {
        _alpha = (op==1.0) ? null : op;
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
  
  void show() {
    isShow = true;
  }
  
  void hide() {
    isShow = false;
  }
}
