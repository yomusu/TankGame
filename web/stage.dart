part of tankgame;

/**
 * ステージデータ
 */
List  stageList = [
   // Stage1
   { 'enable':true, 'name':"Stage1",
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
   { 'enable':true, 'name':"Stage2",
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
   { 'enable':false, 'name':"Stage3",
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
