//
//  GameViewController.swift
//  SimpleTouchTheNumber
//
//  Created by bpqd on 2016/01/19.
//  Copyright © 2016年 nakayama. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    @IBOutlet weak var readyScreenView: UIView!     // 「3,2,1」カウントダウン用の黒いスクリーン
    @IBOutlet weak var readyCountLabel: UILabel!    // 「3,2,1」カウントダウン用のラベル
    var timerCountDown: NSTimer!                    // 「3,2,1」カウントダウン用タイマー
    var numberCountDown = 3;                        // 「3,2,1」カウントダウン用のラベルに表示する数字
    
    @IBOutlet weak var clearImage: UIImageView!     // "CLEAR" の画像
    @IBOutlet weak var startButton: UIButton!       // クリア後の"START"ボタン
    @IBOutlet weak var topButton: UIButton!         // クリア後の"TOP"ボタン
    
    @IBOutlet var numButton: [UIButton]!            // ゲーム中の1から9までのボタン
    var positionArray = [1, 2, 3, 4, 5, 6, 7, 8, 9] // 1から9までのボタンをシャッフルするための配列
    var indexNum = 1;                               // 次にタッチしなければならないボタンの数字
    
    @IBOutlet weak var timerCountLabel: UILabel!    // ゲーム中のカウントアップ用ラベル
    var timerCountUp: NSTimer!                      // ゲーム中のカウントアップ用タイマー
    var numberCountUp = 0.0;                        // ゲーム中のカウントアップ用ラベルに表示する数字
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // カウントダウン用のタイマーを作成。
        // 1秒毎に update を呼び出す
        timerCountDown = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countDown"), userInfo: nil, repeats: true)
    }
    
    // 1秒毎にカウントダウンタイマーに呼び出されるメソッド
    func countDown() {
        if numberCountDown <= 1 {
            timerCountDown.invalidate() // タイマーを停止
            
            start()                     // ゲームスタートのメソッドを呼び出す
        } else {
            // カウントダウン
            numberCountDown -= 1
            // ラベルに反映
            readyCountLabel.text = String(numberCountDown)    // String(整数)とすれば、整数を文字列として変換できる
    }
}

func start() {
    // ゲーム画面を覆っていたViewを非表示に。
    readyCountLabel.hidden = true
    readyScreenView.hidden = true
    
    // まずボタンの色を選ぶ
    let buttonColor = selectButtonColor()
    
    // 配置のための配列をシャッフルをする
    shuffleArray()
    
    // シャッフルした配列にもとづいてボタンに1から9までの画像を貼り付ける
    setButtonImage(positionArray, color: buttonColor)
    
    // 0.01秒ごとに countUp を呼び出すタイマーを作成する
    timerCountUp = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("countUp"), userInfo: nil, repeats: true)
    }
    
    // まずはボタンの色をランダムに決める
    func selectButtonColor() -> String {
        let array = ["b", "g", "r"]
        let num = Int(arc4random_uniform(UInt32(array.count)))
        return array[num]
    }
    
    func shuffleArray() {
        // 少し難しい書き方ですが、配列内の数字を入れ替えていくことでシャッフルを実現する
        // positionArrayは最初に定義していた変数
        for var j = positionArray.count - 1; j > 0; j-- {
            let k = Int(arc4random_uniform(UInt32(j))) // 0 <= k < j
            swap(&positionArray[k], &positionArray[j])
    }
}

    func setButtonImage(positionArray: [Int], color: String) {
        // positionArrayは1から9がシャッフルされた配列
        // numButtonはボタンの配列で、画面の左上から右下まで1から9まで順番になっている
        // 左上のボタンからpositionArrayのランダムな数字に沿って数字の画像が貼られていく
        for i in 0..<9 {
            let img:UIImage = UIImage(named: (color+String(positionArray[i])+".png"))!
            numButton[i].setImage(img, forState: UIControlState.Normal)
            numButton[i].hidden = false;
        }
    }
    
    // 0.01秒ごとに呼び出されて、ゲーム中のタイムを計測する
    func countUp() {
        timerCountLabel.text = "Time: ".stringByAppendingFormat("%.2f", numberCountUp)
        numberCountUp += 0.01
    }

@IBAction func numButtonAction(sender: UIButton) {
    
    // indexNumが指す数字のボタンが押されると正解の処理が実行される
    if positionArray[sender.tag-1] == indexNum {
        // 1.0秒間かけてアニメーションする
        UIView.animateWithDuration(1.0, animations: {
            // 回転
            sender.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            // 縮小
            sender.transform = CGAffineTransformMakeScale(0.001, 0.001)
            // 透明化
            sender.alpha = 0.0
            }, completion: { (finish: Bool) -> Void in  // アニメーションが終わったあとの処理
                // まずボタンを隠す
                sender.hidden = true;
                
                // 次に使うので、隠したボタンを元の状態に戻しておく
                sender.transform = CGAffineTransformMakeRotation(0)
                sender.transform = CGAffineTransformMakeScale(1.0, 1.0)
                sender.alpha = 1.0
            }
        )
        
        // 正解ボタンが押されると次の数字のために、`indexNum` の数字を増やしておく
        indexNum++;
        if indexNum >= 10 {
            // 9のボタンが押されるとクリア
            clear()
        }
    }
}

func clear() {
    // カウントアップタイマーを停止
    timerCountUp.invalidate()
    numberCountUp = 0.0
    
    // クリア状態の画像やボタンを表示させる
    clearImage.hidden = false;
    startButton.hidden = false;
    topButton.hidden = false;
}

// クリア後の"START"ボタンが押されたときのメソッド
@IBAction func startButtonAction(sender: UIButton) {
    clearImage.hidden = true;
    startButton.hidden = true;
    topButton.hidden = true;
    
    // カウントの画面を表示
    readyScreenView.hidden = false
    numberCountDown = 3
    readyCountLabel.text = String(numberCountDown)
    readyCountLabel.hidden = false
    
    timerCountDown = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countDown"), userInfo: nil, repeats: true)
}

// クリア後の"TOP"ボタンが押されたときのメソッド
@IBAction func topButtonAction(sender: UIButton) {
    // NavigationControllerを使ってTOPに戻る
    // navigationController?の最後の?はnilの場合は実行されないためのSwiftの便利な機能
    self.navigationController?.popViewControllerAnimated(true)
    }
}