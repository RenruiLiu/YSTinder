//
//  YSSwipingPhotoController.swift
//  YSTinder
//
//  Created by jozen on 2019/1/21.
//  Copyright © 2019 liurenrui. All rights reserved.
//

import UIKit

protocol YSSwipingPhotoControllerDelegate{
    func didChangeIndex(_ index: Int)
}

class YSSwipingPhotoController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    lazy var controllers = [UIViewController]()
    var indexDelegate: YSSwipingPhotoControllerDelegate?
    
    fileprivate let isCardViewMode: Bool
    
    init(isCardViewMode: Bool = false) {
        self.isCardViewMode = isCardViewMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cardViewModel: YSCardViewModel!{
        didSet{
            //对imageUrls每一个进行map，构造出一个个photoController 到数组里
            controllers = cardViewModel.imageUrls.map({ (imageUrlStr) -> UIViewController in
                let photoController = YSPhotoController(imageUrl: imageUrlStr)
                return photoController
            })
            
            //设定pageViewController的第一个页面
            setViewControllers([controllers.first!], direction: .forward, animated: true, completion: nil)
            
            setupBars()
        }
    }
    
    fileprivate let barsStackView = UIStackView(arrangedSubviews: [])
    
    fileprivate func setupBars(){
        cardViewModel.imageUrls.forEach { (_) in
            let barView = UIView()
            barView.backgroundColor = Constants.barDeselectedColor
            barView.layer.cornerRadius = 2
            barsStackView.addArrangedSubview(barView)
        }
        
        view.addSubview(barsStackView)
        barsStackView.arrangedSubviews.first?.backgroundColor = .white
        barsStackView.spacing = 4
        barsStackView.layer.cornerRadius = 2
        barsStackView.distribution = .fillEqually
        
        //获取statusBar的高，而不用safeAreaGuide是因为其导致bar在拉拽时闪烁
        var paddingTop : CGFloat = 8
        if !isCardViewMode {
            paddingTop += UIApplication.shared.statusBarFrame.height
        }
        
        barsStackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: paddingTop, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        view.backgroundColor = .white
        
        if isCardViewMode {
            disableSwiping()
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        }
    }
    
    fileprivate func disableSwiping(){
        //在首页中，不能转动scrollView
        view.subviews.forEach { (v) in
            if let v = v as? UIScrollView{
                v.isScrollEnabled = false
            }
        }
    }
    
    @objc fileprivate func handleTap(gestrue: UITapGestureRecognizer){
        let currentController = viewControllers!.first!
        
        if let index = controllers.firstIndex(of: currentController){
            
            let delta = gestrue.location(in: self.view).x > view.frame.width / 2 ? 1 : -1
            let nextIndex = max(0, min(controllers.count - 1, index + delta))

            if index == nextIndex {return} //当前即为第一张或最后一张图
            
            indexDelegate?.didChangeIndex(nextIndex)
            setViewControllers([controllers[nextIndex]], direction: .forward, animated: false, completion: nil)
            
            barsStackView.arrangedSubviews.forEach({$0.backgroundColor = Constants.barDeselectedColor})
            barsStackView.arrangedSubviews[nextIndex].backgroundColor = .white
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        //返回当前的viewController的index
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        
        // index超出数组长度的话则不返回新的controller
        if index == 0 {return nil}
        return controllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count - 1 {return nil}
        return controllers[index + 1]
    }
    
    // didFinishAnimating 当完成一次滑动操作后调用此方法
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // 获取当前的pageViewController里面的第一个controller（当前展示的）（viewControllers数组会不断变动）
        let currentPhotoController = viewControllers?.first
        // 获取此currentPhotoController在自定义的controllers数组里的index，从而改变bar的颜色
        if let index = controllers.firstIndex(where: {$0 == currentPhotoController}) {
            barsStackView.arrangedSubviews.forEach({$0.backgroundColor = Constants.barDeselectedColor})
            barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
}

class YSPhotoController: UIViewController{
    
    let imageView = UIImageView()
    
    init(imageUrl: String){
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url, completed: nil)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
}
