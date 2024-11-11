//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Sümeyra Demirtaş on 11/11/24.
//

import CoreML
import UIKit
import Vision // CoreML ile Image Recognition icin kullandigimiz yardimci kutuphane

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var chosenImage = CIImage()
    
    @IBOutlet var resultLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imageView.image = info[.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) {
            chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
    }
    
    func recognizeImage(image: CIImage) {
        // 1) Request
        // 2) Handler
        
        resultLabel.text = "Loading..."
        let MobileNetConfig = MLModelConfiguration()
        if let model = try? VNCoreMLModel(for: MobileNetV2(configuration: MobileNetConfig).model) {
            let request = VNCoreMLRequest(model: model) { vnrequest, _ in
                
                if let results = vnrequest.results as? [VNClassificationObservation] { // gorsel analizinin sonucunda uretilen bir siniflandirma
                    if results.count > 0 {
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            let rounded = Int(confidenceLevel * 100) / 100
                            self.resultLabel.text = "\(rounded)% it's \(topResult!.identifier)"
                            
                            //                            self.resultLabel.text = "\(topResult!.identifier) (\(topResult!.confidence * 100)%)"
                        }
                    }
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("error")
                }
            }
        }
    }
}
