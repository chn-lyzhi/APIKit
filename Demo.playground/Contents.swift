import XCPlayground
import UIKit
import APIKit

XCPSetExecutionShouldContinueIndefinitely()

//: Step 1: Define request protocol
protocol GitHubRequest: Request {

}

extension GitHubRequest {
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }
}

//: Step 2: Create model object
struct RateLimit {
    let count: Int
    let resetDate: NSDate

    init?(dictionary: [String: AnyObject]) {
        guard let count = dictionary["rate"]?["limit"] as? Int else {
            return nil
        }

        guard let resetDateString = dictionary["rate"]?["reset"] as? NSTimeInterval else {
            return nil
        }

        self.count = count
        self.resetDate = NSDate(timeIntervalSince1970: resetDateString)
    }
}

//: Step 3: Define request type conforming to created request protocol
// https://developer.github.com/v3/rate_limit/
struct GetRateLimitRequest: GitHubRequest {
    typealias Response = RateLimit

    var method: HTTPMethod {
        return .GET
    }

    var path: String {
        return "/rate_limit"
    }

    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
        guard let dictionary = object as? [String: AnyObject] else {
            return nil
        }

        guard let rateLimit = RateLimit(dictionary: dictionary) else {
            return nil
        }

        return rateLimit
    }
}

//: Step 4: Send request
let request = GetRateLimitRequest()

API.sendRequest(request) { result in
    switch result {
    case .Success(let rateLimit):
        debugPrint("count: \(rateLimit.count)")
        debugPrint("reset: \(rateLimit.resetDate)")

    case .Failure(let error):
        debugPrint("error: \(error)")
    }
}
