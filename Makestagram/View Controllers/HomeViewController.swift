//
//  HomeViewController.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 29/11/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {
    
    @IBOutlet var noItemView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    
    let timesStampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter
    }()
    
    deinit {
        print("deinit HomeViewController!")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = messageLabel
        messageLabel.textAlignment = NSTextAlignment.center
        
        tableView.delegate = self
        tableView.dataSource = self
        
        UserService.timeline() { (posts) in
            self.posts.append(contentsOf: posts)
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(kPostCountNotification), object: nil, queue: OperationQueue.main) { (notification) in
            // Implement code run when something changes
            self.reloadTimeline()
        }
        
        configureTableView()
    }
    
    @objc func reloadTimeline() {
        self.posts.removeAll()
        
        UserService.timeline() { (posts) in
            self.posts.append(contentsOf: posts)
            self.tableView.reloadData()
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func configureTableView(){
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        refreshControl.addTarget(self, action: #selector(reloadTimeline), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func handleOptionsButtonTap(from cell: PostHeaderCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let post = posts[indexPath.section]
        let poster = post.poster
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if poster.uid != User.current!.uid {
            let flagAction = UIAlertAction(title: "Report as Inappropriate", style: .default) { _ in
                PostService.flag(post)
                
                let okAlert = UIAlertController(title: nil, message: "The post has been flagged.", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(okAlert, animated: true)
            }
            
            alertController.addAction(flagAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

extension HomeViewController :  UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard posts.count > 0 else { return UITableViewCell() }
        
        let post = posts[indexPath.section]
        
        switch indexPath.row {
        case 0:
            let cell: PostHeaderCell = tableView.dequeueReusableCell()
            cell.usernameLabel.text = post.poster.username
            cell.didTapOptionsButtonForCell = handleOptionsButtonTap(from:)
            
            return cell
        case 1:
            let cell: PostImageCell = tableView.dequeueReusableCell()
            let imageURL = URL(string: post.imageURL)
            cell.postImageView.kf.setImage(with: imageURL)
            return cell
        case 2:
            let cell: PostActionCell = tableView.dequeueReusableCell()
            cell.delegate = self
            configureCell(cell, with: post)
            
            return cell
        default:
            fatalError("Error")
        }
    }
    
    func configureCell(_ cell: PostActionCell, with post: Post) {
        cell.timeAgoLabel.text = timesStampFormatter.string(from: post.creationDate)
        cell.likeButton.isSelected = post.isLiked
        if post.likeCount > 1 {
           cell.likeCountLabel.text = "\(post.likeCount) likes"
            
        } else {
            cell.likeCountLabel.text = "\(post.likeCount) like"
        }
    }
}

extension HomeViewController : UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard posts.count > 0 else { return 0 }
        
        switch indexPath.row {
        case 0:
            return PostHeaderCell.height
        case 1:
            let post = posts[indexPath.section]
            return post.imageHeight
        case 2:
            return PostActionCell.height
        default:
            fatalError("Error")
        }
    }
}

extension HomeViewController: PostActionCellDelegate {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell) {
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        likeButton.isUserInteractionEnabled = false
        
        let post = posts[indexPath.section]
        LikeService.setIsLiked(!post.isLiked, for: post) { (success) in
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            guard success
                else { return }
            
            post.likeCount += !post.isLiked ? 1 : -1
            post.isLiked = !post.isLiked
            
            guard let cell = self.tableView.cellForRow(at: indexPath) as? PostActionCell
                else { return }
            
            DispatchQueue.main.async {
                self.configureCell(cell, with: post)
            }
        }
    }
}
