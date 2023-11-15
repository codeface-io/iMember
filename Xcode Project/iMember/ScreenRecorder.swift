import ScreenCaptureKit

class ScreenRecorder: NSObject, SCStreamDelegate, SCStreamOutput {
    
    // MARK: - Respond to Errors
    
    func stream(_ stream: SCStream,
                didStopWithError error: Error) {
        print("Error: streaming stopped: " + error.localizedDescription)
        stopRecording()
    }
    
    // MARK: - Control Recording
    
    func startRecordingFirstDisplay() {
        SCShareableContent.getWithCompletionHandler {
            [weak self] sharableContent, error in
            
            guard let self else {
                print("Error: \(Self.self) died")
                return
            }
            
            if let error {
                print("Error getting sharable content: " + error.localizedDescription)
                return
            }
            
            guard let firstDisplay = sharableContent?.displays.first else {
                print("Error: found no display")
                return
            }
            
            startRecording(firstDisplay)
        }
    }
    
    private func startRecording(_ display: SCDisplay) {
        videoFileWriter = VideoFileWriter()
        videoFileWriter?.restart()
        
        startStreaming(display)
    }
    
    func stopRecording() {
        stopStreaming()
        
        videoFileWriter?.stop()
        videoFileWriter = nil
    }
    
    // MARK: - Write Streamed Samples to Video File
    
    /**
     @abstract stream:didOutputSampleBuffer:ofType:
     @param sampleBuffer the sample buffer
     @param type the sample buffer type
     @discussion protocol method for passing back screen sample buffers
     */
    func stream(_ stream: SCStream,
                didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
                of type: SCStreamOutputType) {
        guard sampleBuffer.isValid,
              sampleBuffer.containsCompleteFrames else { return }
        
        videoFileWriter?.write(sampleBuffer)
    }
    
    private var videoFileWriter: VideoFileWriter?
    
    // MARK: - Stream a Display
    
    private func startStreaming(_ display: SCDisplay) {
        stream = SCStream(filter: SCContentFilter(display: display,
                                                  excludingWindows: []),
                          configuration: .iMember(for: display),
                          delegate: self)
        
        do {
            try stream?.addStreamOutput(self,
                                        type: .screen,
                                        sampleHandlerQueue: videoQueue)
        } catch {
            print("Error adding stream output: " + error.localizedDescription)
            return
        }
        
        stream?.startCapture()
    }
    
    func stopStreaming() {
        stream?.stopCapture()
        stream = nil
    }
    
    private var stream: SCStream?
    private let videoQueue = DispatchQueue(label: "io.codeface.iMember.VideoQueue")
}

private extension CMSampleBuffer {
    var containsCompleteFrames: Bool {
        let saa = CMSampleBufferGetSampleAttachmentsArray(self,
                                                          createIfNecessary: false)
        
        let frameInfosArray = saa as? [[SCStreamFrameInfo: Any]]
        
        for frameInfos in (frameInfosArray ?? []) {
            guard let statusCode = frameInfos[.status] as? Int,
                  let status = SCFrameStatus(rawValue: statusCode),
                  status == .complete 
            else {
                return false
            }
        }
        
        return true
    }
}

private extension SCStreamConfiguration {
    static func iMember(for display: SCDisplay) -> SCStreamConfiguration {
        let config = SCStreamConfiguration()
        
        config.capturesAudio = false
   
        config.width = display.width * scaleFactor
        config.height = display.height * scaleFactor
        
        // Set the capture interval at 30 fps.
        config.minimumFrameInterval = CMTime(value: 1, timescale: 30)
        
        // Increase the depth of the frame queue to ensure high fps at the expense of increasing the memory footprint of WindowServer.
        config.queueDepth = 5
        
        return config
    }
    
    private static var scaleFactor: Int {
        Int(NSScreen.main?.backingScaleFactor ?? 2)
    }
}
