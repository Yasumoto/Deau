import Dispatch
import Foundation

public enum Visibility {
    case publicEvent
    case privateEvent
}

public enum Status {
    case cancelled
    case upcoming
    case past
    case draft
    case proposed
    case suggested
}

public enum JoinMode {
    case open
}

public struct Venue {
    public let address: String
    public let city: String
    //public let country: String
    //public let localizedCountryName: String
    public let id: Int
    //public let lat: Float
    //public let lon: Float
    public let name: String
}

public struct Group {
    public let created: Date
    public let name: String
    public let id: Int
    public let joinMode: JoinMode
    public let lat: Float
    public let lon: Float
    public let urlname: String
    public let who: String
    public let localizedLocation: String
    public let region: Locale
}

public struct Event {
    public let id: String
    public let name: String
    //public let description: String
    //public let visibility: Visibility
    public let venue: Venue
    //public let updated: Date
    //public let created: Date
    //public let link: URL
    public let yesRsvpCount: Int
    public let waitlistCount: Int
    //public let utcOffset: TimeZone
    public let time: Date
    //public let status: Status
    //public let group: Group
}

public struct Deau {
    let baseDomain = "https://api.meetup.com"
    let sema = DispatchSemaphore(value: 0)
    let meetupName: String
    let apiKey: String

    public init(meetupName: String, apiKey: String) {
        self.meetupName = meetupName
        self.apiKey = apiKey
    }

    func submitRequest(path: String,
                       parameters: [String:String],
                       method: String = "GET",
                       debug: Bool = false) -> Any {
        var response: Any = ""
        var requestString = "\(baseDomain)/\(self.meetupName)/\(path)?key=\(apiKey)"

        for (key, value) in parameters {
            requestString.append("&\(key)=\(value)")
        }

        if let requestURL = URL(string: requestString) {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            var request = URLRequest(url: requestURL)

            request.httpMethod = method
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let task = session.dataTask(with: request) {
                if let responded = $1 as? HTTPURLResponse {
                    if responded.statusCode != 200 {
                        print("Non-200 response was: \(responded)")
                    }
                    if let responseError = $2 {
                        if debug {
                            print("Error: \(responseError)")
                            print("Code: \(responseError._code)")
                        }
                    }
                    if let data = $0 {
                        do {
                            response = try JSONSerialization.jsonObject(
                                with: data, options: .allowFragments)
                            if debug {
                                print(response)
                            }
                        } catch {
                            print("Warning, did not receive valid JSON!\n\(error)")
                        }
                    }
                }
                self.sema.signal()
            }
            task.resume()
            sema.wait()
        }
        return response
    }

    /**
     List venues associated with a Meetup

    [API Documentation](https://www.meetup.com/meetup_api/docs/:urlname/venues/#list)
    */
    public func listVenues() -> [Venue] {
        var venues = [Venue]()
        if let response = submitRequest(path: "venues",
                                        parameters: [:]) as? [[String: Any]] {
            for venueResponse in response {
                if let venue = parse(venueResponse: venueResponse) {
                    venues.append(venue)
                }
            }
        }
        return venues
    }

    /**
     List events scheduled for a Meetup

     https://www.meetup.com/meetup_api/docs/:urlname/events/#list
     */
    public func listEvents() -> [Event] {
        var events = [Event]()

        if let response = submitRequest(path: "events",
                                        parameters: [:]) as? [[String: Any]] {
            for eventResponse in response {
                if let event = parse(eventResponse: eventResponse) {
                    events.append(event)
                }
            }
        }

        return events
    }

    /**
     Create a new event

     [API Documentation](https://www.meetup.com/meetup_api/docs/:urlname/events/#create)

     - parameters
        - name: Title of the event
        - description: Details for the meetup
        - duration: defaults to 3 hours (10800000)
        - startTime: Starting time for event
     */
    public func postEvent(name: String,
                          description: String,
                          duration: Int,
                          startTime: Date,
                          venue: Int) -> Event? {
        let timestamp = Int(startTime.timeIntervalSince1970) * 1000
        print("Start: \(timestamp)")
        if let response = submitRequest(path: "events",
                                        parameters: ["name": name,
                                                     "description": description,
                                                     "duration": String(duration),
                                                     "time": String(timestamp),
                                                     "venue_id": String(venue)],
                                        method: "POST",
                                        debug: true) as? [String: Any] {
            return parse(eventResponse: response)
        }
        return nil
    }
}
