//
//  AlertViewController.swift
//  CVI
//
//  Created by ted on 6/3/16.
//  Copyright © 2016 CItyUAppsLab. All rights reserved.
//

import Foundation
import UIKit
class AlertViewController{
    static let sharedInstance=AlertViewController()
    
    private init() {
        
    }
    func showLoadingAlert(tvc:UINavigationController)->UIAlertController{
        let alertCtrl = UIAlertController(title: "loadData", message: "      ", preferredStyle: UIAlertControllerStyle.Alert )
        tvc.presentViewController(alertCtrl, animated: true, completion: {
            let viewBack:UIView = UIView(frame: CGRectMake(83,10,100,100))
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(50, 10, 37, 37))
            loadingIndicator.center = viewBack.center
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            loadingIndicator.startAnimating();
            alertCtrl.view.addSubview(loadingIndicator)
            viewBack.center = tvc.view.center
        })
        return alertCtrl
    }
    
    func genCancelAction()-> UIAlertAction{
        return UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: {
            (alert: UIAlertAction) -> Void in
        })

    }
    
    func showAlert(nc:UINavigationController,displayTitle:String){
        let alertCtrl = UIAlertController(title: displayTitle, message: nil, preferredStyle: UIAlertControllerStyle.Alert )
        alertCtrl.addAction(genCancelAction())
        nc.presentViewController(alertCtrl, animated: true, completion: {

        })
    }
    
}




