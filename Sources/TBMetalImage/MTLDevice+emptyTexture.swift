//
//  MTLDevice+emptyTexture.swift
//  
//
//  Created by Todd Bowden on 5/12/23.
//

import Foundation
import MetalKit

public extension MTLDevice {
    
    func emptyTexture(width: Int, height: Int, format: MTLPixelFormat = .rgba8Unorm) throws -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: format,
            width: width,
            height: height,
            mipmapped: false
        )
        descriptor.usage = [.shaderRead, .shaderWrite]
        guard let texture = makeTexture(descriptor: descriptor) else {
            throw TBMetalImageError.errorCreatingMTLTexture
        }
        return texture
    }
    
}
