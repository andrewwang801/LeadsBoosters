//
//  RxAlamofire.swift
//  RxAlamofire
//
//  Created by Junior B. (@bontojr) on 23/08/15.
//  Developed with the kind help of Krunoslav Zaher (@KrunoslavZaher)
//
//  Updated by Ivan Đikić for the latest version of Alamofire(3) and RxSwift(2) on 21/10/15
//  Updated by Krunoslav Zaher to better wrap Alamofire (3) on 1/10/15
//
//  Copyright © 2015 Bonto.ch. All rights reserved.
//

import Foundation

import Alamofire
import RxSwift

/// Default instance of unknown error
public let RxAlamofireUnknownError = NSError(domain: "RxAlamofireDomain", code: -1, userInfo: nil)

// MARK: Manager - Extension of Manager
extension SessionManager {
    /**
     Creates a NSMutableURLRequest using all necessary parameters.
     
     - parameter method: Alamofire method object
     - parameter URLString: An object adopting `URLStringConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     - returns: An instance of `NSMutableURLRequest`
     */
    static func ac_urlRequest(
        _ url: URLConvertible,
        _ method: Alamofire.HTTPMethod,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: [String: String]? = nil)
        throws -> URLRequest
    {
        var urlRequest = URLRequest(url: try url.asURL())
        urlRequest.httpMethod = method.rawValue
        
        if let headers = headers {
            for (headerField, headerValue) in headers {
                urlRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        
        if let parameters = parameters {
            urlRequest = try encoding.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
}


// Extend session manager with reactive compatible
extension SessionManager: ReactiveCompatible{}
extension Reactive where Base:Alamofire.SessionManager {
    // MARK: Generic request convenience
    /**
     Creates an observable of the returned decoded JSON.
     
     - parameter createRequest: A function used to create a `Request` using a `Manager`
     
     - returns: A generic observable of created request
     */
    public func request<T>(_ createRequest: @escaping (SessionManager) throws -> T) -> Observable<T> where T:Request{
        return Observable.create { observer -> Disposable in
            let request: T
            do {
                request = try createRequest(self.base)
            }
            catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }
            
            observer.on(.next(request))
            #if DEBUG
                debugPrint(request)
            #endif
            // needs to wait for response because sending complete immediatelly will cancel the request
            // Currently have 4 kind of request (DataRequest, DownloadRequest, UploadRequest, StreamRequest)
            if let dataRequest = request as? DataRequest {
                dataRequest.response{
                    guard let error = $0.error else { observer.on(.completed); return }
                    observer.on(.error(error))
                }
            } else if let downloadRequest = request as? DownloadRequest {
                downloadRequest.response{
                    guard let error = $0.error else { observer.on(.completed); return }
                    observer.on(.error(error))
                }
            } else if let uploadRequest = request as? UploadRequest {
                uploadRequest.response{
                    guard let error = $0.error else { observer.on(.completed); return }
                    observer.on(.error(error))
                }
            }
            
            if !self.base.startRequestsImmediately {
                request.resume()
            }
            
            return Disposables.create{
                request.cancel()
            }
        }
    }
    
    /**
     Creates an observable of the `Request`.
     
     - parameter method: Alamofire method object
     - parameter URLString: An object adopting `URLStringConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of the `Request`
     */
    public func request(_ url: URLConvertible,
                        _ method: Alamofire.HTTPMethod,
                        parameters: [String: Any]? = nil,
                        encoding: ParameterEncoding = Alamofire.URLEncoding.default,
                        headers: [String: String]? = nil
        )
        -> Observable<DataRequest>
    {
        return request { manager in
            let urlRequest = try SessionManager.ac_urlRequest(url, method, parameters: parameters, encoding: encoding, headers: headers)
            return manager.request(urlRequest)
        }
    }
    
    
    /**
     Creates an observable of the `Request`.
     
     - parameter URLRequest: An object adopting `URLRequestConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of the `Request`
     */
    public func request(_ urlRequest : URLRequestConvertible)
        -> Observable<DataRequest>
    {
        return request { manager in
            return manager.request(urlRequest)
        }
    }
    
    // MARK: data
    
    /**
     Creates an observable of the data.
     
     - parameter URLRequest: An object adopting `URLRequestConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of the tuple `(NSHTTPURLResponse, NSData)`
     */
    public func responseData(_ url: URLConvertible,
                             _ method: Alamofire.HTTPMethod,
                             parameters: [String: Any]? = nil,
                             encoding: ParameterEncoding = Alamofire.URLEncoding.default,
                             headers: [String: String]? = nil
        )
        -> Observable<(HTTPURLResponse, Data)>
    {
        return request(
            url,
            method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
            ).flatMap { $0.rx.responseData }
    }
    
    /**
     Creates an observable of the data.
     
     - parameter URLRequest: An object adopting `URLRequestConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of `NSData`
     */
    public func data(_ url: URLConvertible,
                     _ method: Alamofire.HTTPMethod,
                     parameters: [String: Any]? = nil,
                     encoding: ParameterEncoding = Alamofire.URLEncoding.default,
                     headers: [String: String]? = nil
        )
        -> Observable<Data>
    {
        return request(
            url,
            method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
            ).flatMap { $0.rx.data }
    }
    
    // MARK: string
    
    /**
     Creates an observable of the tuple `(NSHTTPURLResponse, String)`.
     
     - parameter URLRequest: An object adopting `URLRequestConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of the tuple `(NSHTTPURLResponse, String)`
     */
    public func responseString(_ url: URLConvertible,
                               _ method: Alamofire.HTTPMethod,
                               parameters: [String: Any]? = nil,
                               encoding: ParameterEncoding = Alamofire.URLEncoding.default,
                               headers: [String: String]? = nil
        )
        -> Observable<(HTTPURLResponse, String)>
    {
        return request(
            url,
            method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
            ).flatMap { $0.rx.responseString() }
    }
    
    /**
     Creates an observable of the data encoded as String.
     
     - parameter URLRequest: An object adopting `URLRequestConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of `String`
     */
    public func string(_ url: URLConvertible,
                       _ method: Alamofire.HTTPMethod,
                       parameters: [String: Any]? = nil,
                       encoding: ParameterEncoding = Alamofire.URLEncoding.default,
                       headers: [String: String]? = nil
        )
        -> Observable<String>
    {
        return request(
            url,
            method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
            ).flatMap { $0.rx.string() }
    }
    
    // MARK: JSON
    
    /**
     Creates an observable of the data decoded from JSON and processed as tuple `(NSHTTPURLResponse, AnyObject)`.
     
     - parameter URLRequest: An object adopting `URLRequestConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of the tuple `(NSHTTPURLResponse, AnyObject)`
     */
    public func responseJSON(_ url: URLConvertible,
                             _ method: Alamofire.HTTPMethod,
                             parameters: [String: Any]? = nil,
                             encoding: ParameterEncoding = Alamofire.URLEncoding.default,
                             headers: [String: String]? = nil
        )
        -> Observable<(HTTPURLResponse, Any)>
    {
        return request(
            url,
            method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
            ).flatMap { $0.rx.responseJSON() }
    }
    
    /**
     Creates an observable of the data decoded from JSON and processed as `AnyObject`.
     
     - parameter URLRequest: An object adopting `URLRequestConvertible`
     - parameter parameters: A dictionary containing all necessary options
     - parameter encoding: The kind of encoding used to process parameters
     - parameter header: A dictionary containing all the addional headers
     
     - returns: An observable of `AnyObject`
     */
    public func json(_ url: URLConvertible,
                     _ method: Alamofire.HTTPMethod,
                     parameters: [String: Any]? = nil,
                     encoding: ParameterEncoding = Alamofire.URLEncoding.default,
                     headers: [String: String]? = nil
        )
        -> Observable<Any>
    {
        return request(
            url,
            method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
            ).flatMap { $0.rx.json() }
    }
    
    // MARK: Upload
    
    /**
     Returns an observable of a request using the shared manager instance to upload a specific file to a specified URL.
     The request is started immediately.
     
     - parameter URLRequest: The request object to start the upload.
     - paramenter file: An instance of NSURL holding the information of the local file.
     - returns: The observable of `AnyObject` for the created request.
     */
    public func upload(_ file: URL, with URLRequest: URLRequestConvertible) -> Observable<UploadRequest> {
        return request { manager in
            return manager.upload(file, with: URLRequest)
        }
    }
    
    /**
     Returns an observable of a request using the shared manager instance to upload any data to a specified URL.
     The request is started immediately.
     
     - parameter URLRequest: The request object to start the upload.
     - paramenter data: An instance of NSData holdint the data to upload.
     - returns: The observable of `AnyObject` for the created request.
     */
    public func upload(_ data: Data, with URLRequest: URLRequestConvertible) -> Observable<UploadRequest> {
        return request { manager in
            return manager.upload(data, with: URLRequest)
        }
    }
    
    /**
     Returns an observable of a request using the shared manager instance to upload any stream to a specified URL.
     The request is started immediately.
     
     - parameter URLRequest: The request object to start the upload.
     - paramenter stream: The stream to upload.
     - returns: The observable of `(NSData?, RxProgress)` for the created upload request.
     */
    public func upload(_ stream: InputStream, with URLRequest: URLRequestConvertible) -> Observable<UploadRequest> {
        return request { manager in
            return manager.upload(stream, with: URLRequest)
        }
    }
    
    // MARK: Download
    
    /**
     Creates a download request using the shared manager instance for the specified URL request.
     - parameter URLRequest:  The URL request.
     - parameter destination: The closure used to determine the destination of the downloaded file.
     - returns: The observable of `(NSData?, RxProgress)` for the created download request.
     */
    public func download(_ urlRequest: URLRequestConvertible, to destination: @escaping DownloadRequest.DownloadFileDestination) -> Observable<DownloadRequest> {
        return request { manager in
            return manager.download(urlRequest, to: destination)
        }
    }
    
    /**
     Creates a request using the shared manager instance for downloading with a resume data produced from a
     previous request cancellation.
     
     - parameter resumeData:  The resume data. This is an opaque data blob produced by `NSURLSessionDownloadTask`
     when a task is cancelled. See `NSURLSession -downloadTaskWithResumeData:` for additional
     information.
     - parameter destination: The closure used to determine the destination of the downloaded file.
     - returns: The observable of `(NSData?, RxProgress)` for the created download request.
     */
    public func download(resumingWith data: Data, to destination: @escaping DownloadRequest.DownloadFileDestination) -> Observable<DownloadRequest> {
        return request { manager in
            manager.download(resumingWith: data, to: destination)
        }
    }
    
    public func download(url:URLConvertible, to destination: @escaping DownloadRequest.DownloadFileDestination) -> Observable<DownloadRequest>{
        return request { manager in
            manager.download(url)
        }
    }
}

// MARK: Request - Common Response Handlers
extension Alamofire.DataRequest: ReactiveCompatible { }
extension Reactive where Base:DataRequest{
    
    /// - returns: A validated request based on the status code
    private func validateSuccessfulResponse() -> DataRequest {
        return base.validate(statusCode: 200..<300)
    }
    
    /**
     Transform a request into an observable of the response and serialized object.
     
     - parameter queue: The dispatch queue to use.
     - parameter responseSerializer: The the serializer.
     - returns: The observable of `(NSHTTPURLResponse, T.SerializedObject)` for the created download request.
     */
    public func responseResult<T:DataResponseSerializerProtocol>(
        _ queue:DispatchQueue? = nil,
        responseSerializer:T)
        -> Observable<(HTTPURLResponse, T.SerializedObject)>
    {
        return Observable.create{ observer in
            let request = self.base.response(queue: queue, responseSerializer: responseSerializer){ dataResponse -> Void in
                switch dataResponse.result {
                case .success(let result):
                    if let httpResponse = dataResponse.response {
                        observer.on(.next((httpResponse, result)))
                        observer.on(.completed)
                    }
                    else {
                        observer.on(.error(RxAlamofireUnknownError))
                    }
                case .failure(let error):
                    observer.on(.error(error as Error))
                }
            }
            return Disposables.create{ request.cancel() }
        }
    }
    
    /**
     Transform a request into an observable of the serialized object.
     
     - parameter queue: The dispatch queue to use.
     - parameter responseSerializer: The the serializer.
     - returns: The observable of `T.SerializedObject` for the created download request.
     */
    public func result<T:DataResponseSerializerProtocol>(
        _ queue:DispatchQueue? = nil,
        responseSerializer:T)
        -> Observable<T.SerializedObject>
    {
        return Observable.create{ observer in
            let request = self.base.response(queue: queue, responseSerializer: responseSerializer){ dataResponse -> Void in
                switch dataResponse.result {
                case .success(let result):
                    if let _ = dataResponse.response {
                        observer.on(.next(result))
                        observer.on(.completed)
                    }
                    else {
                        observer.on(.error(RxAlamofireUnknownError))
                    }
                case .failure(let error):
                    observer.on(.error(error as Error))
                }
            }
            return Disposables.create{ request.cancel() }
        }
    }
    
    /**
     Returns an `Observable` of NSData for the current request.
     
     - parameter cancelOnDispose: Indicates if the request has to be canceled when the observer is disposed, **default:** `false`
     
     - returns: An instance of `Observable<NSData>`
     */
    public var responseData:Observable<(HTTPURLResponse, Data)> {
        return responseResult(responseSerializer: DataRequest.dataResponseSerializer())
    }
    
    public var data: Observable<Data> {
        return result(responseSerializer: DataRequest.dataResponseSerializer())
    }
    
    /**
     Returns an `Observable` of a String for the current request
     
     - parameter encoding: Type of the string encoding, **default:** `nil`
     
     - returns: An instance of `Observable<String>`
     */
    public func responseString(_ encoding: String.Encoding? = nil) -> Observable<(HTTPURLResponse, String)> {
        return responseResult(responseSerializer: DataRequest.stringResponseSerializer(encoding: encoding))
    }
    
    public func string(_ encoding: String.Encoding? = nil) -> Observable<String> {
        return result(responseSerializer: DataRequest.stringResponseSerializer(encoding: encoding))
    }
    
    /**
     Returns an `Observable` of a serialized JSON for the current request.
     
     - parameter options: Reading options for JSON decoding process, **default:** `.AllowFragments`
     
     - returns: An instance of `Observable<AnyObject>`
     */
    public func responseJSON(_ options: JSONSerialization.ReadingOptions = .allowFragments) -> Observable<(HTTPURLResponse, Any)> {
        return responseResult(responseSerializer: DataRequest.jsonResponseSerializer(options: options))
    }
    
    /**
     Returns an `Observable` of a serialized JSON for the current request.
     
     - parameter options: Reading options for JSON decoding process, **default:** `.AllowFragments`
     
     - returns: An instance of `Observable<AnyObject>`
     */
    public func json(_ options: JSONSerialization.ReadingOptions = .allowFragments) -> Observable<Any> {
        return result(responseSerializer: DataRequest.jsonResponseSerializer(options: options))
    }
    
    /**
     Returns and `Observable` of a serialized property list for the current request.
     
     - parameter options: Property list reading options, **default:** `NSPropertyListReadOptions()`
     
     - returns: An instance of `Observable<AnyData>`
     */
    public func responsePropertyList(_ options: PropertyListSerialization.ReadOptions = []) -> Observable<(HTTPURLResponse, Any)> {
        return responseResult(responseSerializer: DataRequest.propertyListResponseSerializer(options: options))
    }
    
    public func propertyList(_ options: PropertyListSerialization.ReadOptions = []) -> Observable<Any> {
        return result(responseSerializer: DataRequest.propertyListResponseSerializer(options: options))
    }
    
    /**
     Returns an `Observable` for the current progress status.
     
     Parameters on observed tuple:
     
     1. bytes written
     1. total bytes written
     1. total bytes expected to write.
     
     - returns: An instance of `Observable<(Int64, Int64, Int64)>`
     */
    public var progress: Observable<Progress> {
        return Observable.create { observer in
            self.base.downloadProgress{progress in
                observer.on(.next(progress))
            }
            return Disposables.create()
        }
    }
}
