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
struct m {
    var name:String?
    var size:Int?
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
    
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    let  player = AudioPlayer()
    var musics = [m]()
    let dataStore=DataStore.sharedInstance
    var playing:Bool=false
    var uiv:UIView?
    var uislider:UISlider?
    var uilbl:UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadMp3()
        self.navigationController!.navigationBar.tintColor=UIColor.redColor()
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "loadMp3")
        self.navigationItem.leftBarButtonItem=UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addMP3")
        let delegate: AudioPlayerDelegate = self
        player.delegate=delegate
        uiv = UIView(frame: CGRect(origin: CGPoint(x: tabBarController!.tabBar.frame.minX, y:tabBarController!.tabBar.frame.minY-(tabBarController!.tabBar.frame.height*0.7)), size: CGSize(width: tabBarController!.tabBar.frame.width, height: tabBarController!.tabBar.frame.height * 0.7)))
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = (uiv?.bounds)!
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        uiv?.addSubview(blurEffectView)
        
        
        print(uiv?.frame.minY)
        uislider = UISlider(frame: CGRect(origin: CGPoint(x: uiv!.frame.midX/2, y: -5), size: CGSize(width: uiv!.frame.width/2, height: uiv!.frame.height
            )))
        uislider?.maximumValue=100
        uislider?.minimumValue=0
        uislider?.value=50
        
        let thumbImage : UIImage = UIImage(named: "glass")!
        uislider?.setThumbImage(thumbImage, forState: UIControlState.Normal )
        
        uislider?.minimumTrackTintColor=UIColor.redColor()
        uislider?.addTarget(self, action: "sliderTouch:", forControlEvents: .TouchDown)
        uislider?.addTarget(self, action: "sliderTouchUp:", forControlEvents: .TouchUpInside)
        uiv?.addSubview(uislider!)
        uiv?.hidden=true
        
        uilbl=UILabel(frame: CGRect(origin: CGPoint(x: uislider!.frame.midX-12, y: uislider!.frame.midY+5), size: CGSize(width: uiv!.frame.width/2, height: 15
            )))
        uilbl?.font = UIFont(name: "Avenir-Light", size: 15.0)
        uiv?.addSubview(uilbl!)
        tabBarController?.view.addSubview(uiv!)
        uiv?.hidden=true
    }
    
    func sliderTouch(sender:UISlider!){
        player.pause()
    }
    
    func sliderTouchUp(sender:UISlider!){
        player.seekToTime(NSTimeInterval(sender.value / 100 * Float(player.currentItemDuration!)))
        player.resume()
    }
    
    
    @IBAction func click(sender: AnyObject) {
        player.seekToTime(sender.value/100/player.currentItemDuration!)
        
    }
    @IBAction func play(sender: AnyObject) {
        print("play")
        if player.items==nil && musics.count > 0 {
            randomPlay(self)
            return
        }
        let state = String(player.state)
        if state == "Playing" {
            player.pause()
        }else{
            player.resume()
        }
    }
    
    func handlePlayButton(){
        if playing == true {
            player.pause()
            playing=false
        }else{
            player.resume()
            playing=true
        }
    }
    
    @IBAction func randomPlay(sender: AnyObject) {
        print("rad")
        var ais  = [AudioItem]();
        for index in musics {
            let path2 = dataStore.getPathByFileName(index.name!)
            let item = AudioItem(highQualitySoundURL: NSURL(fileURLWithPath: path2))
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
        playing=true
        playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        self.title=musics[indexPath.row].name!
        let path2 = dataStore.getPathByFileName(musics[indexPath.row].name!)
        let item = AudioItem(highQualitySoundURL: NSURL(fileURLWithPath: path2))
        player.playItems([item!])
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musics.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "TableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TableViewCell
        
        
        cell.lblName.text = "\(musics[indexPath.row].name!)"
        
        return cell
    }
    
    func loadMp3(){
        musics.removeAll()
        let files=NSFileManager().enumeratorAtPath(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.AllDomainsMask, true)[0])
        while let file = files?.nextObject(){
            let fileName = "\(file)"
            if fileName.rangeOfString(".mp3") != nil {
                musics.append(m(name:"\(file)",size:6))
            }
        }
        self.tableView.reloadData()
    }
    
    func addMP3(){
        var inputTextField: UITextField?
        let passwordPrompt = UIAlertController(title: "Youtube Link", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        passwordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        passwordPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            guard (inputTextField?.text != nil && inputTextField?.text != "") else {
                return
            }
            self.sendRequest((inputTextField?.text)!)
        }))
        passwordPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter youtube link"
            inputTextField = textField
        })
        
        self.navigationController!.presentViewController(passwordPrompt, animated: true, completion: nil)
        
        
    }
    
    func sendRequest(youtubeLink:String){
        var newlink:String?
        if youtubeLink.rangeOfString("http://youtu.be/") != nil{
            newlink = youtubeLink.stringByReplacingOccurrencesOfString("http://youtu.be/", withString: "https://www.youtube.com/watch?v=", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }else if youtubeLink.rangeOfString("https://m.youtube.com/watch?v=") != nil{
            newlink = youtubeLink.stringByReplacingOccurrencesOfString("https://m.youtube.com/watch?v=", withString: "https://www.youtube.com/watch?v=", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        guard let _ = newlink else{
            return;
        }
        DataConnectionManager.getJSON("loadData",link:newlink!,nc: self.navigationController!, resultJSON: { (result: JSON) -> Void in
            print(result)
            guard result["success"] == "true" else{
                
                return
            }
            print("success")
            self.downloadWithAlert(result["link"].stringValue)
        })
        
    }
    
    
    private func downloadWithAlert(link:String){
        let newString = link.stringByReplacingOccurrencesOfString("http", withString: "https", options: NSStringCompareOptions.LiteralSearch, range: nil)
        print(newString)
        // create controller with style as Alert
        let alertCtrl = UIAlertController(title: "downloading", message: "      ", preferredStyle: UIAlertControllerStyle.Alert )
        
        // create button action
        
        
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Default, handler: nil)
        // add action to controller
        
        
        alertCtrl.addAction(cancelAction)
        let progressView = UIProgressView()
        // show alert
        self.navigationController!.presentViewController(alertCtrl, animated: true, completion: {
            //  Add your progressbar after alert is shown (and measured)
            let margin:CGFloat = 8.0
            let rect = CGRectMake(margin, 72.0, alertCtrl.view.frame.width - margin * 2.0 , 2.0)
            progressView.frame=rect
            progressView.setProgress(0, animated: true)
            alertCtrl.view.addSubview(progressView)
        })
        
        Alamofire.download(.GET, newString, destination: DataStore.sharedInstance.destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                dispatch_async(dispatch_get_main_queue()) {
                    let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
                    
                    progressView.progress=progress
                    alertCtrl.message="\(Int(progress*100))%"
                }
            }
            .response { request, response, _, error in
                
                if let error = error {
                    print("Failed with error: \(error)")
                } else {
                    print("Downloaded file successfully")
                    self.loadMp3()
                }
                
                alertCtrl.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            DataStore.sharedInstance.removeFile(musics[indexPath.row].name!)
            loadMp3()
            
        }
    }
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if let event = event {
            player.remoteControlReceivedWithEvent(event)
        }
    }
    
    func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState){
        print("change state\(to)")
        let state = String(to)
        if state == "Paused" || state == "Stopped" {
            playButton.setImage(UIImage(named: "play"), forState: .Normal)
            if state == "Stopped" {
                uilbl?.text="0:00"
            }
        }else{
            playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        }
        guard state == "Playing" || state == "Paused"  else {
            uiv?.hidden=true
            return
        }
        uiv?.hidden=false
        
    }
    
    /**
     This method is called when the audio player is about to start playing
     a new item.
     
     - parameter audioPlayer: The audio player.
     - parameter item:        The item that is about to start being played.
     */
    func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem){
        print("start")
    }
    
    /**
     This method is called a regular time interval while playing. It notifies
     the delegate that the current playing progression changed.
     
     - parameter audioPlayer:    The audio player.
     - parameter time:           The current progression.
     - parameter percentageRead: The percentage of the file that has been read.
     It's a Float value between 0 & 100 so that you can
     easily update an `UISlider` for example.
     */
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: NSTimeInterval, percentageRead: Float){
        //print("progrss:\(time)")
        uislider?.value=percentageRead
        guard time > 0 else{
            return
        }
        uilbl?.text="\(Int(floor(time/60))):\(String(format: "%02d", Int(trunc(time - floor(time/60) * 60))))"
    }
    
    /**
     This method gets called when the current item duration has been found.
     
     - parameter audioPlayer: The audio player.
     - parameter duration:    Current item's duration.
     - parameter item:        Current item.
     */
    func audioPlayer(audioPlayer: AudioPlayer, didFindDuration duration: NSTimeInterval, forItem item: AudioItem){
        print("duration:\(duration)")
    }
    
    /**
     This methods gets called before duration gets updated with discovered metadata.
     
     - parameter audioPlayer: The audio player.
     - parameter item:        Found metadata.
     - parameter data:        Current item.
     */
    func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata){
        print("empty")
    }
    
    /**
     This method gets called while the audio player is loading the file (over
     the network or locally). It lets the delegate know what time range has
     already been loaded.
     
     - parameter audioPlayer: The audio player.
     - parameter range:       The time range that the audio player loaded.
     - parameter item:        Current item.
     */
    func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){
        print("timerange")
    }
    
    
    
    
}

