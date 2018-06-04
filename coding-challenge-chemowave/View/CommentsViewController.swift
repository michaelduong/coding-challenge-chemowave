//
//  CommentsViewController.swift
//  coding-challenge-chemowave
//
//  Created by Michael Duong on 6/2/18.
//  Copyright © 2018 Turnt Labs. All rights reserved.
//

import UIKit
import WebKit

class CommentsViewController: UIViewController {

    // MARK: - Outlets and Actions
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: - Properties
    
    private let baseUrl = "https://www.reddit.com"
    var postJson: Post?
    
    // MARK: - Lifecycle Functions & Initial setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = postJson?.title
        
        loadComments()
    }
    
    // MARK: - Functions
    
    func loadComments() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        guard let commentEndPoint = postJson?.permalink else { return }
        guard let url = URL(string: baseUrl + commentEndPoint) else { return }
        
        let request = URLRequest(url: url)
        webView.load(request)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        progressView.progress = Float(webView.estimatedProgress)
    }
}
