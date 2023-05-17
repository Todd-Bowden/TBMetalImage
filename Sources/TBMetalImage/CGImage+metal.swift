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
    
    func metal(function: String, bundle: Bundle, outFormat: TBMetalImageOutputFormat = .rgba, outWidth: Int? = nil, outHeight: Int? = nil) throws -> CGImage {
        let commandBuffer = try TBMakeMetalCommandBuffer.makeDefault()
        let device = commandBuffer.device
        
        // Create textures
        let loader = MTKTextureLoader(device: device)
        let selfTexture = try loader.newTexture(cgImage: self)
        let w = outWidth ?? selfTexture.width
        let h = outHeight ?? selfTexture.height
        let outTexture = try device.emptyTexture(width: w, height: h, format: outFormat.mtlPixelFormat)
        
        try commandBuffer.encode(function, bundle: bundle, inTexture: selfTexture, outTexture: outTexture)
        
        // Commit and wait
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    
        // Return cgImage
        return try outTexture.cgImage()
    }
}

