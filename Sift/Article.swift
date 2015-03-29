//
//  Article.swift
//  Sift
//
//  Created by Connor Giles on 2015-03-28.
//  Copyright (c) 2015 Connor Giles. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import SVProgressHUD

class Article {
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
    var articleImage = UIImage()
    var hasImage: Bool!
    var isRetrieving: Bool!
    var publication: String!
    var summarizedArticle: String!
    var fullArticle: String!
    
    let publicationLogos = ["TechCrunch": UIImage(named: "logo-tech-crunch"), "VentureBeat": UIImage(named: "logo-venturebeat"), "FastCompany": UIImage(named: "logo-fast-company")]
    
    init(title: String, author: String, date: NSDate, pictureURL: String, publication: String, summarizedArticle: String, fullArticle: String){
        self.title = title
        self.author = author
        self.date = date
        self.pictureURL = NSURL(string: pictureURL)
        self.publication = publication
        self.summarizedArticle = summarizedArticle
        self.fullArticle = fullArticle
        hasImage = false
        isRetrieving = false
        
    }
    
    init(article: GTLSiftMainArticle) {
        title = article.title
        author = article.author
        date = NSDate(timeIntervalSince1970: article.publishedTimestamp as Double as NSTimeInterval)
        pictureURL = NSURL(string: article.imageUrl)
        publication = article.publication
        
        var summary = ""
        
        for sentence in article.summarizedArticle as [String] {
            summary = "\(summary)\(sentence) "
        }
        
        summarizedArticle = summary
        fullArticle = article.fullArticle
        hasImage = false
        isRetrieving = false
    }
    
    func retrieveImage(completion: () -> ()) {
        
        if !isRetrieving {
            
            isRetrieving = true
            
            imagesDownloading++
            //SVProgressHUD.show()
            
            let manager = SDWebImageManager()
            
            println("Start Download")
            
            manager.downloadImageWithURL(self.pictureURL, options: SDWebImageOptions.RetryFailed, progress: { (progress, total) -> Void in
                println(progress/total)
            }, completed: { (image, error, cacheType, finished, URL) -> Void in
                if error != nil {
                    println("Error: \(error)")
                } else {
                    self.hasImage = true
                    self.isRetrieving = false
                    self.articleImage = image
                    completion()
                }
                imagesDownloading--
                
                if imagesDownloading == 0 {
                    SVProgressHUD.dismiss()
                }
            })
        }
    }
    
    func getPublicationLogo() -> UIImage {
        let image = publicationLogos[publication]
        if image != nil {
            return image as UIImage!!
        }
        return UIImage()
    }
    
}