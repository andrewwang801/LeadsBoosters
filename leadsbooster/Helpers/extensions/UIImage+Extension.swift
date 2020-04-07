//
//  UIImage+Resize.swift
//  MyTaxPal
//
//  Created by iOS Developer on 4/4/16.
//  Copyright © 2016 XinZhe. All rights reserved.
//

import Foundation
import UIKit
import Photos

let kJPEGRepresentationQuality: CGFloat = 1.0

extension UIImage {
    
    class func imageWithImage(image:UIImage, scaledSize:CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func imageWithImage(image:UIImage, scaledSize:CGSize, cornerRadius:CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContext(scaledSize)
        let rect = CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        image.draw(in: rect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    class func image(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    class func loadImageFromPHAsset(asset: PHAsset) -> UIImage? {
        
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail: UIImage? = UIImage()
        option.isSynchronous = true
        option.resizeMode = .none
        
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result
        })
        return thumbnail
    }
    
    class func loadSceneImageFromVideo(videoPath: String) -> UIImage? {
        
        //let videoURL = NSURL(string: videoPath)
        let asset = AVURLAsset(url: NSURL.fileURL(withPath: videoPath))
        let generator = AVAssetImageGenerator(asset: asset)
        let requestedTime = CMTimeMake(value: 1, timescale: 60)
        
        guard let imageRef = try? generator.copyCGImage(at: requestedTime, actualTime: nil) else {return nil}
        
        let thumbnail = UIImage(cgImage: imageRef)
        return thumbnail
    }

    class func rotate(srcImage: UIImage, degrees: CGFloat) -> UIImage {

        UIGraphicsBeginImageContext(srcImage.size)

        let context = UIGraphicsGetCurrentContext()
        context?.rotate(by: degrees*CGFloat(Double.pi/180))
        srcImage.draw(at: CGPoint(x: 0, y: 0))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return resultImage!
    }
}
