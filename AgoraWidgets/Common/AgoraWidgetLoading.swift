//
//  AgoraWidgetLoading.swift
//  AgoraWidgets
//
//  Created by Jonathan on 2022/1/14.
//

import UIKit
import FLAnimatedImage

public class AgoraWidgetLoading: NSObject {
    /// 往一个视图上添加loading，对应 removeLoading(in view: UIView)
    /// - parameter view: 需要添加loading的View
    @objc public static func addLoading(in view: UIView,
                                        msg: String? = nil) {
        guard view != UIApplication.shared.keyWindow else {
            fatalError("use loading(msg: String)")
            return
        }
        for subView in view.subviews {
            if let v = subView as? AgoraLoadingView {
                v.label.text = msg
                return
            }
        }
        let v = AgoraLoadingView(frame: .zero)
        v.label.text = msg
        view.addSubview(v)
        v.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        v.startAnimating()
    }
    /// 移除一个视图上的loading
    /// - parameter view: 需要移除loading的View
    @objc public static func removeLoading(in view: UIView?) {
        guard let `view` = view else {
            return
        }
        for subView in view.subviews {
            if let v = subView as? AgoraLoadingView {
                v.stopAnimating()
                v.removeFromSuperview()
            }
        }
    }
}

fileprivate class AgoraLoadingView: UIView {
    
    private var contentView: UIView!
    
    public var label: UILabel!
    
    private var loadingView: FLAnimatedImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.createViews()
        self.createConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var size = min(self.bounds.width, self.bounds.height) * 0.25
        size = size > 90 ? 90 : size
        self.contentView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        self.contentView.layer.cornerRadius = size * 0.12
        self.contentView.center = self.center
    }
    
    public func startAnimating() {
        loadingView.startAnimating()
    }
    
    public func stopAnimating() {
        loadingView.stopAnimating()
    }
    
    private func createViews() {
        contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 15
        contentView.layer.shadowColor = UIColor(hex: 0x2F4192,
                                                transparency: 0.15)?.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0,
                                                height: 2)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 6
        addSubview(contentView)
        
        var image: FLAnimatedImage?
        if let url = Bundle.ag_compentsBundleNamed("AgoraWidgets")?.url(forResource: "img_loading", withExtension: "gif") {
            let imgData = try? Data(contentsOf: url)
            image = FLAnimatedImage.init(animatedGIFData: imgData)
        }
        loadingView = FLAnimatedImageView()
        loadingView.animatedImage = image
        contentView.addSubview(loadingView)
        
        label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(label)
    }
    
    private func createConstraint() {
        loadingView.mas_makeConstraints { make in
            make?.centerX.equalTo()(0)
            make?.centerY.equalTo()(0)
            make?.width.height().equalTo()(contentView)?.multipliedBy()(0.62)
        }
        label.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.bottom.equalTo()(-5)
        }
    }
}
