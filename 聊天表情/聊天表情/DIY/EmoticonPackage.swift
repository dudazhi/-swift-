//
//  EmoticonPackage.swift
//  聊天表情
//
//  Created by 杜志 on 17/3/7.
//  Copyright © 2017年 杜志. All rights reserved.
//

import UIKit
/*
 结构:
 1. 加载emoticons.plist拿到每组表情的路径
 
 emoticons.plist(字典)  存储了所有组表情的数据
 |----packages(字典数组)
 |-------id(存储了对应组表情对应的文件夹)
 
 2. 根据拿到的路径加载对应组表情的info.plist
 info.plist(字典)
 |----id(当前组表情文件夹的名称)
 |----group_name_cn(组的名称)
 |----emoticons(字典数组, 里面存储了所有表情)
 |----chs(表情对应的文字)
 |----png(表情对应的图片)
 |----code(emoji表情对应的十六进制字符串)
 */
class EmoticonPackage: NSObject {
    /// 当前组表情文件夹的名称
    var id: String?
    /// 组的名称
    var group_name_cn : String?
    /// 当前组所有的表情对象
    var emoticons: [Emoticon]?
    
    /// 获取所有组的表情数组
    // 浪小花 -> 一组  -> 所有的表情模型(emoticons)
    // 默认 -> 一组  -> 所有的表情模型(emoticons)
    // emoji -> 一组  -> 所有的表情模型(emoticons)
    
    //防止多次调用，浪费性能
    static let packageList : [EmoticonPackage] = EmoticonPackage.loadPackages()!
    private class func loadPackages() -> [EmoticonPackage]? {
        let path = Bundle.main.path(forResource: "emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
         var packages = [EmoticonPackage]()
        //创建最近的组
        let pk = EmoticonPackage(id:"")
        pk.group_name_cn = "最近"
        pk.emoticons=[Emoticon]()
        pk.appendEntyEmoticon()
        packages.append(pk)
        
        // 1.加载emoticons.plist
        let dict = NSDictionary(contentsOfFile: path)!
        // 2.或emoticons中获取packages
        let dictArray = dict["packages"] as! [[String:AnyObject]]
        // 3.遍历packages数组
        for d in dictArray
        {
            // 4.取出ID, 创建对应的组
            let package = EmoticonPackage(id: d["id"]! as! String)
            packages.append(package)
            package.loadEmoticons()
            package.appendEntyEmoticon()
            
            
        }
        return packages
    }
    
    /// 加载每一组中所有的表情
    func loadEmoticons() {
        let emoticonDict = NSDictionary(contentsOfFile: infoPath())!
        group_name_cn = emoticonDict["group_name_cn"] as? String
        let dictArray = emoticonDict["emoticons"] as! [[String: String]]
        emoticons = [Emoticon]()
        var index = 0
        for dict in dictArray{
            
            if index == 20
            {
                emoticons?.append(Emoticon(isRemoveButton:true))
                index = 0
            }
            emoticons?.append(Emoticon(dict: dict, id: id!))
             index = index + 1
        }
        
    }
    //如果一页不够21个就添加空白按钮补齐
    func appendEntyEmoticon(){
        let count = emoticons!.count % 21
      
        for _ in count..<20
        {
            //追加空白按钮
            emoticons?.append(Emoticon(isRemoveButton:false))
        }
        //追加删除按钮
        emoticons?.append(Emoticon(isRemoveButton:true))
        
     
    }
    
    /**
     用于给最近添加表情
     */
    func appendEmoticons(emoticon: Emoticon)
    {
        
        // 1.判断是否是删除按钮
        if emoticon.isRemoveButton
        {
            return
        }
        // 2.判断当前点击的表情是否已经添加到最近数组中
        let contains = emoticons!.contains(emoticon)
        if !contains
        {
            // 删除删除按钮
            emoticons?.removeLast()
        }
        // 3.对数组进行排序
        var result = emoticons?.sorted(by: { (e1, e2) -> Bool in
            return e1.times > e2.times
        })
        //把最新的表情插入到最前面，后面的是按点击次数的排序
        if !contains
        {
//           result.append(emoticon)
            result?.insert(emoticon, at: 0)
        }
        
        // 4.删除多余的表情
        if !contains
        {
            result?.removeLast()
            // 添加一个删除按钮
            result?.append(Emoticon(isRemoveButton: true))
        }
   
        emoticons = result
        
        
        
    }
    
    /**
     获取指定文件的全路径
     
     :param: fileName 文件的名称
     
     :returns: 全路径
     */
    func infoPath() -> String {
        return (EmoticonPackage.emoticonPath().appendingPathComponent(id!) as NSString).appendingPathComponent("info.plist")
    }
    /// 获取微博表情的主路径
    class func emoticonPath() -> NSString{
        return (Bundle.main.bundlePath as NSString).appendingPathComponent("Emoticons.bundle") as NSString
    }
    
    init(id: String)
    {
        self.id = id
    }
}

class Emoticon: NSObject {
    /// 表情对应的文字
    var chs: String?
    /// 表情对应的图片
    var png: String?
    {
        didSet{
        let path =  EmoticonPackage.emoticonPath()
        imagePath = (path.appendingPathComponent(id!) as NSString).appendingPathComponent(png!)
    
        
        }
    }
    /// emoji表情对应的十六进制字符串
    var code: String?
    {
        didSet{
            // 1.从字符串中取出十六进制的数
            // 创建一个扫描器, 扫描器可以从字符串中提取我们想要的数据
            let scanner = Scanner(string: code!)
            
            // 2.将十六进制转换为字符串
            var result:UInt32 = 0
            scanner.scanHexInt32(&result)
            
            // 3.将十六进制转换为emoji字符串
            emojiStr = "\(Character(UnicodeScalar(result)!))"
 

        }
    }
    /// 记录当前表情被使用的次数
    var times: Int = 0
    /// 当前表情对应的文件夹
    var id: String?
    
    ///enmoji的十六进制数
    var emojiStr:String?
    ///表情图片的全路径
    var imagePath:String?
    ///标记是否是删除按钮
    var isRemoveButton:Bool = false
    init(isRemoveButton:Bool) {
        super.init()
        self.isRemoveButton  = isRemoveButton
        
    }
    init(dict: [String: String], id: String)
    {
        super.init()
        self.id = id
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }

}
