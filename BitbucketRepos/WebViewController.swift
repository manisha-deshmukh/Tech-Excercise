//
//  WebViewController.swift
//  BitbucketRepos
//
//  Created by Manisha Deshmukh on 12/7/21.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var viewTitle:String?
    var webViewUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = viewTitle ?? ""
        if let _ = webViewUrl, let url = URL.init(string: webViewUrl!)  {
            webView.load(URLRequest.init(url: url))
        }
    }
    
    // MARK: - Navigation
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
