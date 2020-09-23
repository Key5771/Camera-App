//
//  ViewController.swift
//  FullScreenCamera
//
//  Created by 김기현 on 2020/09/23.
//

import UIKit
import AVFoundation

class CameraController: UIViewController {
    // #1
    var captureSession: AVCaptureSession?
    
    // #2
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    
    // #3
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    
    // #4
    var photoOutput: AVCapturePhotoOutput?
    
    // preview
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    
    // Preview display
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
}

// MARK: - Error & Position enum
extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}

// MARK: - Camera 동작 기능
extension CameraController {
//    func prepare(completionHandler: @escaping (Error?) -> Void) {
//        self.captureSession = AVCaptureSession()
//        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) else {
//            fatalError("no dual camera")
//        }
//
//        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice), ((self.captureSession?.canAddInput(videoDeviceInput)) != nil) else {
//            fatalError("Can't add video input")
//        }
//
//        self.captureSession?.beginConfiguration()
//        self.captureSession?.addInput(videoDeviceInput)
//
//        let photoOutput = AVCapturePhotoOutput()
//        photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
//
//        guard ((self.captureSession?.canAddOutput(photoOutput)) != nil) else {
//            fatalError("Can't add photo output")
//        }
//
//        self.captureSession?.addOutput(photoOutput)
//        self.captureSession?.sessionPreset = .photo
//        self.captureSession?.commitConfiguration()
//
//        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
//        photoSettings.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
//    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        // #1 : Creating a capture session
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }

        // #2 : Obtaining and configuring the necessary capture devices
        func configureCaptureDevices() throws {
//            let session = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
//            guard let cameras = (session?.constituentDevices.compactMap { $0 }), !cameras.isEmpty else {
//                throw CameraControllerError.noCamerasAvailable
//            }
//
//            for camera in cameras {
//                if camera.position == .front {
//                    self.frontCamera = camera
//                }
//
//                if camera.position == .back {
//                    self.rearCamera = camera
//
//                    try camera.lockForConfiguration()
//                    camera.focusMode = .continuousAutoFocus
//                    camera.unlockForConfiguration()
//                }
//            }
            
            if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                self.rearCamera = device
            } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                self.rearCamera = device
            } else {
                fatalError("Missing expected back camera device")
            }
        }

        // #3 : Creating inputs using the capture devices
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }

            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)

                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)
                }

                self.currentCameraPosition = .rear
            }
//            else if let frontCamera = self.frontCamera {
//                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
//
//                if captureSession.canAddInput(self.frontCameraInput!) {
//                    captureSession.addInput(self.frontCameraInput!)
//                } else {
//                    throw CameraControllerError.inputsAreInvalid
//                }
//
//                self.currentCameraPosition = .front
//            }
            else {
                throw CameraControllerError.noCamerasAvailable
            }
        }

        // #4 : Configuring a photo output object to process captured images
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else {
                throw CameraControllerError.captureSessionIsMissing
            }

            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)

            if captureSession.canAddOutput(self.photoOutput!) {
                captureSession.addOutput(self.photoOutput!)
            }

            captureSession.startRunning()
        }

        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }

                return
            }

            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                            previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                            resolvedSettings: AVCaptureResolvedPhotoSettings,
                            bracketSettings: AVCaptureBracketedStillImageSettings?,
                            error: Swift.Error?) {
        
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)
        } else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
                let image = UIImage(data: data) {
            
            self.photoCaptureCompletionBlock?(image, nil)
        }
        
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}

