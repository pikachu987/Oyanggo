//
//  ViewController.swift
//  Oyanggo
//
//  Created by guanho on 2016. 6. 13..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit
import ActionKit
import Darwin
import MapKit

class ViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    //user 저장소
    var user : User!
    //현재위치 manager
    let locationManager = CLLocationManager()
    //MapView
    @IBOutlet var mapView: MKMapView!
    //마커
    var marker : MKPointAnnotation!
    //blackScreen
    var blackScreen : UIButton!
    //leftScrollView
    var leftCourtView : UIScrollView!
    //centerLocationView
    var centerLocView : UIView!
    //centerLocationScroll
    var centerLocScroll : UIScrollView!
    //네비뷰
    var navView : UIView!
    //코트 검색 필드
    @IBOutlet var courtSearchField: UITextField!
    //코트 등록 버튼
    @IBOutlet var courtInsertBtn: UIButton!
    
    
    
    //내위치 표시 변수
    var myLocationMove = true
    //현재 내위치 검색
    var myLocationSearch = false
    //위치가져왔는지 못가져왔는지
    var isMyLocation = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")
        
        user = Storage.getRealmUser()
        
        //현재 나의 위치설정
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        courtSearchField.delegate = self
        
        
        
        
        
        //layout create
        blackScreen = UIButton().blackScreen()
        leftCourtView = UIScrollView(frame: CGRect(x: 0, y: 80, width: Util.screenSize.width/2, height: Util.screenSize.height-80-self.courtInsertBtn.frame.height), backgroundColor: UIColor.whiteColor())
        centerLocView = UIView(frame: CGRect(x: (Util.screenSize.width-300)/2, y: (Util.screenSize.height-440)/2, width: 300, height: 440), backgroundColor: UIColor.whiteColor())
        navView = UIView(frame: CGRect(x: Util.screenSize.width/5*2, y: 20, width: Util.screenSize.width/5*3, height: Util.screenSize.height-20))
        
        leftCourtView.hidden = true
        centerLocView.hidden = true
        
        self.view.addSubview(blackScreen)
        self.view.addSubview(leftCourtView)
        self.view.addSubview(centerLocView)
        self.view.addSubview(navView)
        
        
        
        
        
        //navView layout
        navLayout()
        
        
        
        
        //centerView layout
        let centerLocHeader = UIView(frame: CGRect(x: 0, y: 0, width: centerLocView.frame.width, height: 60), backgroundColor: Util.commonColor)
        let centerLocHeaderField = UITextField(frame: CGRect(x: 5, y: 10, width: centerLocHeader.frame.width-130, height: 40), placeholder: "현재 위치를 검색하세요.", placeholderColor: UIColor.blackColor(), textAlignment: .Left, delegate: self, fontSize: 15)
        let centerLocHeaderMyLocBtn = UIButton(frame: CGRect(x: centerLocHeader.frame.width-110, y: 10, width: 40, height: 40), image: UIImage(named: "ic_myLocation.png")!)
        let centerLocHeaderBtn = UIButton(frame: CGRect(x: centerLocHeader.frame.width-55, y: 10, width: 50, height: 40), text: "검색", fontSize: 13)
        centerLocScroll = UIScrollView(frame: CGRect(x: 0, y: 60, width: centerLocView.frame.width, height: centerLocView.frame.height-60), backgroundColor: UIColor.whiteColor())
        
        centerLocHeaderBtn.boxLayout(radius: 6, borderWidth: 1, backgroundColor: UIColor.grayColor(), borderColor: UIColor.blackColor())
        centerLocHeaderField.returnKeyType = UIReturnKeyType.Done
        
        centerLocView.addSubview(centerLocHeader)
        centerLocHeader.addSubview(centerLocHeaderField)
        centerLocHeader.addSubview(centerLocHeaderMyLocBtn)
        centerLocHeader.addSubview(centerLocHeaderBtn)
        centerLocView.addSubview(centerLocScroll)
        
        
        
        
        
        
        let location = setMapLocation(user.latitude, longitude: user.longitude)
        initMarket(location)
        
        
        //맵뷰 터치했을때 이벤트
        self.mapView.userInteractionEnabled = true
        self.mapView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(self.mapViewTouch(_:))))
        
        
        //delegete 앱이 살아났을때??
        let window = UIApplication.sharedApplication().windows[0] as UIWindow;
        UIView.transitionFromView(
            window.rootViewController!.view,
            toView: self.view,
            duration: 0.65,
            options: .TransitionCrossDissolve,
            completion: {
                finished in window.rootViewController = self
        })
        
        
        
        
        
        //event
        
        
        
        //자기위치 가져오기
        centerLocHeaderMyLocBtn.addControlEvent(.TouchUpInside){
            self.blackScreen.hidden = true
            self.centerLocView.hidden = true
            self.myLocationSearch = false
            self.myLocationMove = true
            if self.isMyLocation == false{
                Util.alert(message: "설정-오양고에 들어가셔서 위치 항상을 눌려주세요.", ctrl: self)
            }else{
                self.locationManager.startUpdatingLocation()
            }
        }
        
        
        
        //검색어 기반 검색하기
        centerLocHeaderBtn.addControlEvent(.TouchUpInside){
            if centerLocHeaderField.text?.characters.count >= 2{
                self.view.endEditing(true)
                self.centerLocScroll.subviews.forEach({$0.removeFromSuperview()})
                //자기위치 검색 통신
                var i : CGFloat = 0
                let locObjHeight : CGFloat = 80
                for j in 0 ... 10{
                    let objBtn = UIButton(frame: CGRect(x: 0, y: locObjHeight*i, width: self.centerLocScroll.frame.width, height: locObjHeight-1))
                    let addressShortLbl = UILabel(frame: CGRect(x: 5, y: 10, width: objBtn.frame.width-5, height: 15), text: "어디어디주소", color: UIColor.blackColor(), textAlignment: .Left, fontSize: 17)
                    let addressLbl = UILabel(frame: CGRect(x: 5, y: 25, width: objBtn.frame.width-5, height: 65), text: "어디어디주소길게길게어디어디주소길게길게어디어디주소길게길게", color: UIColor.blackColor(), textAlignment: .Left, fontSize: 13)
                    addressLbl.numberOfLines = 2
                    objBtn.boxBorder(.Bottom, borderWidth: 1, color: UIColor.blackColor())
                    self.centerLocScroll.addSubview(objBtn)
                    objBtn.addSubview(addressShortLbl)
                    objBtn.addSubview(addressLbl)
                    
                    objBtn.addControlEvent(.TouchUpInside){
                        self.blackScreen.hidden = true
                        self.centerLocView.hidden = true
                        let user = Storage.copyUser()
                        user.latitude = 37.5571274
                        user.longitude = 126.9239304
                        user.address = "어디어디주소길게길게어디어디주소길게길게어디어디주소길게길게"
                        user.addressShort = "어디어디주소"
                        Storage.setRealmUser(user)
                        self.myLocationSearch = true
                        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.5571274, 126.9239304)
                        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                        self.mapView.region = region
                        self.marker.coordinate = location
                    }
                    i += 1
                }
                self.centerLocScroll.contentSize = CGSize(width: self.centerLocScroll.frame.width, height: locObjHeight*i)
            }else{
                Util.alert(message: "검색어는 2글자 이상으로 넣어주세요.", ctrl: self)
            }
        }
        
        
        //블랙스크린 클릭
        blackScreen.addControlEvent(.TouchUpInside){
            if self.leftCourtView.hidden == false{
                self.leftCourtView.hidden = true
                self.blackScreen.hidden = true
            }
            if self.centerLocView.hidden == false{
                self.centerLocView.hidden = true
                self.blackScreen.hidden = true
            }
            if self.navView.hidden == false{
                let tmpRect = self.navView.frame
                //애니메이션 적용
                UIView.animateWithDuration(0.2, animations: {
                    self.navView.frame = CGRect(x: Util.screenSize.width, y: 20, width: tmpRect.width, height: tmpRect.height)
                    }, completion: {(_) in
                        self.blackScreen.hidden = true
                        self.navView.hidden = true
                        self.navView.frame = CGRect(x: Util.screenSize.width, y: 0, width: tmpRect.width, height: tmpRect.height)
                })
            }
            
        }
        
        
        
    }
    
    
    
    
    
    
    //맵뷰 터치
    func mapViewTouch(sender: AnyObject){
        self.view.endEditing(true)
        leftCourtView.subviews.forEach({$0.removeFromSuperview()})
        leftCourtView.scrollToTop()
        leftCourtView.hidden = true
    }
    
    //mapView init
    func initMarket(location : CLLocationCoordinate2D){
        self.marker = MKPointAnnotation()
        mapView.addAnnotation(self.marker)
        markerMove(location)
    }
    
    //mapView 위치 이동
    func setMapLocation(latitude: Double, longitude: Double, mapViewRegion : Bool = true) -> CLLocationCoordinate2D{
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        if mapViewRegion == true{
            mapView.setRegion(region, animated: true)
        }
        return location
    }
    
    //marker 위치 이동
    func markerMove(location : CLLocationCoordinate2D){
        self.marker.coordinate = location
    }
    
    
    //왼쪽이미지 클릭
    @IBAction func myLocationAction(sender: AnyObject) {
        centerLocScroll.subviews.forEach({$0.removeFromSuperview()})
        centerLocScroll.scrollToTop()
        blackScreen.hidden = false
        centerLocView.hidden = false
        leftCourtView.hidden = true
    }
    
    //검색 클릭
    @IBAction func courtSearchAction(sender: AnyObject) {
        if courtSearchField.text?.characters.count >= 2{
            self.view.endEditing(true)
            leftCourtView.subviews.forEach({$0.removeFromSuperview()})
            leftCourtView.scrollToTop()
            leftCourtView.hidden = false
            //코트 검색 통신
            var i : CGFloat = 0
            let locObjHeight : CGFloat = 80
            for j in 0 ... 10{
                let objBtn = UIButton(frame: CGRect(x: 0, y: locObjHeight*i, width: leftCourtView.frame.width, height: locObjHeight-1))
                let addressShortLbl = UILabel(frame: CGRect(x: 5, y: 10, width: objBtn.frame.width-5, height: 15), text: "1234어디주소", color: UIColor.blackColor(), textAlignment: .Left, fontSize: 17)
                let addressLbl = UILabel(frame: CGRect(x: 5, y: 25, width: objBtn.frame.width-5, height: 65), text: "어디어디주소길게길게어디어디주소길게길게어디어디주소길게길게", color: UIColor.blackColor(), textAlignment: .Left, fontSize: 13)
                addressLbl.numberOfLines = 2
                objBtn.boxBorder(.Bottom, borderWidth: 1, color: UIColor.blackColor())
                leftCourtView.addSubview(objBtn)
                objBtn.addSubview(addressShortLbl)
                objBtn.addSubview(addressLbl)
                
                objBtn.addControlEvent(.TouchUpInside){
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let uvc = storyBoard.instantiateViewControllerWithIdentifier("courtVC")
                    (uvc as! CourtViewController).courtSeq = j
                    uvc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                    self.presentViewController(uvc, animated: true, completion: nil)
                }
                i += 1
            }
            leftCourtView.contentSize = CGSize(width: leftCourtView.frame.width, height: locObjHeight*i)
        }else{
            Util.alert(message: "검색어는 2글자 이상으로 넣어주세요.", ctrl: self)
        }
    }
    
    //네비 클릭
    @IBAction func navAction(sender: AnyObject) {
        blackScreen.hidden = false
        leftCourtView.hidden = true
        
        let tmpRect = navView.frame
        navView.frame = CGRect(x: Util.screenSize.width, y: 20, width: tmpRect.width, height: tmpRect.height)
        navView.hidden = false
        //애니메이션 적용
        UIView.animateWithDuration(0.2, animations: {
            self.navView.frame = CGRect(x: Util.screenSize.width-tmpRect.width, y: 20, width: tmpRect.width, height: tmpRect.height)
            }, completion: nil)
    }
    
    
    //코트등록 클릭
    @IBAction func courtInsertAction(sender: AnyObject) {
        if user.isLogin == -1{
            Util.alert(message: "로그인을 하셔야 이용 가능합니다.", ctrl: self)
        }else{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let uvc = storyBoard.instantiateViewControllerWithIdentifier("courtCreateVC")
            uvc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            self.presentViewController(uvc, animated: true, completion: nil)
        }
    }
    
    //현재 나의 위치
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isMyLocation = true
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        if myLocationSearch == false{
            user = Storage.copyUser()
            user.latitude = locValue.latitude
            user.longitude = locValue.longitude
            Storage.setRealmUser(user)
            let appDelegateLocationMove = (UIApplication.sharedApplication().delegate as! AppDelegate).vcMyLocationMove
            
            if myLocationMove == true || appDelegateLocationMove == true{
                myLocationMove = false
                (UIApplication.sharedApplication().delegate as! AppDelegate).vcMyLocationMove = false
                let location = setMapLocation(user.latitude, longitude: user.longitude)
                markerMove(location)
            }else{
                let location = setMapLocation(user.latitude, longitude: user.longitude, mapViewRegion: false)
                markerMove(location)
            }
        }
    }
    
    
    
    //현재 나의위치 가져오기 실패함
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        isMyLocation = false
        if NSProcessInfo.processInfo().environment["SIMULATOR_DEVICE_NAME"] != nil{
            print("It's an iOS Simulator")
        }else{
            print("It's a device")
            Util.alert(message: "설정-오양고에 들어가셔서 위치 항상을 눌려주세요.", ctrl: self)
        }
    }
    
    
    //인풋창 끝나면 키보드 없애기
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    //인풋창 Done가 들어오면 키보드 없애기
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    //////////navLayout
    func navLayout(){
        navView.backgroundColor = UIColor.whiteColor()
        navView.hidden = true
        
        let logView = UIView(frame: CGRect(x: 0, y: 0, width: navView.frame.width, height: 40))
        let logBtn = UIButton(frame: CGRect(x: 0, y: 0, width: logView.frame.width-60, height: logView.frame.height))
        let settingBtn = UIButton(frame: CGRect(x: logView.frame.width-40, y: 7.5, width: 25, height: 25), image: UIImage(named: "ic_navi_setting.png")!)
        let mypageBtn = UIButton(frame: CGRect(x: 0, y: 41, width: navView.frame.width, height: 40))
        let messageBtn = UIButton(frame: CGRect(x: 0, y: 90, width: navView.frame.width, height: 40))
        let friendBtn = UIButton(frame: CGRect(x: 0, y:140, width: navView.frame.width, height: 40))
        let noticeBtn = UIButton(frame: CGRect(x: 0, y: 181, width: navView.frame.width, height: 40))
        let appInfoBtn = UIButton(frame: CGRect(x: 0, y: 230, width: navView.frame.width, height: 40))
        let guideBtn = UIButton(frame: CGRect(x: 0, y: 280, width: navView.frame.width, height: 40))
        let inquiryBtn = UIButton(frame: CGRect(x: 0, y: 330, width: navView.frame.width, height: 40))
        let courtInsertBtn = UIButton(frame: CGRect(x: 10, y: navView.frame.height-50, width: navView.frame.width-20, height: 40), text: "코트등록", color: UIColor.whiteColor(), fontSize: 17)
        
        let mainView = UIImageView(frame: CGRect(x: 5, y: 2.5, width: 35, height: 35), image: UIImage(named: "ic_navi_main.png")!)
        let mypageImg = UIImageView(frame: CGRect(x: 10, y: 7.5, width: 25, height: 25), image: UIImage(named: "ic_navi_mypage.png")!)
        let messageImg = UIImageView(frame: CGRect(x: 10, y: 7.5, width: 25, height: 25), image: UIImage(named: "ic_navi_message.png")!)
        let friendImg = UIImageView(frame: CGRect(x: 10, y: 7.5, width: 25, height: 25), image: UIImage(named: "ic_navi_friend.png")!)
        let noticeImg = UIImageView(frame: CGRect(x: 10, y: 7.5, width: 25, height: 25), image: UIImage(named: "ic_navi_notice.png")!)
        let appInfoImg = UIImageView(frame: CGRect(x: 10, y: 7.5, width: 25, height: 25), image: UIImage(named: "ic_navi_appInfo.png")!)
        let guideImg = UIImageView(frame: CGRect(x: 10, y: 7.5, width: 25, height: 25), image: UIImage(named: "ic_navi_guide.png")!)
        let inquiryImg = UIImageView(frame: CGRect(x: 10, y: 7.5, width: 25, height: 25), image: UIImage(named: "ic_navi_inquiry.png")!)
        
        var loginStr = "로그아웃"
        if user.isLogin == -1{
            loginStr = "로그인"
        }
        
        let logLbl = UILabel(frame: CGRect(x: 50, y: 0, width: logBtn.frame.width-50, height: logBtn.frame.height), text: loginStr, color: UIColor.blackColor(), textAlignment: .Left, fontSize: 17)
        let mypageLbl = UILabel(frame: CGRect(x: 50, y: 0, width: mypageBtn.frame.width-50, height: mypageBtn.frame.height), text: "내정보", color: UIColor.blackColor(), textAlignment: .Left, fontSize: 17)
        let messageLbl = UILabel(frame: CGRect(x: 50, y: 0, width: messageBtn.frame.width-50, height: messageBtn.frame.height), text: "쪽지함", color: UIColor.blackColor(), textAlignment: .Left, fontSize: 17)
        let friendLbl = UILabel(frame: CGRect(x: 50, y: 0, width: friendBtn.frame.width-50, height: friendBtn.frame.height), text: "친구초대", color: UIColor.blackColor(), textAlignment: .Left, fontSize: 17)
        let noticeLbl = UILabel(frame: CGRect(x: 50, y: 0, width: noticeBtn.frame.width-50, height: noticeBtn.frame.height), text: "공지사항", color: UIColor.blackColor(), textAlignment: .Left, fontSize: 17)
        let appInfoLbl = UILabel(frame: CGRect(x: 50, y: 0, width: appInfoBtn.frame.width-50, height: appInfoBtn.frame.height), text: "앱정보", color: UIColor.blackColor(), textAlignment: .Left, fontSize: 17)
        let guideLbl = UILabel(frame: CGRect(x: 50, y: 0, width: guideBtn.frame.width-50, height: guideBtn.frame.height), text: "가이드", color: UIColor.blackColor(), textAlignment: .Left, fontSize: 17)
        let inquiryLbl = UILabel(frame: CGRect(x: 50, y: 0, width: inquiryBtn.frame.width-50, height: inquiryBtn.frame.height), text: "문의하기", color: UIColor.blackColor(), textAlignment: .Left, fontSize: 17)
        
        logView.boxBorder(.Bottom, borderWidth: 1, color: UIColor.blackColor())
        friendBtn.boxBorder(.Bottom, borderWidth: 1, color: UIColor.blackColor())
        courtInsertBtn.boxLayout(radius: 6, backgroundColor: UIColor.blackColor())
        
        navView.addSubview(logView)
        navView.addSubview(settingBtn)
        navView.addSubview(mypageBtn)
        navView.addSubview(messageBtn)
        navView.addSubview(friendBtn)
        navView.addSubview(noticeBtn)
        navView.addSubview(appInfoBtn)
        navView.addSubview(guideBtn)
        navView.addSubview(inquiryBtn)
        navView.addSubview(courtInsertBtn)
        
        logView.addSubview(logBtn)
        logView.addSubview(settingBtn)
        
        logBtn.addSubview(mainView)
        mypageBtn.addSubview(mypageImg)
        messageBtn.addSubview(messageImg)
        friendBtn.addSubview(friendImg)
        noticeBtn.addSubview(noticeImg)
        appInfoBtn.addSubview(appInfoImg)
        guideBtn.addSubview(guideImg)
        inquiryBtn.addSubview(inquiryImg)
        
        logBtn.addSubview(logLbl)
        mypageBtn.addSubview(mypageLbl)
        messageBtn.addSubview(messageLbl)
        friendBtn.addSubview(friendLbl)
        noticeBtn.addSubview(noticeLbl)
        appInfoBtn.addSubview(appInfoLbl)
        guideBtn.addSubview(guideLbl)
        inquiryBtn.addSubview(inquiryLbl)
        
        func storyBoard(destination : String){
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let uvc = storyBoard.instantiateViewControllerWithIdentifier(destination)
            if uvc.classForCoder != self.classForCoder{
                uvc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                self.presentViewController(uvc, animated: true, completion: nil)
            }
        }
        
        logBtn.addControlEvent(.TouchUpInside){
            func logout(){
                self.user = Storage.copyUser()
                self.user.isLogin = -1
                Storage.setRealmUser(self.user)
                logLbl.text = "로그인"
                self.blackScreen.hidden = true
                self.navView.hidden = true
            }
            if self.user.isLogin == -1{
                storyBoard("loginVC")
            }else{
                if self.user.isLogin == 1{
                    Util.alert("로그아웃", message: "로그아웃 하시겠습니까?", confirmTitle: "확인", ctrl: self, cancelStr: "취소", confirmHandler: {(_) in
                        logout()
                    })
                }else if self.user.isLogin == 2{
                    Util.alert("로그아웃", message: "페이스북로그아웃 하시겠습니까?", confirmTitle: "확인", ctrl: self, cancelStr: "취소", confirmHandler: {(_) in
                        logout()
                    })
                }else if self.user.isLogin == 3{
                    Util.alert("로그아웃", message: "카카오톡로그아웃 하시겠습니까?", confirmTitle: "확인", ctrl: self, cancelStr: "취소", confirmHandler: {(_) in
                        logout()
                    })
                }
            }
        }
        settingBtn.addControlEvent(.TouchUpInside){
            storyBoard("settingVC")
        }
        mypageBtn.addControlEvent(.TouchUpInside){
            if self.user.isLogin == -1{
                Util.alert(message: "로그인을 하셔야 이용 가능합니다.", ctrl: self)
            }else{
                storyBoard("mypageVC")
            }
        }
        
        
        func dummyLinkObject() -> [KakaoTalkLinkObject] {
            let image = KakaoTalkLinkObject.createImage("https://developers.kakao.com/assets/img/link_sample.jpg", width: 138, height: 80)
            let androidAppAction = KakaoTalkLinkAction.createAppAction(KakaoTalkLinkActionOSPlatform.Android, devicetype: KakaoTalkLinkActionDeviceType.Phone, execparam: [:])
            let iphoneAppAction = KakaoTalkLinkAction.createAppAction(KakaoTalkLinkActionOSPlatform.IOS, devicetype: KakaoTalkLinkActionDeviceType.Phone, execparam: [:])
            let ipadAppAction = KakaoTalkLinkAction.createAppAction(KakaoTalkLinkActionOSPlatform.IOS, devicetype: KakaoTalkLinkActionDeviceType.Pad, execparam: [:])
            let appLink = KakaoTalkLinkObject.createAppButton("앱 열기", actions: [androidAppAction, iphoneAppAction, ipadAppAction])
            return [image, appLink]
        }
        messageBtn.addControlEvent(.TouchUpInside){
            if self.user.isLogin == -1{
                Util.alert(message: "로그인을 하셔야 이용 가능합니다.", ctrl: self)
            }else{
                storyBoard("memoVC")
            }
        }
        friendBtn.addControlEvent(.TouchUpInside){
            if KOAppCall.canOpenKakaoTalkAppLink() {
                KOAppCall.openKakaoTalkAppLink(dummyLinkObject())
            } else {
                print("Cannot open kakaotalk.")
            }
        }
        noticeBtn.addControlEvent(.TouchUpInside){
            storyBoard("noticeVC")
        }
        appInfoBtn.addControlEvent(.TouchUpInside){
            storyBoard("appVersionVC")
        }
        guideBtn.addControlEvent(.TouchUpInside){
            storyBoard("appGuideVC")
        }
        inquiryBtn.addControlEvent(.TouchUpInside){
            storyBoard("inquiryVC")
        }
        courtInsertBtn.addControlEvent(.TouchUpInside){
            if self.user.isLogin == -1{
                Util.alert(message: "로그인을 하셔야 이용 가능합니다.", ctrl: self)
            }else{
                storyBoard("courtCreateVC")
            }
        }
    }
}

