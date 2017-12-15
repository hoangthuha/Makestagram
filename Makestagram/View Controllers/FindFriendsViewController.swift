//
//  FindFriendsViewController.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 29/11/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import UIKit

class FindFriendsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 71
        self.automaticallyAdjustsScrollViewInsets = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserService.usersExcludingCurrentUser { [unowned self] (users) in
            self.users = users
            self.tableView.reloadData()
        }
    }
    @IBAction func dismissButtonTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true)
    }
}

extension FindFriendsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.count == 0 {
            self.tableView.setEmptyMessage("Don't have any friends available")
        } else {
            self.tableView.restore()
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsCell") as! FindFriendsCell
        cell.delegate = self
        configure(cell: cell, atIndexPath: indexPath)
        return cell
    }
    
    func configure(cell: FindFriendsCell, atIndexPath indexPath: IndexPath) {
        let user = users[indexPath.row]
        cell.usernameLabel.text = user.username
        cell.followButton.isSelected = user.isFollowed
        cell.followButton.backgroundColor = user.isFollowed ? .white : UIColor.init(red: 3/255, green: 121/255, blue: 251/255, alpha: 1)
    }
}

extension FindFriendsViewController: FindFriendsCellDelegate {
    func didTapFollowButton(_ followButton: UIButton, on cell: FindFriendsCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        followButton.isUserInteractionEnabled = false
        let followee = users[indexPath.row]
        
        FollowService.setIsFollowing(!followee.isFollowed, fromCurrentUserTo: followee) { (success) in
            followButton.isUserInteractionEnabled = true
            
            guard success else { return }
            
            followee.isFollowed = !followee.isFollowed
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "Menlo", size: 20)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
