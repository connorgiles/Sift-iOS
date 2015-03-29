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
import SDWebImage

var imagesDownloading = 0

class FeedCell: UITableViewCell{
    
    @IBOutlet weak var upvotesLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var publicationLogo: UIImageView!
    @IBOutlet weak var articleImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        articleImage.frame = CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: self.contentView.bounds.height)
    }
    
    func setupArticle(article: Article) {
        
        titleLabel.text = article.title
        detailsLabel.text = article.details
        publicationLogo.image = article.getPublicationLogo()
        upvotesLabel.text = String(article.upvotes)
        
        articleImage.image = article.articleImage
        articleImage.clipsToBounds = true
        articleImage.contentMode = UIViewContentMode.ScaleAspectFill
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
        
        //Setup Google Service
        var service = GTLServiceSift()
        service.retryEnabled = true
        
        //Declare Request Message
        var articleRequest = GTLSiftMainArticleRequest()
        
        //Set Request Paramaters
        if articles.count == 0 {
            articleRequest.currentArticleTimestamp = NSInteger(NSDate().timeIntervalSince1970-(12*60*60*7))
        } else {
            articleRequest.currentArticleTimestamp = articles.last?.date.timeIntervalSince1970
        }
        
        articleRequest.numOfArticles = 20
        articleRequest.userId = "TEST"
        
        //Delare query
        var query = GTLQuerySift.queryForSiftApiGetArticlesWithObject(articleRequest) as GTLQuerySift
        
        //Perform authentication and login
        service.executeQuery(query, completionHandler: { (ticket: GTLServiceTicket!, object: AnyObject!, error: NSError!) -> Void in
            if object != nil {
                
                //Cast down to Article Response Message
                let response = object as GTLSiftMainArticleResponse
                
                if response.articles != nil {
                    let newArticles = response.articles as [GTLSiftMainArticle]
                    
                    for article in newArticles {
                        self.articles.append(Article(article: article))
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.articles.count-1
                            , inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                    }
                } else {
                    println("NO MORE ARTICLES")
                    
                    SVProgressHUD.showInfoWithStatus("That's all for today!")
                }
                
                
            } else {
                println("Error: \(error)")
            }
            
            self.tableView.infiniteScrollingView.stopAnimating()
            
        })
        
    }
    
    func getOlderArticles() {
        
        /*
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
        
        for var i = 0; i<10; i++ {
        articles.insert(Article(title: "Article", author: "Author", date: NSDate(), pictureURL: "https://download.unsplash.com/photo-1423753623104-718aaace6772", publication: "Publication", summarizedArticle: "", fullArticle: ""), atIndex: 0)
        }
        
        tableView.reloadData()
        
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 10, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        
        tableView.pullToRefreshView.stopAnimating()
        
        */
        
        //Setup Google Service
        var service = GTLServiceSift()
        service.retryEnabled = true
        
        //Declare Request Message
        var articleRequest = GTLSiftMainArticleRequest()
        
        //Set Request Paramaters
        if articles.count == 0 {
            articleRequest.currentArticleTimestamp = NSDate().timeIntervalSince1970
        } else {
            articleRequest.currentArticleTimestamp = articles.first?.date.timeIntervalSince1970
        }
        
        articleRequest.numOfArticles = -20
        articleRequest.userId = "TEST"
        
        //Delare query
        var query = GTLQuerySift.queryForSiftApiGetArticlesWithObject(articleRequest) as GTLQuerySift
        
        //Perform authentication and login
        service.executeQuery(query, completionHandler: { (ticket: GTLServiceTicket!, object: AnyObject!, error: NSError!) -> Void in
            if object != nil {
                
                //Cast down to Article Response Message
                let response = object as GTLSiftMainArticleResponse
                
                if response.articles != nil {
                    let newArticles = response.articles as [GTLSiftMainArticle]
                    
                    for article in newArticles {
                        self.articles.insert(Article(article: article), atIndex: 0)
                        
                        self.tableView.reloadData()
                        
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: newArticles.count, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                        
                        self.tableView.pullToRefreshView.stopAnimating()
                    }
                } else {
                    println("NO MORE ARTICLES")
                    
                    SVProgressHUD.showInfoWithStatus("You've tapped us out!")
                }
                
                
            } else {
                println("Error: \(error)")
            }
            
            self.tableView.infiniteScrollingView.stopAnimating()
            
        })
        
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
        tableView.reloadData()
        
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
        
        if article.hasImage! {
            
            println("Has Image")
            
            cell.setupArticle(article)
            cell.setNeedsLayout()
            
        } else {
            
            println("Needs image")
            
            article.retrieveImage({ () -> () in
                cell.setupArticle(article)
                cell.setNeedsLayout()
                println("Image has been cached")
                
            })
        }
        
        cell.layoutSubviews()
        
        
        return cell
        
    }
}

extension FeedViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selected = articles[indexPath.row]
        println("Reading \"\(selected.title)\"")
        
        performSegueWithIdentifier("displayArticle", sender: self)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    
}