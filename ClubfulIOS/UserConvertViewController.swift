//
//  UserConvertViewController.swift
//  ClubfulIOS
//
//  Created by guanho on 2016. 8. 22..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit

class UserConvertViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var spin: UIActivityIndicatorView!
    var mypageCtrl : MypageViewController!
    
    @IBOutlet var scrollView: UIScrollView!
    var scrollViewHeight : CGFloat = 0
    @IBOutlet var idField: UITextField!
    @IBOutlet var pwdField: UITextField!
    @IBOutlet var newPwdField: UITextField!
    @IBOutlet var newRepwdField: UITextField!
    @IBOutlet var nicknameField: UITextField!
    
    let user = Storage.getRealmUser()
    
    @IBOutlet var backgroundImage: UIImageView!
    let background_landscape = UIImage(named: "background_landscape.png")
    let background_portrait = UIImage(named: "background_portrait.png")
    
    var isRotated = true
    
    
    //회전됬을때
    func rotated(){
        if(self.isRotated == false && UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
            self.isRotated = true
            self.view.endEditing(true)
            self.scrollViewHeight = self.scrollView.frame.height
            self.backgroundImage.image = self.background_portrait
        }
        if(self.isRotated == true && UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
            self.isRotated = false
            self.view.endEditing(true)
            self.scrollViewHeight = self.scrollView.frame.height
            self.backgroundImage.image = self.background_landscape
        }
    }
    
    
    override func viewDidLoad() {
        print("UserConvertViewController viewDidLoad")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        spin.isHidden = true
        idField.delegate = self
        pwdField.delegate = self
        newPwdField.delegate = self
        newRepwdField.delegate = self
        nicknameField.delegate = self
        
        idField.maxLength(14)
        pwdField.maxLength(14)
        newPwdField.maxLength(14)
        newRepwdField.maxLength(14)
        nicknameField.maxLength(10)
        
        scrollViewHeight = scrollView.frame.height
        
        
        if user.isLogin == 1{
            idField.text = user.userId
        } else if user.isLogin == 2{
            idField.text = "카카오톡으로 로그인 된 아이디입니다."
        } else if user.isLogin == 3{
            idField.text = "페이스북으로 로그인 된 아이디입니다."
        } else if user.isLogin == 4{
            idField.text = "네이버로 로그인 된 아이디입니다."
        }
        nicknameField.text = user.nickName
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
            self.backgroundImage.image = self.background_portrait
        }
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
            self.backgroundImage.image = self.background_landscape
        }
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 1)
            if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation)){
                self.isRotated = true
                self.scrollViewHeight = self.scrollView.frame.height
            }
            if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)){
                self.isRotated = false
                self.scrollViewHeight = self.scrollView.contentSize.height
            }
        }
    }
    
    
    //회원수정 클릭
    @IBAction func convertAction(_ sender: AnyObject) {
        if pwdField.text!.characters.count < 6{
            Util.alert(self, message: "비밀번호를 제대로 입력해주세요.")
        }else if newPwdField.text! != newRepwdField.text!{
            Util.alert(self, message: "새로운 비밀번호가 틀립니다.")
        }else if newPwdField.text!.characters.count != 0 && newPwdField.text!.characters.count < 6{
            Util.alert(self, message: "새로운 비밀번호는 6자리 이상 입력해 주세요.")
        }else if nicknameField.text!.characters.count < 2{
            Util.alert(self, message: "닉네임을 2자 이상 입력해 주세요.")
        }else{
            spin.isHidden = false
            spin.startAnimating()
            let parameters : [String: AnyObject] = ["token": user.token as AnyObject, "userId": user.userId as AnyObject, "password": self.pwdField.text! as AnyObject, "newPassword": self.newPwdField.text! as AnyObject, "gcmId": user.gcmId as AnyObject, "nickName": self.nicknameField.text! as AnyObject]
            URL.request(self, url: URL.apiServer+URL.api_user_update, param: parameters, callback: { (dic) in
                var user = Storage.getRealmUser()
                user = Storage.copyUser()
                user.nickName = self.nicknameField.text!
                Storage.setRealmUser(user)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    //뒤로가기
    @IBAction func backAction(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    //키보드 생김/사라짐 셀렉터
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    //view 사라지기 전 작동
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    //키보드생길때
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentSize.height = self.scrollViewHeight+keyboardSize.height
        }
    }
    //키보드없어질때
    func keyboardWillHide(_ notification: Notification) {
        scrollView.contentSize.height = self.scrollViewHeight
    }
    
    
    //인풋창 끝나면 키보드 없애기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //인풋창 Done가 들어오면 키보드 없애기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
