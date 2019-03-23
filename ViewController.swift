//
//  ViewController.swift
//  CityScroller
//
//  Created by Tomek on 21/03/2019.
//  Copyright © 2019 Tomek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var scrollView: InfiniteScrollView { return view as! InfiniteScrollView}
    
    override func loadView() {
        self.view = InfiniteScrollView.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
    }
    
    private func positionMoon() {
        guard let moonView = scrollView.moonView else { return }
        let newPosition = scrollView.originalOffset > 0 ? scrollView.contentOffset.x + (scrollView.frame.size.width - scrollView.originalOffset) : scrollView.contentOffset.x
        moonView.frame.origin.x = newPosition
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        positionMoon()
    }
}

