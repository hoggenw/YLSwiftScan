# YLSwiftScan

[![CI Status](http://img.shields.io/travis/dev-wangliugen/YLSwiftScan.svg?style=flat)](https://travis-ci.org/dev-wangliugen/YLSwiftScan)
[![Version](https://img.shields.io/cocoapods/v/YLSwiftScan.svg?style=flat)](http://cocoapods.org/pods/YLSwiftScan)
[![License](https://img.shields.io/cocoapods/l/YLSwiftScan.svg?style=flat)](http://cocoapods.org/pods/YLSwiftScan)
[![Platform](https://img.shields.io/cocoapods/p/YLSwiftScan.svg?style=flat)](http://cocoapods.org/pods/YLSwiftScan)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

YLSwiftScan is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "YLSwiftScan"
```

## Author

dev-wangliugen

## 调用方法

注意要在.plist设置相机相关的权限

```
        //初始化
        let manager = YLScanViewManager.shareManager()
        //视图UI相关的设置更改，可以不做设置，使用默认配置
       // 是否需要边框
       //manager.isNeedShowRetangle = true
       //扫描框的宽高比
       // manager.whRatio = 1
       //相对中心点Y的偏移
       //manager.centerUpOffset = -20
       //扫描框的宽度
       // manager.scanViewWidth = 160
       //扫描框的颜色
       //manager.colorRetangleLine = UIColor.red
       //4角与扫描框的位置关系
       //manager.photoframeAngleStyle = YLScanViewPhotoframeAngleStyle.Outer
       //扫描框4角的颜色
       //manager.colorAngle = UIColor.red
       //扫码区域4个角的线条宽度
       //manager.photoframeLineW = 4
       //扫描动画的样式，自带4种样式
       // manager.imageStyle = YLAnimationImageStyle.secondeNetGrid
       //自定义扫描动画
       manager.animationImage = image
       //添加扫描成功返回代理
        manager.delegate = self
       //显示(viewController要求有UINavigationController)
        manager.showScanView(viewController: self) 
        
```
在YLScanViewManagerDelegate的代理中处理成功后返回的数据

```
    func scanSuccessWith(result: YLScanResult) {
         print("wlg====%@",result.strScanned!)
    }
    
```

二维码的生成

```
 //  frame: 生成视图的frame
 //  logoIconName：是否需要logo。可选
 //  codeMessage： 二维码包含信息
 //例如
 let codeView = manager.produceQRcodeView(frame: CGRect(x: (self.view.bounds.size.width - 200)/2, y: self.view.bounds.size.height/2, width: 200, height: 200), logoIconName: nil,codeMessage: "wlg's test Message")
 
```

## License

YLSwiftScan is available under the MIT license. See the LICENSE file for more info.
