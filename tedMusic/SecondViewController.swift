//
//  SecondViewController.swift
//  tedMusic
//
//  Created by ted on 10/3/16.
//  Copyright © 2016 ted. All rights reserved.
//

import UIKit
import KDEAudioPlayer
import SwiftyJSON
import Alamofire
import AVFoundation
import ESTMusicIndicator

struct m {
    var name:String?
    var size:Float64?
}
extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}
extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}


class SecondViewController: UITableViewController, AudioPlayerDelegate  {
    
    let  player = AudioPlayer()
    var musics = [m]()
    let dataStore=DataStore.sharedInstance
    var uiv:UIView?
    var uislider:UISlider?
    var uilbl:UILabel?
    var sliderTouch:Bool = false
    var uiplay:UIButton?
    let gr = CAGradientLayer()
    let indicator2 = ESTMusicIndicatorView.init()
    var itemName:String?
    var showSlider:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Music List"
        // nav button
        self.navigationController!.navigationBar.tintColor=UIColor.redColor()
        
        loadMp3()
        player.delegate=self
        
        // view
        setupView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadMp3Withreload"), name: "loadMp3", object: nil)
        let uiv_block = UIView(frame: CGRect(x: 0, y: 0, width: (uiv?.frame.size.width)!, height: (uiv?.frame.size.height)!))
        self.tableView.tableFooterView=uiv_block;
    }
    
    func loadMp3Withreload(){
        loadMp3()
        reload()
    }
    
    override func viewDidAppear(animated: Bool) {
        reload()
    }
    
    func reload(){
        if String(player.state) == "Playing" {
            indicator2.state = .ESTMusicIndicatorViewStatePlaying
        }else{
            indicator2.state = .ESTMusicIndicatorViewStatePaused
        }
        self.tableView.reloadData()
        
        for var i=0;i<musics.count;i++ {
            if musics[i].name == nil{
                continue
            }
            if musics[i].name == itemName{
                let rowToSelect:NSIndexPath = NSIndexPath(forRow: i, inSection: 0);  //slecting 0th row with 0th section
                self.tableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.None);
                break
            }
        }
        
    }
    
    func setupView(){
        let c1 = UIColor(red: 211/255.0, green: 131/255.0, blue: 18/255.0, alpha: 1)
        let c2 = UIColor(red: 168/255.0, green: 50/255.0, blue: 121/255.0, alpha: 1)
        
        indicator2.frame = CGRectMake((self.navigationController?.navigationBar.frame.size.width)! - 50, (self.navigationController?.navigationBar.frame.size.height)!/2-25, 50, 50)
        indicator2.tintColor = UIColor.redColor()
        self.navigationController?.navigationBar.addSubview(indicator2)
        
        indicator2.hidden = true
        let gesture2 = UITapGestureRecognizer(target: self, action: "showPlay")
        indicator2.addGestureRecognizer(gesture2)
        self.navigationController?.navigationBar
        
        gr.colors = [c1.CGColor,c2.CGColor]
        gr.startPoint = CGPointZero
        gr.endPoint = CGPointMake(1, 1)
        
        
        
        //uiview
        uiv = UIView(frame: CGRect(origin: CGPoint(x: tabBarController!.tabBar.frame.minX, y:tabBarController!.tabBar.frame.minY-(tabBarController!.tabBar.frame.height*0.7)), size: CGSize(width: tabBarController!.tabBar.frame.width, height: tabBarController!.tabBar.frame.height * 0.7)))
        let gesture = UITapGestureRecognizer(target: self, action: "hidePlay")
        uiv?.addGestureRecognizer(gesture)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = (uiv?.bounds)!
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        uiv?.addSubview(blurEffectView)
        uiv?.hidden=true
        
        // slider
        uislider = UISlider(frame: CGRect(origin: CGPoint(x: uiv!.frame.midX/2, y: -5), size: CGSize(width: uiv!.frame.width/2, height: uiv!.frame.height
            )))
        uislider?.maximumValue=100
        uislider?.minimumValue=0
        uislider?.value=50
        
        let thumbImage : UIImage = UIImage(named: "glass")!
        uislider?.setThumbImage(thumbImage, forState: UIControlState.Normal )
        
        //uislider?.minimumTrackTintColor=UIColor.redColor()
        uislider?.addTarget(self, action: "sliderTouch:", forControlEvents: .TouchDown)
        uislider?.addTarget(self, action: "sliderTouchUp:", forControlEvents: .TouchUpInside)
        uislider?.addTarget(self, action: "sliderTouchUp2:", forControlEvents: .TouchCancel)
        uislider?.addTarget(self, action: "sliderValueChanged:", forControlEvents: .ValueChanged)
        //test grad.
        let tgl = CAGradientLayer()
        let frame = CGRectMake(0, 0, (uislider?.frame.size.width)!, 5)
        tgl.frame = frame
        tgl.colors = [c1.CGColor,c2.CGColor]
        tgl.startPoint = CGPointMake(0.0, 0.5)
        tgl.endPoint = CGPointMake(1.0, 0.5)
        
        UIGraphicsBeginImageContextWithOptions(tgl.frame.size, tgl.opaque, 0.0);
        tgl.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        image.resizableImageWithCapInsets(UIEdgeInsetsZero)
        
        uislider?.setMinimumTrackImage(image, forState: .Normal)
        
        // time label
        uilbl=UILabel(frame: CGRect(origin: CGPoint(x: uislider!.frame.midX-12, y: uislider!.frame.midY+5), size: CGSize(width: uiv!.frame.width/2, height: 15
            )))
        uilbl?.font = UIFont(name: "Avenir-Light", size: 12.0)
        uilbl?.textColor = UIColor.grayColor()
        
        uiplay=UIButton(frame: CGRect(origin: CGPoint(x: 12, y: (uiv?.frame.size.height)!/2/2/2), size: CGSize(width: 30, height: 30
            )))
        uiplay?.setImage(UIImage(named: "play"), forState: .Normal)
        uiplay?.addTarget(self, action: "play:",forControlEvents:.TouchUpInside)
        // add subview
        uiv?.addSubview(uislider!)
        uiv?.addSubview(uilbl!)
        uiv?.addSubview(uiplay!)
        tabBarController?.view.addSubview(uiv!)
        
        
    }
    
    func hidePlay(){
        if !sliderTouch{
            uiv?.hidden = true
        }
    }
    
    func showPlay(){
        uiv?.hidden = false
        self.tableView.editing = !self.tableView.editing
        reload()
    }
    
    func sliderTouch(sender:UISlider!){
    }
    
    func sliderTouchUp(sender:UISlider!){
        print("up")
        if sliderTouch {
            sliderTouch = false
        }
    }
    
    func sliderTouchUp2(sender:UISlider!){
        print("up2")
        if sliderTouch {
            sliderTouch = false
        }
    }
    
    func sliderValueChanged(sender:UISlider!){
        print("change")
        sliderTouch = true
        player.seekToTime(NSTimeInterval(sender.value / 100 * Float(player.currentItemDuration!)))
    }
    
    func play(sender: AnyObject) {
        print("play")
        let state = String(player.state)
        if state == "Playing" {
            player.pause()
        }else{
            player.resume()
        }
    }
    
    func randomPlay() {
        
        print("rad")
        var ais  = [AudioItem]();
        for index in musics {
            if(index.name == nil){
                continue
            }
            let path2 = dataStore.getPathByFileName(index.name!)
            let item = AudioItem(highQualitySoundURL: NSURL(fileURLWithPath: path2))
            item?.title = index.name!.stringByReplacingOccurrencesOfString(".mp3", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            ais.append(item!)
        }
        ais.shuffleInPlace()
        player.playItems(ais)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            randomPlay()
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
            return
        }
        
        let path2 = dataStore.getPathByFileName(musics[indexPath.row].name!)
        let item = AudioItem(highQualitySoundURL: NSURL(fileURLWithPath: path2))
        item?.title = musics[indexPath.row].name!.stringByReplacingOccurrencesOfString(".mp3", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        player.playItems([item!])
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
        cell.indicator.state = .ESTMusicIndicatorViewStatePlaying
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musics.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cellIdentifier = "TableViewCell2"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TableViewCell2
            
            gr.removeFromSuperlayer()
            let h = (cell.frame.size.height * CGFloat(musics.count+20))
            gr.frame = CGRectMake(0, -1000, self.view.frame.size.width, h+1000)
            self.tableView.layer.insertSublayer(gr, atIndex: 0)
            cell.backgroundColor = UIColor.clearColor()
            
            
            return cell
        }
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "TableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TableViewCell
        cell.backgroundColor = UIColor.clearColor()
        
        cell.lblName.text = "\(musics[indexPath.row].name!.stringByReplacingOccurrencesOfString(".mp3", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil))"
        cell.lblName.textColor = UIColor.whiteColor()
        
        let ti = NSInteger(musics[indexPath.row].size!)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        
        cell.time.text = "\(minutes):\(String(format: "%02d", seconds))"
        cell.indicator.frame = cell.indic.frame
        cell.addSubview(cell.indicator)
        
        if musics[indexPath.row].name! == itemName{
            cell.indicator.state = indicator2.state
            cell.indic.hidden = true
        }else{
            cell.indicator.state = .ESTMusicIndicatorViewStateStopped
            cell.indic.hidden = false
        }
        
        
        if self.tableView.editing {
            cell.indicator.state = .ESTMusicIndicatorViewStateStopped
            cell.indic.hidden = false
        }
        
        return cell
    }
    
    func loadMp3(){
        musics.removeAll()
        musics.append(m())
        let files=NSFileManager().enumeratorAtPath(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.AllDomainsMask, true)[0])
        while let file = files?.nextObject(){
            
            let fileName = "\(file)"
            
            if fileName.rangeOfString(".mp3") != nil {
                musics.append(m(name:"\(file)",size:dataStore.checkTime(dataStore.getPathByFileName(fileName))))
            }
        }
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        if (self.tableView.editing) {
            return true
        }else{
            return false
        }
        
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let m = musics[sourceIndexPath.row]
        musics.removeAtIndex(sourceIndexPath.row)
        musics.insert(m, atIndex: destinationIndexPath.row)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
        // add the action button you want to show when swiping on tableView's cell , in this case add the delete button.
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action , indexPath) -> Void in
            if self.musics[indexPath.row].name == self.itemName{
                self.player.stop()
                self.itemName = nil
                self.uiv?.hidden = true
            }
            DataStore.sharedInstance.removeFile(self.musics[indexPath.row].name!)
            self.loadMp3()
        })
        
        // You can set its properties like normal button
        deleteAction.backgroundColor = UIColor.clearColor()
        
        return [deleteAction]
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if let event = event {
            player.remoteControlReceivedWithEvent(event)
        }
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState){
        
        print(String(to))
        
        let state = String(to)
        
        
        if state == "Paused" || state == "Stopped" {
            uiplay!.setImage(UIImage(named: "play"), forState: .Normal)
            indicator2.state = .ESTMusicIndicatorViewStatePaused
            if state == "Stopped" {
                uilbl?.text="0:00"
            }
            
        }
        if state == "Playing" {
            uiplay!.setImage(UIImage(named: "pause"), forState: .Normal)
            indicator2.state = .ESTMusicIndicatorViewStatePlaying;
        }
        
        reload()
        
        guard showSlider else {
            return
        }
        showSlider = false
        uiv?.hidden=false
        
    }
    
    
    func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem){
        let tabArray = self.tabBarController!.tabBar.items! as NSArray
        let tabItem1 = tabArray.objectAtIndex(1) as! UITabBarItem
        tabItem1.title = item.title
        itemName = item.title! + ".mp3"
        reload()
    }
    
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float){
        //print("progrss:\(time)")
        uislider?.value=percentageRead
        guard time > 0 else{
            return
        }
        uilbl?.text="\(Int(floor(time/60))):\(String(format: "%02d", Int(trunc(time - floor(time/60) * 60))))"
    }
    
    
    func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem){
    }
    
    
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata){
        print("empty")
    }
    
    
    func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){
        //print("timerange")
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            player.next()
        }
    }
    
    
    
}

