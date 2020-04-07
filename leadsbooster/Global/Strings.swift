// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum L10n {
  /// Books
  internal static let books = L10n.tr("Localizable", "Books")
  /// Buying
  internal static let buying = L10n.tr("Localizable", "Buying")
  /// camera
  internal static let camera = L10n.tr("Localizable", "camera")
  /// camearEnableAccess
  internal static let cameraEnableAccess = L10n.tr("Localizable", "cameraEnableAccess")
  /// Done
  internal static let done = L10n.tr("Localizable", "Done")
  /// Facebook
  internal static let facebook = L10n.tr("Localizable", "Facebook")
  /// Google
  internal static let google = L10n.tr("Localizable", "Google")
  /// You don't have network connection now. Please check internet connection...
  internal static let internetError = L10n.tr("Localizable", "internetError")
  /// Keyword can not be blank
  internal static let keywordMissed = L10n.tr("Localizable", "keywordMissed")
  /// Loading...
  internal static let loading = L10n.tr("Localizable", "Loading")
  /// Login
  internal static let login = L10n.tr("Localizable", "Login")
  /// microphone
  internal static let microphone = L10n.tr("Localizable", "microphone")
  /// microphoneEnableAccess
  internal static let microphoneEnableAccess = L10n.tr("Localizable", "microphoneEnableAccess")
  /// No
  internal static let no = L10n.tr("Localizable", "no")
  /// photoEnableAccess
  internal static let photoEnableAccess = L10n.tr("Localizable", "photoEnableAccess")
  /// photoLibrary
  internal static let photoLibrary = L10n.tr("Localizable", "photoLibrary")
  /// Printing
  internal static let printing = L10n.tr("Localizable", "Printing")
  /// Radius
  internal static let radius = L10n.tr("Localizable", "radius")
  /// Remove
  internal static let remove = L10n.tr("Localizable", "remove")
  /// Are you sure to remove this bot
  internal static let removeConfirm = L10n.tr("Localizable", "removeConfirm")
  /// Reply can not be blank
  internal static let replyMissed = L10n.tr("Localizable", "replyMissed")
  /// Campaign Round Robin Settings
  internal static let robinSetting = L10n.tr("Localizable", "robinSetting")
  /// Selling
  internal static let selling = L10n.tr("Localizable", "Selling")
  /// Our server has some issue now, we will fix it soon
  internal static let serverError = L10n.tr("Localizable", "serverError")
  /// You have not installed Whatsapp or your device can not connect Whatsapp Service. Please confirm it and try again.
  internal static let serviceNotAvailable = L10n.tr("Localizable", "serviceNotAvailable")
  /// SignUp
  internal static let signUp = L10n.tr("Localizable", "SignUp")
  /// Tools
  internal static let tools = L10n.tr("Localizable", "Tools")
  /// Welcome
  internal static let welcome = L10n.tr("Localizable", "Welcome")
  /// Yes
  internal static let yes = L10n.tr("Localizable", "yes")
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
