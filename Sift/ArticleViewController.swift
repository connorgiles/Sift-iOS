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
    
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textContent: UITextView!
    @IBOutlet weak var publicationLogo: UIImageView!
    @IBOutlet weak var detailsLabel: UILabel!
    
    var feedView: FeedViewController!
    
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
    
}

extension ArticleViewController: NSLayoutManagerDelegate {
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}

extension ArticleViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let bottomOffset = scrollView.contentSize.height - scrollView.bounds.origin.y - scrollView.bounds.height
        
        if bottomOffset < -60 {

            var anim = POPBasicAnimation(propertyNamed: kPOPLayerPosition)
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            //anim.fromValue = NSValue(CGPoint: view.frame.origin)
            anim.toValue = NSValue(CGPoint: CGPoint(x: view.center.x, y: -view.frame.height))
            anim.completionBlock = {
                (pop: POPAnimation!, done: Bool) -> Void in
                if done {
                    self.dismissViewControllerAnimated(false, completion: { () -> Void in
                        self.feedView.tableView.reloadData()
                    })
                }
            }
            anim.duration = 0.3
            
            view.pop_addAnimation(anim, forKey: "slideUp")
            
            view.pop_animationForKey("slideUp")
            
        } else if scrollView.bounds.origin.y < -60 {
            dismissViewControllerAnimated(true, completion: { () -> Void in
                self.feedView.tableView.reloadData()
            })
        }
    }
}
