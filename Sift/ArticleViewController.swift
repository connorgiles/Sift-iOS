//
//  ArticleViewController.swift
//  Sift
//
//  Created by Connor Giles on 2015-03-28.
//  Copyright (c) 2015 Connor Giles. All rights reserved.
//

import UIKit
import SDWebImage
import AudioToolbox
import pop

class ArticleViewController: UIViewController {
    
    var article: Article!
    
    @IBOutlet weak var upvotesLabel: UILabel!
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
        upvotesLabel.text = String(article.upvotes)
        
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
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            var newText: String!
            
            switch textContent.text {
                
            case article.fullArticle:
                newText = article.summarizedArticle
                
            case article.summarizedArticle:
                newText = article.fullArticle
                
            default:
                println("NO CONTENT")
                
            }
            
            var anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            anim.fromValue = 1
            anim.toValue = 0
            
            textContent.pop_addAnimation(anim, forKey: "fadeOut")
            
            anim.fromValue = 0
            anim.toValue = 1
            
            textContent.pop_addAnimation(anim, forKey: "fadeIn")
            
            textContent.pop_animationForKey("fadeOut")
            textContent.text = newText
            textContent.pop_animationForKey("fadeIn")
            
            //Vibrate Phone
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
        }
    }
    
    @IBAction func recommentArticle(sender: AnyObject) {
        //Setup Google Service
        var service = GTLServiceSift()
        service.retryEnabled = true
        
        //Declare Request Message
        var upvoteRequest = GTLSiftMainUpvoteRequest()
        
        //Set Request Paramaters
        
        upvoteRequest.articleTitle = article.title
        upvoteRequest.userId = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        //Declare query
        var query = GTLQuerySift.queryForSiftApiUpvoteWithObject(upvoteRequest) as GTLQuerySift
        
        if(article.upvotedByUser == 0){
        //Perform authentication and login
        service.executeQuery(query, completionHandler: { (ticket: GTLServiceTicket!, object: AnyObject!, error: NSError!) -> Void in
            if object != nil {
                
                //Cast down to Article Response Message
                let response = object as GTLSiftMainUpvoteResponse
                
                self.upvotesLabel.text = response.articleUpvotes.stringValue
                
                self.article.upvotes = response.articleUpvotes as Int
                
                self.article.upvotedByUser = 1
                
                
            } else {
                println("Error: \(error)")
            }
            
        })
        }

    }

}



extension ArticleViewController: NSLayoutManagerDelegate {
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}
