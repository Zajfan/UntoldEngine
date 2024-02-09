//
//  FuncUtils.swift
//  UntoldEngine
//
//  Created by Harold Serrano on 11/24/23.
//

import Foundation
import CoreGraphics
import MetalKit

enum LoadHDRError: Error {
    case urlCreationFailed(String)
    case imageSourceCreationFailed
    case cgImageCreationFailed
    case colorSpaceCreationFailed
    case bitmapContextCreationFailed
    case textureCreationFailed
}


func loadTexture(device: MTLDevice,
                       textureName: String) throws -> MTLTexture {
    /// Load texture data with optimal parameters for sampling

    let textureLoader = MTKTextureLoader(device: device)

    let textureLoaderOptions = [
        MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
        MTKTextureLoader.Option.textureStorageMode: NSNumber(value: MTLStorageMode.`private`.rawValue)
    ]

    var url:URL?
    
    if let imageURL = Bundle.main.url(forResource: textureName, withExtension: nil) {
        // Use imageURL here
        url=imageURL
        
    }
    
    return try textureLoader.newTexture(URL: url!, options: textureLoaderOptions);
}

func loadHDR(_ textureName: String) throws -> MTLTexture? {
    
    guard let url = Bundle.main.url(forResource: textureName, withExtension: nil) else {
            throw LoadHDRError.urlCreationFailed(textureName)
    }
    
    let cfURLString = url.path as CFString
    guard let cfURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, cfURLString, CFURLPathStyle.cfurlposixPathStyle, false) else {
        throw LoadHDRError.imageSourceCreationFailed
    }
    
    guard let cgImageSource = CGImageSourceCreateWithURL(cfURL, nil) else {
        throw LoadHDRError.imageSourceCreationFailed
        
    }
    guard let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil) else {
        throw LoadHDRError.cgImageCreationFailed
    }
    
    print(cgImage.width)
    print(cgImage.height)
    print(cgImage.bitsPerComponent)
    print(cgImage.bytesPerRow)
    print(cgImage.byteOrderInfo)
    
    guard let colorSpace = CGColorSpace(name: CGColorSpace.extendedLinearSRGB) else {
        throw LoadHDRError.colorSpaceCreationFailed
    }
    let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.floatComponents.rawValue | CGImageByteOrderInfo.order16Little.rawValue
    guard let bitmapContext = CGContext(data: nil,
                                        width: cgImage.width,
                                        height: cgImage.height,
                                        bitsPerComponent: cgImage.bitsPerComponent,
                                        bytesPerRow: cgImage.width * 2 * 4,
                                        space: colorSpace,
                                        bitmapInfo: bitmapInfo) else {
        throw LoadHDRError.bitmapContextCreationFailed
    }
    
    bitmapContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
    
    let descriptor = MTLTextureDescriptor()
    descriptor.pixelFormat = .rgba16Float
    descriptor.width = cgImage.width
    descriptor.height = cgImage.height
    descriptor.depth = 1
    descriptor.usage = .shaderRead
    descriptor.resourceOptions = .storageModeShared
    descriptor.sampleCount = 1
    descriptor.textureType = .type2D
    descriptor.mipmapLevelCount = Int(1 + floorf(log2f(fmaxf(renderInfo.viewPort.x, renderInfo.viewPort.y))))
    
    guard let texture = renderInfo.device.makeTexture(descriptor: descriptor) else {
        throw LoadHDRError.textureCreationFailed
    }
    
    texture.replace(region: MTLRegionMake2D(0, 0, cgImage.width, cgImage.height), mipmapLevel: 0, withBytes: bitmapContext.data!, bytesPerRow: cgImage.width * 2 * 4)
    
    return texture
    
}

//func readBuffer<T>(from metalBuffer: MTLBuffer, dataType: T.Type) -> [T] {
//    let count = metalBuffer.length / MemoryLayout<T>.size
//    let pointer = metalBuffer.contents().bindMemory(to: T.self, capacity: count)
//    return Array(UnsafeBufferPointer(start: pointer, count: count))
//}

func readBuffer(from metalBuffer: MTLBuffer, count: Int) -> [PointLight] {
    let pointer = metalBuffer.contents().bindMemory(to: PointLight.self, capacity: count)
    return Array(UnsafeBufferPointer(start: pointer, count: count))
}

func readArrayOfStructsFromFile<T: Codable>(filePath: URL) -> [T]? {
    
    do {
        let jsonData = try Data(contentsOf: filePath)
        let decoder = JSONDecoder()
        let dataArray = try decoder.decode([T].self, from: jsonData)
        return dataArray
    } catch {
        print("Error reading file: \(error.localizedDescription)")
        return nil
    }
}

func readArrayOfStructsFromFile<T: Codable>(filePath: String, directoryURL: URL) -> [T]? {
    let fileURL = directoryURL.appendingPathComponent(filePath)
    
    do {
        let jsonData = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let dataArray = try decoder.decode([T].self, from: jsonData)
        return dataArray
    } catch {
        print("Error reading file: \(error.localizedDescription)")
        return nil
    }
}
