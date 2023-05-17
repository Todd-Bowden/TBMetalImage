//
//  TBMakeMetalCommandBuffer.swift
//  
//
//  Created by Todd Bowden on 5/16/23.
//

import Foundation
import MetalKit

public enum TBMakeMetalCommandBuffer {
    
    public static func makeDefault() throws -> MTLCommandBuffer {
        // The default device / GPU
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw TBMetalImageError.errorCreatingMTLDevice
        }
        
        // The metal command queue
        guard let commandQueue = device.makeCommandQueue() else {
            throw TBMetalImageError.errorCreatingMTLCommandQueue
        }
        
        // Create the command buffer
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            throw TBMetalImageError.errorCreatingMTLCommandBuffer
        }
        
        return commandBuffer
    }
    
}

