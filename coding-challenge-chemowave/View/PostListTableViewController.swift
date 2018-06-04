//
//  PostListTableViewController.swift
//  coding-challenge-chemowave
//
//  Created by Michael Duong on 6/1/18.
//  Copyright © 2018 Turnt Labs. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    // MARK: - Outlets and Actions
    
    @IBAction func loadMorePosts(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Loading next page...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        print("Loading next page...")
        
        PostController.shared.fetchNextPagePosts { (posts, error) in
            
            DispatchQueue.main.async { [weak self] in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self?.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Lifecycle Functions & Initial setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.prefetchDataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        self.title = "/r/all/hot"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
        
        fetchInitialPosts()
    }


    // MARK: - Table view data source functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.shared.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        let post = PostController.shared.posts[indexPath.row]
        cell.post = post
        
        PostController.shared.fetchThumbnail(post: post) { (newImage, error) in
            DispatchQueue.main.async {
                cell.post = post
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath == indexPath {
                    if cell.postThumbnail.image == nil {
                        cell.postThumbnail.image = #imageLiteral(resourceName: "redditDefaultImage")
                    } else {
                        cell.postThumbnail.image = newImage
                    }
                } else {
                    return
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toCommentsView", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == PostController.shared.posts.count - 1 {
            let alert = UIAlertController(title: nil, message: "Loading next page...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            print("Loading next page...")
            
            PostController.shared.fetchNextPagePosts { (posts, error) in
                DispatchQueue.main.async { [weak self] in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    self?.tableView.reloadData()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Functions
    
    func fetchInitialPosts() {
        PostController.shared.fetchPost { (posts, error) in
            
            DispatchQueue.main.async { [weak self] in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self?.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCommentsView" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let post = PostController.shared.posts[indexPath.row]
            guard let commentsVC = segue.destination as? CommentsViewController else { return }
            commentsVC.postJson = post
        }
    }
}


extension PostListTableViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let post = PostController.shared.posts[indexPath.row]
            guard let postThumbnail = post.thumbnail, let postUrl = URL(string: postThumbnail) else { return }
            
            URLSession.shared.dataTask(with: postUrl)
            print("Prefetching \(post.title ?? "no prefetch")")
        }
    }
}
