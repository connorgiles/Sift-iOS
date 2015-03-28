//
//  ViewController.swift
//  Sift
//
//  Created by Connor Giles on 2015-03-28.
//  Copyright (c) 2015 Connor Giles. All rights reserved.
//

import UIKit
import SVPullToRefresh
import SVProgressHUD
import Spring
import SDWebImage

var imagesDownloading = 0

class FeedCell: UITableViewCell{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var publicationLogo: UIImageView!
    @IBOutlet weak var articleImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        articleImage.frame = CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: self.contentView.bounds.height)
    }
    
}

class FeedViewController: UIViewController {
    
    var articles = [Article]()
    var selected: Article!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addPullToRefreshWithActionHandler({self.getOlderArticles()})
        tableView.addInfiniteScrollingWithActionHandler({self.getNewerArticles()})
        
        tableView.pullToRefreshView.setTitle("Get older articles...", forState: UInt(SVPullToRefreshStateTriggered))
        
        tableView.scrollsToTop = true
        
        getNewerArticles()
        
    }
    
    func getNewerArticles() {
        
        for var i = 0; i<10; i++ {
            articles.append(Article(title: "Article", author: "Author", date: NSDate(), pictureURL: "https://download.unsplash.com/photo-1421977870504-378093748ae6", publication: "Publication", summarizedArticle: "", fullArticle: ""))
            
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: articles.count-1
                , inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        tableView.infiniteScrollingView.stopAnimating()
    }
    
    func getOlderArticles() {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
        
        for var i = 0; i<10; i++ {
            articles.insert(Article(title: "Article", author: "Author", date: NSDate(), pictureURL: "https://download.unsplash.com/photo-1421977870504-378093748ae6", publication: "Publication", summarizedArticle: "", fullArticle: ""), atIndex: 0)
        }
        
        tableView.reloadData()
        
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 10, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        
        tableView.pullToRefreshView.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let articleView = segue.destinationViewController as ArticleViewController
        articleView.article = selected
    }
    
    @IBAction func closeArticleViewController (sender: UIStoryboardSegue){
        let articleView = sender.sourceViewController as ArticleViewController
        articleView.removeFromParentViewController()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}

extension FeedViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let article = articles[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell") as FeedCell
        
        cell.titleLabel.text = article.title
        cell.detailsLabel.text = article.details
        
        println(article.hasImage)
        SVProgressHUD.show()
        imagesDownloading++
        
        cell.articleImage.sd_setImageWithURL(article.pictureURL, placeholderImage: UIImage(), options: SDWebImageOptions.RetryFailed, completed:  {
            (image, error, imageCacheType, URL) -> Void in
            
            if error != nil {
                println("Error: \(error)")
            } else {
                cell.articleImage.clipsToBounds = true
                cell.articleImage.contentMode = UIViewContentMode.ScaleAspectFill
                cell.setNeedsLayout()
            }
            imagesDownloading--
            
            if imagesDownloading == 0 {
                SVProgressHUD.dismiss()
            }
            
        })
        
        cell.layoutSubviews()
        
        
        return cell
        
    }
}

extension FeedViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selected = articles[indexPath.row]
        println("\(selected.title) Selected")
        
        performSegueWithIdentifier("displayArticle", sender: self)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    
}