//
//  ViewController.swift
//  Sift
//
//  Created by Connor Giles on 2015-03-28.
//  Copyright (c) 2015 Connor Giles. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var publicationLabel: UILabel!
    
}

class FeedViewController: UIViewController {
    
    var articles = [Article]()
    var selected: Article!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for var i = 0; i<10; i++ {
            articles.append(Article(articleID: String(i), title: "Article \(i)", author: "Author \(i)", date: NSDate(), pictureURL: "", publication: "Publication \(i)", summarizedArticle: "", fullArticle: ""))
        }
        
    }
    
    func getNewArticles() {
        
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

}

extension FeedViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell") as FeedCell
        
        cell.titleLabel.text = articles[indexPath.row].title
        cell.detailsLabel.text = articles[indexPath.row].details
        cell.publicationLabel.text = articles[indexPath.row].publication
        
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