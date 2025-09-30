//
//  LocationModel.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/31/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
struct LocationModel : Codable {
    let id : Int?
    let display_name : String?
    var isSelected:Bool = false

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case display_name = "display_name"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {  id = try values.decodeIfPresent(Int.self, forKey: .id) } catch { id = nil }
        do {  display_name = try values.decodeIfPresent(String.self, forKey: .display_name) } catch { display_name = nil }
    }
}
struct PickingTypeModel : Codable {
    let id : Int?
    let display_name : String?
    var isSelected:Bool = false

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case display_name = "display_name"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {  id = try values.decodeIfPresent(Int.self, forKey: .id) } catch { id = nil }

        do {  display_name = try values.decodeIfPresent(String.self, forKey: .display_name) } catch { display_name = nil }
    }
}
struct PartnerModel : Codable {
    let id : Int?
    let display_name : String?
    let image_128: String?
    var isSelected:Bool = false

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case display_name = "display_name"
        case image_128 = "image_128"

    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {  id = try values.decodeIfPresent(Int.self, forKey: .id) } catch { id = nil }

        do {  display_name = try values.decodeIfPresent(String.self, forKey: .display_name) } catch { display_name = nil }
        do {  image_128 = try values.decodeIfPresent(String.self, forKey: .image_128) } catch { image_128 = nil }

    }
}
