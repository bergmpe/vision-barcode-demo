//
//  ViewController.swift
//  Vision Track Demonstration
//
//  Created by Williamberg on 19/10/17.
//  Copyright © 2017 padrao. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var previewView: UIView!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.isHidden = true
        let captureDevice = AVCaptureDevice.default(for: .video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.addInput(input)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            captureSession.startRunning()
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            captureSession.addOutput(videoOutput)
            
        } catch {
            print(error)
        }
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard
            // make sure the pixel buffer can be converted
            let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            else { return }
        // create the request
        let request = VNDetectBarcodesRequest { (request, error) in
            guard let results = request.results as? [VNBarcodeObservation] else{ return }
            
            results.forEach({ (barcodeObservation) in
                DispatchQueue.main.async {
                    self.descriptionLabel.isHidden = false
                    self.descriptionLabel.text = barcodeObservation.payloadStringValue
                }
                self.captureSession.stopRunning()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3 , execute: {
                    self.descriptionLabel.isHidden = true
                    self.captureSession.startRunning()
                })
            })
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform( [request] )
        } catch let reqError {
            print("Error in req",reqError)
        }
    }
    
}


