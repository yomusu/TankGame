part of tankgame;

/**
 * ステージデータ
 */
List  stageList = [
   // Stage1
   { 'id':'stage1', 'name':"Stage1",
     "caption" : "ねらえ10連コンボ！訓練専用ステージ",
     'speed':3.0, 'length':2500,
     'map':[
         [ 900, 100, "large" ],
         [ 1300, 100, "large" ],
         [ 1700, 100, "small" ],
         [ 2000, 100, "small" ],
         [ 2300, 100, "small" ],
     ]
   },
   // Stage2
   { 'id':'stage2', 'name':"Stage2",
     "caption" : "戦略が勝負を分ける！実戦専用ステージ",
     'speed':3.0, 'length':2100,
     'map':[
         [ 900, 50, "large" ],
         [ 1100, 150, "small" ],
         [ 1300, 180, "small" ],
         [ 1450, 70, "large" ],
         [ 1610, 200, "small" ],
         [ 1700, 50, "large" ],
         [ 1900, 70, "large" ],
     ]
   },
   // Stage3
   { 'id':'stage3', 'name':"Stage3",
     "caption" : "撃て！撃ってみせろ！破壊専用ステージ",
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
                    'cannonSize' : 10,
                    'cannonSpeed' : 8,
                    'text' : "まめ砲弾",
                  },
                  
                  {
                    'id' : "big001",
                    'obtained' : true,
                    'price' : 3000,
                    'cannonSize' : 26,
                    'cannonSpeed' : 8,
                    'text' : "デカい砲弾",
                  },
                  
                  {
                    'id' : "fast001",
                    'obtained' : true,
                    'price' : 3000,
                    'cannonSize' : 10,
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
  
}
