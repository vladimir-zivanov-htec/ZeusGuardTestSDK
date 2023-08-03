//
//  ViewController.swift
//  ZeusGuard
//
//  Created by Vladimir Dinic on 5.12.22..
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var keyInput: FormTextField!
    @IBOutlet weak var create: UIButton!
    @IBOutlet weak var keyLabel: UILabel!
    
    @IBOutlet weak var textInput: FormTextField!
    @IBOutlet weak var encriptLabel: UILabel!
    @IBOutlet weak var decriptLabel: UILabel!
    
    @IBOutlet weak var verifyLabel: UILabel!
    
    @IBAction func createKey(_ sender: Any) {
        let keyName = keyInput.text!
        guard let key = SecureEnclaveManager.makeAndStoreKey(name: keyName) else {
            keyLabel.text = ""
            showDialog(message: "Ima vec")
            return
        }
        guard let publicKey = SecureEnclaveManager.loadPublicKey(name: keyName) else { return }
        
        keyLabel.text = publicKey.asString
    }
    
    @IBAction func loadKey(_ sender: Any) {
        let keyName = keyInput.text!
        guard let key = SecureEnclaveManager.loadKey(name: keyName) else {
            keyLabel.text = ""
            showDialog(message: "nema to")
            return
        }
        guard let publicKey = SecureEnclaveManager.loadPublicKey(name: keyName) else { return }
        
        keyLabel.text = publicKey.asString
    }
    
    @IBAction func verify(_ sender: Any) {
        performSecureEnclaveSigning()
    }
    
    @IBAction func remove(_ sender: Any) {
        let keyName = keyInput.text!
        
        if SecureEnclaveManager.removeKey(name: keyName) {
            keyLabel.text = keyName + " removed"
        }
    }
    
    let sessionManagerDleegate = SessionManagerDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        performSecureEnclaveEncryptionDecryption()
//        performSecureEnclaveSigning()
//        AppCheckManager.generateToken()
//        performCertificatePinningTest()
//        performCertificatePinningTestIOS14Plus()
        if UIDevice.current.isJailBroken {
            print("JailBroken")
        } else {
            print("No JailBroken")
        }
        
    }
    
    private func performCertificatePinningTest() {
        // Before iOS 14, from iOS 14+ we use info.plist
        let session: URLSession = {
            if #available(iOS 15.0, *) {
                return .shared
            } else {
                return .init(configuration: .default, delegate: sessionManagerDleegate, delegateQueue: .main)
            }
        }()
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                print(json)
                print(session.delegate)
                
            }
        }
        if #available(iOS 15.0, *) {
            task.delegate = SessionManagerDelegate()
        }
        task.resume()
    }
    
    private func performCertificatePinningTestIOS14Plus() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                print(json)
                
            }
        }
        task.resume()
    }
    
    private func performSecureEnclaveEncryptionDecryption() {
        let keyName = "MyKey23"
        let textToEncrypt = "Bravo 123"
        guard let key = SecureEnclaveManager.makeAndStoreKey(name: keyName) else { return }
        guard let key = SecureEnclaveManager.loadKey(name: keyName) else { return }
        guard let publicKey = SecureEnclaveManager.loadPublicKey(name: keyName) else { return }
        guard let encryptedData = SecureEnclaveManager.encrypt(text: textToEncrypt, with: publicKey) else { return }
        SecureEnclaveManager.decrypt(data: encryptedData, with: key, completion: {
            guard $0 == textToEncrypt else { return }
            print("Success")
        })
    }
    
    private func performSecureEnclaveSigning() {
        let keyName = keyInput.text!
        let textToEncrypt = textInput.text!
        guard let textData = textToEncrypt.data(using: .utf8) else { return }
        guard let key = SecureEnclaveManager.loadKey(name: keyName) else { return }
        guard let publicKey = SecureEnclaveManager.loadPublicKey(name: keyName) else { return }
        guard let data = SecureEnclaveManager.sign(key: key, data: textData) else { return }
        if SecureEnclaveManager.verifySignature(data: textData, signature: data, publicKey: publicKey) {
            verifyLabel.text = textToEncrypt + " verified"
        } else {
            verifyLabel.text = "Greska"
        }
    }


    func showDialog(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

@IBDesignable
class FormTextField: UITextField {

    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
}
