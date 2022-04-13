//
//  ViewController.swift
//  TextToPdf
//
//  Created by Imam MohammadUvesh on 24/03/22.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var inputTextBox: UITextField!
    
    //MARK: Variables
    var textMessage: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func shareButton(_ sender: UIButton) {
        self.enterTextViaAlert()
    }
    
    func enterTextViaAlert(){
        
        let alert = UIAlertController(title: "Enter Text", message: "Please enter text to convert it in PDF file.", preferredStyle: UIAlertController.Style.alert)

        alert.addTextField { (textField) in
            textField.delegate = self
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Convert", style: .default, handler: {_ in
            self.view.endEditing(true)
            guard self.textMessage.count>0 else {
                let alert = UIAlertController(title: "", message: "Please enter text to convert it in PDF file.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.convertToPdfFileAndShare()
            
        }))

        self.present(alert, animated: true, completion: nil)

    }
    func convertToPdfFileAndShare(){
        
        let fmt = UIMarkupTextPrintFormatter(markupText: textMessage)
        
        // 2. Assign print formatter to UIPrintPageRenderer
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        
        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage();
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("output").appendingPathExtension("pdf")
            else { fatalError("Destination URL not created") }
        
        pdfData.write(to: outputURL, atomically: true)
        print("open \(outputURL.path)")
        
        if FileManager.default.fileExists(atPath: outputURL.path){
            
            let url = URL(fileURLWithPath: outputURL.path)
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            let excludedActivities = [UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.message, UIActivity.ActivityType.mail, UIActivity.ActivityType.print, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.saveToCameraRoll, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo,UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTencentWeibo]

                activityViewController.excludedActivityTypes = excludedActivities
            
            
            activityViewController.popoverPresentationController?.sourceView=self.view
            
            //If user on iPad
            if UIDevice.current.userInterfaceIdiom == .pad {
                if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                }
            }
            present(activityViewController, animated: true, completion: nil)

        }
        else {
            print("document was not found")
        }
        
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard (textField.text?.count ?? 0)>0 else{ return }
        textMessage = textField.text ?? ""
    }
}

