//
//  PostTableViewCell.swift
//  coding-challenge-chemowave
//
//  Created by Michael Duong on 6/1/18.
//  Copyright © 2018 Turnt Labs. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    // MARK: - Outlets and Actions
    
    @IBOutlet weak var postThumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Properties
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    var thumbnail: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Functions
    
    func updateViews() {
        guard let post = post else { return }
        titleLabel.text = post.title
        if let thumbnail = thumbnail {
            postThumbnail.image = thumbnail
        } else {
            postThumbnail.image = #imageLiteral(resourceName: "redditDefaultImage")
        }
    }
}
