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
    
    private lazy var contentView = UIView()
    
    public lazy var label = UILabel()
    
    private lazy var loadingView = FLAnimatedImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
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
}

// MARK: - AgoraUIContentContainer
private extension AgoraLoadingView {
    func initViews() {
        addSubview(contentView)
        
        var image: FLAnimatedImage?
        if let url = Bundle.agora_bundle("AgoraWidgets")?.url(forResource: "img_loading", withExtension: "gif") {
            let imgData = try? Data(contentsOf: url)
            image = FLAnimatedImage.init(animatedGIFData: imgData)
        }
        loadingView.animatedImage = image
        contentView.addSubview(loadingView)
        
        label.textAlignment = .center
        contentView.addSubview(label)
    }
    
    func initViewFrame() {
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
    
    func updateViewProperties() {
        let ui = AgoraUIGroup()
        
        contentView.backgroundColor = FcrWidgetsColorGroup.fcr_system_component_color
        contentView.layer.cornerRadius = ui.frame.fcr_round_container_corner_radius
        FcrWidgetsColorGroup.borderSet(layer: contentView.layer)
        label.font = ui.font.fcr_font14
    }
}
