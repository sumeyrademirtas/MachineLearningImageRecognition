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
        
        if let ciImage = CIImage(image: imageView.image!) { // Eğer imageView'den bir resim alındıysa
            chosenImage = ciImage // Resmi CIImage formatına çevirip chosenImage'a atıyoruz
        }
        
        recognizeImage(image: chosenImage)
    }
    
    func recognizeImage(image: CIImage) {
        // 1) Request
        // 2) Handler
        
        resultLabel.text = "Loading..."
        let MobileNetConfig = MLModelConfiguration() // ML model konfigürasyonu oluşturuluyor
        if let model = try? VNCoreMLModel(for: MobileNetV2(configuration: MobileNetConfig).model) { // MobileNetV2 modelini VNCoreMLModel'a dönüştürüyoruz
            let request = VNCoreMLRequest(model: model) { vnrequest, _ in
                
                if let results = vnrequest.results as? [VNClassificationObservation] { // gorsel analizinin sonuclarini aliyoruz
                    if results.count > 0 {
                        let topResult = results.first // ilk sonuc (en yuksek ihtimalle dogru olan)
                        
                        DispatchQueue.main.async { // UI Islemleri yapilacak. ana threadde.
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            let rounded = Int(confidenceLevel * 100) / 100
                            self.resultLabel.text = "\(rounded)% it's \(topResult!.identifier)"

                        }
                    }
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image) // Resmi işlemek için handler oluşturuluyor
            DispatchQueue.global(qos: .userInteractive).async { // Arka planda işlem yapılacak
//                qos: .userInteractive ise, işlemin kullanıcı etkileşimleriyle bağlantılı olduğunu belirtir. Bu, UI ile hızlı bir şekilde etkileşime giren işlemleri tanımlar.
//                 Eğer yoğun işlemci gerektiren bir işlem ana iş parçacığında yapılırsa, UI kilitlenebilir veya donmuş gibi görünebilir. Bu nedenle, işlemi arka planda (global) çalıştırmak için async ile birlikte kullanılır, böylece UI düzgün çalışmaya devam eder.
                do {
                    try handler.perform([request]) // Request'i gerçekleştirecegiz
                } catch {
                    print("error")
                }
            }
        }
    }
}
