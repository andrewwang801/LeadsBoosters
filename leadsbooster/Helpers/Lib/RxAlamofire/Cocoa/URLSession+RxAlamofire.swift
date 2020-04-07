//
//  URLSession+RxAlamofire.swift
//  RxAlamofire
//
//  Created by Junior B. on 04/11/15.
//  Copyright © 2015 Bonto.ch. All rights reserved.
//

import Foundation

import Alamofire
import RxSwift
import RxCocoa

// MARK: NSURLSession extensions
extension Reactive where Base: URLSession {
    /**
     Creates an observable returning a decoded JSON object as `AnyObject`.
     
     - parameter method: Alamofire method object
     - parameter URLString: An object adopting `URLStringConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of a decoded JSON object as `AnyObject`
     */
    public func json(_ url: URLConvertible,
                     _ method: Alamofire.HTTPMethod,
                     parameters: [String: Any]? = nil,
                     encoding: ParameterEncoding = URLEncoding.default,
                     headers: [String: String]? = nil) -> Observable<Any>{
        do {
            let request = try SessionManager.ac_urlRequest(url, method, parameters: parameters, encoding: encoding, headers: headers)
            
            return json(request: request) // This is RxSwift's functionality, not RxAlamofires!
        }
        catch let error {
            return Observable.error(error)
        }
    }
    
    /**
     Creates an observable returning a tuple of `(NSData!, NSURLResponse)`.
     
     - parameter method: Alamofire method object
     - parameter URLString: An object adopting `URLStringConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of a tuple containing data and the request
     */
    public func response(_ url: URLConvertible,
                         _ method: Alamofire.HTTPMethod,
                         parameters: [String: Any]? = nil,
                         encoding: ParameterEncoding = URLEncoding.default,
                         headers: [String: String]? = nil) -> Observable<(response: HTTPURLResponse, data: Data)> {
        do {
            let request = try SessionManager.ac_urlRequest(url, method, parameters: parameters, encoding: encoding, headers: headers)
            return response(request: request) // This is RxSwift's functionality, not RxAlamofires!
        }
        catch let error {
            return Observable.error(error)
        }
    }
    
    /**
     Creates an observable of response's content as `NSData`.
     
     - parameter method: Alamofire method object
     - parameter URLString: An object adopting `URLStringConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of a data
     */
    public func data(_ url:URLConvertible,
                     _ method: Alamofire.HTTPMethod,
                     parameters: [String: Any]? = nil,
                     encoding: ParameterEncoding = URLEncoding.default,
                     headers: [String: String]? = nil) -> Observable<Data> {
        do {
            return data(request: try SessionManager.ac_urlRequest(url, method, parameters: parameters, encoding: encoding, headers: headers)) // This is RxSwift's functionality, not RxAlamofires!
        }
        catch let error {
            return Observable.error(error)
        }
    }
}
