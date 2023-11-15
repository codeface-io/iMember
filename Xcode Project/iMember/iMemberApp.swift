import SwiftUI

@main
struct iMemberApp: App {
    var body: some Scene {
        
        /// https://developer.apple.com/documentation/swiftui/menubarextra
        MenuBarExtra("iMember", systemImage: "brain") {
            Button("Record Main Display") {
                Self.recorder.startRecordingFirstDisplay()
            }
            
            Button("Stop Recording") {
                Self.recorder.stopRecording()
            }
        }
    }
    
    static let recorder = ScreenRecorder()
}
