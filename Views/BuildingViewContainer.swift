//
//  BuildingViewContainer.swift
//  CityScroller
//
//  Created by Tomek on 22/03/2019.
//  Copyright © 2019 Tomek. All rights reserved.
//

import UIKit

class BuildingViewContainer: UIView{
    
    private let building : BuildingView?
    
    init(_building: BuildingView?){
        self.building = _building
        super.init(frame: CGRect(origin: .zero, size: building?.frame.size ?? .zero))
        self.addSubview(self.building!)
    }
    
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
}
