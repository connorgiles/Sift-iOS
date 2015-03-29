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
        textContent.text = article.fullArticle
        
        if article.hasImage! {
            
            println("Has Image")
            articleImage.image = article.articleImage
            
        } else {
            
            println("Needs image")
            
            article.retrieveImage({ () -> () in
                self.articleImage.image = self.article.articleImage
                println("Image has been cached")
                
            })
            
            
        }
        
        articleImage.clipsToBounds = true
        articleImage.contentMode = UIViewContentMode.ScaleAspectFill
        
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
