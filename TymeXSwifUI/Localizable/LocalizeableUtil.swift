//
//  LocalizeableUtil.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 21/6/25.
//

import Foundation
import Combine

enum LanguageSupport: String, CaseIterable, Hashable {
    case English = "English"
    case Vietnamese = "Vietnamese"
    
    var code: String {
        switch self {
        case .English:
            return "en"
        case .Vietnamese:
            return "vi"
        }
    }
}

class LanguageManager {
    static let shared = LanguageManager()
    
    let languagePublisher = CurrentValueSubject<String, Never>(UserDefaultsHelper.language ?? LanguageSupport.Vietnamese.rawValue )
    
    var currentLanguage: String {
        get { languagePublisher.value }
        set {
            UserDefaultsHelper.language = newValue
            languagePublisher.send(newValue)
        }
    }
    
    var currentLanguageCode: String { // Code
        get {
            switch currentLanguage {
            case LanguageSupport.Vietnamese.rawValue:
                return LanguageSupport.Vietnamese.code
            default:
                return LanguageSupport.English.code
            }
        }
    }
}

struct LocalizableKey {
    static var login: String { return "login".localized() }
    static var books: String { return "books".localized() }
    static var skills: String { return "skills".localized() }
    static var email: String { return "books".localized() }
    static var password: String { return "skills".localized() }
}

extension String {
    func localized() -> String {
        let currentLanguageCode = LanguageManager.shared.currentLanguageCode
        if let path = Bundle.main.path(forResource: currentLanguageCode, ofType: "lproj") {
            let bundle = Bundle(path: path)
            return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
        }
        return ""
    }
}
