//
//  WebViewController.swift
//  BitbucketRepos
//
//  Created by Manisha Deshmukh on 12/7/21.
//

import UIKit
import WebKit
import RxSwift
import RxWebKit
import RxCocoa

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backBtn: UIBarButtonItem!

    var webViewUrl: String?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let _ = webViewUrl, let url = URL.init(string: webViewUrl!)  {
            webView.load(URLRequest.init(url: url))
        }
        setupWebViewErrorHandling()
        setupBackBtnBinding()
    }
    
    // MARK: - Utility methods
    func setupBackBtnBinding() {
        backBtn.rx.tap.asObservable().subscribe { [weak self](sender) in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
    }
    
    fileprivate func setupWebViewErrorHandling() {
        webView.rx
            .didFailProvisionalNavigation
            .observe(on: MainScheduler.instance)
            .debug("didFailProvisionalNavigation")
            .subscribe(onNext: { [weak self] (webView, navigation, error) in
                
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                    self?.navigationController?.popViewController(animated: true)
                }))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
}
