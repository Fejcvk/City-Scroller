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
    var grabOffsetVector:CGVector = CGVector.zero
    var moonView: UIView?
    var originalOffset: CGFloat = 0
    
    override func loadView() {
        self.view = InfiniteScrollView.init()
        self.moonView = createMoon()
        view.addSubview(moonView!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self

    }

    private func createMoon() -> UIView {
        let side = 100
        let size = CGSize(width: side, height: side)
        let circle = UIView(frame: CGRect(origin: .zero, size: size))
        circle.backgroundColor = .white
        circle.layer.cornerRadius = CGFloat(side) * 0.5
        
        let moveGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        circle.addGestureRecognizer(moveGesture)
        
        return circle
    }
    
    private func positionMoon() {
        guard let moonView = moonView else { return }
        let newPosition = originalOffset > 0 ? scrollView.contentOffset.x + (scrollView.frame.size.width - originalOffset) : scrollView.contentOffset.x
        moonView.frame.origin.x = newPosition
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        guard let movedCircle = gesture.view else { return }
        
        switch gesture.state {
        case .began:
            let grabPoint = gesture.location(in: view)
            let circleCenter = movedCircle.center
            let grabOffset = CGVector(dx: grabPoint.x - circleCenter.x, dy: grabPoint.y - circleCenter.y)
            self.grabOffsetVector = grabOffset
            self.view.sendSubviewToBack(movedCircle)
            UIView.animate(withDuration: 0.2) {
                movedCircle.alpha = 0.5
                movedCircle.transform = .init(scaleX: 1.2, y: 1.2)
            }
        case .changed:
            let grabOffset = self.grabOffsetVector
            let touchLocation = gesture.location(in: self.view)
            movedCircle.center = CGPoint(x: touchLocation.x - grabOffset.dx, y: touchLocation.y - grabOffset.dy)
            originalOffset = abs(movedCircle.frame.origin.x - scrollView.bounds.maxX)
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2) {
                movedCircle.alpha = 1
                movedCircle.transform = .identity
            }
        default:
            break
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        positionMoon()
    }
}

