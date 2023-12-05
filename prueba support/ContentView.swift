//
//  ContentView.swift
//  prueba support
//
//  Created by Danilo Hernandez on 24/11/23.
//

import SwiftUI
import SupportModule
import FirebaseAuth


struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    var body: some View {
        VStack {
           SupportModuleView()
//           Text("")
//                .onAppear{
//                    viewModel.registerUserFirebase { result in
//                        switch result {
//                            case .success(let succes) :
//                                print("Registered\(succes)")
//                            case .failure(let error) :
//                                print(error)
//                        }
//                    }
//                }
//
//                        //
//                        //             viewModel.getLastChats()
//                        //                viewModel.getAvailableSupports { result in
//                        //                    switch result {
//                        //                        case .success(let succes) :
//                        //                            print("Registered\(succes)")
//                        //                        case .failure(let error) :
//                        //                            print(error)
//                        //                    }
//                                        }
//                    }
                }
        }
    }
    
    
    
    
    #Preview {
        ContentView()
    }
