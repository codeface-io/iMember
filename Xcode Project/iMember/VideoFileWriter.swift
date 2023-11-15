import AVFoundation

class VideoFileWriter {

    func restart() {
        let movieFile = URL(filePath: "/Users/seb/Desktop/recording.mov")
        
        do {
            try FileManager.default.removeFileIfItExists(movieFile)
            
            assetWriter = try AVAssetWriter(outputURL: movieFile,
                                            fileType: .mov)
            
            sessionIsOngoing = false
            
            var outputSettings = AVOutputSettingsAssistant(preset: .preset3840x2160)?.videoSettings
            
            outputSettings?[AVVideoCodecKey] = AVVideoCodecType.h264
            outputSettings?[AVVideoWidthKey] = 3456
            outputSettings?[AVVideoHeightKey] = 2234
            
            assetWriterInput = AVAssetWriterInput(mediaType: .video,
                                                  outputSettings: outputSettings)
            
            assetWriterInput?.expectsMediaDataInRealTime = true
            
            guard let assetWriterInput,
                  let assetWriter,
                  assetWriter.canAdd(assetWriterInput) else {
                throw "Error: can't add video input to asset writer"
            }
            
            assetWriter.add(assetWriterInput)
            assetWriter.startWriting()
        } catch {
            print("Error setting up asset writer: \(error)")
        }
    }
    
    func stop() {
        assetWriterInput?.markAsFinished()
        
        assetWriter?.finishWriting {
            guard let status = self.assetWriter?.status else {
                print("Error: asset writer died while finishing writing")
                return
            }
            
            guard status == .completed else {
                print("Error: Writing ended in status \(status)")
                return
            }
        }
    }
    
    func write(_ sampleBuffer: CMSampleBuffer) {
        guard let assetWriter else {
            print("Error: no asset writer created")
            return
        }
        
        if !sessionIsOngoing {
            assetWriter.startSession(atSourceTime: sampleBuffer.presentationTimeStamp)
            sessionIsOngoing = true
        }
        
        if assetWriter.status == .failed {
            let description = assetWriter.error?.localizedDescription ?? "Unknown error"
            print("Error: asset writer failed: " + description)
            return
        }
        
        guard assetWriter.status == .writing else {
            print("Error: asset writer is not writing but in status \(assetWriter.status)")
            return
        }
        
        guard let assetWriterInput else {
            print("Error: no video input created")
            return
        }
        
        guard assetWriterInput.isReadyForMoreMediaData else {
            print("Error: video input is not ready for more media data")
            return
        }
        
        assetWriterInput.append(sampleBuffer)
        
        // print("✅ did record \(sampleBuffer.numSamples) samples")
    }
    
    private var sessionIsOngoing = false
    
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
}

extension String: Error {}
