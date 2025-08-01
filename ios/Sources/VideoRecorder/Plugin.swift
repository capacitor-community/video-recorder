import Foundation
import AVFoundation
import Capacitor

extension UIColor {
    convenience init(fromHex hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

public class FrameConfig {
    var id: String
    var stackPosition: String
    var x: CGFloat
    var y: CGFloat
    var width: Any
    var height: Any
    var borderRadius: CGFloat
    var dropShadow: DropShadow
    var mirrorFrontCam: Bool

    init(_ options: [AnyHashable: Any] = [:]) {
        self.id = options["id"] as! String
        self.stackPosition = options["stackPosition"] as? String ?? "back"
        self.x = options["x"] as? CGFloat ?? 0
        self.y = options["y"] as? CGFloat ?? 0
        self.width = options["width"] ?? "fill"
        self.height = options["height"] ?? "fill"
        self.borderRadius = options["borderRadius"] as? CGFloat ?? 0
        self.dropShadow = DropShadow(options["dropShadow"] as? [AnyHashable: Any] ?? [:])
        self.mirrorFrontCam = options["mirrorFrontCam"] as? Bool ?? true
    }

    class DropShadow {
        var opacity: Float
        var radius: CGFloat
        var color: CGColor
        init(_ options: [AnyHashable: Any]) {
            self.opacity = (options["opacity"] as? NSNumber ?? 0).floatValue
            self.radius = options["radius"] as? CGFloat ?? 0
            self.color = UIColor(fromHex: options["color"] as? String ?? "#000000").cgColor
        }
    }
}

class CameraView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    func interfaceOrientationToVideoOrientation(_ orientation : UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch (orientation) {
        case UIInterfaceOrientation.portrait:
            return AVCaptureVideoOrientation.portrait;
        case UIInterfaceOrientation.portraitUpsideDown:
            return AVCaptureVideoOrientation.portraitUpsideDown;
        case UIInterfaceOrientation.landscapeLeft:
            return AVCaptureVideoOrientation.landscapeLeft;
        case UIInterfaceOrientation.landscapeRight:
            return AVCaptureVideoOrientation.landscapeRight;
        default:
            return AVCaptureVideoOrientation.portraitUpsideDown;
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews();
        if let sublayers = self.layer.sublayers {
            for layer in sublayers {
                layer.frame = self.bounds
            }
        }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            self.videoPreviewLayer?.connection?.videoOrientation = interfaceOrientationToVideoOrientation(windowScene.interfaceOrientation)
        }
    }

    func addPreviewLayer(_ previewLayer:AVCaptureVideoPreviewLayer?) {
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer!.frame = self.bounds
        self.layer.addSublayer(previewLayer!)
        self.videoPreviewLayer = previewLayer;
    }

    func removePreviewLayer() {
        self.videoPreviewLayer?.removeFromSuperlayer()
        self.videoPreviewLayer = nil
    }
}

public func checkAuthorizationStatus(_ call: CAPPluginCall) -> Bool {
    let videoStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    if (videoStatus == AVAuthorizationStatus.restricted) {
        call.reject("Camera access restricted")
        return false
    } else if videoStatus == AVAuthorizationStatus.denied {
        call.reject("Camera access denied")
        return false
    }
    let audioStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
    if (audioStatus == AVAuthorizationStatus.restricted) {
        call.reject("Microphone access restricted")
        return false
    } else if audioStatus == AVAuthorizationStatus.denied {
        call.reject("Microphone access denied")
        return false
    }
    return true
}

enum CaptureError: Error {
    case backCameraUnavailable
    case frontCameraUnavailable
    case couldNotCaptureInput(error: NSError)
}

/**
	* Create capture input
	*/
public func createCaptureDeviceInput(currentCamera: Int, frontCamera: AVCaptureDevice?, backCamera: AVCaptureDevice?) throws -> AVCaptureDeviceInput {
	var captureDevice: AVCaptureDevice
	if (currentCamera == 0) {
		if (frontCamera != nil){
			captureDevice = frontCamera!
		} else {
			throw CaptureError.frontCameraUnavailable
		}
	} else {
		if (backCamera != nil){
			captureDevice = backCamera!
		} else {
			throw CaptureError.backCameraUnavailable
		}
	}
	let captureDeviceInput: AVCaptureDeviceInput
	do {
		captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
	} catch let error as NSError {
		throw CaptureError.couldNotCaptureInput(error: error)
	}
	return captureDeviceInput
}

public func joinPath(left: String, right: String) -> String {
    let nsString: NSString = NSString.init(string:left);
    return nsString.appendingPathComponent(right);
}

public func randomFileName() -> String {
    return UUID().uuidString
}

@objc(VideoRecorder)
public class VideoRecorder: CAPPlugin, AVCaptureFileOutputRecordingDelegate, CAPBridgedPlugin {
    public let identifier = "VideoRecorder" 
    public let jsName = "VideoRecorder" 
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "initialize", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "destroy", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "flipCamera", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "toggleFlash", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "enableFlash", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "disableFlash", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isFlashAvailable", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "isFlashEnabled", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "addPreviewFrameConfig", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "editPreviewFrameConfig", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "switchToPreviewFrame", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "showPreviewFrame", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "hidePreviewFrame", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "startRecording", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stopRecording", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getDuration", returnType: CAPPluginReturnPromise),
    ] 

    var capWebView: WKWebView!

    var cameraView: CameraView!
    var captureSession: AVCaptureSession?
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    var videoOutput: AVCaptureMovieFileOutput?
    var durationTimer: Timer?

    var audioLevelTimer: Timer?
    var audioRecorder: AVAudioRecorder?

    var cameraInput: AVCaptureDeviceInput?

    var currentCamera: Int = 0
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var quality: Int = 0
    var videoBitrate: Int = 3000000
    var _isFlashEnabled: Bool = false

    var stopRecordingCall: CAPPluginCall?

    var previewFrameConfigs: [FrameConfig] = []
    var currentFrameConfig: FrameConfig = FrameConfig(["id": "default"])

    /**
     * Capacitor Plugin load
     */
    override public func load() {
        self.capWebView = self.bridge?.webView
    }

    /**
     * AVCaptureFileOutputRecordingDelegate
     */
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        self.durationTimer?.invalidate()
        self.stopRecordingCall?.resolve([
            "videoUrl": self.bridge?.portablePath(fromLocalURL: outputFileURL)?.absoluteString as Any
        ])
    }

    @objc func levelTimerCallback(_ timer: Timer?) {
        self.audioRecorder?.updateMeters()
        // let peakDecebels: Float = (self.audioRecorder?.peakPower(forChannel: 1))!
        let averagePower: Float = (self.audioRecorder?.averagePower(forChannel: 1))!
        self.notifyListeners("onVolumeInput", data: ["value":averagePower])
    }


	/**
	* Initializes the camera.
	* { camera: Int, quality: Int }
	*/
    @objc func initialize(_ call: CAPPluginCall) {
        // log to console for initializing
        print("Initializing camera")

        // flash is turned off by default when initializing camera
        self._isFlashEnabled = false;

        if (self.captureSession?.isRunning != true) {
            self.currentCamera = call.getInt("camera", 0)
            self.quality = call.getInt("quality", 0)
            self.videoBitrate = call.getInt("videoBitrate", 3000000)
            let autoShow = call.getBool("autoShow", true)

            for frameConfig in call.getArray("previewFrames", [ ["id": "default"] ]) {
                self.previewFrameConfigs.append(FrameConfig(frameConfig as! [AnyHashable : Any]))
            }
            self.currentFrameConfig = self.previewFrameConfigs.first!

            if checkAuthorizationStatus(call) {
                DispatchQueue.main.async {
                    do {
                        // Set webview to transparent and set the app window background to white
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            windowScene.windows.first?.backgroundColor = UIColor.white
                        }
                        self.capWebView?.isOpaque = false
                        self.capWebView?.backgroundColor = UIColor.clear

                        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(
                            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                            mediaType: AVMediaType.video,
                            position: AVCaptureDevice.Position.unspecified)

                        for device in deviceDescoverySession.devices {
                            if device.position == AVCaptureDevice.Position.back {
                                self.backCamera = device
                            } else if device.position == AVCaptureDevice.Position.front {
                                self.frontCamera = device
                            }
                        }

                        if (self.backCamera == nil) {
                            self.currentCamera = 1
                        }

                        // Create capture session
                        self.captureSession = AVCaptureSession()
                        // Begin configuration
                        self.captureSession?.beginConfiguration()

                        self.captureSession?.automaticallyConfiguresApplicationAudioSession = false

                        /**
                         * Video file recording capture session
                         */
                        self.captureSession?.usesApplicationAudioSession = true
                        // Add Camera Input
                        self.cameraInput = try createCaptureDeviceInput(currentCamera: self.currentCamera, frontCamera: self.frontCamera, backCamera: self.backCamera)
                        self.captureSession!.addInput(self.cameraInput!)
                        // Add Microphone Input
                        let microphone = AVCaptureDevice.default(for: .audio)
                        if let audioInput = try? AVCaptureDeviceInput(device: microphone!), (self.captureSession?.canAddInput(audioInput))! {
                            self.captureSession!.addInput(audioInput)
                        }
                        // Add Video File Output
                        self.videoOutput = AVCaptureMovieFileOutput()
                        self.videoOutput?.movieFragmentInterval = CMTime.invalid
                        self.captureSession!.addOutput(self.videoOutput!)

                        // Set Video quality
                        switch(self.quality){
                        case 1:
                            self.captureSession?.sessionPreset = AVCaptureSession.Preset.hd1280x720
                            break;
                        case 2:
                            self.captureSession?.sessionPreset = AVCaptureSession.Preset.hd1920x1080
                            break;
                        case 3:
                            self.captureSession?.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
                            break;
                        case 4:
                            self.captureSession?.sessionPreset = AVCaptureSession.Preset.high
                            break;
                        case 5:
                            self.captureSession?.sessionPreset = AVCaptureSession.Preset.low
                            break;
                        case 6:
                            self.captureSession?.sessionPreset = AVCaptureSession.Preset.cif352x288
                            break;
                        default:
                            self.captureSession?.sessionPreset = AVCaptureSession.Preset.vga640x480
                            break;
                        }

                        let connection: AVCaptureConnection? = self.videoOutput?.connection(with: .video)
                        self.videoOutput?.setOutputSettings([AVVideoCodecKey : AVVideoCodecType.h264], for: connection!)

                        // Commit configurations
                        self.captureSession?.commitConfiguration()


                        do {
                            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [
                                .mixWithOthers,
                                .defaultToSpeaker,
                                .allowBluetoothA2DP,
                                .allowAirPlay
                            ])
                        } catch {
                            print("Failed to set audio session category.")
                        }
                        try? AVAudioSession.sharedInstance().setActive(true)
                        let settings = [
                            AVSampleRateKey : 44100.0,
                            AVFormatIDKey : kAudioFormatAppleLossless,
                            AVNumberOfChannelsKey : 2,
                            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue
                            ] as [String : Any]
                        self.audioRecorder = try AVAudioRecorder(url: URL(fileURLWithPath: "/dev/null"), settings: settings)
                        self.audioRecorder?.isMeteringEnabled = true
                        self.audioRecorder?.prepareToRecord()
                        self.audioRecorder?.record()
                        self.audioLevelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.levelTimerCallback(_:)), userInfo: nil, repeats: true)
                        self.audioRecorder?.updateMeters()

                        // Start running sessions
                        self.captureSession!.startRunning()

                        // Initialize camera view
                        self.initializeCameraView()

                        if autoShow {
                            self.cameraView.isHidden = false
                        }

                    } catch CaptureError.backCameraUnavailable {
                        call.reject("Back camera unavailable")
                    } catch CaptureError.frontCameraUnavailable {
                        call.reject("Front camera unavailable")
                    } catch CaptureError.couldNotCaptureInput( _){
                        call.reject("Camera unavailable")
                    } catch {
                        call.reject("Unexpected error")
                    }
                    call.resolve()
                }
            }
        }
    }

	/**
	* Destroys the camera.
	*/
    @objc func destroy(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate
            appDelegate?.window?!.backgroundColor = UIColor.black

            self.capWebView?.isOpaque = true
            self.capWebView?.backgroundColor = UIColor.white
            if (self.captureSession != nil) {
				// Need to destroy all preview layers
                self.previewFrameConfigs = []
                self.currentFrameConfig = FrameConfig(["id": "default"])
                if (self.captureSession!.isRunning) {
                    self.captureSession!.stopRunning()
                }
                if (self.audioRecorder != nil && self.audioRecorder!.isRecording) {
                    self.audioRecorder!.stop()
                }
                self.cameraView?.removePreviewLayer()
                self.captureVideoPreviewLayer = nil
                self.cameraView?.removeFromSuperview()
                self.videoOutput = nil
                self.cameraView = nil
                self.captureSession = nil
                self.audioRecorder = nil
                self.audioLevelTimer?.invalidate()
                self.currentCamera = 0
                self.frontCamera = nil
                self.backCamera = nil
                self.notifyListeners("onVolumeInput", data: ["value":0])
            }
            call.resolve()
        }
    }

	/**
	* Toggle between the front facing and rear facing camera.
	*/
    @objc func flipCamera(_ call: CAPPluginCall) {
        if (self.captureSession != nil) {
            var input: AVCaptureDeviceInput? = nil
            do {
                self.currentCamera = self.currentCamera == 0 ? 1 : 0
                input = try createCaptureDeviceInput(currentCamera: self.currentCamera, frontCamera: self.frontCamera, backCamera: self.backCamera)
            } catch CaptureError.backCameraUnavailable {
                self.currentCamera = self.currentCamera == 0 ? 1 : 0
                call.reject("Back camera unavailable")
            } catch CaptureError.frontCameraUnavailable {
                self.currentCamera = self.currentCamera == 0 ? 1 : 0
                call.reject("Front camera unavailable")
            } catch CaptureError.couldNotCaptureInput( _) {
                self.currentCamera = self.currentCamera == 0 ? 1 : 0
                call.reject("Camera unavailable")
            } catch {
                self.currentCamera = self.currentCamera == 0 ? 1 : 0
                call.reject("Unexpected error")
            }

            if (input != nil) {
                let currentInput = self.cameraInput
                self.captureSession?.beginConfiguration()
                self.captureSession?.removeInput(currentInput!)
                self.captureSession!.addInput(input!)
                self.cameraInput = input
                self.captureSession?.commitConfiguration()

                // Update camera view to apply correct mirroring for the new camera
                DispatchQueue.main.async {
                    self.updateCameraView(self.currentFrameConfig)
                }

                call.resolve();
            }
        }
    }

	/**
	* Add a camera preview frame config.
	*/
    @objc func addPreviewFrameConfig(_ call: CAPPluginCall) {
        if (self.captureSession != nil) {
            guard let layerId = call.getString("id") else {
                call.reject("Must provide layer id")
                return
            }
			let newFrame = FrameConfig(call.options)

            // Check to make sure config doesn't already exist, if it does, edit it instead
            if (self.previewFrameConfigs.firstIndex(where: {$0.id == layerId }) == nil) {
                self.previewFrameConfigs.append(newFrame)
            }
            else {
                self.editPreviewFrameConfig(call)
                return
            }
			call.resolve()
        }
    }

	/**
	* Edit an existing camera frame config.
	*/
    @objc func editPreviewFrameConfig(_ call: CAPPluginCall) {
        if (self.captureSession != nil) {
            guard let layerId = call.getString("id") else {
                call.reject("Must provide layer id")
                return
            }

            let updatedConfig = FrameConfig(call.options)

            // Get existing frame config
            let existingConfig = self.previewFrameConfigs.filter( {$0.id == layerId }).first
            if (existingConfig != nil) {
                let index = self.previewFrameConfigs.firstIndex(where: {$0.id == layerId })
                self.previewFrameConfigs[index!] = updatedConfig
            }
            else {
                self.addPreviewFrameConfig(call)
                return
            }

            if (self.currentFrameConfig.id == layerId) {
                // Is set to the current frame, need to update
                DispatchQueue.main.async {
                    self.currentFrameConfig = updatedConfig
                    self.updateCameraView(self.currentFrameConfig)
                }
            }
            call.resolve()
        }
    }

    /**
     * Switch frame configs.
     */
    @objc func switchToPreviewFrame(_ call: CAPPluginCall) {
        if (self.captureSession != nil) {
            guard let layerId = call.getString("id") else {
                call.reject("Must provide layer id")
                return
            }
            DispatchQueue.main.async {
                let existingConfig = self.previewFrameConfigs.filter( {$0.id == layerId }).first
                if (existingConfig != nil) {
                    if (existingConfig!.id != self.currentFrameConfig.id) {
                        self.currentFrameConfig = existingConfig!
                        self.updateCameraView(self.currentFrameConfig)
                    }
                }
                else {
                    call.reject("Frame config does not exist")
                    return
                }
                call.resolve()
            }
        }
    }

	/**
	* Show the camera preview frame.
	*/
    @objc func showPreviewFrame(_ call: CAPPluginCall) {
        if (self.captureSession != nil) {
            DispatchQueue.main.async {
                self.cameraView.isHidden = true
                call.resolve()
            }
        }
    }

	/**
	* Hide the camera preview frame.
	*/
    @objc func hidePreviewFrame(_ call: CAPPluginCall) {
        if (self.captureSession != nil) {
            DispatchQueue.main.async {
                self.cameraView.isHidden = false
                call.resolve()
            }
        }
    }

    func initializeCameraView() {
        self.cameraView = CameraView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.cameraView.isHidden = true
        self.cameraView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        self.captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        self.captureVideoPreviewLayer?.frame = self.cameraView.bounds
        self.cameraView.addPreviewLayer(self.captureVideoPreviewLayer)

        self.cameraView.backgroundColor = UIColor.black
        self.cameraView.videoPreviewLayer?.masksToBounds = true
        self.cameraView.clipsToBounds = false
        self.cameraView.layer.backgroundColor = UIColor.clear.cgColor

        self.capWebView!.superview!.insertSubview(self.cameraView, belowSubview: self.capWebView!)

        self.updateCameraView(self.currentFrameConfig)
    }

    func updateCameraView(_ config: FrameConfig) {
        // Set position and dimensions
        let width = config.width as? String == "fill" ? UIScreen.main.bounds.width : config.width as! CGFloat
        let height = config.height as? String == "fill" ? UIScreen.main.bounds.height : config.height as! CGFloat
        self.cameraView.frame = CGRect(x: config.x, y: config.y, width: width, height: height)

        // Set stackPosition
        if config.stackPosition == "front" {
            self.capWebView!.superview!.bringSubviewToFront(self.cameraView)
        }
        else if config.stackPosition == "back" {
            self.capWebView!.superview!.sendSubviewToBack(self.cameraView)
        }

        // Set decorations
        self.cameraView.videoPreviewLayer?.cornerRadius = config.borderRadius
        self.cameraView.layer.shadowOffset = CGSize.zero
        self.cameraView.layer.shadowColor = config.dropShadow.color
        self.cameraView.layer.shadowOpacity = config.dropShadow.opacity
        self.cameraView.layer.shadowRadius = config.dropShadow.radius
        self.cameraView.layer.shadowPath = UIBezierPath(roundedRect: self.cameraView.bounds, cornerRadius: config.borderRadius).cgPath

        // Set mirroring based on config.mirrorFrontCam property (only for front camera, mirrored by default)
        if let connection = self.cameraView.videoPreviewLayer?.connection {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = self.currentCamera == 0 ? config.mirrorFrontCam : false
        }
    }

	/**
	* Start recording.
	*/
    @objc func startRecording(_ call: CAPPluginCall) {
        if (self.captureSession != nil) {
            if (!(videoOutput?.isRecording)!) {
                let tempDir = NSURL.fileURL(withPath:NSTemporaryDirectory(), isDirectory: true)
                var fileName = randomFileName()
                fileName.append(".mp4")
                let fileUrl = NSURL.fileURL(withPath: joinPath(left: tempDir.path, right: fileName))

                // Configure video output settings
                let videoSettings: [String: Any] = [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoCompressionPropertiesKey: [
                        AVVideoAverageBitRateKey: self.videoBitrate
                    ]
                ]

                if let connection = self.videoOutput?.connection(with: .video) {
                    self.videoOutput?.setOutputSettings(videoSettings, for: connection)
                }

                DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        self.videoOutput?.connection(with: .video)?.videoOrientation = self.cameraView.interfaceOrientationToVideoOrientation(windowScene.interfaceOrientation)
                    }

                    // Apply mirroring setting to video output connection (saved video should never be mirrored to match Android behavior)
                    if let connection = self.videoOutput?.connection(with: .video) {
                        connection.automaticallyAdjustsVideoMirroring = false
                        connection.isVideoMirrored = false
                    }
                    // turn on flash if flash is enabled and camera is back camera
                    if (self.currentCamera == 1 && self._isFlashEnabled) {
                        let device = AVCaptureDevice.default(for: .video)
                        if let device = device {
                            do {
                                try device.lockForConfiguration()
                                try device.setTorchModeOn(level: 1.0)
                                device.unlockForConfiguration()
                            } catch {
                                // ignore error
                            }
                        }
                    }
                    self.videoOutput?.startRecording(to: fileUrl, recordingDelegate: self)
                    call.resolve()
                }
            }
        }
    }

	/**
	* Stop recording.
	*/
    @objc func stopRecording(_ call: CAPPluginCall) {
        if (self.captureSession != nil) {
            if (videoOutput?.isRecording)! {
                self.stopRecordingCall = call
                self.videoOutput!.stopRecording()

                // turn off flash if flash is enabled and camera is back camera
                if (self.currentCamera == 1 && self._isFlashEnabled) {
                    let device = AVCaptureDevice.default(for: .video)
                    if let device = device {
                        do {
                            try device.lockForConfiguration()
                            device.torchMode = .off
                            device.unlockForConfiguration()
                        } catch {
                            // ignore error
                        }
                    }
                }
            }
        }
    }

	/**
	* Get current recording duration.
	*/
    @objc func getDuration(_ call: CAPPluginCall) {
        if (self.videoOutput!.isRecording == true) {
            let duration = self.videoOutput?.recordedDuration;
            if (duration != nil) {
                call.resolve(["value":round(CMTimeGetSeconds(duration!))])
            } else {
                call.resolve(["value":0])
            }
        } else {
            call.resolve(["value":0])
        }
    }

    @objc func isFlashAvailable(_ call: CAPPluginCall) {
        if (self.captureSession != nil) {
            let device = AVCaptureDevice.default(for: .video)
            if let device = device {
                call.resolve(["isAvailable": device.hasTorch])
            } else {
                call.resolve(["isAvailable": false])
            }
        }
    }

    @objc func isFlashEnabled(_ call: CAPPluginCall) {
        call.resolve(["isEnabled": self._isFlashEnabled])
    }

    @objc func enableFlash(_ call: CAPPluginCall) {
        self._isFlashEnabled = true
        call.resolve()
    }

    @objc func disableFlash(_ call: CAPPluginCall) {
        self._isFlashEnabled = false
        call.resolve()
    }

    @objc func toggleFlash(_ call: CAPPluginCall) {
        self._isFlashEnabled = !self._isFlashEnabled
        call.resolve()
    }
}
