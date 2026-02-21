import SwiftUI

// MARK: - App Typography
extension Font {
    /// App-specific font styles
    static let appLargeTitle = Font.largeTitle.weight(.bold)
    static let appTitle = Font.title.weight(.semibold)
    static let appTitle2 = Font.title2.weight(.semibold)
    static let appTitle3 = Font.title3.weight(.medium)
    static let appHeadline = Font.headline.weight(.semibold)
    static let appSubheadline = Font.subheadline.weight(.medium)
    static let appBody = Font.body
    static let appBodyBold = Font.body.weight(.semibold)
    static let appCaption = Font.caption
    static let appCaptionBold = Font.caption.weight(.semibold)
    
    /// Zebra-themed fonts
    static let zebraTitle = Font.system(size: 28, weight: .black, design: .rounded)
    static let zebraHeadline = Font.system(size: 20, weight: .bold, design: .rounded)
    static let zebraBody = Font.system(size: 16, weight: .medium, design: .rounded)
    
    /// Points and numbers
    static let pointsLarge = Font.system(size: 32, weight: .bold, design: .monospaced)
    static let pointsMedium = Font.system(size: 20, weight: .bold, design: .monospaced)
    static let pointsSmall = Font.system(size: 16, weight: .semibold, design: .monospaced)
    
    /// Timer and countdown
    static let timerLarge = Font.system(size: 48, weight: .bold, design: .monospaced)
    static let timerMedium = Font.system(size: 32, weight: .bold, design: .monospaced)
    static let timerSmall = Font.system(size: 20, weight: .semibold, design: .monospaced)
}

// MARK: - Text Styles
struct AppTextStyles {
    /// Welcome screen styles
    static let welcomeTitle = Font.system(size: 32, weight: .black, design: .rounded)
    static let welcomeSubtitle = Font.system(size: 18, weight: .medium, design: .default)
    
    /// Dashboard styles
    static let dashboardTitle = Font.system(size: 24, weight: .bold, design: .rounded)
    static let statsValue = Font.system(size: 28, weight: .bold, design: .monospaced)
    static let statsLabel = Font.system(size: 14, weight: .medium, design: .default)
    
    /// Card styles
    static let cardTitle = Font.system(size: 16, weight: .semibold, design: .default)
    static let cardSubtitle = Font.system(size: 14, weight: .medium, design: .default)
    static let cardCaption = Font.system(size: 12, weight: .regular, design: .default)
    
    /// Button styles
    static let buttonLarge = Font.system(size: 18, weight: .semibold)
    static let buttonMedium = Font.system(size: 16, weight: .semibold)
    static let buttonSmall = Font.system(size: 14, weight: .medium)}
