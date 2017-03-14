//  Converted with Swiftify v1.0.6274 - https://objectivec2swift.com/
//
//  DECreateAccountView.swift
//  whatsgoinon
//
//  Created by adeiji on 8/8/14.
//  Copyright (c) 2014 adeiji. All rights reserved.
//
import UIKit
class DECreateAccountView: UIView, UITextFieldDelegate {
    weak var logoView:CustomHijinnksView!
    weak var txtUsername: UITextField!
    weak var txtEmail: UITextField!
    weak var txtPassword: UITextField!
    weak var txtConfirmPassword: UITextField!
    weak var lblUsernameError: UILabel!
    weak var headerLabel:UILabel!
    weak var signupButton:UIButton!

    func setUp() {
        for view: UIView in self.subviews {
            if (view is UITextField) {
                let textField: UITextField? = (view as? UITextField)
                textField?.delegate = self
            }
        }
    }

    func setUpValidators() {

    }

    let ERROR_CODE_EMAIL_TAKEN = 203

    required init () {
        super.init(frame: .zero)
    }
    
    func setupUI () {
        self.backgroundColor = .white
        self.snp.makeConstraints { (make) in
            make.edges.equalTo(self.superview!)
        }
        
        logoView = setLogoView()
        lblUsernameError = setUsernameErrorLabel()
        txtUsername = setTextField(viewAbove: lblUsernameError, placeholderText: "Enter username", isSecureTextEntry: false)
        txtEmail = setTextField(viewAbove: txtUsername, placeholderText: "Enter your email", isSecureTextEntry: false)
        txtPassword = setTextField(viewAbove: txtEmail, placeholderText: "Enter your password", isSecureTextEntry: true)
        txtConfirmPassword = setTextField(viewAbove: txtPassword, placeholderText: "Confirm your password", isSecureTextEntry: true)
        signupButton = setSignupButton()
    }
    
    func setLogoView () -> CustomHijinnksView {
        let view = CustomHijinnksView(customViewType: .LogoView)
        view.backgroundColor = .white
        self.addSubview(view)
        
        view.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(90)
            make.height.equalTo(40)
            make.width.equalTo(160)
            make.centerX.equalTo(self)
        }
        
        return view
    }
    
    func setUsernameErrorLabel () -> UILabel {
        let label = UILabel()
        label.textColor = .red
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(UIConstants.HorizontalSpacingToSuperview.rawValue)
            make.right.equalTo(self).offset(UIConstants.HorizontalSpacingToSuperview.rawValue)
            make.top.equalTo(logoView.snp.bottom).offset(UIConstants.VerticalDistanceToLogo.rawValue)
        }
        
        return label
    }
    
    func setTextField (viewAbove: UIView!, placeholderText: String, isSecureTextEntry: Bool) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholderText
        textField.isSecureTextEntry = isSecureTextEntry
        textField.layer.borderWidth = 1
        textField.layer.borderColor = Colors.invitationTextGrayColor.value.cgColor
        self.addSubview(textField)
        
        textField.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            if viewAbove != nil {
                make.top.equalTo(viewAbove.snp.bottom).offset(10)
            }
            else {
                make.top.equalTo(logoView.snp.bottom).offset(UIConstants.VerticalDistanceToLogo.rawValue)
            }
            
            make.height.equalTo(50)
            make.left.equalTo(self).offset(UIConstants.HorizontalSpacingToSuperview.rawValue)
            make.right.equalTo(self).offset(-UIConstants.HorizontalSpacingToSuperview.rawValue)
        }
        
        return textField
    }
    
    func setSignupButton () -> UIButton {
        
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(.gray, for: .normal)
        self.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(txtConfirmPassword.snp.bottom).offset(25)
            make.width.equalTo(UIConstants.SignUpAndSignInButtonWidth.rawValue)
        }
        
        return button
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for view: UIView in self.subviews {
            if (view is UITextField) {
                view.resignFirstResponder()
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}