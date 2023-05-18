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
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        
        let threadgroupsPerGrid = MTLSize(width: (outTexture.width + w - 1) / w,
                                          height: (outTexture.height + h - 1) / h,
                                          depth: 1)
        
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        commandEncoder.endEncoding()
    }
    
}
