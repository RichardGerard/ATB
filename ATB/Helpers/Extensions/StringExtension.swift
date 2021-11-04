//
//  StringExtension.swift
//  ATB
//
//  Created by mobdev on 11/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

extension String {
//    func isValidEmail() -> Bool {
//        // here, `try!` will always succeed because the pattern is valid
//        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
//
//        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
//    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: self)
    }
    
    func isValidPhoneNumber() -> Bool {
//        let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}$"
//        let PHONE_REGEX = "^\\+(?:[0-9]?){6,14}[0-9]$"
//        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$" //"^((\\+)|(00))[0-9]{6,14}$"
        let PHONE_REGEX = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    
    var isNumber: Bool {
        let characters = CharacterSet.decimalDigits.inverted
        return !self.isEmpty && rangeOfCharacter(from: characters) == nil
    }
    
    var trimmedString: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func isValidDouble(maxDecimalPlaces: Int) -> Bool
    {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        let decimalSeparator = formatter.decimalSeparator ?? "."
        
        if formatter.number(from: self) != nil {
            let split = self.components(separatedBy: decimalSeparator)
            let digits = split.count == 2 ? split.last ?? "" : ""
            return digits.count <= maxDecimalPlaces
        }
        
        return false
    }
    
//    func isValidUrl () -> Bool
//    {
//        if let url = NSURL(string: self) {
//            return UIApplication.shared.canOpenURL(url as URL)
//        }
//        return false
//    }
    
    var isValidUrl: Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = predicate.evaluate(with: self)
        
        return result
    }
    
    func replacingLastOccurrenceOfString(_ searchString: String,
                                         with replacementString: String,
                                         caseInsensitive: Bool = true) -> String
    {
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        
        if let range = self.range(of: searchString,
                                  options: options,
                                  range: nil,
                                  locale: nil) {
            
            return self.replacingCharacters(in: range, with: replacementString)
        }
        return self
    }
    
    var doubleValue: Double {
        guard let doubleValue = Double(self) else {
            return 0
        }
        
        return doubleValue
    }
    
    var floatValue: Float {
        guard let floatValue = Float(self) else {
            return 0
        }
        
        return floatValue
    }
    
    var intValue: Int {
        guard let intValue = Int(self) else {
            return 0
        }
        
        return intValue
    }
    
    // String to Date
    // format: "yyyy-MM-dd" ("MM-dd-yyyy hh:mm, a" "yyyy-MM-dd h:mm")
    func toDate(_ format: String, timeZone: TimeZone = TimeZone(abbreviation: "GMT")!) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timeZone.secondsFromGMT())
        
        return dateFormatter.date(from: self)
    }
    
    func toDateString(fromFormat from: String, toFormat to: String) -> String {
        guard let date = self.toDate(from) else {
            return ""
        }
        
        return date.toString(to)
    }
    
    var capitalizingFirstLetter: String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalzedFirstLetter() {
        self = self.capitalizingFirstLetter
    }
    
    var encodedString: String {
        let data = self.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    
    var decodedString: String {
        let data = self.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII) ?? ""
    }
    
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        
        UIGraphicsBeginImageContext(size)
        (self as NSString).draw(in: CGRect(origin: .zero, size: size), withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - Float Extension
extension Float {
    
    var priceString: String {
        return String(format: "%.2f", self)
    }
}

// MARK: - Double Extension
extension Double {
    
    var priceString: String {
        return String(format: "%.2f", self)
    }
}

extension Int {
    
    var stringWithLeadingZeros: String {
        return String(format: "%02d", self)
    }
}
