//
//  HomeWorkVC.swift
//  UIComponents
//
//  Created by Hümeyra Şahin on 20.01.2022.
//

import UIKit

class HomeWorkVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageController: UIPageControl!
    var contentWidth = 0.0
    var xOffset = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self

        for image in 0...4 {
            let imageToShow = UIImage(named: "\(image).png")
            let imageView = UIImageView(image: imageToShow)
            
            let x = view.frame.midX + view.frame.width * CGFloat(image)
            contentWidth += view.frame.width
            
            scrollView.addSubview(imageView)
            imageView.frame = CGRect(x: x - 150, y: (view.frame.height / 2) - 150, width: 300, height: 300)
        }
        
        scrollView.contentSize = CGSize(width: contentWidth, height: view.frame.height)
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(imageChange), userInfo: nil, repeats: true)
                
    }
    
    @objc func imageChange(){
        print(scrollView.contentOffset.x)
        if xOffset < 414 * 4{
            xOffset += 414
        } else {
            xOffset = 0
        }
        
        scrollView.contentOffset.x = xOffset
        pageController.currentPage = Int(scrollView.contentOffset.x / CGFloat(414))
    }
                                   
    
}

extension HomeWorkVC: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageController.currentPage = Int(scrollView.contentOffset.x / CGFloat(414))
    }
    
    
}


