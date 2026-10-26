import SwiftUI
#if os(iOS)
@preconcurrency import AVFoundation

/// The phone's back camera for the viewfinder. Asks permission the first time; when it is refused or missing, `available`
/// stays false and the viewfinder shows a made-up plate instead (SS-0032).
@MainActor @Observable
final class CameraSession: NSObject {
    private(set) var available = false
    nonisolated(unsafe) let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var waiting: CheckedContinuation<Data?, Never>?

    func start() async {
        guard !available, await AVCaptureDevice.requestAccess(for: .video),
              let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.beginConfiguration()
        session.sessionPreset = .photo
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()
        available = true
        let running = session
        DispatchQueue.global(qos: .userInitiated).async { running.startRunning() }
    }

    func stop() {
        let running = session
        DispatchQueue.global(qos: .userInitiated).async { running.stopRunning() }
    }

    func capture() async -> Data? {
        guard available else { return nil }
        return await withCheckedContinuation { continuation in
            waiting = continuation
            output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
}

extension CameraSession: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let data = photo.fileDataRepresentation()
        Task { @MainActor in
            waiting?.resume(returning: data)
            waiting = nil
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ view: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
#else
@MainActor @Observable
final class CameraSession {
    private(set) var available = false

    func start() async {}
    func stop() {}
    func capture() async -> Data? { nil }
}
#endif
