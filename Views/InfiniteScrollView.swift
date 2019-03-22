//
//  File.swift
//  
//
//  Created by Tomek on 21/03/2019.
//

import UIKit

class InfiniteScrollView: UIScrollView {
    
    init() {
        super.init(frame: .zero)
        isPagingEnabled = true
    }
    
    override var frame: CGRect {
        didSet {
            setup(size: bounds.size)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func setup(size: CGSize) {
        
        contentSize = CGSize(width: size.width * 3, height: size.height)
        
        backgroundColor = .black
        indicatorStyle = .white
        
    }
}
