// =================================================================
// 直径5cmホイール対応 ロッカーボギー機構 パラメトリック設計
// =================================================================

/* [表示・出力コントロール] */
// 出力したいパーツを選択してください
part = "bogie"; // [all: 全て配置（確認用）, rocker: ロッカーアームのみ, bogie: ボギーアームのみ]

/* [共通パラメータ] */
$fn = 60;          // 円の分割数（精度）
link_h = 8;        // アームの厚み (mm)
pin_d = 4;         // シャフト・ネジ用の穴の直径 (mm) - 使用する軸に合わせ変更してください
joint_d = 14;      // ジョイント結合部の外径 (mm) - 強度確保のため少し太くしました

/* [既存ホイール基準パラメータ (変更不可)] */
wheel_d = 50;      // ホイールの直径 = 50mm (5cm)
wheel_r = wheel_d / 2; // ホイールの半径 = 25mm
wheel_w = 20;      // ホイールの想定幅 (mm)

/* [アーム寸法設計 (直径50mmホイールの干渉回避用)] */
// ボギーアームの軸間距離（ミドル〜リアホイール間）。直径50mmに対し、傾きを考慮して100mmに設定
bogie_length = 100; 

// ロッカーアームのフロント軸から、ボギーピボット（結合点）までの水平距離
// ホイール同士の衝突を防ぐため、130mmのゆとりを確保
rocker_total_x = 130; 


// --- パーツの配置・プレビュー処理 ---
if (part == "all") {
    // 1. ロッカーアーム
    color("LightCoral") rocker_arm();
    
    // 2. ボギーアーム（ロッカーアームのボギーピボット位置へ移動して配置）
    translate([rocker_total_x, -15, -link_h - 2]) 
        color("LightSteelBlue") bogie_arm();
    
    // 3. 既存ホイールのダミー表示（位置関係確認用：半透明）
    % group() {
        // フロントホイール
        translate([0, 10, 0]) rotate([90, 0, 0]) dummy_wheel();
        // ミドルホイール（ボギーアームの前方軸）
        translate([rocker_total_x - (bogie_length/2), -10, -link_h - 2]) rotate([90, 0, 0]) dummy_wheel();
        // リアホイール（ボギーアームの後方軸）
        translate([rocker_total_x + (bogie_length/2), -10, -link_h - 2]) rotate([90, 0, 0]) dummy_wheel();
    }
}

if (part == "rocker") {
    rocker_arm();
}

if (part == "bogie") {
    bogie_arm();
}


// ==========================================
// コンポーネント 1: ロッカーアーム (Rocker Arm)
// ==========================================
module rocker_arm() {
    // 各ピボットの座標定義
    p_front = [0, 0];                     // フロントホイール軸
    p_body  = [70, 45];                   // 車体差動ギア接続ピボット（高さを出して地上高を確保）
    p_bogie = [rocker_total_x, -15];      // ボギーアーム接続ピボット

    linear_extrude(height = link_h) {
        difference() {
            union() {
                // フロント軸から車体ピボットへのリンク
                hull() {
                    translate(p_front) circle(d = joint_d);
                    translate(p_body)  circle(d = joint_d * 1.6); // 負荷がかかる中心は太く
                }
                // 車体ピボットからボギーピボットへのリンク
                hull() {
                    translate(p_body)  circle(d = joint_d * 1.6);
                    translate(p_bogie) circle(d = joint_d * 1.3);
                }
            }
            // 1. フロントホイール取付穴
            translate(p_front) circle(d = pin_d); 
            
            // 2. 車体（ディファレンシャル機構）接続穴
            translate(p_body) circle(d = pin_d); 
            
            // 3. ボギーアーム接続穴
            translate(p_bogie) circle(d = pin_d); 
        }
    }
}

// ==========================================
// コンポーネント 2: ボギーアーム (Bogie Arm)
// ==========================================
module bogie_arm() {
    // ロッカーとの接続ピボットを原点(0,0)とする
    p_pivot = [0, 0];
    p_middle = [-(bogie_length / 2), -20]; // 前方（ミドルホイール）軸
    p_rear   = [(bogie_length / 2), -20];  // 後方（リアホイール）軸

    linear_extrude(height = link_h) {
        difference() {
            union() {
                // ミドルからリアまでの下部メインフレーム
                hull() {
                    translate(p_middle) circle(d = joint_d);
                    translate(p_rear)   circle(d = joint_d);
                }
                // 下部フレームから上部のロッカー接続ピボットへの立ち上がり
                hull() {
                    translate(p_pivot) circle(d = joint_d * 1.3);
                    translate([-(bogie_length / 4), -20]) circle(d = joint_d);
                    translate([(bogie_length / 4), -20]) circle(d = joint_d);
                }
            }
            // 1. ロッカーアームとの接続穴
            translate(p_pivot) circle(d = pin_d); 
            
            // 2. ミドルホイール取付穴
            translate(p_middle) circle(d = pin_d); 
            
            // 3. リアホイール取付穴
            translate(p_rear) circle(d = pin_d); 
        }
    }
}

// ==========================================
// 参考用: 既存ホイールのダミー (Dummy Wheel)
// ==========================================
// ※3Dプリントはしません（位置確認のプレビュー専用）
module dummy_wheel() {
    difference() {
        cylinder(r = wheel_r, h = wheel_w, center = true);
        cylinder(d = pin_d, h = wheel_w + 2, center = true);
    }
}