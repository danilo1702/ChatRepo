//
//  ViewModel.swift
//  prueba support
//
//  Created by Danilo Hernandez on 27/11/23.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift



class ViewModel: ObservableObject {
    @Published public var dbFirestore: Firestore = Firestore.firestore()
    var informationDevice = InformationDevice()
    func registerUserFirebase(completion: @escaping(Result<Bool, Error>)-> ()) {
        informationDevice.returnInformation()

        Auth.auth().createUser(withEmail: informationDevice.email, password: informationDevice.deviceUUID) {  authResult, error in

            guard let user = authResult?.user, error == nil else {
                if let nsError = error as? NSError, let error = AuthErrorCode.Code(rawValue: nsError.code)  {
                    switch error {
                        case .emailAlreadyInUse:
                            completion(.success(true))
                        default:
                            completion(.failure(nsError))
                    }
                }
                return
            }
            self.registerInfoUser(uuid: user.uid)
            completion(.success(true))
        }
    }
    func getAvailableSupports(completion: @escaping (Result<String, Error>) -> ()) {
        let reference = dbFirestore.collection(FirebaseConstants.supports)
        
        reference.whereField(FirebaseConstants.busy, isEqualTo: false).addSnapshotListener { querySnapshot, error in
//            guard let queryDocument = querySnapshot?.documents, error == nil else { return }
//
//            if let firstSuppor = queryDocument.first?.data(), let uuidSupport = firstSuppor[FirebaseConstants.uuid] as? String {
//                completion(.success(uuidSupport))
//            } else {
//                completion(.failure(NSError(domain: "There isn't a support user", code: 204)))
//            }
            
            guard let queryDocument = querySnapshot, error == nil else { return }
            let support = try? queryDocument.documentChanges.first?.document.data(as: PersonalInformationUser.self)
            print(support?.name)
        }
        
    }
    

    
    func registerInfoUser(uuid: String) {
        let information = PersonalInformationUser(email: informationDevice.email, uuid: uuid, name: UIDevice.modelName)

        do {
            try dbFirestore.collection(FirebaseConstants.supports).document(uuid).setData(from: information)
        } catch let error {
          print("Error writing the user to Firestore: \(error)")
        }
    }
    func getAvailableSupportz(completion: @escaping (Result<PersonalInformationUser, Error>) -> ()) {
        let reference = dbFirestore.collection(FirebaseConstants.supports)
        
        reference.whereField(FirebaseConstants.busy, isEqualTo: false).addSnapshotListener { querySnapshot, error in
            guard let queryDocument = querySnapshot, error == nil else { return }
            
            if let information = try? queryDocument.documentChanges[0].document.data(as: PersonalInformationUser.self) {
                completion(.success(information))
            }
        }
        
    }
    func getLastChats() {
        
        guard let userUUID = Auth.auth().currentUser?.uid else { return }
        let reference = dbFirestore.collection(FirebaseConstants.lastMessages)
            .document(userUUID)
            .collection(FirebaseConstants.messages)
        
        reference.addSnapshotListener { [weak self] querySnapshot, error in
            
            guard let self = self, let querySnapshot = querySnapshot, error == nil else { return }
            
            querySnapshot.documentChanges.forEach { change in
               
                
                let documentId = change.document.documentID
                let referenceSupportInformation = self.dbFirestore.collection("supports").document(documentId)
                
                if let message = try? change.document.data(as: MessageModel.self) {
                    print("FECHAA *-//*-*-/-/*/*-/*-/-*-/*-/*/-*/*-** \(message.timestamp.dateValue().formatted(date: .numeric, time: .shortened))")
                        
                    referenceSupportInformation.getDocument(as: PersonalInformationUser.self) { result in
                        switch result {
                            case .success(let information):
                                print("*/-*-/*-/-/*/*--/*/*-*-/-/*/*-*-/*-/-/*-/*\(String(describing: information.name))")
                            case .failure(let error):
                                print("ERROR GETTING SUPPOR INFORMATION \(error)")
                        }
                    }
                }
            
            }
            
        }
    }
}
struct InformationDevice {
    var email: String = ""
    var deviceUUID: String = ""
    
    mutating func returnInformation()  {
        guard  let deviceUUID = UIDevice.current.identifierForVendor?.uuidString else { return }
        self.deviceUUID = deviceUUID
        self.email = deviceUUID  + "@tribalgt.com"
    }
}

public struct PersonalInformationUser: Codable {
    
    public let email: String
    public let uuid: String
    public let name: String
    @ServerTimestamp public var createdAt: Timestamp?
    
    public init(email: String, uuid: String, name: String, createdAt: Timestamp? = nil) {
        self.email = email
        self.uuid = uuid
        self.name = name
        self.createdAt = createdAt
    }
}


struct FirebaseConstants {
    static let busy = "busy"
    static let supports = "supports"
    static let uuid = "uuid"
    static let timestamp = "timestamp"
    static let messages = "messages"
    static let lastMessages = "lastMessages"
    static let users = "users"
}

public struct MessageModel: Codable {
    @DocumentID var id: String?
    let message: String
    let fromUUID: String
    let toUUID: String
    let timestamp: Timestamp
    
}



import UIKit

public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPhone14,7":                                    return "iPhone 14"
            case "iPhone14,8":                                    return "iPhone 14 Plus"
            case "iPhone15,2":                                    return "iPhone 14 Pro"
            case "iPhone15,3":                                    return "iPhone 14 Pro Max"
            case "iPhone15,4":                                    return "iPhone 15"
            case "iPhone15,5":                                    return "iPhone 15 Plus"
            case "iPhone16,1":                                    return "iPhone 15 Pro"
            case "iPhone16,2":                                    return "iPhone 15 Pro Max"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
           
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}
