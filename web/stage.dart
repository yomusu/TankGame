part of tankgame;

/**
 * ステージデータ
 */
List  stageList = [
                 // Stage1
                 { 'id':'stage0', 'name':"Stage0",
                     "caption" : "試し打ちこちら",
                     'speed':2.5, 'length':2150,
                     'map':[
                            [ 900, 150, "large" ],
                            [ 1400, 150, "large" ],
                            [ 1900, 150, "large" ],
                            ]
                   },
   // Stage1
   { 'id':'stage1', 'name':"Stage1",
     "caption" : "ねらえ10連コンボ！集中力ステージ",
     'speed':4.0, 'length':4000,
     'map':[
         [ 900, 100, "small" ],
         [ 1300, 100, "small" ],
         [ 1700, 100, "small" ],
         [ 1950, 100, "small" ],
         [ 2300, 100, "small" ],
         [ 2550, 100, "small" ],
         [ 2800, 100, "small" ],
         [ 3100, 100, "small" ],
         [ 3400, 100, "small" ],
         [ 3800, 100, "small" ],
     ]
   },
   // Stage2
   { 'id':'stage2', 'name':"Stage2",
     "caption" : "撃て！撃ってみせろ！破壊専用ステージ",
     'speed':4.0, 'length':3300,
     'map':[
         [ 900, 50, "large" ],
         [ 1300, 150, "small" ],
         [ 1500, 180, "small" ],
         [ 1650, 70, "large" ],
         [ 1900, 200, "small" ],
         [ 2100, 70, "large" ],
         [ 2300, 350, "small" ],
         [ 2450, 300, "small" ],
         [ 2600, 100, "large" ],
         [ 2770, 250, "large" ],
         [ 2920, 320, "small" ],
     ]
   },
   // Stage3
   { 'id':'stage3', 'name':"Stage3",
     "caption" : "考えるな、感じろ！超高速ステージ",
     'speed':6.0, 'length':3000,
     'map':[
         [ 1300, 180, "small" ],
         [ 2000, 200, "small" ],
         [ 2600, 70, "small" ],
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
                    'cannonSize' : 14,
                    'cannonSpeed' : 8,
                    'text' : "まめ砲弾",
                  },
                  
                  {
                    'id' : "big001",
                    'obtained' : true,
                    'price' : 3000,
                    'cannonSize' : 26,
                    'cannonSpeed' : 10,
                    'text' : "デカい砲弾",
                  },
                  
                  {
                    'id' : "fast001",
                    'obtained' : true,
                    'price' : 3000,
                    'cannonSize' : 16,
                    'cannonSpeed' : 22,
                    'text' : "スピード砲弾",
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
