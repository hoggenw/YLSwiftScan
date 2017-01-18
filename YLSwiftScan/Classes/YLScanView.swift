//
//  YLScanView.swift
//  YLScan
//
//  Created by 王留根 on 17/1/15.
//  Copyright © 2017年 ios-mac. All rights reserved.
//

import UIKit

open class YLScanView: UIView {
    //默认设置
    var viewStyle: YLScanViewSytle = YLScanViewSytle()
    //扫描区域
    var scanRetangleRect: CGRect = CGRect.zero
    //扫描线
    var scanLineAnimation: YLScanLineAnimation?
    //网格扫描线
    var scanNetAnimation: YLScanLineAnimation?
    //线条在中间位置，不移动
    var fixedLine:UIImageView = UIImageView()
    //启动相机时的等待
    var activityView: UIActivityIndicatorView?
    //启动相机时的等待文字
    var labelReadying: UILabel?
    //动画运行状态
    var isAnimationing: Bool = false
    
    deinit {
        if (scanLineAnimation != nil)
        {
            scanLineAnimation?.stopStepAnimation()
        }
        if (scanNetAnimation != nil)
        {
            scanNetAnimation?.stopStepAnimation()
        }
        print("YLScanView deinit")
    }
    
    
    public init(frame: CGRect, scanViewStyle: YLScanViewSytle?) {
        var frameTmp = frame;
        frameTmp.origin = CGPoint.zero
        super.init(frame: frameTmp)
        if let _scanViewStyle = scanViewStyle {
            viewStyle = _scanViewStyle
        }
        switch viewStyle.animationStyle {
        case .LineMove:
            scanLineAnimation = YLScanLineAnimation.instance()
        case .NetGrid:
            scanNetAnimation = YLScanLineAnimation.nerGridInstance()
        case .LineStill:
            fixedLine.image = viewStyle.animationImage
        default:
            break
        }
        backgroundColor = UIColor.clear
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///UI
    override open func draw(_ rect: CGRect) {
        drawScanRect()
    }
    
    func drawScanRect() {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        var sizeRetangle: CGSize = CGSize(width: frame.size.width - XRetangleLeft * 2, height: frame.size.width -  XRetangleLeft * 2)
        if viewStyle.whRatio != 1.0 {
            let width = sizeRetangle.width
            var height = width / viewStyle.whRatio
            height = CGFloat(Int(height))
            sizeRetangle = CGSize(width: width, height: height)
        }
        //扫描区域Y轴最小坐标
        let YminRetangle = frame.size.height/2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        let YmaxRetangle = YminRetangle + sizeRetangle.height
        let XretangleRight = frame.size.width - XRetangleLeft
        //非扫码区域绘制
        let context = UIGraphicsGetCurrentContext()!
        //非扫码区域半透明
          //设置非识别区域颜色
        context.setFillColor(red: viewStyle.red_notRecoginitonArea, green: viewStyle.green_notRecoginitonArea,
                              blue: viewStyle.blue_notRecoginitonArea, alpha: viewStyle.alpa_notRecoginitonArea)
        //填充区域
        //扫码区域上填充
        var rect = CGRect(x: 0, y: 0, width: frame.size.width, height: YminRetangle)
        context.fill(rect)
        //左边
        rect = CGRect(x: 0, y: YminRetangle, width: XRetangleLeft, height: sizeRetangle.height)
        context.fill(rect)
        //右边
        rect = CGRect(x: XretangleRight, y: YminRetangle, width: XRetangleLeft, height: sizeRetangle.height)
        context.fill(rect)
        //下边
        rect = CGRect(x: 0, y: YmaxRetangle, width: frame.size.width, height: frame.size.height - YmaxRetangle)
        context.fill(rect)
        //执行绘画
        context.strokePath()
        
        if viewStyle.isNeedShowRetangle {
            context.setStrokeColor(viewStyle.colorRetangleLine.cgColor)
            context.setLineWidth(1)
            context.addRect(CGRect(x: XRetangleLeft, y: YminRetangle, width: sizeRetangle.width, height: sizeRetangle.height))
            context.strokePath()
        }
        scanRetangleRect = CGRect(x: XRetangleLeft, y: YminRetangle, width: sizeRetangle.width, height: sizeRetangle.height)
        //画矩形框的框度和高度
        let widthAnlge = viewStyle.photoframeAngleW
        let heightAnlge = viewStyle.photoframeAngleH
        //4个角的线的高度
        let linewidthAngle = viewStyle.photoframeLineW
        //画扫码矩形以及周边半透明黑色坐标参数
        var diffAngle = linewidthAngle/3;//框外面4个角，与框紧密联系在一起
//        diffAngle = linewidthAngle / 2; //框外面4个角，与框有缝隙
//        diffAngle = linewidthAngle/2;  //框4个角 在线上加4个角效果
//        diffAngle = 0;//与矩形框重合
        switch viewStyle.photoframeAngleStyle {
        case .Outer:
             diffAngle = linewidthAngle/3;//框外面4个角，与框紧密联系在一起
        case .On:
            diffAngle = 0;//与矩形框重合
        case .Inner:
            diffAngle = -viewStyle.photoframeLineW/2
        }
        context.setStrokeColor(viewStyle.colorAngle.cgColor);
        context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
        context.setLineWidth(linewidthAngle);
        
        //
        let leftX = XRetangleLeft - diffAngle
        let topY = YminRetangle - diffAngle
        let rightX = XretangleRight + diffAngle
        let bottomY = YmaxRetangle + diffAngle
        //左上角水平线
        context.move(to: CGPoint(x: leftX-linewidthAngle/2, y: topY))
        context.addLine(to: CGPoint(x: leftX + widthAnlge, y: topY))
        
        //左上角垂直线
        context.move(to: CGPoint(x: leftX, y: topY-linewidthAngle/2))
        context.addLine(to: CGPoint(x: leftX, y: topY+heightAnlge))
        
        //左下角水平线
        context.move(to: CGPoint(x: leftX-linewidthAngle/2, y: bottomY))
        context.addLine(to: CGPoint(x: leftX + widthAnlge, y: bottomY))
        
        //左下角垂直线
        context.move(to: CGPoint(x: leftX, y: bottomY+linewidthAngle/2))
        context.addLine(to: CGPoint(x: leftX, y: bottomY - heightAnlge))
        
        //右上角水平线
        context.move(to: CGPoint(x: rightX+linewidthAngle/2, y: topY))
        context.addLine(to: CGPoint(x: rightX - widthAnlge, y: topY))
        
        //右上角垂直线
        context.move(to: CGPoint(x: rightX, y: topY-linewidthAngle/2))
        context.addLine(to: CGPoint(x: rightX, y: topY + heightAnlge))
        
        //        右下角水平线
        context.move(to: CGPoint(x: rightX+linewidthAngle/2, y: bottomY))
        context.addLine(to: CGPoint(x: rightX - widthAnlge, y: bottomY))
        
        //右下角垂直线
        context.move(to: CGPoint(x: rightX, y: bottomY+linewidthAngle/2))
        context.addLine(to: CGPoint(x: rightX, y: bottomY - heightAnlge))
        
        context.strokePath()
    }
    
    func startScanAnimation() {
        guard !isAnimationing else {
            return
        }
        isAnimationing = true
        //扫码区域坐标
        let cropRect: CGRect = YLScanView.getScanRectForAnimation(viewStyle: viewStyle, frame: self.frame)
        switch viewStyle.animationStyle {
        case .LineMove:
            scanLineAnimation?.startAnimationingWithRect(animationRect: cropRect, parentView: self, image: viewStyle.animationImage)
        case .NetGrid:
            scanNetAnimation?.startAnimationingWithRect(animationRect: cropRect, parentView: self, image: viewStyle.animationImage)
        case .LineStill:
            let stillRect = CGRect(x: cropRect.origin.x+20,
                                   y: cropRect.origin.y + cropRect.size.height/2,
                                   width: cropRect.size.width-40,
                                   height: 2);
            fixedLine.frame = stillRect
            addSubview(fixedLine)
            fixedLine.isHidden = false
        default:
            break
        }
    }
    func deviceStartReadying(readyStr:String)
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        
        let sizeRetangle = getRetangeSize()
        
        //扫码区域Y轴最小坐标
        let YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        
        //设备启动状态提示
        if (activityView == nil)
        {
            self.activityView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            
            activityView?.center = CGPoint(x: XRetangleLeft +  sizeRetangle.width/2 - 50, y: YMinRetangle + sizeRetangle.height/2)
            activityView?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            
            addSubview(activityView!)
            
            
            let labelReadyRect = CGRect(x: activityView!.frame.origin.x + activityView!.frame.size.width + 10, y: activityView!.frame.origin.y, width: 100, height: 30);
            //print("%@",NSStringFromCGRect(labelReadyRect))
            self.labelReadying = UILabel(frame: labelReadyRect)
            labelReadying?.text = readyStr
            labelReadying?.backgroundColor = UIColor.clear
            labelReadying?.textColor = UIColor.white
            labelReadying?.font = UIFont.systemFont(ofSize: 18.0)
            addSubview(labelReadying!)
        }
        
        addSubview(labelReadying!)
        activityView?.startAnimating()
        
    }
    
    func getRetangeSize()->CGSize
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        
        var sizeRetangle = CGSize(width: self.frame.size.width - XRetangleLeft*2, height: self.frame.size.width - XRetangleLeft*2)
        
        let w = sizeRetangle.width;
        var h = w / viewStyle.whRatio;
        
        
        let hInt:Int = Int(h)
        h = CGFloat(hInt)
        
        sizeRetangle = CGSize(width: w, height:  h)
        
        return sizeRetangle
    }
    
    
    /// 停止扫描
    func stopScanAnimtion() {
        isAnimationing = false
        switch viewStyle.animationStyle {
        case .LineMove:
            scanLineAnimation?.stopStepAnimation()
        case .NetGrid:
            scanNetAnimation?.stopStepAnimation()
        case .LineStill:
            fixedLine.isHidden = true
        default:
            break
        }
    }
    private class func getScanRectForAnimation(viewStyle:YLScanViewSytle,frame:CGRect) -> CGRect{
        
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        var sizeRetangle: CGSize = CGSize(width: frame.size.width - XRetangleLeft * 2, height: frame.size.width -  XRetangleLeft * 2)
        if viewStyle.whRatio != 1 {
            let width = sizeRetangle.width
            var height = width / viewStyle.whRatio
            height = CGFloat(Int(height))
            sizeRetangle = CGSize(width: width, height: height)
        }
        //扫描区域Y轴最小坐标
        let YminRetangle = frame.size.height/2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        
        let cropRect = CGRect(x: XRetangleLeft, y: YminRetangle, width: sizeRetangle.width, height: sizeRetangle.height)
        return cropRect
    }
    
    static func getScanRectWithPreview(preview: UIView, style: YLScanViewSytle) -> CGRect {
        let cropRect = YLScanView.getScanRectForAnimation(viewStyle: style, frame: preview.frame)
        //计算兴趣区域
        var rectOfInterest:CGRect
        let size = preview.bounds.size
        let p1 = size.height/size.width
        let p2:CGFloat = 1920.0/1080.0 //使用1080p的图像输出
        if p1 < p2 {
            let fixHeight = size.width * 1920.0 / 1080.0;
            let fixPadding = (fixHeight - size.height)/2;
            rectOfInterest = CGRect(x: (cropRect.origin.y + fixPadding)/fixHeight,
                                    y: cropRect.origin.x/size.width,
                                    width: cropRect.size.height/fixHeight,
                                    height: cropRect.size.width/size.width)
        }else {
            let fixWidth = size.height * 1080.0 / 1920.0;
            let fixPadding = (fixWidth - size.width)/2;
            rectOfInterest = CGRect(x: cropRect.origin.y/size.height,
                                    y: (cropRect.origin.x + fixPadding)/fixWidth,
                                    width: cropRect.size.height/size.height,
                                    height: cropRect.size.width/fixWidth)
        }
        
        return rectOfInterest
    }
    
    func deviceStopReadying() {
        if activityView != nil {
            activityView?.stopAnimating()
            activityView?.removeFromSuperview()
            labelReadying?.removeFromSuperview()
            
            activityView = nil
            labelReadying = nil
            
        }
    }

}



















