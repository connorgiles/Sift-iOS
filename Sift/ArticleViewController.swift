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
    @IBOutlet weak var detailsLabel: UILabel!
    
    override func viewDidLoad() {
        
        textContent.textContainer.lineFragmentPadding = 0
        textContent.layoutManager.delegate = self
        
        titleLabel.text = article.title
        textContent.text = article.summarizedArticle
        detailsLabel.text = article.details
        publicationLogo.image = article.getPublicationLogo()
        
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

extension ArticleViewController: NSLayoutManagerDelegate {
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}
