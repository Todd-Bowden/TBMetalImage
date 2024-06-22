//
//  TBMetalImageError.swift
//  
//
//  Created by Todd Bowden on 5/13/23.
//

import Foundation

public enum TBMetalImageError: Error {
    case errorCreatingCGContext
    case errorCreatingCGImage
    case errorCreatingMTLTexture
    case errorCreatingMTLDevice
    case errorCreatingMTLCommandQueue
    case errorCreatingMTLCommandBuffer
    case errorCreatingMTLFunction(String)
    case errorCreatingMTLComputeCommandEncoder
    case errorCreatingDataBuffer
    case noTexturesProvided
}
