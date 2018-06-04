//
//  PostController.swift
//  coding-challenge-chemowave
//
//  Created by Michael Duong on 6/1/18.
//  Copyright © 2018 Turnt Labs. All rights reserved.
//

import UIKit

class PostController {
    
    static let shared = PostController()
    
    // MARK: - Properties
    
    private let baseURL = URL(string: "https://www.reddit.com/r/all/hot")
    var posts = [Post]()
    var nextUrl: String?
    typealias PostCompletionHandler = ([Post]?, PostError?) -> Void
    
    // MARK: - Functions
    
    func fetchPost(completion: @escaping PostCompletionHandler) {
        guard let url = baseURL else { completion(nil,.invalidUrl); return }
        let jsonUrl = url.appendingPathExtension("json")
        print(jsonUrl)
        
        URLSession.shared.dataTask(with: jsonUrl) { (data, _, error) in
            
            do {
                if let error = error { throw error }
                guard let data = data else { throw NSError() }
                
                let postDictionaries = try JSONDecoder().decode(JsonDictionary.self, from: data)
                let nextUrl = postDictionaries.data.after
                let posts = postDictionaries.data.children.compactMap{$0.data}
                
                self.nextUrl = nextUrl
                self.posts = posts
                completion(posts, nil)
                
            } catch let error {
                print("Error fetching post \(error.localizedDescription) \(error) \(#function)")
                completion(nil,.jsonConversionFailure)
            }
        }.resume()
    }
    
    func fetchNextPagePosts(completion: @escaping PostCompletionHandler) {
        let jsonUrl = "https:/www.reddit.com/r/all/hot.json?after="
        guard let nextUrl = nextUrl else { return }
        guard let url = URL(string: jsonUrl + nextUrl) else { return }
        print(url)
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            do {
                if let error = error { throw error}
                guard let data = data else { throw NSError() }
                
                let postDictionaries = try JSONDecoder().decode(JsonDictionary.self, from: data)
                let nextUrl = postDictionaries.data.after
                let newPosts = postDictionaries.data.children.compactMap{$0.data}
                
                self.nextUrl = nextUrl
                self.posts.append(contentsOf: newPosts)
                
                completion(self.posts, nil)
                
            } catch let error {
                print("Error fetching next page \(error.localizedDescription) \(error) \(#function)")
                completion(nil,.jsonConversionFailure)
            }
        }.resume()
    }
    
    func fetchThumbnail(post: Post, completion: @escaping (UIImage?, PostError?) -> Void) {
        guard let postThumbnail = post.thumbnail, let imageUrl = URL(string: postThumbnail) else { return }
        
        URLSession.shared.dataTask(with: imageUrl) { (data, _, error) in
            
            do {
                if let error = error { throw error }
                guard let data = data else { throw NSError() }
                
                let image = UIImage(data: data)
                completion(image, nil)
                
            } catch let error {
                print("Error fetching thumbnail from task \(error.localizedDescription) \(error) \(#function)")
                completion(nil, .imageDataFailure)
            }
        }.resume()
    }
}
