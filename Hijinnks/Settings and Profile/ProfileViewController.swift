//
//  ProfileViewController.swift
//  Hijinnks
//
//  Created by adeiji on 3/10/17.
//  Copyright © 2017 adeiji. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ProfileViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, PassDataBetweenViewControllersProtocol, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
 
    var profileView:ProfileView!
    var user:PFUser!
    var invitations:[Invitation]! = [Invitation]()
    var activitySpinner:UIActivityIndicatorView!
    
    func startActivitySpinner () {
        // Add the activity spinner
        self.activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activitySpinner.startAnimating()
        self.activitySpinner.hidesWhenStopped = true
        
        self.view.addSubview(self.activitySpinner)
        self.activitySpinner.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
    }
    
    init(user: PFUser) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.profileView = ProfileView(myUser: self.user, myTableViewDataSourceAndDelegate: self)
        self.view.addSubview(self.profileView)
        self.profileView.setupUI()  // Setup the UI after we've added to the subview to make sure that the profile view can be set up with autolayout to it's superview
        self.getAllInvitationsFromUser()
        if self.profileView.optionsButton != nil {
            self.profileView.optionsButton.addTarget(self, action: #selector(displayProfileOptions), for: .touchUpInside)
        }
        if self.profileView.addFriendButton != nil {
            self.profileView.addFriendButton.addTarget(self, action: #selector(addFriendButtonPressed), for: .touchUpInside)
        }
        // Only allow the user to edit the profile image if the user is looking at his own profile page
        if user == PFUser.current() {
            self.profileView.imageViewTapRecognizer.addTarget(self, action: #selector(profileImageTapped))
            self.profileView.imageViewTapRecognizer.delegate = self
        }
    }
    
    func profileImageTapped () {
        let photoHandler = PhotoHandler(viewController: self)
        _ = photoHandler.promptForPicture()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 0.2)
        self.profileView.profileImageView.image = image
        DEUserManager.sharedManager.addProfileImage(imageData!)
    }
    
    // Display the interests page to allow the user to affiliate their friend with specific interests
    func addFriendButtonPressed () {
        let viewInterestsViewController = ViewInterestsViewController(setting: Settings.ViewInterestsAddFriend)
        viewInterestsViewController.delegate = self
        self.navigationController?.pushViewController(viewInterestsViewController, animated: true)
    }
    
    // When the user sets the interests for the friend that they're adding than we add the friend and attribute the friend to specific interests
    func setSelectedInterests(mySelectedInterest: NSArray) {
        // The name of the interests_group will be set to whatever the name of the interests is that was selected
        // So we go through each interests and add this new friend to the interests selected
        for interest in mySelectedInterest {
            let myInterestGroup = InterestsGroupParseObject()
            myInterestGroup.name = interest as! String
            myInterestGroup.friend = user
            myInterestGroup.owner = PFUser.current()!
            myInterestGroup.saveEventually()
        }
        
        // Add the friend and save to the server
        PFUser.current()?.add(user.objectId!, forKey: ParseObjectColumns.Friends.rawValue)
        PFUser.current()?.saveEventually()
    }
    
    func displayProfileOptions () {
        let optionsViewController = OptionsViewController()
        self.navigationController?.pushViewController(optionsViewController, animated: true)
    }
    
    // Get all the invitations that have been sent by the user of this profile view
    func getAllInvitationsFromUser () {
        
        self.startActivitySpinner()
        let query = InvitationParseObject.query()
        query?.whereKey(ParseObjectColumns.FromUser.rawValue, equalTo: user)
        query?.findObjectsInBackground(block: { (invitationParseObjects, error) in
            if error != nil {
                // Display that there was an error retrieving the invitations
                print(error!.localizedDescription)
            }
            else {
                self.displayInvitationsForUser(invitationParseObjects: invitationParseObjects as! [InvitationParseObject]!)
                self.activitySpinner.stopAnimating()
                self.activitySpinner.removeFromSuperview()
                self.tabBarController?.tabBar.isUserInteractionEnabled = true
            }
        })
    }
    
    // Display the invitations that this user has done in the table view for this view controller
    func displayInvitationsForUser (invitationParseObjects : [InvitationParseObject]!) {
        for invitationParseObject in invitationParseObjects! {
            let myInvitation = invitationParseObject.getInvitation()
            // Set the user to the user that is already set for this View Controller, otherwise we'll have to fetch the user from every single invitation parse object that is received from the user which would be pointless because we already have that fetched object (user) as a property for this class
            myInvitation.fromUser = user
            self.invitations?.append(myInvitation)
        }
        
        self.profileView.viewInvitationsTableView.dataSource = self
        self.profileView.viewInvitationsTableView.delegate = self
        self.profileView.viewInvitationsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // This can happen if there are no invitations for the user or any in the area
        return invitations.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeightForCell(invitation: invitations[indexPath.row])
    }
    
    func calculateHeightForCell (invitation: Invitation) -> CGFloat {
        let viewInvitationCell = ViewInvitationsCell(invitation: invitation)
        viewInvitationCell.contentView.layoutIfNeeded()
        let size = viewInvitationCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return size.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewInvitationsCell = ViewInvitationsCell(invitation: invitations[indexPath.row])
        return viewInvitationsCell
    }
    
}
