//
//  MTLTexture+cgImage.swift
//  
//
//  Created by Todd Bowden on 5/12/23.
//

import Foundation
import MetalKit

public extension MTLTexture {
    
    func cgImage() throws -> CGImage {
        switch self.pixelFormat {
        case .rgba8Unorm:
            return try self.cgImageRGBA()
        case .r8Unorm:
            return try self.cgImageGray()
        default:
            throw TBMetalImageError.errorCreatingCGImage
        }
    }
    
    private func cgImageRGBA() throws -> CGImage {
        var data = Array<UInt8>(repeatElement(0, count: height*width*4))
        
        let region = MTLRegionMake2D(0, 0, width, height)
        self.getBytes(&data, bytesPerRow: width*4, from: region, mipmapLevel: 0)
        
        let bitmapInfoRawValue = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        let bitmapInfo = CGBitmapInfo(rawValue: bitmapInfoRawValue)
        
        let context = CGContext(data: &data,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width*4,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: bitmapInfo.rawValue)
        
        guard let context else {
            throw TBMetalImageError.errorCreatingCGContext
        }
        guard let cgImage = context.makeImage() else {
            throw TBMetalImageError.errorCreatingCGImage
        }
        return cgImage
    }
    
    private func cgImageGray() throws -> CGImage {
        var data = Array<UInt8>(repeatElement(0, count: height*width))
        
        let region = MTLRegionMake2D(0, 0, width, height)
        self.getBytes(&data, bytesPerRow: width, from: region, mipmapLevel: 0)
        
        let context = CGContext(data: &data,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width,
                                space: CGColorSpaceCreateDeviceGray(),
                                bitmapInfo: 0)
        
        guard let context else {
            throw TBMetalImageError.errorCreatingCGContext
        }
        guard let cgImage = context.makeImage() else {
            throw TBMetalImageError.errorCreatingCGImage
        }
        return cgImage
    }

}


