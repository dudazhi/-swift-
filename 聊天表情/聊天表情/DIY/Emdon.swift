//
//  Emdon.swift
//  聊天表情
//
//  Created by 杜志 on 17/3/13.
//  Copyright © 2017年 杜志. All rights reserved.
//

import UIKit

class Emdon: NSTextAttachment {
    //保存图片的名字
    var chs : String?
    
    class func imageText(emot:Emoticon,font:UIFont) ->NSMutableAttributedString{
        //创建附件
        //            let attchment = NSTextAttachment()
        let attchment = Emdon()
        attchment.chs = emot.chs
        attchment.image = UIImage(contentsOfFile: emot.imagePath!)
        let f =  font.lineHeight
        attchment.bounds = CGRect(x: 0, y: -4, width: f, height:f)
        //创建图片文字字符串
        return NSAttributedString(attachment: attchment) as! NSMutableAttributedString
}
}
