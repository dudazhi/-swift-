//
//  UITextView+category.swift
//  聊天表情
//
//  Created by 杜志 on 17/3/13.
//  Copyright © 2017年 杜志. All rights reserved.
//

import UIKit


extension UITextView
{
    func insertEmoticon(emoticon:Emoticon)
    {
        //处理删除按钮
        if emoticon.isRemoveButton {
            deleteBackward()
        }
        //2.判断是否是emoji表情
        if emoticon.emojiStr != nil{
            self.replace((self.selectedTextRange!), withText: emoticon.emojiStr!)
        }
        //3.判断是否是图片
        if emoticon.png != nil
        {
            //创建表情字符串
            let imageText = Emdon.imageText(emot: emoticon, font: font!)
            
            //拿到当前所有的内容
            let trM = NSMutableAttributedString(attributedString: (self.attributedText!))
            //插入表情到光标的位置
            let range = self.selectedRange
            trM.replaceCharacters(in: range, with: imageText)
            //属性字符串有默认的尺寸(改掉他，不然有bug<在图片后面的emoji比单独插入的emoji要小>)
            trM.addAttribute(NSFontAttributeName,value:font,range:NSMakeRange((range.location), 1))
            self.attributedText = trM
            //回复光标所在的位置
            self.selectedRange = NSMakeRange((range.location)+1, 0)
        }
    }
    
    func emoticonAttr() -> String
    {
        var strM = String()
        //发送服务器的文本
      attributedText.enumerateAttributes(in: NSMakeRange(0, self.attributedText.length), options: NSAttributedString.EnumerationOptions(rawValue:0)){ (objc, range, _) -> Void in
            /*
             // 遍历的时候传递给我们的objc是一个字典, 如果字典中的NSAttachment这个key有值
             // 那么就证明当前是一个图片
             print(objc["NSAttachment"])
             // range就是纯字符串的范围
             // 如果纯字符串中间有图片表情, 那么range就会传递多次
             print(range)
             let res = (self.customTextView.text as NSString).substringWithRange(range)
             print(res)
             print("++++++++++++++++++++++++++")
             */
            
            
            if objc["NSAttachment"] != nil
            {
                let attachment =  objc["NSAttachment"] as! Emdon
                // 图片
                //                strM += "[图片]"
                strM += attachment.chs!
            }else
            {
                // 文字
                strM += (self.text as NSString).substring(with: range)
            }
            
        }
        
       return strM
    }
}
