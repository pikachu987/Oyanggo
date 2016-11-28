//
//  LoginViewController.swift
//  ClubfulIOS
//
//  Created by guanho on 2016. 8. 21..
//  Copyright © 2016년 guanho. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController {
    var preAddress : Address!
    //이전 버튼
    var preBtn : UIButton!
    
    //맵뷰
    @IBOutlet var mapView: MKMapView!
    //마커
    var marker : MKPointAnnotation!
    
    //검색 필드
    @IBOutlet var searchField: UITextField!
    //확인버튼
    @IBOutlet var confirmBtn: UIButton!
    //취소뷰
    @IBOutlet var cancelView: UIView!
    //맵 리스트뷰
    var mapListView : MapListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.keyboardHide(_:))))
        self.marker = MKPointAnnotation()
        self.mapView.addAnnotation(marker)
        let deviceUser = Storage.getRealmDeviceUser()
        var latitude = deviceUser.latitude
        var longitude = deviceUser.longitude
        if deviceUser.isMyLocation == false{
            latitude = deviceUser.deviceLatitude
            longitude = deviceUser.deviceLongitude
        }
        self.locationMove(latitude: latitude, longitude: longitude)
        //맵뷰 터치했을때 이벤트
        self.mapView.isUserInteractionEnabled = true
        self.mapView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(self.mapViewTouch)))
        self.cancelView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(self.cancelAction)))
        self.mapView.delegate = self
        self.searchField.delegate = self
        self.searchField.borderStyle = .none
        //추가정보 뷰 만들기
        if let customView = Bundle.main.loadNibNamed("MapListView", owner: self, options: nil)?.first as? MapListView {
            self.mapListView = customView
            self.mapListView.setLayout(self)
        }
    }
    //지도 위치 수정
    func locationMove(latitude: Double, longitude: Double){
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        self.mapView.setRegion(region, animated: true)
        self.marker.coordinate = location
    }
    //검색 클릭
    func searchAction() {
        self.mapListView.searchAction()
    }
    //등록 클릭
    @IBAction func confirmAction(_ sender: AnyObject) {
        var parameters : [String: AnyObject] = [:]
        parameters.updateValue(self.mapView.region.center.latitude as AnyObject, forKey: "latitude")
        parameters.updateValue(self.mapView.region.center.longitude as AnyObject, forKey: "longitude")
        parameters.updateValue(Util.language as AnyObject, forKey: "language")
        URLReq.request(self, url: URLReq.apiServer+URLReq.api_location_geocode, param: parameters, callback: {(dic) in
            if let result = dic["results"] as? [String: AnyObject]{
                if let results = result["results"] as? [[String: AnyObject]]{
                    if results.count > 0{
                        let element : [String: AnyObject] = results[0]
                        let (_, _, addressShort, address) = Util.googleMapParse(element)
                        
                        self.preAddress.latitude = self.mapView.region.center.latitude
                        self.preAddress.longitude = self.mapView.region.center.longitude
                        self.preAddress.address = address
                        self.preAddress.addressShort = addressShort
                        self.preBtn.setTitle("\(addressShort)", for: UIControlState())
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }else{
                if let isMsgView = dic["isMsgView"] as? Bool{
                    if isMsgView == true{
                        Util.alert(self, message: "\(dic["msg"]!)")
                    }
                }
            }
        })
    }
    
    //뒤로가기
    @IBAction func backAction(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    //취소뷰를 클릭했을 때
    func cancelAction(){
        self.searchField.text = ""
        self.mapListView.hide()
    }
    
    //맵뷰 터치
    func mapViewTouch(){
        self.mapListView.hide()
    }
}

extension MapViewController{
    //뷰 클릭했을때
    func keyboardHide(_ sender: AnyObject){
        self.view.endEditing(true)
    }
}
extension MapViewController: MKMapViewDelegate{
    //맵 렌더링 시작
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude)
        self.marker.coordinate = location
    }
    //맵 렌더링 끝
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude)
        self.marker.coordinate = location
    }
    //맵 지역 변경시작
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude)
        self.marker.coordinate = location
    }
    //맵 지역 변경후
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude)
        self.marker.coordinate = location
    }
}
extension MapViewController: UITextFieldDelegate{
    //키보드 검색이 리턴됫을 때
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.searchField {
            textField.resignFirstResponder()
            self.searchAction()
            return false
        }
        return true
    }
}

extension MapViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mapListView.addressArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let address = self.mapListView.addressArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapListCell", for: indexPath) as! MapListCell
        cell.setAddress(address)
        cell.touchCallback = {(addr: Address) in
            self.mapListView.hideAlpha(){ (_) in
                self.locationMove(latitude: addr.latitude, longitude: addr.longitude)
            }
        }
        return cell
    }
}

extension MapViewController : UITableViewDelegate{
    
}
