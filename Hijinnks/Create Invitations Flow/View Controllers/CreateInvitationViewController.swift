//
//  CreateInvitationViewController.swift
//  Hijinnks
//
//  Created by adeiji on 2/23/17.
//  Copyright © 2017 adeiji. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import GooglePlaces
import Parse
import FBSDKShareKit

class CreateInvitationViewController : UIViewController, PassDataBetweenViewControllersProtocol {
    weak var wrapperView:UIView! // This is so that we can have one view in which the Scroll View will have as it's indicator for scrolling
    weak var headerLabel:UILabel! // This label displays the short description for this page -- Create Invitation
    weak var nameTextField:UITextField!
    weak var locationTextField:UITextField!
    weak var inviteMessageTextField:UITextField!
    weak var startingTimeTextField:UITextField!
    weak var durationTextField:UITextField!
    
    weak var inviteesTextField:UITextField!
    weak var inviteInterestsTextField:UITextField! // Change this in production
    weak var scrollView:UIScrollView!
    
    var selectedInterests:NSArray!
    var selectedFriends:NSArray!
    var name:String!
    var address:String!
    var locationCoordinates:CLLocation!
    var inviteMessage:String!
    var startingTime:Date!
    var duration:String!
    var place:GMSPlace!
    var durations:Array<String>!
    var delegate:PassDataBetweenViewControllersProtocol!
    var isPublic:Bool!
    var invitationSendScope:InvitationSendScope!
    
    enum InvitationSendScope {
        case Everyone
        case AllFriends
        case SomeFriends
    }
    
    weak var selectedTextField:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification: )), name: NSNotification.Name.UIKeyboardWillShow , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification: )), name: NSNotification.Name.UIKeyboardWillHide , object: nil)
    }
    
    func reset () {
        setupUI()
        self.selectedInterests = nil
        self.selectedFriends = nil
        self.name = nil
        self.address = nil
        self.locationCoordinates = nil
        self.inviteMessage = nil
        self.startingTime = nil
        self.duration = nil
        self.place = nil
        self.durations = nil
        self.isPublic = true
        self.invitationSendScope = nil
    }
    
    func setSelectedInterests(mySelectedInterest: NSArray) {
        selectedInterests = mySelectedInterest
        var interestsString = String()
        
        for interest in selectedInterests {
            if (interest as! String) != (selectedInterests.lastObject as! String) {
                interestsString += (interest as! String) + ", "
            }
            else {
                interestsString += (interest as! String)
            }
        }
        
        inviteInterestsTextField.text = interestsString
    }
    
    func setSelectedFriends(mySelectedFriends: NSArray) {
        self.selectedFriends = mySelectedFriends
        let selectedFriendsUserObjects = mySelectedFriends as! [PFUser]
        for user in selectedFriendsUserObjects {
            if user != selectedFriendsUserObjects.last {
                self.inviteesTextField.text = self.inviteesTextField.text! + "\(user.username!), "
            } else {
                self.inviteesTextField.text = self.inviteesTextField.text! + "\(user.username!)"
            }
        }
        self.invitationSendScope = InvitationSendScope.SomeFriends
    }
    
    func setSelectedFriendsToEveryone() {
        if PFUser.current()?.object(forKey: ParseObjectColumns.Friends.rawValue) != nil {
            self.selectedFriends = PFUser.current()?.object(forKey: ParseObjectColumns.Friends.rawValue) as! NSArray
            self.inviteesTextField.text = "All Your Friends"
            self.invitationSendScope = InvitationSendScope.AllFriends
        }
    }
    
    func setSelectedFriendsToAnyone() {
        self.selectedFriends = [PFUser]() as NSArray!
        self.inviteesTextField.text = "Public to Anyone"
        self.invitationSendScope = InvitationSendScope.Everyone
    }
    
    func getLocation () -> CLLocation! {
        // If the user did not select a place using the Google Maps Autocomplete feature, than we need to use his current location
        // So we need to get the current location from the Location Manager and than we need to get an address using the Lat/Long coordinates returned
        if self.place == nil {
            let locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager
            self.locationCoordinates = locationManager!.currentLocation
        
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(self.locationCoordinates, completionHandler: { (placemarks : [CLPlacemark]?, error: Error?) in
                let placemark = placemarks?.first
                let addressNumber = placemark?.subThoroughfare
                let address = placemark?.thoroughfare
                let city = placemark?.locality
                let state = placemark?.administrativeArea
                let zipCode = placemark?.postalCode
                
                let fullAddress = String("\(addressNumber!) \(address!), \(city!), \(state!) \(zipCode!)")
                self.address = fullAddress
                self.saveAndSendInvitation(currentLocation: (placemark?.location)!)
            })
        }
        else {
            return CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        
        return nil
    }
    
    func saveAndSendInvitation (currentLocation: CLLocation) {
        // Check to make sure all the data entered is valid
        var invitees:NSArray!
        if validateTextFields() {
            if invitationSendScope == InvitationSendScope.SomeFriends // If the user has selected some friends
            {
                invitees = self.selectedFriends
                createInvitationAndSend(currentLocation: currentLocation, invitees: invitees as! Array<PFUser>)
            }
            else if invitationSendScope == InvitationSendScope.AllFriends { // If the user has selected all friends
                let query = PFUser.query()
                // Get all the Users that have ObjectIds stored on the device as friends object ids
                query?.whereKey(ParseObjectColumns.ObjectId.rawValue, containedIn: PFUser.current()?.object(forKey: ParseObjectColumns.Friends.rawValue) as! [Any])
                query?.findObjectsInBackground(block: { (friends, error) in
                    if (friends != nil) {
                        self.createInvitationAndSend(currentLocation: currentLocation, invitees: friends as! [PFUser])
                    }
                })
            }
            else {  // If the user has made the invitation public
                createInvitationAndSend(currentLocation: currentLocation, invitees: Array<PFUser>())
            }

            self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers?.last
            self.promptPostToFacebook()
            self.reset()
        }
    }
    
    // Check to make sure that the information that needs to be entered is entered correctly
    func validateTextFields () -> Bool
    {
        if nameTextField.text == "" || self.address == nil || self.inviteMessageTextField.text == "" || self.startingTime == nil || self.durationTextField.text == nil || self.inviteesTextField.text == "" || self.selectedInterests == nil {
            
            let alertController = UIAlertController(title: "Invitation", message: "Please enter data into all fields", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    func createInvitationAndSend (currentLocation: CLLocation, invitees: Array<PFUser>) {
        // Create an invitation object with all the specified data entered by the user
        let newInvitation = Invitation( eventName: nameTextField.text!,
                                        location:  currentLocation,
                                        address: self.address,
                                        message: self.inviteMessageTextField.text,
                                        startingTime: self.startingTime,
                                        duration: self.durationTextField.text,
                                        invitees: invitees, // Send an empty array, this will mean that anyone can see it
                                        interests: self.selectedInterests as! Array<String>!,
                                        fromUser: PFUser.current()!,
                                        dateInvited: Date(),
                                        rsvpCount: 0,
                                        rsvpUsers: Array<String>())
        
        let newInvitationParseObject = newInvitation.getParseObject()
        newInvitation.invitationParseObject = newInvitationParseObject
        newInvitation.invitationParseObject.isPublic = true
        ParseManager.save(parseObject: newInvitationParseObject) // Save the new invitation to the server
        // On the view invitations view controller, add this new invitation object
        delegate.addInvitation!(invitation: newInvitation)
    }
    
    // Ask the user if they would like to post the invitation to Facebook for others to see
    func promptPostToFacebook () {
        let alertController = UIAlertController(title: "Share", message: "Would you like to share this invitation to Facebook?", preferredStyle: .actionSheet)
        let postToFacebookAction = UIAlertAction(title: "Post to Facebook", style: .default) { (action) in
            self.postToFacebook()
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(postToFacebookAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Send an invitation to facebook users
    func postToFacebook () {
        let content = FBSDKShareLinkContent()
        content.contentTitle = self.name
        content.contentURL = NSURL(string: "http://hijinnks.com") as URL!
        content.contentDescription = self.inviteMessage
        FBSDKShareDialog.show(from: self, with: content, delegate: nil)
    }
    
    // Save the invitation to the server and update the View Invitations View Controller with the new invitation
    func sendInvite () {
        let location:CLLocation! = getLocation()
        // If the location returns nil than that means that the invitations has already been created and saved to the server
        if location != nil {
            self.address = locationTextField.text
            saveAndSendInvitation(currentLocation: location)
        }
    }
    
    // Place all of the UI elements on screen
    func setupUI() {
        let donebutton = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendInvite))
        self.navigationItem.rightBarButtonItem = donebutton
        self.view.backgroundColor = .white
        scrollView = createScrollView()
        scrollView.contentSize = scrollView.frame.size
        wrapperView = createWrapperView(myScrollView: scrollView)
        nameTextField = createTextField(superview: wrapperView, relativeViewAbove: nil, leftConstraintOffset: 0, rightConstraintOffset: 0, verticalSpacingToRelativeViewAbove: UIConstants.CreateInvitationVerticalSpacing .rawValue, placeholderText: "Enter the event name", showViewController: nil, colorViewColor: Colors.green.value)
        
        locationTextField = createTextField(superview: wrapperView, relativeViewAbove: nameTextField, leftConstraintOffset: 0, rightConstraintOffset: 0, verticalSpacingToRelativeViewAbove: UIConstants.CreateInvitationVerticalSpacing .rawValue, placeholderText: "Leave Empty to Use Current Location", showViewController: nil, colorViewColor: Colors.blue.value)
        
        inviteMessageTextField = createTextField(superview: wrapperView, relativeViewAbove: locationTextField, leftConstraintOffset: 0, rightConstraintOffset: 0, verticalSpacingToRelativeViewAbove: UIConstants.CreateInvitationVerticalSpacing .rawValue, placeholderText: "Enter a message", showViewController: nil, colorViewColor: Colors.green.value)
        
        startingTimeTextField = createTextField(superview: wrapperView, relativeViewAbove: inviteMessageTextField, leftConstraintOffset: 0, rightConstraintOffset: 0, verticalSpacingToRelativeViewAbove: UIConstants.CreateInvitationVerticalSpacing .rawValue, placeholderText: "Start time and date", showViewController: nil, colorViewColor: Colors.blue.value)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        let date = NSDate.init() // gets me the current date and time
        datePicker.minimumDate = date as Date // make sure the minimum time they can choose is the current time
        datePicker.minuteInterval = 10
        startingTimeTextField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(startTimePickerDateChanged(sender:)), for: .valueChanged)
        
        durationTextField = createTextField(superview: wrapperView, relativeViewAbove: startingTimeTextField, leftConstraintOffset: 0, rightConstraintOffset: 0, verticalSpacingToRelativeViewAbove: UIConstants.CreateInvitationVerticalSpacing .rawValue, placeholderText: "Enter a duration", showViewController: nil, colorViewColor: Colors.grey.value)
        
        let selectFriendsViewController = SelectFriendsViewController()
        selectFriendsViewController.delegate = self
        
        inviteesTextField = createTextField(superview: wrapperView, relativeViewAbove: durationTextField, leftConstraintOffset: 0, rightConstraintOffset: 0, verticalSpacingToRelativeViewAbove: UIConstants.CreateInvitationVerticalSpacing .rawValue, placeholderText: "Whom would you like to invite?", showViewController: nil, colorViewColor: Colors.green.value)
        
        inviteInterestsTextField = createTextField(superview: wrapperView, relativeViewAbove: inviteesTextField, leftConstraintOffset: 0, rightConstraintOffset: 0, verticalSpacingToRelativeViewAbove: UIConstants.CreateInvitationVerticalSpacing .rawValue, placeholderText: "What kind of invite is this?", showViewController: nil, colorViewColor: Colors.blue.value)
        
        setupDurationTextFieldInputView()
    }
    
    func createHeaderLabel () -> UILabel {
        let label = UILabel()
        label.text = "Create Invitation"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        self.view.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).offset(20)
        }
        
        return label
    }
    
    // Whenever the user changes the date and the time the startingTimeTextField is updated with the selected information
    func startTimePickerDateChanged (sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let startDateAndTime = dateFormatter.string(from: sender.date)
        self.startingTime = sender.date
        startingTimeTextField.text = startDateAndTime
    }
    
    // This is the view that contains all the other subviews.  It acts as a wrapper so that the scroll view works correctly
    func createWrapperView (myScrollView: UIScrollView) -> UIView {
        let myWrapperView = UIView()
        myWrapperView.backgroundColor = .white
        myScrollView.addSubview(myWrapperView)
        myWrapperView.snp.makeConstraints { (make) in
            make.edges.equalTo(myScrollView)
            make.centerX.equalTo(myScrollView)
            make.width.equalTo(self.view)
            make.height.equalTo(self.view)
        }
        
        return myWrapperView
    }
    
    // Scroll view which will basically act as our main view
    func createScrollView () -> UIScrollView {
        let myScrollView = UIScrollView()
        self.view.addSubview(myScrollView)
        myScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(20)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        return myScrollView
    }
    
    func createTextField (superview: UIView, relativeViewAbove: UIView!, leftConstraintOffset: Int, rightConstraintOffset: Int, verticalSpacingToRelativeViewAbove: Int, placeholderText: String, showViewController: UIViewController!, colorViewColor: UIColor) -> UITextField {
        let textField = UITextField()
        // The superview is the wrapper which contains all our elements within the scroll view
        superview.addSubview(textField)
        textField.textAlignment = .center
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [ NSForegroundColorAttributeName : UIColor.black ])
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 0.75
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.delegate = self
    
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(wrapperView).offset(UIConstants.HorizontalSpacingToSuperview.rawValue)
            make.right.equalTo(wrapperView).offset(-UIConstants.HorizontalSpacingToSuperview.rawValue)
            
            if relativeViewAbove == nil { // If there is no other view above this one than this is the view at the very top of the screen
                make.top.equalTo(wrapperView)
            }
            else {
                make.top.equalTo(relativeViewAbove.snp.bottom).offset(verticalSpacingToRelativeViewAbove)
            }
            make.height.equalTo(45)
        }
        
        return textField
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.selectedTextField != nil && textField == self.selectedTextField {
            self.selectedTextField = nil
            return false
        }
        
        return true
    }
    
    // When the text field is selected than change the color of the border
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.selectedTextField = textField
        if textField == locationTextField {
            let autocompleteViewController = GMSAutocompleteViewController()
            autocompleteViewController.delegate = self
            self.navigationController?.present(autocompleteViewController, animated: true, completion: nil)
        }
        else if textField == inviteInterestsTextField {
            let viewInterestsViewController = ViewInterestsViewController(setting: Settings.ViewInterestsCreateInvite)
            viewInterestsViewController.delegate = self
            self.navigationController?.pushViewController(viewInterestsViewController, animated: true)
        }
        else if textField == inviteesTextField {
            let viewUsersViewController = ViewUsersViewController(setting: Settings.ViewUsersInvite)
            viewUsersViewController.showAllFriends()
            viewUsersViewController.delegate = self
            self.navigationController?.pushViewController(viewUsersViewController, animated: true)
        }
    }
}
// Handle the creation, source, and delegation for the duration text field
extension CreateInvitationViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func setupDurationTextFieldInputView () {
        var durationOptions:Array<String> = Array<String>()
        for counter in 1...20 {
            durationOptions.append(String((counter * 10)) + " mins")
        }
        
        let durationPicker = UIPickerView()
        durationPicker.dataSource = self
        durationPicker.delegate = self
        durationTextField.inputView = durationPicker
        durations = durationOptions
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return durations[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return durations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        durationTextField.text = durations[row]
    }
    
}

class ColorView : UIControl {
    var textField:UITextField!
    var showViewController:UIViewController!
}
