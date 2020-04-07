// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: Any> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: Any> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal protocol SegueType: RawRepresentable { }

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum BHStoryboard {
  internal enum AutoReplyBot: StoryboardType {
    internal static let storyboardName = "AutoReplyBot"

    internal static let autoReplyBot = SceneType<LeadsBoosters.AutoReplyBots>(storyboard: AutoReplyBot.self, identifier: "AutoReplyBot")

    internal static let autoReplyBotDefault = SceneType<LeadsBoosters.AutoReplyBot>(storyboard: AutoReplyBot.self, identifier: "AutoReplyBotDefault")

    internal static let customReplyBot = SceneType<LeadsBoosters.CustomReplyBot>(storyboard: AutoReplyBot.self, identifier: "CustomReplyBot")

    internal static let visitCampaignSettingsVC = SceneType<LeadsBoosters.VisitCampaignSettingsVC>(storyboard: AutoReplyBot.self, identifier: "VisitCampaignSettingsVC")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum Leads: StoryboardType {
    internal static let storyboardName = "Leads"

    internal static let facebookLeadsSetupVC = SceneType<LeadsBoosters.FacebookLeadsSetupVC>(storyboard: Leads.self, identifier: "FacebookLeadsSetupVC")

    internal static let profileVC = SceneType<LeadsBoosters.ProfileVC>(storyboard: Leads.self, identifier: "ProfileVC")

    internal static let thirdPartyApiLeadsVC = SceneType<LeadsBoosters.ThirdPartyApiLeadsVC>(storyboard: Leads.self, identifier: "ThirdPartyApiLeadsVC")

    internal static let visitContactFormInfoVC = SceneType<LeadsBoosters.VisitContactFormInfoVC>(storyboard: Leads.self, identifier: "VisitContactFormInfoVC")

    internal static let wordpressLeadsVC = SceneType<LeadsBoosters.WordpressLeadsVC>(storyboard: Leads.self, identifier: "WordpressLeadsVC")
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<UIViewController>(storyboard: Main.self)

    internal static let loginVC = SceneType<LeadsBoosters.SigninVC>(storyboard: Main.self, identifier: "LoginVC")

    internal static let signupVC = SceneType<LeadsBoosters.SignupVC>(storyboard: Main.self, identifier: "SignupVC")

    internal static let tutorialVC = SceneType<LeadsBoosters.TutorialVC>(storyboard: Main.self, identifier: "TutorialVC")

    internal static let verificationCodeVC = SceneType<LeadsBoosters.VerificationCodeVC>(storyboard: Main.self, identifier: "verificationCodeVC")
  }
  internal enum Membership: StoryboardType {
    internal static let storyboardName = "Membership"

    internal static let membershipVC = SceneType<LeadsBoosters.MembershipVC>(storyboard: Membership.self, identifier: "MembershipVC")

    internal static let singleMembershipInfo = SceneType<LeadsBoosters.SingleMembershipInfo>(storyboard: Membership.self, identifier: "SingleMembershipInfo")
  }
  internal enum Menu: StoryboardType {
    internal static let storyboardName = "Menu"

    internal static let menuVC = SceneType<LeadsBoosters.MenuVC>(storyboard: Menu.self, identifier: "MenuVC")
  }
  internal enum WhatsCrm: StoryboardType {
    internal static let storyboardName = "WhatsCrm"

    internal static let agentPhoneNumberSettingsVC = SceneType<LeadsBoosters.AgentPhoneNumberSettingsVC>(storyboard: WhatsCrm.self, identifier: "AgentPhoneNumberSettingsVC")

    internal static let dashboardVC = SceneType<LeadsBoosters.DashboardVC>(storyboard: WhatsCrm.self, identifier: "DashboardVC")

    internal static let inboxVC = SceneType<LeadsBoosters.InboxVC>(storyboard: WhatsCrm.self, identifier: "InboxVC")

    internal static let inquiryVC = SceneType<LeadsBoosters.InquiryVC>(storyboard: WhatsCrm.self, identifier: "InquiryVC")

    internal static let noResponseVC = SceneType<LeadsBoosters.NoResponseVC>(storyboard: WhatsCrm.self, identifier: "NoResponseVC")
  }
}

internal enum BHStoryboardSegue {
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
