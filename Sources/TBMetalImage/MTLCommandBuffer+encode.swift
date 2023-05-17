//
//  MTLCommandBuffer+encode.swift
//  
//
//  Created by Todd Bowden on 5/16/23.
//

import Foundation
import MetalKit

public extension MTLCommandBuffer {
    
    func encode(_ funcName: String, bundle: Bundle, inTexture: MTLTexture, outTexture: MTLTexture) throws {
        try self.encode(funcName, bundle: bundle, inTextures: [inTexture], outTexture: outTexture)
    }
    
    func encode(_ funcName: String, bundle: Bundle, inTextures: [MTLTexture], outTexture: MTLTexture) throws {
        // Get the function
        let library = try device.makeDefaultLibrary(bundle: bundle)
        guard let function = library.makeFunction(name: funcName) else {
            throw TBMetalImageError.errorCreatingMTLFunction(funcName)
        }
        
        let computePipelineState: MTLComputePipelineState = try device.makeComputePipelineState(function: function)
        guard let commandEncoder = self.makeComputeCommandEncoder() else {
            throw TBMetalImageError.errorCreatingMTLComputeCommandEncoder
        }
        commandEncoder.setComputePipelineState(computePipelineState)
        
        // Add textures to the command encoder
        for i in 0..<inTextures.count {
            commandEncoder.setTexture(inTextures[i], index: i)
        }
        commandEncoder.setTexture(outTexture, index: inTextures.count)
    
        // Threadgroups
        let s = computePipelineState.maxTotalThreadsPerThreadgroup < 1024 ? 16 : 32
        let threadsPerGrid = MTLSize(width: s, height: s, depth: 1)
        let tw = (outTexture.width  + threadsPerGrid.width - 1) / threadsPerGrid.width
        let th = (outTexture.height + threadsPerGrid.height - 1) / threadsPerGrid.height
        let threadsPerThreadgroup = MTLSize(width: tw, height: th, depth: 1)
        commandEncoder.dispatchThreadgroups(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        commandEncoder.endEncoding()
    }
    
}
