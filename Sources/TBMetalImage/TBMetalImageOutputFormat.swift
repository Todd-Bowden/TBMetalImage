//
//  TBMetalImageOutputFormat.swift
//  
//
//  Created by Todd Bowden on 5/16/23.
//

import Foundation
import MetalKit

public enum TBMetalImageOutputFormat {
    case rgba
    case gray
    
    var mtlPixelFormat: MTLPixelFormat {
        switch self {
        case .rgba:
            return MTLPixelFormat.rgba8Unorm
        case .gray:
            return MTLPixelFormat.r8Unorm
        }
    }
}
