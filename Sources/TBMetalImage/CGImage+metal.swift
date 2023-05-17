//
//  CGImage+metal.swift
//  
//
//  Created by Todd Bowden on 5/16/23.
//

import Foundation
import CoreGraphics
import MetalKit

public extension CGImage {
    
    func metal(function: String, bundle: Bundle, outFormat: TBMetalImageOutputFormat = .rgba) throws -> CGImage {
        let commandBuffer = try TBMakeMetalCommandBuffer.makeDefault()
        let device = commandBuffer.device
        
        // Create textures
        let loader = MTKTextureLoader(device: device)
        let selfTexture = try loader.newTexture(cgImage: self)
        let w = selfTexture.width
        let h = selfTexture.height
        let outTexture = try device.emptyTexture(width: w, height: h, format: outFormat.mtlPixelFormat)
        
        try commandBuffer.encode(function, bundle: bundle, inTexture: selfTexture, outTexture: outTexture)
        
        // Commit and wait
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    
        // Return cgImage
        return try outTexture.cgImage()
    }
}

