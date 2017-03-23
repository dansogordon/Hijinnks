//
//  Constants.swift
//  Hijinnks
//
//  Created by adeiji on 2/23/17.
//  Copyright © 2017 adeiji. All rights reserved.
//

import Foundation
import UIKit

let kInterestsPlistFile = "interests"

enum StringConstants : String {
    case Hijinnks = "Hijinnks"
    case ViewInvitations = "View Invitations"
    case CreateInvitation = "Create Invite"
    case Profile = "Profile"
    case Connect = "Connect"
    case Friends = "Friends"
}

enum fileType : String {
    case plist = "plist"
}

enum InviteesPresets : String {
    case Everyone = "Everyone"
    case Anyone = "Anyone"
}

enum ParseCustomObjectsClassNames : String {
    case Invitation = "Invitation"
    case InterestsGroup = "Interests_Group"
}

enum ProfileOptions : String {
    case ChangeInterests = "Change Interests"
    case InviteFacebookFriends = "Invite Facebook Friends"
    case ChangePassword = "Change Password"
    case ReportProblem = "Report a Problem"
    case Logout = "Log Out"
}

enum ParseObjectColumns : String {
    case EventName = "eventName"
    case Location = "location"
    case Details = "details"
    case Message = "message"
    case StartingTime = "startingTime"
    case Duration = "duration"
    case Invitees = "invitees"
    case Interests = "interests"
    case Friends = "friends"
    case FromUser = "fromUser"
    case Address = "address"
    case RSVPCount = "rsvpCount"
    case UserSentInvitations = "sentInvitations"
    case UserBio = "bio"
    case Name = "name"
    case InterestsGroups = "interests_groups"
    case Owner = "owner"
    case ObjectId = "objectId"
    case RsvpUsers = "rsvpUsers"
    case IsPublic = "isPublic"
    case Profile_Picture = "profile_picture"
    
}

enum UIConstants : Int {
    case VerticalDistanceToLogo = 30
    case HorizontalSpacingToSuperview = 45
    case SignUpAndSignInButtonWidth = 225
    case ProfileViewHorizontalSpacing = 15
    case ProfileViewVerticalSpacing = 5
    case ProfileViewNumberOfLabelColumns = 4
    case ProfileViewButtonHeights = 35
    case ProfileViewUserDetailCountsHeight = 100
    case CreateInvitationVerticalSpacing = 20
}

enum Colors {
    case green
    case blue
    case red
    case grey
    case invitationTextGrayColor
    case invitationHeaderViewColor
    case TableViewSeparatorColor
    case AccountTextFieldColor
    case AccountTextFieldBorderColor
    case FacebookButton
}

enum Settings {
    case ViewUsersAll
    case ViewUsersInvite
    case ViewInterestsCreateAccountOrChangeInterests
    case ViewInterestsAddFriend
    case ViewInterestsCreateInvite
}

extension Colors {
    var value: UIColor {
        get {
            switch self {
            case .green:
                return UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 0.75)
            case .blue:
                return UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 0.75)
            case .red:
                return UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 0.75)
            case .grey:
                return UIColor(red: 127/255, green: 140/255, blue: 141/255, alpha: 0.75)
            case .invitationTextGrayColor:
                return UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.75)
            case .invitationHeaderViewColor:
                return UIColor(red: 48/255, green: 62/255, blue: 146/255, alpha: 0.75)
            case .TableViewSeparatorColor:
                return UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.00)
            case .AccountTextFieldColor:
                return UIColor(red: 103/255, green: 111/255, blue: 128/255, alpha: 0.50)
            case .AccountTextFieldBorderColor:
                return UIColor(red: 28/255, green: 105/255, blue: 241/255, alpha: 0.90)
            case .FacebookButton:
                return UIColor(red: 59/255, green: 87/255, blue: 157/255, alpha: 1.0)
            }
        }
    }
}

enum HijinnksViewTypes {
    case MapButton
    case LikeEmptyButton
    case LikeFilledButton
    case HomeButton
    case ProfileButton
    case SearchButton
    case LogoView
}

enum Images : String {
    case HouseButton = "home.png"
    case CreateInvitationButton = "plus.png"
    case ProfileImageButton = "user.png"
    case ConnectButton = "connect.png"
    case Background = "Background.png"
}

enum APIKeys : String {
    case SendBirdAPIKey = "F9F8AD8A-06BE-467C-8FD4-3567B9D904A3"    
}
