//
//  ResponseParser.swift
//  Deau
//
//  Created by Joseph Smith on 7/18/17.
//
//

import Foundation

func parse(venueResponse: [String: Any]) -> Venue? {
    if let id = venueResponse["id"] as? Int,
        let name = venueResponse["name"] as? String,
        let address = venueResponse["address_1"] as? String,
        let city = venueResponse["city"] as? String {
            return Venue(address: address, city: city, id: id, name: name)
    }
    return nil
}

func parse(eventResponse: [String: Any]) -> Event? {
    if let name = eventResponse["name"] as? String,
        let id = eventResponse["id"] as? String,
        let rsvpCount = eventResponse["yes_rsvp_count"] as? Int,
        let waitlistCount = eventResponse["waitlist_count"] as? Int {
        if let timeResponse = eventResponse["time"] as? Int {
            let time = Date(timeIntervalSince1970: Double(timeResponse) / 1000)
            if let venueResponse = eventResponse["venue"] as? [String: Any] {
                if let venue = parse(venueResponse: venueResponse) {
                    return Event(id: id, name: name, venue: venue,
                                 yesRsvpCount: rsvpCount,
                                 waitlistCount: waitlistCount, time: time)
                }
            }
        }
    }
    return nil
}
