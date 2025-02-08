
//  ChameleonShorthand.swift

/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014-2015 Vicc Alexander.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import UIKit

// MARK: - UIColor Methods Shorthand

/**
 Creates and returns a complementary flat color object 180 degrees away in the HSB colorspace from the specified color.
 
 - parameter color: The color whose complementary color is being requested.
 
 - returns: A flat UIColor object in the HSB colorspace.
 */
public func ComplementaryFlatColorOf(_ color: UIColor) -> UIColor {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    return UIColor(
        red: 1.0 - red,
        green: 1.0 - green,
        blue: 1.0 - blue,
        alpha: alpha
    )
}


/**
 Returns a randomly generated flat color object with an alpha value of 1.0 in either a light or dark shade.
 
 - parameter shade: Specifies whether the randomly generated flat color should be a light or dark shade.
 
 - returns: A flat UIColor object in the HSB colorspace.
 */
public func RandomFlatColorWithShade(_ shade: UIShadeStyle) -> UIColor {
    let hue: CGFloat = CGFloat.random(in: 0...1)
    let saturation: CGFloat = 0.9
    let brightness: CGFloat = shade == .light ? CGFloat.random(in: 0.7...1) : CGFloat.random(in: 0...0.3)
    
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
}

/**
 Creates and returns either a black or white color object depending on which contrasts more with a specified color.
 
 - parameter backgroundColor: The specified color of the contrast color that is being requested.
 - parameter returnFlat:      Pass **true** to return flat color objects.
 
 - returns: A UIColor object in the HSB colorspace.
 */
public func ContrastColorOf(_ backgroundColor: UIColor, returnFlat: Bool) -> UIColor {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
    
    let contrastingColor: UIColor = luminance > 0.5 ? .black : .white
    
    return returnFlat ? flattenColor(contrastingColor) : contrastingColor
}

private func flattenColor(_ color: UIColor) -> UIColor {
    return color
}

/**
 Creates and returns a gradient as a color object with an alpha value of 1.0
 
 - parameter gradientStyle: Specifies the style and direction of the gradual blend between colors.
 - parameter frame:         The frame rectangle, which describes the view’s location and size in its superview’s coordinate system.
 - parameter colors:        An array of color objects used to create a gradient.
 
 - returns: A UIColor object using colorWithPattern.
 */
public func GradientColor(_ gradientStyle: UIGradientStyle, frame: CGRect, colors: [UIColor]) -> UIColor {
    // Vytvoření CAGradientLayer pro generování gradientu
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = frame
    gradientLayer.colors = colors.map { $0.cgColor }
    
    // Pokud je potřeba změnit gradientStyle (například horizontální nebo vertikální)
    switch gradientStyle {
    case .horizontal:
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    case .vertical:
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    default:
        break
    }
    
    // Vytvoření obrázku z gradientu
    UIGraphicsBeginImageContext(gradientLayer.bounds.size)
    gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
    let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return UIColor(patternImage: gradientImage ?? UIImage())
}

public func HexColor(_ hexString: String, _ alpha: CGFloat = 1.0) -> UIColor? {
    var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if hexSanitized.hasPrefix("#") {
        hexSanitized.remove(at: hexSanitized.startIndex)
    }
    
    guard hexSanitized.count == 6 else { return nil }
    
    var rgb: UInt64 = 0
    Scanner(string: hexSanitized).scanHexInt64(&rgb)
    
    let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
    let blue = CGFloat(rgb & 0x0000FF) / 255.0
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}

/**
 Returns the average color generated by averaging the colors of a specified image.
 
 - parameter image: A specified UIImage.
 
 - returns: A flat UIColor object in the HSB colorspace.
 */
//TO-DO: now on Swift 6 is really complicated -> waiting

//public func AverageColorFromImage(_ image: UIImage) -> UIColor {
//    return UIColor(averageColorFrom: image)
//}

// MARK: - Array Methods Shorthand

// TODO Array Extension needed ;)

/**
 Generates and creates an array of 5 color objects in the HSB colorspace from the specified color.
 
 - parameter colorSchemeType: The color scheme with which to select colors using a specified color.
 - parameter color:           The specified color which the color scheme is built around.
 - parameter isFlatScheme:    Pass *true* to return flat color objects.
 
 - returns: An array of 5 color objects in the HSB colorspace.
 */
public func ColorSchemeOf(_ colorSchemeType: ColorScheme, color: UIColor, isFlatScheme: Bool) -> [UIColor] {
    var colors: [UIColor] = []
    
    switch colorSchemeType {
    case .analogous:
        colors = analogousColors(for: color)
    case .complementary:
        colors = complementaryColors(for: color)
    case .triadic:
        colors = triadicColors(for: color)
    default:
        colors.append(color)
    }
    
    return isFlatScheme ? colors.map { flattenColor($0) } : colors
}

// Helper functions to generate specific color schemes
private func analogousColors(for color: UIColor) -> [UIColor] {
    // Dummy implementation for analogous colors
    return [color, color.withHueOffset(30), color.withHueOffset(-30)]
}

private func complementaryColors(for color: UIColor) -> [UIColor] {
    return [color, color.withHueOffset(180)]
}

private func triadicColors(for color: UIColor) -> [UIColor] {
    return [color, color.withHueOffset(120), color.withHueOffset(240)]
}

// Helper to adjust the hue of a color
private extension UIColor {
    func withHueOffset(_ offset: CGFloat) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            hue = fmod(hue + offset / 360.0, 1.0)
            if hue < 0 { hue += 1.0 }
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        return self
    }
}

/**
 Generates and creates an array of 5 color objects in the HSB colorspace that appear most often in a specified image.
 
 - parameter image:          The specified image which the color scheme is built around.
 - parameter withFlatScheme: Pass **true** to return flat color objects.
 
 - returns: An array of 5 color objects in the HSB colorspace.
 */
//TO-DO: now on Swift 6 is really complicated -> waiting
//public func ColorsFromImage(_ image: UIImage, withFlatScheme: Bool) -> [UIColor] {
//    // TODO: Remove forced casting
//    return NSArray(ofColorsFrom: image, withFlatScheme: withFlatScheme) as! [UIColor]
//}


// MARK: - Special Colors Shorthand

/**
 Returns a randomly generated flat color object whose alpha value is 1.0.
 
 - returns: A flat UIColor object in the HSB colorspace.
 */
public func RandomFlatColor() -> UIColor {
    let hue: CGFloat = CGFloat.random(in: 0...1)  // Náhodná hodnota pro odstín
    let saturation: CGFloat = 0.9                 // Vysoká saturace pro "flat" efekt
    let brightness: CGFloat = 0.85                // Vysoký jas pro plochý vzhled
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
}
public func ClearColor() -> UIColor {
    return UIColor.clear
}


// MARK: - Light Shades Shorthand

public func FlatBlack() -> UIColor {
    return UIColor(white: 0.15, alpha: 1.0)
}

public func FlatBlue() -> UIColor {
    return UIColor(red: 0.2, green: 0.6, blue: 0.86, alpha: 1.0)
}

public func FlatBrown() -> UIColor {
    return UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
}

public func FlatCoffee() -> UIColor {
    return UIColor(red: 0.64, green: 0.44, blue: 0.37, alpha: 1.0)
}

public func FlatForestGreen() -> UIColor {
    return UIColor(red: 0.13, green: 0.55, blue: 0.13, alpha: 1.0)
}

public func FlatGray() -> UIColor {
    return UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
}

public func FlatGreen() -> UIColor {
    return UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
}

public func FlatLime() -> UIColor {
    return UIColor(red: 0.75, green: 1.0, blue: 0.0, alpha: 1.0)
}

public func FlatMagenta() -> UIColor {
    return UIColor(red: 1.0, green: 0.0, blue: 0.6, alpha: 1.0)
}

public func FlatMaroon() -> UIColor {
    return UIColor(red: 0.69, green: 0.19, blue: 0.38, alpha: 1.0)
}

public func FlatMint() -> UIColor {
    return UIColor(red: 0.62, green: 1.0, blue: 0.86, alpha: 1.0)
}

public func FlatNavyBlue() -> UIColor {
    return UIColor(red: 0.0, green: 0.19, blue: 0.38, alpha: 1.0)
}

public func FlatOrange() -> UIColor {
    return UIColor(red: 1.0, green: 0.58, blue: 0.21, alpha: 1.0)
}

public func FlatPink() -> UIColor {
    return UIColor(red: 1.0, green: 0.61, blue: 0.73, alpha: 1.0)
}

public func FlatPlum() -> UIColor {
    return UIColor(red: 0.56, green: 0.27, blue: 0.52, alpha: 1.0)
}

public func FlatPowderBlue() -> UIColor {
    return UIColor(red: 0.69, green: 0.88, blue: 0.9, alpha: 1.0)
}

public func FlatPurple() -> UIColor {
    return UIColor(red: 0.62, green: 0.35, blue: 0.71, alpha: 1.0)
}

public func FlatRed() -> UIColor {
    return UIColor(red: 1.0, green: 0.22, blue: 0.27, alpha: 1.0)
}

public func FlatSand() -> UIColor {
    return UIColor(red: 0.94, green: 0.87, blue: 0.71, alpha: 1.0)
}

public func FlatSkyBlue() -> UIColor {
    return UIColor(red: 0.4, green: 0.73, blue: 1.0, alpha: 1.0)
}

public func FlatTeal() -> UIColor {
    return UIColor(red: 0.0, green: 0.65, blue: 0.65, alpha: 1.0)
}

public func FlatWatermelon() -> UIColor {
    return UIColor(red: 0.99, green: 0.34, blue: 0.45, alpha: 1.0)
}

public func FlatWhite() -> UIColor {
    return UIColor(white: 0.92, alpha: 1.0)
}

public func FlatYellow() -> UIColor {
    return UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
}

// MARK: - Chameleon - Dark Shades Shorthand
public func FlatBlackDark() -> UIColor {
    return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
}

public func FlatBlueDark() -> UIColor {
    return UIColor(red: 0.0, green: 0.4, blue: 0.7, alpha: 1.0)
}

public func FlatBrownDark() -> UIColor {
    return UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0)
}

public func FlatCoffeeDark() -> UIColor {
    return UIColor(red: 0.45, green: 0.3, blue: 0.25, alpha: 1.0)
}

public func FlatForestGreenDark() -> UIColor {
    return UIColor(red: 0.1, green: 0.3, blue: 0.1, alpha: 1.0)
}

public func FlatGrayDark() -> UIColor {
    return UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
}

public func FlatGreenDark() -> UIColor {
    return UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
}

public func FlatLimeDark() -> UIColor {
    return UIColor(red: 0.5, green: 0.75, blue: 0.0, alpha: 1.0)
}

public func FlatMagentaDark() -> UIColor {
    return UIColor(red: 0.8, green: 0.0, blue: 0.5, alpha: 1.0)
}

public func FlatMaroonDark() -> UIColor {
    return UIColor(red: 0.5, green: 0.1, blue: 0.2, alpha: 1.0)
}

public func FlatMintDark() -> UIColor {
    return UIColor(red: 0.4, green: 0.85, blue: 0.65, alpha: 1.0)
}

public func FlatNavyBlueDark() -> UIColor {
    return UIColor(red: 0.0, green: 0.1, blue: 0.3, alpha: 1.0)
}

public func FlatOrangeDark() -> UIColor {
    return UIColor(red: 0.9, green: 0.4, blue: 0.0, alpha: 1.0)
}

public func FlatPinkDark() -> UIColor {
    return UIColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 1.0)
}

public func FlatPlumDark() -> UIColor {
    return UIColor(red: 0.4, green: 0.2, blue: 0.4, alpha: 1.0)
}

public func FlatPowderBlueDark() -> UIColor {
    return UIColor(red: 0.5, green: 0.7, blue: 0.85, alpha: 1.0)
}

public func FlatPurpleDark() -> UIColor {
    return UIColor(red: 0.35, green: 0.2, blue: 0.6, alpha: 1.0)
}

public func FlatRedDark() -> UIColor {
    return UIColor(red: 0.7, green: 0.0, blue: 0.1, alpha: 1.0)
}

public func FlatSandDark() -> UIColor {
    return UIColor(red: 0.7, green: 0.6, blue: 0.4, alpha: 1.0)
}

public func FlatSkyBlueDark() -> UIColor {
    return UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
}

public func FlatTealDark() -> UIColor {
    return UIColor(red: 0.0, green: 0.4, blue: 0.4, alpha: 1.0)
}

public func FlatWatermelonDark() -> UIColor {
    return UIColor(red: 0.8, green: 0.2, blue: 0.3, alpha: 1.0)
}

public func FlatWhiteDark() -> UIColor {
    return UIColor(white: 0.85, alpha: 1.0)
}

public func FlatYellowDark() -> UIColor {
    return UIColor(red: 0.9, green: 0.75, blue: 0.0, alpha: 1.0)
}

// MARK: - Supporting enumerations
public enum UIShadeStyle {
    case light
    case dark
}

public enum ColorScheme {
    case analogous
    case complementary
    case triadic
}

public enum UIGradientStyle {
    case horizontal
    case vertical
}
