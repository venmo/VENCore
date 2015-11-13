@objc class DateFormatter: NSObject {
    static let sharedFormatter = DateFormatter()

    private let formatter: NSDateFormatter

    private override init() {
        formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone(abbreviation: "GMT")
    }

    func dateFromString(string: String) -> NSDate? {
        formatter.dateFormat = dateFormatForString(string)
        return formatter.dateFromString(string)
    }

    func stringFromDate(date: NSDate) -> String {
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter.stringFromDate(date)
    }

    private func dateFormatForString(string: String) -> String {
        let scanner = NSScanner(string: string)
        scanner.charactersToBeSkipped = nil

        var format = String()

        if scanner.scanInteger(nil) {
            format += "yyyy"
        }

        if scanner.scanString("-", intoString: nil) {
            format += "-"
        }

        if scanner.scanInteger(nil) {
            format += "MM"
        }

        if scanner.scanString("-", intoString: nil) {
            format += "-"
        }

        if scanner.scanInteger(nil) {
            format += "dd"
        }

        var timeSentinel: NSString? = ""
        if scanner.scanCharactersFromSet(NSCharacterSet(charactersInString: "T "), intoString: &timeSentinel) {
            format += "'\(timeSentinel!)'"
        }

        if scanner.scanInteger(nil) {
            format += "HH"
        }

        if scanner.scanString(":", intoString: nil) {
            format += ":"
        }

        if scanner.scanInteger(nil) {
            format += "mm"
        }

        if scanner.scanString(":", intoString: nil) {
            format += ":"
        }

        if scanner.scanInteger(nil) {
            format += "ss"
        }

        if scanner.scanString(".", intoString: nil) && scanner.scanInteger(nil) {
            format += ".S"
        }

        if scanner.scanCharactersFromSet(NSCharacterSet(charactersInString: "Z+-"), intoString: nil) {
            scanner.scanUpToString(":", intoString: nil)
            if scanner.scanString(":", intoString: nil) {
                format += "XXX"
            } else {
                format += "X"
            }
        }

        return format
    }
}

extension NSDate {
    public convenience init?(ISO8601String: String) {
        guard let date = DateFormatter.sharedFormatter.dateFromString(ISO8601String) else {
            return nil
        }

        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
    
    public var ISO8601String: String {
        return DateFormatter.sharedFormatter.stringFromDate(self)
    }
}
