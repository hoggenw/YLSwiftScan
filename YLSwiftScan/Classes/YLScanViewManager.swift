//
//  YLScanViewManager.swift
//  YLScan
//
//  Created by 王留根 on 17/1/17.
//  Copyright © 2017年 ios-mac. All rights reserved.
//

import UIKit


public enum  YLAnimationImageStyle{
    case firstLine
    case secondeLine
    case firstNetGrid
    case secondeNetGrid
}

public protocol YLScanViewManagerDelegate {
    func scanSuccessWith(result: YLScanResult)
}

public class YLScanViewManager: NSObject {
    //是否需要扫描框
    public var isNeedShowRetangle:Bool? {
        didSet {
            if let _ = isNeedShowRetangle {
                 scanViewController.scanStyle.isNeedShowRetangle = isNeedShowRetangle!
            }
        }
    }
    /**
    * 矩形框线条颜色，默认白色
    */
    public var colorRetangleLine:UIColor? {
        didSet {
            if let _ = colorRetangleLine {
                scanViewController.scanStyle.colorRetangleLine = colorRetangleLine!
            }
            
        }
    }
    /**
     *  默认扫码区域为正方形，如果扫码区域不是正方形，设置宽高比
     */
    public var whRatio: CGFloat? {
        didSet {
            if let  _ = whRatio {
                scanViewController.scanStyle.whRatio = whRatio!
            }
            
        }
    }
    /**
     *  矩形框(视频显示透明区)域向上移动偏移量，0表示扫码透明区域在当前视图中心位置，如果负值表示扫码区域下移(默认44)
     */
    public var centerUpOffset:CGFloat? {
        didSet {
            if let _ = centerUpOffset {
                scanViewController.scanStyle.centerUpOffset = centerUpOffset!
            }
            
        }
    }
    /**
     *  矩形框宽度
     */
    public var scanViewWidth: CGFloat? {
        didSet {
            if let _ = scanViewWidth {
                scanViewController.scanStyle.xScanRetangleOffset = (UIScreen.main.bounds.size.width - scanViewWidth!) / 2
            }
            
        }
    }
    //MARK -矩形框(扫码区域)周围4个角
    
    /**
     *  扫码区域的4个角类型
     */
    public var photoframeAngleStyle: YLScanViewPhotoframeAngleStyle? {
        didSet {
            if let _ =  photoframeAngleStyle{
                scanViewController.scanStyle.photoframeAngleStyle = photoframeAngleStyle!
            }
            
        }
    }
    
    //4个角的颜色
    public var colorAngle: UIColor? {
        didSet {
            if let _ = colorAngle {
                scanViewController.scanStyle.colorAngle = colorAngle!
            }
            
        }
    }
    
    /**
       扫码区域4个角的线条宽度,默认6，建议8到4之间
     */
    public var photoframeLineW:CGFloat? {
        didSet {
            if let _ = photoframeLineW {
                scanViewController.scanStyle.photoframeLineW = photoframeLineW!
            }
            
        }
    }
    /**
    *  自带扫描动画image样式
    */
    public var imageStyle:YLAnimationImageStyle? {
        didSet {
            if let _ = imageStyle {
                switch imageStyle! {
                case .firstLine:
                    scanViewController.scanStyle.animationImage = YLScanViewSetting.imageFromBundleWithName(name: "qrcode_Scan_weixin_Line@2x")
                case .secondeLine :
                    scanViewController.scanStyle.animationImage = YLScanViewSetting.imageFromBundleWithName(name:  "qrcode_scan_light_green@2x")
                case .firstNetGrid :
                    scanViewController.scanStyle.animationImage = YLScanViewSetting.imageFromBundleWithName(name: "qrcode_scan_full_net")
                case .secondeNetGrid :
                    scanViewController.scanStyle.animationImage = YLScanViewSetting.imageFromBundleWithName(name:  "qrcode_scan_part_net")
                }
            }
        }
    }
    /**
     *  动画效果的图像，自定义图像
     */
    public var animationImage:UIImage? {
        didSet {
            if let _ = animationImage {
               scanViewController.scanStyle.animationImage = animationImage!
            }
            
        }
    }
    
    public static let scanViewManager = YLScanViewManager()
    private var scanViewController = YLScanViewController()
    public var delegate: YLScanViewManagerDelegate?

    
    public class func shareManager() -> YLScanViewManager {
        return scanViewManager;
    }

    //显示扫描界面
    public func showScanView(viewController: UIViewController) {
        scanViewController.delegate = self
        viewController.navigationController?.pushViewController(scanViewController, animated: true)
    }
    //生成二维码界面
    /*
     frame: 生成视图的frame
     logoIconName：是否需要logo。可选
     codeMessage： 二维码包含信息
     **/
    public func produceQRcodeView(frame:CGRect, logoIconName:String? ,codeMessage: String) -> UIView {
        let QRCodeView = YLScanViewSetting.QRcodeView
        QRCodeView.frame = frame
        let imageView = YLScanViewSetting.creatQRCodeView(bound: QRCodeView.bounds, codeMessage:codeMessage, logoName: logoIconName)
        QRCodeView.addSubview(imageView)
        return QRCodeView
    }
    
}

extension YLScanViewManager: YLScanViewControllerDelegate {
    func scanViewControllerSuccessWith(result: YLScanResult) {
        delegate?.scanSuccessWith(result: result)
    }
}
