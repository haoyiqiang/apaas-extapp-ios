//
//  SingleTimeGroup.swift
//  AgoraEducation
//
//  Created by LYY on 2021/5/11.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import AgoraUIBaseViews

@objcMembers class SingleTimeGroup: UIView {
        
    private lazy var topView: SingleTimeView = SingleTimeView(frame: .zero)
    private lazy var bottomView: SingleTimeView = SingleTimeView(frame: .zero)
    private lazy var upPageView: SingleTimeView = SingleTimeView(frame: .zero)
    private lazy var downPageView: SingleTimeView = SingleTimeView(frame: .zero)
    private lazy var lineImgView: UIImageView = {
        let v = UIImageView(image: GetWidgetImage(object: self,
                                                  "countdown_line"))
        return v
    }()
    
    private var timeStr: String = "" {
        didSet {
            guard oldValue != timeStr else {
                return
            }
            self.startAnimation()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topView.frame = self.bounds
        bottomView.frame = self.bounds
        upPageView.frame = self.bounds
        downPageView.frame = self.bounds
        maskTopView()
        maskBottomView()
    }
}
// MARK: - Private
private extension SingleTimeGroup {
    func maskTopView() {
        let height = self.bounds.height
        let path = UIBezierPath(rect: CGRect(x: 0,
                                             y: 0,
                                             width: self.bounds.width,
                                             height: height * 0.5))
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillRule = .evenOdd
        shapeLayer.path = path.cgPath
        topView.layer.mask = shapeLayer
    }
    func maskBottomView() {
        let height = self.bounds.height
        let path = UIBezierPath(rect: CGRect(x: 0,
                                             y: height * 0.5,
                                             width: self.bounds.width,
                                             height: height * 0.5))
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillRule = .evenOdd
        shapeLayer.path = path.cgPath
        bottomView.layer.mask = shapeLayer
    }
    
    func startAnimation() {
        upPageView.isHidden = false
        topView.label.text = self.timeStr
        downPageView.isHidden = true
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
            self.upPageView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi * -0.5),
                                                                        1,
                                                                        0,
                                                                        0)
        } completion: { isFinish in
            self.upPageView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi * -0.1),
                                                                        1,
                                                                        0,
                                                                        0)
            self.upPageView.isHidden = true
            self.continueAnimation()
            self.upPageView.label.text = self.timeStr
        }
    }
    
    func continueAnimation() {
        downPageView.label.text = timeStr
        downPageView.isHidden = false
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
            self.downPageView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi * -1.9),
                                                                          1,
                                                                          0,
                                                                          0)
        } completion: { isFinish in
            self.downPageView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi * -1.5),
                                                                          1,
                                                                          0,
                                                                          0)
            self.bottomView.label.text = self.timeStr
        }
    }
}

// MARK: public
extension SingleTimeGroup {
    public func updateStr(str: String) {
        DispatchQueue.main.async {
            self.timeStr = str
        }
    }
    
    public func turnColor(color: UIColor) {
        DispatchQueue.main.async {
            for timeView in [self.topView,self.bottomView,self.upPageView,self.downPageView] {
                timeView.turnColor(color: color)
            }
        }
    }
}

// MARK: private
fileprivate extension SingleTimeGroup {
    private func createViews() {
        upPageView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi * -0.1),
                                                               1,
                                                               0,
                                                               0)
        addSubview(upPageView)
        addSubview(topView)
        addSubview(bottomView)
        downPageView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi * -1.5),
                                                                 1,
                                                                 0,
                                                                 0)
        addSubview(downPageView)
        addSubview(lineImgView)
        lineImgView.mas_makeConstraints { make in
            make?.left.right().centerY().equalTo()(0)
            make?.height.equalTo()(1)
        }
        self.isUserInteractionEnabled = false
    }
}
