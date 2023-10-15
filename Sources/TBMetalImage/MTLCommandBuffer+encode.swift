//
//  MTLCommandBuffer+encode.swift
//  
//
//  Created by Todd Bowden on 5/16/23.
//

import Foundation
import MetalKit

public extension MTLCommandBuffer {
    
    func encode(_ funcName: String, bundle: Bundle, inTexture: MTLTexture, outTexture: MTLTexture, buffer: MTLBuffer? = nil) throws {
        try self.encode(funcName, bundle: bundle, inTextures: [inTexture], outTexture: outTexture, buffer: buffer)
    }
    
    func encode(_ funcName: String, bundle: Bundle, inTextures: [MTLTexture], outTexture: MTLTexture, buffer: MTLBuffer? = nil) throws {
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
        
        // Add optional buffer and length to the command encoder
        if let buffer {
            commandEncoder.setBuffer(buffer, offset: 0, index: inTextures.count + 1)
            var bufferLength: UInt32 = UInt32(buffer.length)
            commandEncoder.setBytes(&bufferLength, length: 4, index: inTextures.count + 2)
        }
    
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
