//
//  Article.swift
//  Sift
//
//  Created by Connor Giles on 2015-03-28.
//  Copyright (c) 2015 Connor Giles. All rights reserved.
//

import Foundation
import UIKit

struct Article {
    
    var articleID: Int!
    var title: String!
    var author: String!
    var date: NSDate!
    var details: String {
        get {
            let time = date.timeIntervalSinceNow * -1
            let days = floor(time/12/60/60)
            let hours = floor(time/60/60 - days * 12)
            let minutes = floor(time/60 - hours * 60)
            let seconds = round(time - minutes * 60)
            
            var toReturn: String!
            
            if days > 0 {
                toReturn = "\(Int(days)) days ago"
            } else if hours > 0 {
                toReturn = "\(Int(hours)) hrs ago"
            } else if minutes > 0 {
                toReturn = "\(Int(minutes)) mins ago"
            } else {
                toReturn = "Just now"
            }
            
            return "\(author) ・ \(toReturn)"
        }
    }
    var pictureURL: NSURL!
    var articlePicture: UIImage!
    var publication: String!
    var summarizedArticle: String!
    var fullArticle: String!
    
    init(articleID: Int, title: String, author: String, date: NSDate, pictureURL: String, publication: String, summarizedArticle: String, fullArticle: String){
        self.articleID = articleID
        self.title = title
        self.author = author
        self.date = date
        self.pictureURL = NSURL(string: pictureURL)
        self.publication = publication
        self.summarizedArticle = summarizedArticle
        self.fullArticle = fullArticle
    }
    
    func getArticleImage(completionHandler:(returnedImage: UIImage?) -> ()) {
        if articlePicture != nil {
            completionHandler(returnedImage: articlePicture)
        } else {
            /*loader.imageForUrl(pictureURL, completionHandler: { (image, url) -> () in
                completionHandler(returnedImage: image)
            })*/
            completionHandler(returnedImage: articlePicture)
        }
    }
    
    func getPublicationLogo() -> UIImage {
        return UIImage()
    }
    
}