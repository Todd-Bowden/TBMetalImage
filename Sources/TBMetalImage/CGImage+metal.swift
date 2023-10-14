//
//  CGImage+metal.swift
//  
//
//  Created by Todd Bowden on 5/16/23.
//

import Foundation
import CoreGraphics
import MetalKit

/*
 
Metal function should be one input and one output texture
 
kernel void function_name(texture2d<half, access::read>  inTexture  [[ texture(0) ]],
                          texture2d<half, access::write> outTexture [[ texture(1) ]],
                          uint2                          gid        [[ thread_position_in_grid ]]) {
*/

public extension CGImage {
    
    func metal(function: String,
               bundle: Bundle,
               image: CGImage,
               data: Data? = nil,
               outFormat: TBMetalImageOutputFormat = .rgba,
               outWidth: Int? = nil,
               outHeight: Int? = nil,
               srgb: Bool = false) throws -> CGImage {
        
        try metal(function: function, bundle: bundle, images: [image], data: data, outFormat: outFormat, outWidth: outWidth, outHeight: outHeight, srgb: srgb)
    }
    
    func metal(function: String,
               bundle: Bundle,
               images: [CGImage] = [],
               data: Data? = nil,
               outFormat: TBMetalImageOutputFormat = .rgba,
               outWidth: Int? = nil,
               outHeight: Int? = nil,
               srgb: Bool = false) throws -> CGImage {
        
        let commandBuffer = try TBMakeMetalCommandBuffer.makeDefault()
        let device = commandBuffer.device
        
        // Create textures
        let loader = MTKTextureLoader(device: device)
        let selfTexture = try loader.newTexture(cgImage: self, options: [.SRGB: srgb])
        var inTextures = [selfTexture]
        for image in images {
            let texture = try loader.newTexture(cgImage: image, options: [.SRGB: srgb])
            inTextures.append(texture)
        }
        let w = outWidth ?? selfTexture.width
        let h = outHeight ?? selfTexture.height
        let outTexture = try device.emptyTexture(width: w, height: h, format: outFormat.mtlPixelFormat)
        
        var buffer: MTLBuffer? = nil
        if let data {
            try data.withUnsafeBytes { rawBufferPointer in
                if let pointer = rawBufferPointer.baseAddress {
                    buffer = device.makeBuffer(bytes: pointer, length: data.count)
                } else {
                    throw TBMetalImageError.errorCreatingDataBuffer
                }
            }
        }
        
        try commandBuffer.encode(function, bundle: bundle, inTextures: inTextures, outTexture: outTexture, buffer: buffer)
        
        // Commit and wait
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    
        // Return cgImage
        return try outTexture.cgImage()
    }
}

