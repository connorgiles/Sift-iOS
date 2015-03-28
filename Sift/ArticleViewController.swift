//
//  ArticleViewController.swift
//  Sift
//
//  Created by Connor Giles on 2015-03-28.
//  Copyright (c) 2015 Connor Giles. All rights reserved.
//

import UIKit
import SDWebImage

class ArticleViewController: UIViewController {
    
    var article: Article!
    
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textContent: UITextView!
    @IBOutlet weak var publicationLogo: UIImageView!
    
    override func viewDidLoad() {
        
        titleLabel.text = article.title
        textContent.text = article.summarizedArticle
        
        articleImage.sd_setImageWithURL(article.pictureURL, placeholderImage: UIImage(), options: SDWebImageOptions.RetryFailed, completed:  {
            (image, error, imageCacheType, URL) -> Void in
            
            if error != nil {
                println("Error: \(error)")
            } else {
                self.articleImage.clipsToBounds = true
            }
            
            if imagesDownloading == 0 {
            }
            
        })
        
    }

}
