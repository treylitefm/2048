//
//  ViewController.swift
//  2048
//
//  Created by Team No Shoes  on 11/4/16.
//  Copyright © 2016 Team No Shoes. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet var cells: [UILabel]!
   
    var map: Array<[UILabel]> = [[], [], [], []]
    var topScore = Int()
    var score = Int()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var saveContext = (UIApplication.shared.delegate as! AppDelegate).saveContext
    
    @IBOutlet var Up: UISwipeGestureRecognizer!
    @IBOutlet var Right: UISwipeGestureRecognizer!
    @IBOutlet var Down: UISwipeGestureRecognizer!
    @IBOutlet var Left: UISwipeGestureRecognizer!
    @IBOutlet var Reset: UIPinchGestureRecognizer!
    @IBOutlet weak var ScoreNum: UILabel!
    @IBOutlet weak var TopScoreValue: UILabel!
    
    @IBAction func resetPinch(_ sender: UIPinchGestureRecognizer) {
        print(sender, sender.state)
        if sender.state == UIGestureRecognizerState.ended{
            resetter()
        }
        
    }
    
    func createTopScore(_ newScore:Int)-> Void {
        context.performAndWait {
            do{
                let score = TopScoreClass(context: self.context)
                score.topScore = Int32(newScore)
                self.contextSave()
            }
        }
        print("createdScore")
        
    }
    
    func getTopScore() -> Void {
        context.performAndWait{
            let request: NSFetchRequest<TopScoreClass> = TopScoreClass.fetchRequest()
            do {
                print("gotScore")
                let numbers = try? request.execute()
                print(numbers ?? "WHAT DID I SIGN UP FOR?!??!?!?")
            
                if numbers! != []{
                    print(numbers![0].topScore)
                    let top = numbers![0].topScore
                    self.topScore = Int(top)
                    print(self.topScore)
                    self.TopScoreValue.text = String(self.topScore)
                }
                else{
                    print("creating a new top score")
                    self.createTopScore(0)
                    self.TopScoreValue.text = "0"
                    self.topScore = 0
                }
            }
        }
    }
    
    func updateScore()-> Void {
        print("updatedScore")
        context.performAndWait{
            let request: NSFetchRequest<TopScoreClass> = TopScoreClass.fetchRequest()
            do {
                print("gotScore")
                let numbers = try? request.execute()
                print(numbers ?? "WHAT DID I SIGN UP FOR?!??!?!?")
                
                if numbers != nil{
                    print(numbers!)
                    numbers?[0].topScore = Int32(self.score)
                    self.contextSave()
                }
                else{
                    print("creating a new top score")
                    self.createTopScore(0)
                    self.contextSave()
                }
            }
        }
    }
    
    
    func resetter(){
        for cell in cells {
            cell.text = "0"
        }
        score = 0
        ScoreNum.text = String(score)
        randomNewTile()
        randomNewTile()
        updateColors()
    }
    
    func scoreUpdate(){
        if score > topScore {
            print("score > topScore")
            updateScore()
            topScore = self.score
            TopScoreValue.text = String(topScore)
        }
        ScoreNum.text = String(score)
    }
    
    let colors: [String:UIColor] = [
        "0": UIColor(netHex:0xFFFFFF),
        "2": UIColor(netHex:0x9E9E9E),
        "4": UIColor(netHex:0x424242),
        "8": UIColor(netHex:0x000000),
        "16": UIColor(netHex:0xF3C01D),
        "32": UIColor(netHex:0x0D27DB),
        "64": UIColor(netHex:0x01BD9F),
        "128": UIColor(netHex:0xE10203),
        "256": UIColor(netHex:0x09BD52),
        "512": UIColor(netHex:0x24115E),
        "1024": UIColor(netHex:0x0B1578),
        "2048": UIColor(netHex:0x070D4A)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTopScore()
        scoreUpdate()
        // Do any additional setup after loading the view, typically from a nib.
        ScoreNum.text = "0"
        Up.direction = UISwipeGestureRecognizerDirection.up
        Right.direction = UISwipeGestureRecognizerDirection.right
        Down.direction = UISwipeGestureRecognizerDirection.down
        Left.direction = UISwipeGestureRecognizerDirection.left
        
        self.view.addGestureRecognizer(Up)
        self.view.addGestureRecognizer(Right)
        self.view.addGestureRecognizer(Down)
        self.view.addGestureRecognizer(Left)
        self.view.addGestureRecognizer(Reset)
        
        for (i,cell) in cells.enumerated() {
            cell.text = "0"
            map[Int(floor(Double(i)/4.0))].append(cell)
        }
        randomNewTile()
        randomNewTile()
        
        updateColors()
    }
    
    //Top Score Saving
    func contextSave() -> Void{
        do {
            try context.save()
        }
        catch let error as NSError{
            fatalError("Unresolved error \(error)")
        }
    }
    
    @IBAction func mover(_ sender: UISwipeGestureRecognizer) {
        var success = Bool()
        
        if sender.direction == UISwipeGestureRecognizerDirection.left{
            success = leftSwipe()
        }
        else if sender.direction == UISwipeGestureRecognizerDirection.right{
            success = rightSwipe()
        }
        else if sender.direction == UISwipeGestureRecognizerDirection.up{
            success = upSwipe()
        }
        else if sender.direction == UISwipeGestureRecognizerDirection.down{
            success = downSwipe()
        }
        
        if success {
            randomNewTile()
        } else {
            print("No swipe for you!")
        }
        
        updateColors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func randomNewTile() {
        for _ in 0...cells.count {
            let r = Int(arc4random_uniform(UInt32(cells.count)))
            
            if cells[r].text == "0" {
                let r0 = Int(arc4random_uniform(11))
                if r0 < 7 {
                    cells[r].text = "2"
                } else {
                    cells[r].text = "4"
                }
                print(r)
                break
            }
        }
    }

    func leftSwipe() -> Bool {
        var successfulSwipe = false
        
        for i in 0...3 {
            var x = 0
            for j in 0...3 {
                var tmp = j
                while tmp-1 >= x && map[i][tmp-1].text! == "0" {
                   tmp -= 1
                }
                if tmp-1 >= x && map[i][tmp-1].text! == map[i][j].text! {
                    map[i][tmp-1].text = String(Int(map[i][j].text!)!*2)
                    score += Int(map[i][tmp-1].text!)!
                    scoreUpdate()
                    map[i][j].text = "0"
                    successfulSwipe = true
                    x += 1
                } else if map[i][tmp].text! == "0" {
                    map[i][tmp].text = map[i][j].text!
                    map[i][j].text = "0"
                    successfulSwipe = true
                }
            }
        }
        
        return successfulSwipe
    }
    
    func rightSwipe() -> Bool {
        var successfulSwipe = false
        
        for i in 0...3 {
            var x = 3
            for j in (0...3).reversed() {
                var tmp = j
                while tmp+1 <= 3 && map[i][tmp+1].text! == "0" {
                    tmp += 1
                }
                if tmp+1 <= 3 && map[i][tmp+1].text! == map[i][j].text! {
                    map[i][tmp+1].text = String(Int(map[i][j].text!)!*2)
                    score += Int(map[i][tmp+1].text!)!
                    scoreUpdate()
                    map[i][j].text = "0"
                    successfulSwipe = true
                    x -= 1
                    //score.text = String(Int(score.text!)! + Int(map[i][tmp-1].text!)!)
                } else if map[i][tmp].text! == "0" {
                    map[i][tmp].text = map[i][j].text!
                    map[i][j].text = "0"
                    successfulSwipe = true
                }
            }
        }
        
        return successfulSwipe
    }
    
    func upSwipe() -> Bool {
        var successfulSwipe = false
        
        for j in 0...3 {
            var x = 0
            for i in 0...3 {
                var tmp = i
                while tmp-1 >= x && map[tmp-1][j].text! == "0" {
                   tmp -= 1
                }
                if tmp-1 >= x && map[tmp-1][j].text! == map[i][j].text! {
                    map[tmp-1][j].text = String(Int(map[i][j].text!)!*2)
                    score += Int(map[tmp-1][j].text!)!
                    scoreUpdate()
                    map[i][j].text = "0"
                    successfulSwipe = true
                    x += 1
                    //score.text = String(Int(score.text!)! + Int(map[i][tmp-1].text!)!)
                } else if map[tmp][j].text! == "0" {
                    map[tmp][j].text = map[i][j].text!
                    map[i][j].text = "0"
                    successfulSwipe = true
                }
            }
        }
        
        return successfulSwipe
    }
    
    func downSwipe() -> Bool {
        var successfulSwipe = false
        
        for j in 0...3 {
            var x = 3
            for i in (0...x).reversed() {
                var tmp = i
                while tmp+1 <= x && map[tmp+1][j].text! == "0" {
                    tmp += 1
                }
                if tmp+1 <= x && map[tmp+1][j].text! == map[i][j].text! {
                    map[tmp+1][j].text = String(Int(map[i][j].text!)!*2)
                    score += Int(map[tmp+1][j].text!)!
                    scoreUpdate()
                    map[i][j].text = "0"
                    successfulSwipe = true
                    x -= 1
                    //score.text = String(Int(score.text!)! + Int(map[i][tmp-1].text!)!)
                } else if map[tmp][j].text! == "0" {
                    map[tmp][j].text = map[i][j].text!
                    map[i][j].text = "0"
                    successfulSwipe = true
                }
            }
        }
        
        return successfulSwipe
    }
    
    func updateColors() {
        for cell in cells {
            cell.backgroundColor = colors[cell.text!]
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

