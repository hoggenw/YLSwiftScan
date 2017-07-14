//
//  YLScanViewController.swift
//  YLScan
//
//  Created by 王留根 on 17/1/15.
//  Copyright © 2017年 ios-mac. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

protocol YLScanViewControllerDelegate: class {
    func scanViewControllerSuccessWith(result: YLScanResult)
}

open class YLScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var scanObj: YLScanViewSetting?
    open var scanStyle: YLScanViewSytle = YLScanViewSytle()
    open var qRScanView : YLScanView?
    //启动区域识别功能
    open var isOpenInterestRect = false
    
    //闪光灯
    var btnFlash:UIButton = UIButton()
    
    //返回
    var buttonBcak: UIButton = UIButton()
    
    //相册
    var buttonPhone: UIButton = UIButton()
    
    //识别码的类型
    var arrayCodeType: [String]?
    
    //是否需要识别后的当前图像
    var isNeedCodeImage = false
    
    //
    private var ifShow: Bool = true;
    
    weak var delegate: YLScanViewControllerDelegate?
    
    deinit {
        print("YLScanViewController deinit")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.navigationController?.navigationBar.isHidden = true;

        // Do any additional setup after loading the view.
    }
    open func setNeedCodeImage(needCodeImg: Bool) {
        isNeedCodeImage = needCodeImg;
    }
    //设置框内识别
    open func setOpenInterestRect(isOpen: Bool) {
        isOpenInterestRect = isOpen
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drawScanView()
    }
    open func drawScanView() {
        if qRScanView == nil {
            qRScanView = YLScanView(frame: self.view.frame,scanViewStyle:scanStyle )
            self.view.addSubview(qRScanView!)
        }
            qRScanView?.deviceStartReadying(readyStr: "相机启动中...")
    }
    
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScan()
        initialBottomView()

    }
    override open func viewWillDisappear(_ animated: Bool) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        qRScanView?.stopScanAnimtion()
        
        scanObj?.stop()
    }
    
    func initialBottomView() {
        let size = CGSize(width: 65, height: 87);
        btnFlash.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        btnFlash.center = CGPoint(x: self.view.frame.width - 40, y: self.view.frame.height - 80)

        btnFlash.setImage(YLScanViewSetting.imageFromBundleWithName(name:  "qrcode_scan_btn_flash_nor@2x"), for:UIControlState.normal)
        btnFlash.setImage(YLScanViewSetting.imageFromBundleWithName(name:  "qrcode_scan_btn_flash_down@2x"), for:UIControlState.selected)
        btnFlash.addTarget(self, action: #selector(openOrCloseFlash(sender:)), for: UIControlEvents.touchUpInside)
        
        let sizeBack = CGSize(width: 50, height: 50);
        buttonBcak.bounds = CGRect(x: 0, y: 0, width: sizeBack.width, height: sizeBack.height)
        buttonBcak.center = CGPoint(x: 40, y: 50)
        buttonBcak.layer.cornerRadius = 25
        buttonBcak.clipsToBounds = true;
        buttonBcak.backgroundColor = UIColor.black;
        buttonBcak.alpha = 0.5
        buttonBcak.setImage(YLScanViewSetting.imageFromBundleWithName(name:  "qr_vc_left"), for:UIControlState.normal);
        buttonBcak.addTarget(self, action: #selector(back(sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(buttonBcak)
        
        self.view.addSubview(btnFlash)
        
        
        let sizePhone = CGSize(width: 65, height: 87);
        buttonPhone.bounds = CGRect(x: 0, y: 0, width: sizePhone.width, height: sizePhone.height)
        buttonPhone.center = CGPoint(x: 40, y: self.view.frame.height - 80)
        buttonPhone.clipsToBounds = true;
        buttonPhone.backgroundColor = UIColor.clear;
        buttonPhone.setImage(YLScanViewSetting.imageFromBundleWithName(name: "qrcode_scan_btn_photo_down"), for:UIControlState.normal);
        buttonPhone.addTarget(self, action: #selector(openPhotoAlbum), for: UIControlEvents.touchUpInside)
        self.view.addSubview(buttonPhone)
    }
    //开关闪光灯
    func openOrCloseFlash(sender:UIButton){
        scanObj?.changeTorch()
        sender.isSelected = !sender.isSelected
        
    }
    func back(sender: UIButton) {
        self.navigationController?.popViewController(animated: true);
    }
    
    open func openPhotoAlbum() {
        if(!YLPhonePermissions.isGetPhotoPermission())
        {
            showMsg(title: "提示", message: "没有相册权限，请到设置->隐私中开启本程序相册权限")
        }
        
        let picker = UIImagePickerController()
        
        picker.sourceType = .photoLibrary
        
        picker.delegate = self;
        
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    //MARK: -----相册选择图片识别二维码 （条形码没有找到系统方法）
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var image: UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        } else {
            let arrayResult = YLScanViewSetting.recognizeQRImage(image: image!)
            if arrayResult.count > 0
            {
                handleCodeResult(arrayResult: arrayResult)
                return
            }
        }
        
        showMsg(title: "", message: "识别失败")
    }
    
    open func startScan() {
        if(!YLPhonePermissions.isGetCameraPermission()) {
            showMsg(title: "提示", message: "没有相机权限，请到设置->隐私中开启本程序相机权限")
            return
        }
        
        if (scanObj == nil) {
            var cropRect = CGRect.zero
            if isOpenInterestRect {
                cropRect = YLScanView.getScanRectWithPreview(preview: self.view, style:scanStyle)
            }
            
            //识别各种码，
            //let arrayCode = LBXScanWrapper.defaultMetaDataObjectTypes()
            
            //指定识别几种码
            if arrayCodeType == nil {
                arrayCodeType = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeCode128Code]
            }
            
            scanObj = YLScanViewSetting(videoPreView: self.view,objType:arrayCodeType!, isCaptureImg: isNeedCodeImage,cropRect:cropRect, success: { [weak self] (arrayResult) in
                if let strongSelf = self {
                    //停止扫描动画
                    strongSelf.qRScanView?.stopScanAnimtion()
                    strongSelf.handleCodeResult(arrayResult: arrayResult)
                }
            })
        }
        
        //结束相机等待提示
        qRScanView?.deviceStopReadying()
        
        //开始扫描动画
        qRScanView?.startScanAnimation()
        
        //相机运行
        scanObj?.start()
    }
    /**
     处理扫码结果，如果是继承本控制器的，可以重写该方法,作出相应地处理
     */
    open func handleCodeResult(arrayResult:[YLScanResult]) {
//        for result:YLScanResult in arrayResult
//        {
//            print("\(result.strScanned)")
//        }
        
        let result:YLScanResult = arrayResult[0]
        delegate?.scanViewControllerSuccessWith(result: result)
        _ = self.navigationController?.popViewController(animated: true)
        //showMsg(title: result.strBarCodeType, message: result.strScanned)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showMsg(title: String?,message: String?) {
        if YLScanViewSetting.isSysIos8Later() {
            let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title:  "知道了", style: .default) { [weak self] (alertAction) in
                if let strongSelf = self {
                    strongSelf.startScan()
                }
            }
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
