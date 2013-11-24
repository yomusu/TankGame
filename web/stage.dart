part of tankgame;

/**
 * ステージデータ
 */
List  stageList = [
                 // Stage1
                 { 'id':'stage0', 'name':"Stage0",
                     "caption" : "試し打ちこちら",
                     'speed':3.0, 'length':3800,
                     'map':[
                            [ 900, 150, "large" ],
                            [ 1400, 150, "large" ],
                            [ 1900, 150, "large" ],
                            [ 2400, 150, "small" ],
                            [ 2900, 150, "small" ],
                            [ 3400, 150, "small" ],
                            ]
                   },
   // Stage1
   { 'id':'stage1', 'name':"Stage1",
     "caption" : "ねらえ10連コンボ！集中力ステージ",
     'speed':3.0, 'length':4000,
     'map':[
         [ 900, 200, "large" ],
         [ 1300, 250, "small" ],
         [ 1700, 150, "large" ],
         [ 1950, 150, "small" ],
         [ 2300, 250, "large" ],
         [ 2550, 100, "small" ],
         [ 2800, 250, "large" ],
         [ 3100, 150, "small" ],
         [ 3400, 100, "large" ],
         [ 3800, 100, "small" ],
     ]
   },
];


/**
 * アイテムデータ
 */
List  itemList = [

                  {
                    'id' : "nom001",
                    'obtained' : true,
                    'price' : 0,
                    'cannonSize' : 20,
                    'cannonSpeed' : 6,
                    'text' : "まめ砲弾",
                  },
];



class GamePointManager {
  
  /** 現在保持しているゲームポイント */
  int _point;
  /** Unlockされた要素 */
  HashSet<String> _unlocked = new HashSet();
  
  Map unlockPoints = {
              "stage0" : 0,
              "stage1" : 0,     // ステージ1
              "stage2" : 1000,  // ステージ2
              "stage3" : 5000,  // ステージ3
              "nom001" : 0,     // まめ砲弾
              "big001" : 2000,  // でかい砲弾
              "fast001" : 3000, // 速い砲弾
  };
  
  /** 初期化：読み込み、初期化 */
  void init() {
    if( window.localStorage.containsKey("gamePoint") )
      _point = int.parse( window.localStorage["gamePoint"] );
    else
      _point = 0;
    
    _updateUnlockSet();
  }
  
  int get point => _point;
  
  /** ゲームポイントの追加 */
  bool addPoint( int point ) {
    _point += point;
    window.localStorage["gamePoint"] = "$_point";
    
    // 戻り値は新しくUnlockされた要素があるかどうか
    var oldNumberOfUnlocked = _unlocked.length;
    _updateUnlockSet();
    return _unlocked.length != oldNumberOfUnlocked;
  }
  
  void _updateUnlockSet() {
    unlockPoints.forEach( (key,p) {
      if( _point >= p )
        _unlocked.add( key );
    });
  }
  
  /** 要素がUnlockされているか確認する */
  bool isUnlock( String key ) {
    return _unlocked.contains(key);
  }
  
  void clearPoint() {
    window.localStorage.remove("gamePoint");
  }
}
