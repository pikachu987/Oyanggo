//
//  AppSetting.swift
//  ClubfulIOS
//
//  Created by guanho on 2016. 8. 21..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit

class AppSettingViewController : UIViewController{
    @IBOutlet var noticeSwitch: UISwitch!
    @IBOutlet var myCourtSwitch: UISwitch!
    @IBOutlet var distanceSwitch: UISwitch!
    @IBOutlet var interestSwitch: UISwitch!
    
    @IBOutlet var startTime: UIDatePicker!
    @IBOutlet var endTime: UIDatePicker!
    @IBOutlet var timeAndLbl: UILabel!
    
    @IBOutlet var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deviceUser = Storage.getRealmDeviceUser()
        noticeSwitch.isOn = deviceUser.noticePushCheck
        myCourtSwitch.isOn = deviceUser.myCourtPushCheck
        distanceSwitch.isOn = deviceUser.distancePushCheck
        interestSwitch.isOn = deviceUser.interestPushCheck
        
        startTime.date = deviceUser.startPushTime as Date
        endTime.date = deviceUser.endPushTime as Date
        
        switchFn()
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        let user = Storage.getRealmUser()
        let deviceUser = Storage.getRealmDeviceUser()
        let parameters : [String: AnyObject] = ["id": user.userId as AnyObject, "startTime": startTime.date.getTime() as AnyObject, "endTime": endTime.date.getTime() as AnyObject, "noticePush": noticeSwitch.isOn as AnyObject, "myCreateCourtPush": myCourtSwitch.isOn as AnyObject, "distancePush": distanceSwitch.isOn as AnyObject, "interestPush": interestSwitch.isOn as AnyObject]
        
        URLReq.request(self, url: URLReq.apiServer+URLReq.api_user_set, param: parameters, callback: { (dic) in
            deviceUser.noticePushCheck = self.noticeSwitch.isOn
            deviceUser.myCourtPushCheck = self.myCourtSwitch.isOn
            deviceUser.distancePushCheck = self.distanceSwitch.isOn
            deviceUser.interestPushCheck = self.interestSwitch.isOn
            deviceUser.startPushTime = self.startTime.date
            deviceUser.endPushTime = self.endTime.date
            Storage.setRealmDeviceUser(deviceUser)
            
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func noticeAction(_ sender: AnyObject) {
        switchFn()
    }
    @IBAction func myCourtAction(_ sender: AnyObject) {
        switchFn()
    }
    @IBAction func distanceAction(_ sender: AnyObject) {
        switchFn()
    }
    @IBAction func interestAction(_ sender: AnyObject) {
        switchFn()
    }
    
    func switchFn(){
        if noticeSwitch.isOn == false && myCourtSwitch.isOn == false && distanceSwitch.isOn == false && interestSwitch.isOn == false{
            startTime.isHidden = true
            endTime.isHidden = true
            timeAndLbl.isHidden = true
        }else{
            startTime.isHidden = false
            endTime.isHidden = false
            timeAndLbl.isHidden = false
        }
    }
    
    //뒤로가기
    @IBAction func backAction(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    //제스처
    var interactor:Interactor? = nil
    @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let progress = MenuHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .right)
        MenuHelper.mapGestureStateToInteractor(sender.state,progress: progress,interactor: interactor){
            self.dismiss(animated: true, completion: nil)
        }
    }
}
