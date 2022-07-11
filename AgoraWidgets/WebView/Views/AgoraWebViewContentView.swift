//
//  AgoraWebViewContentView.swift
//  AgoraWidgets
//
//  Created by DoubleCircle on 2022/5/25.
//

import AgoraUIBaseViews
import WebKit

protocol AgoraWebViewContentViewDelegate: NSObjectProtocol {
    func onClickRefresh()
    func onClickScale()
    func onClickClose()
}

class AgoraWebViewContentView: UIView {
    /**data**/
    private weak var delegate: AgoraWebViewContentViewDelegate?
    private var hitPoint = CGPoint.zero
    /**views**/
    private(set) lazy var tabView = AgoraWebViewContentTabView(frame: .zero)
    private(set) lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero,
                                configuration: config)
        return webView
    }()
    
    // public functions
    public func openWebUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    public func refreshWebView() {
        // TODO: 加载动画
        webView.reload()
    }
    
    convenience init(uiDelegate: WKUIDelegate?,
                     navigationDelegate: WKNavigationDelegate?,
                     delegate: AgoraWebViewContentViewDelegate?) {
        self.init(frame: .zero)
        
        self.delegate = delegate
        initViews(uiDelegate: uiDelegate,
                  navigationDelegate: navigationDelegate)
        initViewFrame()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AgoraWebViewContentView {
    private func initViews(uiDelegate: WKUIDelegate?,
                           navigationDelegate: WKNavigationDelegate?) {
        let group = AgoraUIGroup()
        
        layer.borderWidth = group.frame.fcr_border_width
        layer.borderColor = FcrWidgetsColorGroup.fcr_border_color
        layer.cornerRadius = group.frame.fcr_button_corner_radius
        layer.masksToBounds = true
        
        backgroundColor = .white
        
        tabView.refreshButton.addTarget(self,
                                        action: #selector(onClickRefresh(_:)),
                                        for: .touchUpInside)
        
        tabView.scaleButton.addTarget(self,
                                      action: #selector(onClickScale(_:)),
                                      for: .touchUpInside)
        
        tabView.closeButton.addTarget(self,
                                      action: #selector(onClickClose(_:)),
                                      for: .touchUpInside)
        addSubview(tabView)
        
        webView.uiDelegate = uiDelegate
        webView.navigationDelegate = navigationDelegate
        
        addSubview(webView)
    }
    
    private func initViewFrame() {
        tabView.mas_makeConstraints { make in
            make?.top.equalTo()(0)
            make?.left.right().equalTo()(0)
            make?.height.equalTo()(26)
        }
        webView.mas_makeConstraints { make in
            make?.left.right().equalTo()(0)
            make?.top.equalTo()(tabView.mas_bottom)
            make?.bottom.equalTo()(0)
        }
    }
}

// MARK: - actions
extension AgoraWebViewContentView {
    @objc func onClickRefresh(_ sender: UIButton) {
        delegate?.onClickRefresh()
    }
    
    @objc func onClickScale(_ sender: UIButton) {
        delegate?.onClickScale()
    }
    
    @objc func onClickClose(_ sender: UIButton) {
        delegate?.onClickClose()
    }
}
