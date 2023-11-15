import SwiftUI

@main
struct iMemberApp: App {
    var body: some Scene {
        
        /// https://developer.apple.com/documentation/swiftui/menubarextra
        MenuBarExtra("iMember", systemImage: "brain") {
            VStack {
                Button("Record Main Display") {
                    recorder.startRecordingFirstDisplay()
                }.disabled(recorder.isRecording)
                
                Button("Stop Recording") {
                    recorder.stopRecording()
                }.disabled(!recorder.isRecording)
                
                Divider()
                
                Button("Quit iMember") {
                    NSApplication.shared.terminate(nil)
                }.disabled(recorder.isRecording)
            }
        }
    }
    
    @StateObject var recorder = ScreenRecorder()
}
