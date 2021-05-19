import UIKit

#if canImport(SwiftUI)
import SwiftUI
#endif

struct ProfitSendConfiguration {
    static var shared = ProfitSendConfiguration()
    
    var apiToken = ""
    var listUID = ""
}

public class MaintenanceSignupController: UIViewController {
    var message = "Sorry, we're down for maintenance, but we'll be back soon!"
    var formTitle = "Sign up to be notified!"
    var textColor = UIColor.systemBlue
    var buttonTextColor = UIColor.white
    var backgroundColor: UIColor = .white
    var buttonBackgroundColor = UIColor.systemBlue
    
    var email = ""
    
    var isLoading = false {
        didSet {
            if self.isLoading == false {
                self.submitButton.setTitle("Submit", for: .normal)
                self.submitButton.isEnabled = true
                self.activityIndicator.stopAnimating()
            } else {
                self.submitButton.setTitle("", for: .normal)
                self.submitButton.isEnabled = false
                self.activityIndicator.startAnimating()
            }
        }
    }
    
    let imageView = UIImageView()
    let emailInput = UITextField()
    let messageView = UILabel()
    let formTitleView = UILabel()
    let centeredContainer = UIView()
    let submitButton = UIButton()
    let activityIndicator = UIActivityIndicatorView()
    
    let intermediateOverlay = UIView()
    let successOverlay = UIView()
    let successImageView = UIImageView()
    let successTitleLabel = UILabel()
    let successMessageLabel = UILabel()
    
    let viewModel = MaintenanceSignupViewModel()
    
    var constraints: [NSLayoutConstraint] = []
    
    public func configure(
        apiToken: String? = nil,
        listUID: String? = nil,
        textColor: UIColor? = nil,
        buttonTextColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        buttonBackgroundColor: UIColor? = nil
    ) {
        self.textColor = textColor ?? self.textColor
        self.buttonTextColor = buttonTextColor ?? self.buttonTextColor
        self.backgroundColor = backgroundColor ?? self.backgroundColor
        self.buttonBackgroundColor = buttonBackgroundColor ?? self.buttonBackgroundColor
        
        if let apiToken = apiToken {
            ProfitSendConfiguration.shared.apiToken = apiToken
        }
        
        if let listUID = listUID {
            ProfitSendConfiguration.shared.listUID = listUID
        }
        
        view.backgroundColor = self.backgroundColor
        
        intermediateOverlay.addSubview(successOverlay)
        successOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        for subview in [ successImageView, successTitleLabel, successMessageLabel ] {
            successOverlay.addSubview(subview)
            successOverlay.translatesAutoresizingMaskIntoConstraints = false
        }
        
        for subview in [
            centeredContainer,
            imageView,
            emailInput,
            messageView,
            formTitleView,
            submitButton,
            activityIndicator
        ] {
            if !view.subviews.contains(subview) {
                view.addSubview(subview)
                subview.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        
        self.constraints.forEach { $0.isActive = false }
        
        self.constraints = [
            centeredContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centeredContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            centeredContainer.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: centeredContainer.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: centeredContainer.topAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.36),
            
            messageView.centerXAnchor.constraint(equalTo: centeredContainer.centerXAnchor),
            messageView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            messageView.widthAnchor.constraint(equalTo: centeredContainer.widthAnchor, multiplier: 0.7),
            
            formTitleView.centerXAnchor.constraint(equalTo: centeredContainer.centerXAnchor),
            formTitleView.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 30),
            formTitleView.widthAnchor.constraint(equalTo: centeredContainer.widthAnchor, multiplier: 0.8),
            
            emailInput.centerXAnchor.constraint(equalTo: centeredContainer.centerXAnchor),
            emailInput.topAnchor.constraint(equalTo: formTitleView.bottomAnchor, constant: 24),
            
            emailInput.heightAnchor.constraint(equalToConstant: 40),
            emailInput.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            submitButton.topAnchor.constraint(equalTo: emailInput.bottomAnchor, constant: 30),
            submitButton.bottomAnchor.constraint(equalTo: centeredContainer.bottomAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.widthAnchor.constraint(equalToConstant: 160),
            submitButton.centerXAnchor.constraint(equalTo: centeredContainer.centerXAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        imageView.image = UIImage(named: "hammer", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = self.textColor
        
        messageView.text = message
        applyMessageStyle(to: messageView)
        
        formTitleView.text = formTitle
        applyTitleStyle(to: formTitleView)
        
        emailInput.backgroundColor = .white
        emailInput.borderStyle = .roundedRect
        emailInput.placeholder = "Email"
        emailInput.keyboardType = .emailAddress
        emailInput.autocorrectionType = .no
        emailInput.textColor = .black.withAlphaComponent(0.8)
        emailInput.returnKeyType = .done
        
        emailInput.delegate = self
        
        submitButton.backgroundColor = buttonBackgroundColor
        submitButton.layer.cornerRadius = 8
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(self.buttonTextColor, for: .normal)
        submitButton.setTitleColor(self.buttonTextColor.withAlphaComponent(0.4), for: .highlighted)
        submitButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        
        if !submitButton.allTargets.contains(self) {
            submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        }
        
        activityIndicator.color = self.buttonTextColor
        
        intermediateOverlay.backgroundColor = .red
    }
    
    func applyTitleStyle(to label: UILabel) {
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = textColor
        label.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    func applyMessageStyle(to label: UILabel) {
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = textColor.withAlphaComponent(0.65)
        label.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    @objc
    func submit() {
        self.isLoading = true
        
        self.emailInput.resignFirstResponder()
        self.resignFirstResponder()

        viewModel.addEmailToContactList(self.email) { result in
            switch result {
            case .success:
                self.fadeOut {
                    self.imageView.image = UIImage(named: "mail_outline", in: .module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    self.messageView.text = "Success"
                    self.applyTitleStyle(to: self.messageView)
                    self.formTitleView.text = "We'll send you an email when we're back in service!"
                    self.applyMessageStyle(to: self.formTitleView)
                    self.emailInput.isHidden = true
                    self.submitButton.isHidden = true
                    self.submitButton.isEnabled = false
                    
                    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                        self.fadeIn {}
                    }
                }
            case .failure(let error):
                let alertController = UIAlertController(
                    title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alertController, animated: true)
                
                self.isLoading = false
            }
        }
    }
    
    func fadeOut(completion: @escaping () -> Void) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            for view in [
                self.imageView,
                self.emailInput,
                self.messageView,
                self.formTitleView,
                self.submitButton,
                self.activityIndicator
            ] {
                view.alpha = 0
            }
        }
        
        animator.addCompletion { _ in completion() }
        
        animator.startAnimation()
    }
    
    func fadeIn(completion: @escaping () -> Void) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            for view in [
                self.imageView,
                self.emailInput,
                self.messageView,
                self.formTitleView,
                self.submitButton,
            ] {
                view.alpha = 1
            }
        }
        
        animator.addCompletion { _ in completion() }
        
        animator.startAnimation()
    }
}

extension MaintenanceSignupController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.emailInput.resignFirstResponder()
        return false
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            let start = text.index(text.startIndex, offsetBy: range.location)
            let end = text.index(text.startIndex, offsetBy: range.location + range.length)
            let newString = text.replacingCharacters(in: start ..< end, with: string)
            
            email = newString
        }
        return true
    }
}

@available(iOS 13.0, *)
public struct MaintenanceSignupView: UIViewControllerRepresentable {
    let textColor: UIColor?
    let buttonTextColor: UIColor?
    let backgroundColor: UIColor?
    let buttonBackgroundColor: UIColor?
    let apiToken: String
    let listUID: String
    
    public init(
        apiToken: String,
        listUID: String,
        textColor: UIColor? = nil,
        buttonTextColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        buttonBackgroundColor: UIColor? = nil
    ) {
        self.apiToken = apiToken
        self.listUID = listUID
        self.textColor = textColor
        self.buttonTextColor = buttonTextColor
        self.backgroundColor = backgroundColor
        self.buttonBackgroundColor = buttonBackgroundColor
    }
    
    public func makeUIViewController(context: Context) -> MaintenanceSignupController {
        MaintenanceSignupController()
    }
    
    public func updateUIViewController(_ uiViewController: MaintenanceSignupController, context: Context) {
        uiViewController.configure(
            apiToken: apiToken,
            listUID: listUID,
            textColor: textColor,
            buttonTextColor: buttonTextColor,
            backgroundColor: backgroundColor,
            buttonBackgroundColor: buttonBackgroundColor
        )
    }
}

@available(iOS 13.0, *)
public struct MaintenanceSignup_Previews: PreviewProvider {
    public static var previews: some View {
        NavigationView {
            MaintenanceSignupView(
                apiToken: "",
                listUID: "",
                textColor: .systemBlue,
                buttonTextColor: .white,
                backgroundColor: .white,
                buttonBackgroundColor: .systemBlue
            )
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
        }
    }
}
