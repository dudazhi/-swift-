//
//  DiyViewController.swift
//  聊天表情
//
//  Created by 杜志 on 17/3/7.
//  Copyright © 2017年 杜志. All rights reserved.
//

import UIKit
private let DZCellWithReuseIdentifier = "CellWithReuseIdentifier"
class DiyViewController: UIViewController {
    
    /// 定义一个闭包属性, 用于传递选中的表情模型
    var emoticonDidSelectedCallBack: (_ emoticon: Emoticon)->()
    
    init(callBack: @escaping (_ emoticon: Emoticon)->())
    {
        self.emoticonDidSelectedCallBack = callBack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
       //1.初始化控件
        setupUI()
        
    }
    private func setupUI()
    {
        //1 添加子控件
        view.addSubview(collection)
        view.addSubview(toobar)
        
        //2 布局子控件
        collection.translatesAutoresizingMaskIntoConstraints = false
        toobar.translatesAutoresizingMaskIntoConstraints = false
        var cons = [NSLayoutConstraint]()
        let dic = ["collection":collection,"toobar":toobar] as [String : Any]
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collection]-0-|", options:NSLayoutFormatOptions (rawValue :0) , metrics: nil, views: dic)
         cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toobar]-0-|", options:NSLayoutFormatOptions (rawValue :0) , metrics: nil, views: dic)
         cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collection]-[toobar(44)]-0-|", options:NSLayoutFormatOptions (rawValue :0) , metrics: nil, views: dic)
        view.addConstraints(cons)
    }
    //toolbarItem的点击事件
    func click(item:UIBarButtonItem)
    {
      collection.scrollToItem(at: NSIndexPath(item: 0, section: item.tag-1) as IndexPath , at: UICollectionViewScrollPosition.left, animated: false)
    }
    //MARK--Lazy
    private lazy var collection : UICollectionView = {
//    let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200), collectionViewLayout: Diylayout())
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: Diylayout())
        collection.register(diyCell.self, forCellWithReuseIdentifier: DZCellWithReuseIdentifier)
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    private lazy var toobar : UIToolbar = {
        let bar = UIToolbar()
        bar.tintColor = UIColor.darkGray
        var items = [UIBarButtonItem]()
        var index = 0
        for title in ["最近","默认","emoji","浪小花"]
        {
            let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: self, action: #selector(DiyViewController.click))
            index += 1
            item.tag = index
            items.append(item)
            //添加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
            
        }
        //去除多余的弹簧
        items.removeLast()
        bar.items = items
        return bar
    }()
     lazy var package : [EmoticonPackage] = EmoticonPackage.packageList

}
extension DiyViewController: UICollectionViewDataSource,UICollectionViewDelegate
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
     
        return package.count
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        
        return package[section].emoticons?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: DZCellWithReuseIdentifier, for: indexPath))as!diyCell
//        let x = indexPath.item % 2
//        cell.backgroundColor = (x == 0) ? UIColor.red : UIColor.white
    
    // 1.取出对应的组
        let pack =  package[indexPath.section]
    // 2.取出对应组的对应模型
        let emoticon = pack.emoticons![indexPath.item]
    // 3.赋值给cell
        cell.emoticon = emoticon
        return cell
        
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        let Emoticon = package[indexPath.section].emoticons![indexPath.item]
        if indexPath.section == 0
        {
            print("我是最近的")
        }
        else{
            //处理最近表情使当前表情添加到最近表情中
            
            Emoticon.times += 1
            package[0].appendEmoticons(emoticon: Emoticon)
            collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
        }
        
        //回调通知使用者点击了哪个表情
        emoticonDidSelectedCallBack(Emoticon)
    }
    
    
}
//自定义cell
class diyCell:UICollectionViewCell{
    
    var emoticon: Emoticon?
        {
        didSet{
          
            // 1.判断是否是图片表情
            if emoticon!.chs != nil
            {
                button.setImage(UIImage(contentsOfFile: emoticon!.imagePath!), for: UIControlState.normal)
            }else
            {
                button.setImage(nil, for: UIControlState.normal)
                
            }
            
            // 2.设置emoji表情
            //注意：？？“”防止重用
            button.setTitle(emoticon!.emojiStr ?? "", for: UIControlState.normal)
            //是否是删除按钮
            if (emoticon!.isRemoveButton)
            {
                //没有图片就先不写
                button.backgroundColor = UIColor.red
            }else
            {
                button.backgroundColor = UIColor.clear
            }
            
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        //初始化界面
        setupButton()
    }
    
    private func setupButton()
    {
        //1.添加子控件
        contentView.addSubview(button)
        //2.布局子控件
        button.frame = contentView.bounds
        button.isUserInteractionEnabled = false

    }
    //MARK--LAZY
    private lazy var button : UIButton = UIButton()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
///自定义布局
class Diylayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
     //设置cell相关属性
    let witdh = (collectionView?.bounds.width)!/7
    itemSize = CGSize(width: witdh, height: witdh)
    minimumLineSpacing = 0
    minimumInteritemSpacing = 0
    scrollDirection = UICollectionViewScrollDirection.horizontal
    //设置collectionview的相关属性
    collectionView?.isPagingEnabled = true
    collectionView?.bounces =  false
    collectionView?.showsHorizontalScrollIndicator = false
        
    //去除竖直方向上的间隙
    //注意：最好不要乘以0.5，因为float类型不是很准确，iphone4/5可能出现未知错误
    let y = (collectionView!.bounds.height - 3*witdh) * 0.45
    collectionView?.contentInset = UIEdgeInsets(top: y, left: 0, bottom: y, right: 0)
    }
}
