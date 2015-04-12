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

var buttonColor = UIColor(red: 18/255.0, green: 94/255.0, blue: 171/255.0, alpha: 1)

class ArticleViewController: UIViewController {
    
    var article: Article!
    
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textContent: UITextView!
    @IBOutlet weak var publicationLogo: UIImageView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var recomendButton: UIButton!
    var isDragging = true
    @IBOutlet weak var groupView: UIView!
    
    var feedView: FeedViewController!
    
    override func viewDidLoad() {
        
        textContent.textContainer.lineFragmentPadding = 0
        textContent.layoutManager.delegate = self
        
        titleLabel.text = article.title
        
        var text = NSMutableAttributedString(string: article.summarizedArticle)
        
        text = addLinks(text)
        
        textContent.attributedText = text
        detailsLabel.text = article.details
        publicationLogo.image = article.getPublicationLogo()
        upvotesLabel.text = "Recommended by \(article.upvotes)"
        
        recomendButton.layer.borderColor = buttonColor.CGColor
        recomendButton.layer.borderWidth = 1
        self.recomendButton.setTitleColor(buttonColor, forState: UIControlState.Normal)
        
        if article.upvotedByUser == 1 {
            self.recomendButton.layer.borderWidth = 0
            self.recomendButton.layer.backgroundColor = buttonColor.CGColor
            self.recomendButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            self.recomendButton.setTitle("Recommended", forState: UIControlState.Normal)
        }
        
        
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
    
    func addLinks(content: NSMutableAttributedString) -> NSMutableAttributedString {
        
        var newText = NSMutableAttributedString()
        var text = content
        
        while text.length > 0 {
            
            //Find Open tag and link
            let openIndex = text.mutableString.rangeOfString("{a=")
            
            if openIndex.location != NSNotFound {
                
                let openEnd = text.mutableString.rangeOfString("}")
                let linkURL = text.mutableString.substringWithRange(NSRange(location: openIndex.location + openIndex.length, length: openEnd.location - (openIndex.location + openIndex.length)))
                println(linkURL)
                
                //Move previous text to newText
                newText.appendAttributedString(NSAttributedString(string: text.mutableString.substringToIndex(openIndex.location)))
                
                //Take off previous text on search text
                text = NSMutableAttributedString(string: text.mutableString.substringFromIndex(openEnd.location + openEnd.length))
                
                //Find Close Tag
                let closeIndex = text.mutableString.rangeOfString("{a}")
                
                //Text range to apply link to
                let linkTextRange = NSRange(location: 0, length: closeIndex.location)
                var linkText = NSMutableAttributedString(string: text.mutableString.substringWithRange(linkTextRange))
                
                //Add Attributes
                linkText.addAttribute(NSLinkAttributeName, value: linkURL, range: linkTextRange)
                linkText.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: linkTextRange)
                
                //Add link to newText
                newText.appendAttributedString(linkText)
                
                
                //Take off previous text on search text
                text = NSMutableAttributedString(string: text.mutableString.substringFromIndex(closeIndex.location + closeIndex.length))
            } else {
                newText.appendAttributedString(text)
                break
            }
            
        }
        
        //println(newText)
        
        return newText
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
    
    @IBAction func recommendArticle(sender: AnyObject) {
        //Setup Google Service
        var service = GTLServiceSift()
        service.retryEnabled = true
        
        //Declare Request Message
        var upvoteRequest = GTLSiftMainUpvoteRequest()
        
        //Set Request Paramaters
        
        upvoteRequest.articleTitle = article.title
        upvoteRequest.userId = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        //Declare query
        var query = GTLQuerySift.queryForSiftApiUpvoteWithObject(upvoteRequest) as! GTLQuerySift
        
        if(article.upvotedByUser == 0) {
            //Perform authentication and login
            service.executeQuery(query, completionHandler: { (ticket: GTLServiceTicket!, object: AnyObject!, error: NSError!) -> Void in
                if object != nil {
                    
                    //Cast down to Article Response Message
                    let response = object as! GTLSiftMainUpvoteResponse
                    
                    self.article.upvotes = response.articleUpvotes as Int
                    
                    self.upvotesLabel.text = "Recommended by \(self.article.upvotes)"
                    
                    self.recomendButton.layer.borderWidth = 0
                    self.recomendButton.layer.backgroundColor = buttonColor.CGColor
                    self.recomendButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    self.recomendButton.setTitle("Recommended", forState: UIControlState.Normal)
                    
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

extension ArticleViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let bottomOffset = scrollView.contentSize.height - scrollView.bounds.origin.y - scrollView.bounds.height
        
        if bottomOffset < -60 && !isDragging {
            
            var anim = POPBasicAnimation(propertyNamed: kPOPLayerPosition)
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            //anim.fromValue = NSValue(CGPoint: view.frame.origin)
            anim.toValue = NSValue(CGPoint: CGPoint(x: view.center.x, y: -view.frame.height))
            anim.completionBlock = {
                (pop: POPAnimation!, done: Bool) -> Void in
                if done {
                    self.dismissViewControllerAnimated(false, completion: { () -> Void in
                        self.feedView.tableView.reloadData()
                        self.feedView.viewingArticle = false
                        self.feedView.setNeedsStatusBarAppearanceUpdate()
                    })
                }
            }
            anim.duration = 0.2
            
            view.pop_addAnimation(anim, forKey: "slideUp")
            
            view.pop_animationForKey("slideUp")
            
        } else if scrollView.bounds.origin.y < -60 && !isDragging {
            dismissViewControllerAnimated(true, completion: { () -> Void in
                self.feedView.tableView.reloadData()
                self.feedView.viewingArticle = false
                self.feedView.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isDragging = true
        println("Touch")
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isDragging = false
        println("End")
    }
}
