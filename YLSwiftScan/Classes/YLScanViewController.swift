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

protocol YLScanViewControllerDelegate {
    func scanViewControllerSuccessWith(result: YLScanResult)
}

open class YLScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var scanObj: YLScanViewSetting?
    open var scanStyle: YLScanViewSytle = YLScanViewSytle()
    open var qRScanView : YLScanView?
    //启动区域识别功能
    open var isOpenInterestRect = false
    
    //识别码的类型
    var arrayCodeType: [String]?
    
    //是否需要识别后的当前图像
    var isNeedCodeImage = false
    
    var delegate: YLScanViewControllerDelegate?
    
    deinit {
        print("YLScanViewController deinit")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)

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
    }
    override open func viewWillDisappear(_ animated: Bool) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        qRScanView?.stopScanAnimtion()
        
        scanObj?.stop()
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
        for result:YLScanResult in arrayResult
        {
            print("\(result.strScanned)")
        }
        
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
