//
//  ApiKeys+CoreDataProperties.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 04.10.2023.
//
//

import Foundation
import CoreData

extension ApiKeys {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ApiKeys> {
        return NSFetchRequest<ApiKeys>(entityName: "ApiKeys")
    }

    @NSManaged public var apiKeyValue: String?
    @NSManaged public var id: UUID?

}

extension ApiKeys : Identifiable {
    var apiKey: String? {
        get {
            return self.apiKeyValue ?? " "
        }
        
        set {
            guard let newValue else {
                self.apiKeyValue = nil
                return
            }
            self.apiKeyValue = newValue.isEmpty ? nil : newValue
        }
    }
}
