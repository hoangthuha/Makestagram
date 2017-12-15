//
//  ProfileViewController.swift
//  Makestagram
//
//  Created by Hoang Thu Ha on 5/12/17.
//  Copyright © 2017 Hoang Thu Ha. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Kingfisher

class ProfileViewController: UIViewController {
    
    let itemWidth = (UIScreen.main.bounds.size.width - (1 * 2)) / 3
    
    var authHandle: AuthStateDidChangeListenerHandle?
    let refreshControl = UIRefreshControl()
    
    var user: User!
    var posts = [Post]()
    
    var profileHandle: DatabaseHandle = 0
    var profileRef: DatabaseReference?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        user = User.current
        navigationItem.title = user.username
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(kPostCountNotification), object: nil, queue: OperationQueue.main) { (notification) in
            if let postCount = notification.object as? Int {
                self.user.postCount = postCount
                self.reloadTimeline()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(kFollowingCountNotification), object: nil, queue: OperationQueue.main) { (notification) in
            if let followingCount = notification.object as? Int {
                self.user.followingCount = followingCount
                self.collectionView.reloadData()
            }
        }
        
        configureCollectionView()
        
        authHandle = Auth.auth().addStateDidChangeListener() { [unowned self] (auth, user) in
            guard user == nil else { return }
            
            let loginViewController = UIStoryboard.initialViewController(for: .login)
            self.view.window?.rootViewController = loginViewController
            self.view.window?.makeKeyAndVisible()
        }
        
        UserService.posts(for: user) { (posts) in
            self.posts = posts
            self.collectionView.reloadData()
        }
    }
    
    @objc func reloadTimeline() {
        self.posts.removeAll()
        
        UserService.posts(for: User.current!, completion: { (posts) in
            self.posts.append(contentsOf: posts)
            self.collectionView.reloadData()
            
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    @objc func configureCollectionView() {
        refreshControl.addTarget(self, action: #selector(reloadTimeline), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    deinit {
        if let authHandle = authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
        NotificationCenter.default.removeObserver(self)
    }
}

extension ProfileViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.itemWidth, height: self.itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}

extension ProfileViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if posts.count == 0 {
            self.collectionView.setEmptyMessage("Upload more photos to let your friends see!")
        } else {
            self.collectionView.restore()
        }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"PostThumbImageCell", for: indexPath) as! PostThumbImageCell
        let post = posts[indexPath.row]
        let imageURL = URL(string: post.imageURL)
        cell.thumbImageView.kf.setImage(with: imageURL)
        collectionView.reloadItems(at: [indexPath])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let cell = collectionView.cellForItem(at: indexPath) as? PostThumbImageCell else { return }
        
        let storyboard = UIStoryboard(name: "Photo", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController else { return }
        let post = posts[indexPath.row]
        controller.post = post
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
   
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            fatalError("Unexpected element kind.")
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ProfileHeaderView", for: indexPath) as! ProfileHeaderView
        
        let postCount = user.postCount ?? 0
        headerView.postCountLabel.text = "\(postCount)"
        
        let followerCount = user.followerCount ?? 0
        headerView.followerCountLabel.text = "\(followerCount)"
        
        let followingCount = user.followingCount ?? 0
        headerView.followingCountLabel.text = "\(followingCount)"
        
        headerView.delegate = self
        
        return headerView
    }
  
}
extension ProfileViewController: ProfileHeaderViewDelegate {
    func didTapSettingsButton(_ button: UIButton, on headerView: ProfileHeaderView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .default) { _ in
            do {
                try Auth.auth().signOut()
            } catch let error as NSError {
                assertionFailure("Error signing out: \(error.localizedDescription)")
            }
        }
        alertController.addAction(signOutAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}

extension ProfileViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "findFriend", sender: self)
    }
}

extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "Menlo", size: 20)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.indicatorStyle = .default
    }
    
    func restore() {
        self.backgroundView = nil
        self.indicatorStyle = .default
    }
}



