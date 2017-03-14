//
//  ViewController.swift
//  聊天表情
//
//  Created by 杜志 on 17/3/6.
//  Copyright © 2017年 杜志. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBAction func clickSend(_ sender: Any)
    {
        //获取要发送服务器的文本
        
       self.customTextView.emoticonAttr()
        print(self.customTextView.emoticonAttr())
        
    }
    @IBOutlet weak var customTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //1.将键盘控制器添加为本控制器的子控制器（保命）
        addChildViewController(vc)
        //2.将表情键盘控制器的view设置为inputView
        customTextView.inputView = vc.view
        customTextView.font = UIFont.systemFont(ofSize: 20)
        
    }
    private lazy var vc : DiyViewController = DiyViewController { [weak self](Emoticon) in
     self!.customTextView.insertEmoticon(emoticon: Emoticon)
    }
   
}

