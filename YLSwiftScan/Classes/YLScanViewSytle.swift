//
//  YLScanViewSytle.swift
//  YLScan
//
//  Created by 王留根 on 17/1/10.
//  Copyright © 2017年 ios-mac. All rights reserved.
//

import UIKit

public enum YLScanViewAnimationStyle{
    case LineMove //线条上下移动
    case NetGrid //网格
    case LineStill //线条停止在扫码区域中央
    case None //无动画
}

public enum YLScanViewPhotoframeAngleStyle {
    case Inner//内嵌，一般不显示矩形框情况下
    case Outer//外嵌,包围在矩形框的4个角
    case On   //在矩形框的4个角上，覆盖
}

public struct YLScanViewSytle {
    // MARK: - -中心位置矩形框
    
    /// 是否需要绘制扫码矩形框，默认YES
    public var isNeedShowRetangle: Bool = false
    
    /**
     *  默认扫码区域为正方形，如果扫码区域不是正方形，设置宽高比
     */
    public var whRatio:CGFloat = 1.0
    /**
     @brief  矩形框(视频显示透明区)域向上移动偏移量，0表示扫码透明区域在当前视图中心位置，如果负值表示扫码区域下移
     */
    public var centerUpOffset:CGFloat = 44
    /**
     *  矩形框(视频显示透明区)域离界面左边及右边距离，默认60
     */
    public var xScanRetangleOffset:CGFloat = 60
    /**
     @brief  矩形框线条颜色，默认白色
     */
    public var colorRetangleLine = UIColor.white
    
    //MARK -矩形框(扫码区域)周围4个角
    
    /**
     @brief  扫码区域的4个角类型
     */
    public var photoframeAngleStyle = YLScanViewPhotoframeAngleStyle.Inner
    
    //4个角的颜色
    public var colorAngle = UIColor(red: 0.0, green: 167.0/255.0, blue: 231.0/255.0, alpha: 1.0)
    
    //扫码区域4个角的宽度和高度
    public var photoframeAngleW:CGFloat = 24.0
    public var photoframeAngleH:CGFloat = 24.0
    /**
     @brief  扫码区域4个角的线条宽度,默认6，建议8到4之间
     */
    public var photoframeLineW:CGFloat = 4
    //MARK:--动画效果
    public var animationStyle = YLScanViewAnimationStyle.LineMove
    /**
     *  动画效果的图像，如线条或网格的图像
     */
    public var animationImage:UIImage? = YLScanViewSetting.imageFromBundleWithName(name: "qrcode_Scan_weixin_Line@2x")
    
    // MARK: -非识别区域颜色,默认 RGBA (0,0,0,0.5)，范围（0--1）
    public var red_notRecoginitonArea:CGFloat    = 0.0
    public var green_notRecoginitonArea:CGFloat  = 0.0
    public var blue_notRecoginitonArea:CGFloat   = 0.0
    public var alpa_notRecoginitonArea:CGFloat   = 0.5
    
    public init()
    {
        
    }
    

}


































