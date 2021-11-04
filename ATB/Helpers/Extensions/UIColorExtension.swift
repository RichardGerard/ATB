//
//  UIColorExtension.swift
//  ATB
//
//  Created by mobdev on 2019/5/13.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import SwiftHEXColors

extension UIColor
{
    enum LocalColorName: String {
        case colorPrimary        =       "#A6BFDE"
        
        // blues
        case colorBlue1     =       "#6A87AB"
        case colorBlue2     =       "#D5E7FF"
        case colorBlue3     =       "#C5CFDD"   // gradient end color
        case colorBlue4     =       "#B1D4FF"   // close button
        case colorBlue5     =       "#728398"
        case colorBlue6     =       "#B6CEEC"
        case colorBlue7     =       "#6F86A5"
        case colorBlue8     =       "#8BA0BA"
        case colorBlue9     =       "#D1E6FF"
        case colorBlue10    =       "#97ACC7"
        case colorBlue11    =       "#CCD5E2"
        case colorBlue12    =       "#375780"
        case colorBlue13    =       "#C8D7EB"  // highlighed skeleton color
        case colorBlue14    =       "#BDCEE4"
        case colorBlue15    =       "#AAC1DE"
        case colorBlue16    =       "#929CA9"
        case colorBlue17    =       "#A5B7CF"
        
        // Grays
        case colorGray1     =       "#3B3B3B"   // input bar placeholder color
        case colorGray2     =       "#737373"   // camera button tint color
        case colorGray3     =       "#DEDEDE"   // inputbar border color
        case colorGray4     =       "#E2E2E2"   // comment bubble background color
        case colorGray5     =       "#575757"   // comment text color
        case colorGray6     =       "#A8A8A8"   // time and likes in comment view
        case colorGray7     =       "#EFEFEF"
        case colorGray8     =       "#6E6E6E"
        case colorGray9     =       "#495462"
        case colorGray10    =       "#C9C9C9"
        case colorGray11    =       "#B3B3B3"
        case colorGray12    =       "#A6A6A6"
        case colorGray13    =       "#3D3D3D"
        case colorGray14    =       "#F4F4F4"       // normal gray background - F4F4F4
        case colorGray15    =       "#8A8A8A"
        case colorGray16    =       "#AFAFAF"
        case colorGray17    =       "#E6E6E6"
        case colorGray18    =       "#A2A2A2"
        case colorGray19    =       "#6B6B6B"
        case colorGray20    =       "#D8D8D8"
        case colorGray21    =       "#818181"
        case colorGray22    =       "#9D9D9D"
        case colorGray23    =       "#F8F8F8"
        
        // Red
        case colorRed1      =       "#E3677F"
        case colorRed2      =       "#D46F80"
        
        // Green
        case colorGreen     =       "#8DD361" 
        
    }
    
    convenience init(_ name: LocalColorName) {
        self.init(hexString: name.rawValue)!
    }
    
    static let colorPrimary     = UIColor(.colorPrimary)
    
    static let colorBlue1       = UIColor(.colorBlue1)
    static let colorBlue2       = UIColor(.colorBlue2)
    static let colorBlue3       = UIColor(.colorBlue3)
    static let colorBlue4       = UIColor(.colorBlue4)
    static let colorBlue5       = UIColor(.colorBlue5)
    static let colorBlue6       = UIColor(.colorBlue6)
    static let colorBlue7       = UIColor(.colorBlue7)
    static let colorBlue8       = UIColor(.colorBlue8)
    static let colorBlue9       = UIColor(.colorBlue9)
    static let colorBlue10      = UIColor(.colorBlue10)
    static let colorBlue11      = UIColor(.colorBlue11)
    static let colorBlue12      = UIColor(.colorBlue12)
    static let colorBlue13      = UIColor(.colorBlue13)
    static let colorBlue14      =   UIColor(.colorBlue14)
    static let colorBlue15      =   UIColor(.colorBlue15)
    static let colorBlue16      =   UIColor(.colorBlue16)
    static let colorBlue17      =   UIColor(.colorBlue17)
    
    static let colorGray1       = UIColor(.colorGray1)
    static let colorGray2       = UIColor(.colorGray2)
    static let colorGray3       = UIColor(.colorGray3)
    static let colorGray4       = UIColor(.colorGray4)
    static let colorGray5       = UIColor(.colorGray5)
    static let colorGray6       = UIColor(.colorGray6)
    static let colorGray7       = UIColor(.colorGray7)
    static let colorGray8       = UIColor(.colorGray8)
    static let colorGray9       = UIColor(.colorGray9)
    static let colorGray10      = UIColor(.colorGray10)
    static let colorGray11      = UIColor(.colorGray11)
    static let colorGray12      = UIColor(.colorGray12)
    static let colorGray13      = UIColor(.colorGray13)
    static let colorGray14      = UIColor(.colorGray14)
    static let colorGray15      = UIColor(.colorGray15)
    static let colorGray16      = UIColor(.colorGray16)
    static let colorGray17      = UIColor(.colorGray17)
    static let colorGray18      = UIColor(.colorGray18)
    static let colorGray19      = UIColor(.colorGray19)
    static let colorGray20      = UIColor(.colorGray20)
    static let colorGray21      = UIColor(.colorGray21)
    static let colorGray22      =   UIColor(.colorGray22)
    static let colorGray23      =   UIColor(.colorGray23)
    
    static let colorRed1        = UIColor(.colorRed1)
    static let colorRed2        =   UIColor(.colorRed2)
    
    static let colorGreen       =   UIColor(.colorGreen)
    
    static var backgroundColor: UIColor {
        if #available(iOS 13, *) {
            return systemBackground
        } else {
            return white
        }
    }
    
    public class var viewMoreTextColor: UIColor
    {
        return UIColor(displayP3Red: 110/255, green: 153/255, blue: 220/255, alpha: 1.0)
    }
    
    public class var viewLessTextColor: UIColor
    {
        return UIColor(displayP3Red: 190/255, green: 50/255, blue: 10/255, alpha: 1.0)
    }
    
    public class var textFieldPlaceHolderColor: UIColor
    {
        return UIColor(displayP3Red: 120/255, green: 125/255, blue: 130/255, alpha: 1.0)
    }
    
    public class var primaryButtonColor: UIColor
    {
        return UIColor(displayP3Red: 165/255, green: 190/255, blue: 220/255, alpha: 1.0)
    }
    
    public class var placeholderColor: UIColor {
        return UIColor(displayP3Red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0)
    }
    
    public class var textViewPlaceHolderColor: UIColor
    {
        return UIColor(displayP3Red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    }
    
    public class var atbFeedBackgroundColor: UIColor
    {
        return UIColor(displayP3Red: 193/255, green: 193/255, blue: 193/255, alpha: 1.0)
    }
    
    public class var blurColor: UIColor
    {
        return UIColor(red: 0.65, green: 0.71, blue: 0.79, alpha: 1.00)
    }
    
    public class var mediumGray : UIColor
    {
        return UIColor(displayP3Red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
    }
    
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
