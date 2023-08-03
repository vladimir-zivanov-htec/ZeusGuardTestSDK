//
//  ZGSecureEnclaveManager.swift
//  ZeusGuardTestSDK
//
//  Created by Vladimir Zivanov on 2.8.23..
//

import Foundation

public class ZGSecureEnclaveManager {

    public static func makeAndStorePublicKey(name: String) -> SecKey? {
        guard let key = makeAndStoreKey(name: name) else {
            return nil
        }
        guard let publicKey = SecKeyCopyPublicKey(key) else {
            return nil
        }
        print("Public key: \(publicKey)")
        guard let publicKeyAsString = publicKey.asString else {
            return nil
        }
        print("Public key as string: \(publicKeyAsString)")
        return publicKey
    }
    
    public static func makeAndStoreKey(name: String) -> SecKey? {
        let access =
        SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                        [.privateKeyUsage],
                                        nil)!
       let tag = name.data(using: .utf8)!
       let attributes: [String: Any] = [
           kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
           kSecAttrKeySizeInBits as String     : 256,
           kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
           kSecPrivateKeyAttrs as String : [
               kSecAttrIsPermanent as String       : true,
               kSecAttrApplicationTag as String    : tag,
               kSecAttrApplicationLabel as String  : tag,
               kSecAttrAccessControl as String     : access
           ]
       ]
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print( "Can't encrypt \((error!.takeRetainedValue() as Error).localizedDescription)")
//            let e = error!.takeRetainedValue() as Error
            return nil
        }
        return key
    }
    
    public static func loadPublicKey(name: String) -> SecKey? {
        guard let item = loadKey(name: name) else {
            return nil
        }
        guard let publicKey = SecKeyCopyPublicKey(item) else {
            return nil
        }
        print("Fetched key: \(publicKey)")
        guard let publicKeyAsString = publicKey.asString else {
            return nil
        }
        print("Fetched key as string: \(publicKeyAsString)")
        return publicKey
    }
    
    public static func loadKey(name: String) -> SecKey? {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag,
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecReturnRef as String             : true
        ]

        var key: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &key)
        guard status == errSecSuccess else {
            return nil
        }
        guard let key = key else {
            return nil
        }
        return (key as! SecKey)
    }
    
    public static func removeKey(name: String) -> Bool {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag,
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecReturnRef as String             : true
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            return false
        }
        
        return true
    }
}

extension ZGSecureEnclaveManager {
    
    public static func encrypt(text: String, with publicKey: SecKey) -> Data? {

        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
           print("Can't encrypt, Algorith not supported")
           return nil
        }
        var error: Unmanaged<CFError>?
        let textData = text.data(using: .utf8)!
        let cipherTextData = SecKeyCreateEncryptedData(publicKey,
                                                       algorithm,
                                                       textData as CFData,
                                                       &error) as Data?
        guard let cipherTextData = cipherTextData else {
            print( "Can't encrypt \((error!.takeRetainedValue() as Error).localizedDescription)")
            return nil
        }
        return cipherTextData
    }
    
    public static func decrypt(data: Data, with key: SecKey, completion: @escaping (String?) -> Void) {
        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(key, .decrypt, algorithm) else {
            print( "Can't decrypt. Algorith not supported")
            completion(nil)
            return
        }
        var error: Unmanaged<CFError>?
        let clearTextData = SecKeyCreateDecryptedData(key,
                                                      algorithm,
                                                      data as CFData,
                                                      &error) as Data?
        guard clearTextData != nil else {
            print("Can't decrypt \((error!.takeRetainedValue() as Error).localizedDescription)")
            completion(nil)
            return
        }
        let clearText = String(decoding: clearTextData!, as: UTF8.self)
        completion(clearText)
    }
    
}

extension ZGSecureEnclaveManager {
    
    public static func sign(key: SecKey, data: Data) -> Data? {
        let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256
        guard SecKeyIsAlgorithmSupported(key, .sign, algorithm) else {
            print("Can't sign, Algorith not supported")
            return nil
        }
        
        var error: Unmanaged<CFError>?
        let signature = SecKeyCreateSignature(key,
                                              algorithm,
                                              data as CFData,
                                              &error) as Data?
        guard let signature = signature else {
            print("Can't sign \((error!.takeRetainedValue() as Error).localizedDescription)")
            return nil
        }
        return signature
    }
    
    public static func verifySignature(data: Data, signature: Data, publicKey: SecKey) -> Bool {
        let algorithm: SecKeyAlgorithm = .ecdsaSignatureMessageX962SHA256
        guard SecKeyIsAlgorithmSupported(publicKey, .verify, algorithm) else {
            print("Can't verify signature. Algorithm is not supported")
            return false
        }
        var error: Unmanaged<CFError>?
        guard SecKeyVerifySignature(publicKey, algorithm,
                                    data as CFData,
                                    signature as CFData,
                                    &error) else {
            print("Can't verify signature \(error.debugDescription)")
            return false
        }
        return true
    }
}

extension SecKey {
    
    var asString: String? {
        var error: Unmanaged<CFError>?
        guard let cfdata = SecKeyCopyExternalRepresentation(self, &error) else  {
            // TODO: Throw
            return nil
        }
        let data:Data = cfdata as Data
        let secretKeyAsString = data.base64EncodedString()
        return secretKeyAsString
    }
}
