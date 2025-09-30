//
//  LanguageManager.swift
//  pos
//
//  Created by Khaled on 10/25/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
 
enum lang : String {
    case notSet = ""
    case ar = "ar"
    case en = "en"
}

class LanguageManager {
    
    /*
   static var kLMDefaultLanguage:String = "en"
    static var kLMEnglish:String = "en"
    static var kLMArabic:String = "ar"
    static var kLMSelectedLanguageKey:String = "kLMSelectedLanguageKey"

    class func isSupportedLanguage(_ language: String?) -> Bool {

        if language == kLMEnglish {
            return true
        }
        if language == kLMArabic {
            return true
        }

        return false
    }

    class func localizedString(_ key: String?) -> String? {

        //  NSString *s =NSLocalizedString(key, key);
        //return  s  ;

        let selectedLanguage = LanguageManager.selectedLanguage()

        // Get the corresponding bundle path.
        let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj")

        // Get the corresponding localized string.
        let languageBundle = Bundle(path: path ?? "")
        let str = languageBundle?.localizedString(forKey: key ?? "", value: "", table: nil)
        return str

    }

    class func setSelectedLanguage(_ language: String?) {
        var language = language
        let userDefaults = UserDefaults.standard

        if language == "ar" {
            language = "es"
        }
        // Check if desired language is supported.
        if self.isSupportedLanguage(language) {
            userDefaults.set(language, forKey: kLMSelectedLanguageKey)
        } else {
            // if desired language is not supported, set selected language to nil.
            userDefaults.set(nil, forKey: kLMSelectedLanguageKey)
        }
    }

   

       class func selectedLanguage() -> String? {
           // Get selected language from user defaults.
           let userDefaults = UserDefaults.standard
           let selectedLanguage = userDefaults.string(forKey: kLMSelectedLanguageKey)

           // if the language is not defined in user defaults yet...
           if selectedLanguage == nil {
               // Get the system language.
               let userLangs = userDefaults.object(forKey: "AppleLanguages") as? [AnyHashable]
               if (userLangs?.count ?? 0) > 0 {


                   let systemLanguage = userLangs?[0] as? String

                   // if system language is supported by LanguageManager, set it as selected language.
                   if self.isSupportedLanguage(systemLanguage) {
                       self.setSelectedLanguage(systemLanguage)
                       // if not...
                   } else {
                       // Set the LanguageManager default language as selected language.
                       self.setSelectedLanguage(kLMDefaultLanguage)
                   }
               }
           }

           return userDefaults.string(forKey: kLMSelectedLanguageKey)
       }
 */
    
    class func prefix_LANG() -> String {
           return "LanguageManager"
       }

       class func currentLang() -> lang {
        let userDefaults = UserDefaults.standard
        let selectedLanguage = userDefaults.string(forKey: self.prefix_LANG())
        
        if selectedLanguage == nil {
            return .notSet
           }
 
        return lang(rawValue: selectedLanguage!)!
       }

       class func setLang(_ lng: lang) {

        let userDefaults = UserDefaults.standard
        userDefaults.set(lng.rawValue, forKey: self.prefix_LANG())
        
      
       }

       class func text(_ en: String , ar: String ) -> String  {

        if LanguageManager.currentLang() == .ar {
               return ar
           }

           return en
       }
    
    
}
