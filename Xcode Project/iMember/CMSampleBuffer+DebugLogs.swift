import CoreMedia

extension CMSampleBuffer {
    
    func printDebugInfos() {
        guard let format = formatDescription else {
            print("Error: No format description on \(Self.self)")
            return
        }
        
        print("Sample:")
        print("  Resolution: \(format.dimensions.width)x\(format.dimensions.height)")
        print("  Media type: " + format.mediaType.description)
        print("  Media subtype (codec): " + format.mediaSubType.description)
    }
}
