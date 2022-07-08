//
//  OnPhantomConnect.swift
//  Rhove
//
//  Created by Eric on 7/8/21.
//

import SwiftUI
import Solana

public typealias OnWalletTransactionAction = (_ signature:String?, _ error: Error?) -> Void

@available(iOS 14.0, macOS 11, *)
public struct OnWalletTransaction: ViewModifier {
    
    // ============================================================
    // === Internal API ===========================================
    // ============================================================
    
    // MARK: - Internal API
    
    // MARK: Internal Properties
    
    public var encryptionKey: PublicKey?
    public var secretKey: Data?
    public var action: OnWalletTransactionAction
    
    // MARK: Internal Methods
    
    public func body(content: Content) -> some View {
        
        content
            .onOpenURL { url in
                
                if PhantomUrlHandler.canHandle(url: url) {
                    
                    if let deeplink = try? PhantomUrlHandler.parse(
                        url: url,
                        phantomEncryptionPublicKey: encryptionKey,
                        dappSecretKey: secretKey
                    ) {
                        
                        switch deeplink {
                                
                            case .signAndSendTransaction(let signature, let error):
                                action(signature, error)
                                
                            default:
                                break
                        }
                        
                    }
                    
                }
            }
        
    }
    
}


extension View {
    
    public func onWalletTransaction(
        phantomEncryptionPublicKey: PublicKey?,
        dappEncryptionSecretKey: Data?,
        action: @escaping OnWalletTransactionAction
    ) -> some View {
        
        @available(iOS 14.0, macOS 11, *)
        self.modifier(
            OnWalletTransaction(
                encryptionKey: phantomEncryptionPublicKey,
                secretKey: dappEncryptionSecretKey,
                action: action
            )
        )
        
    }
    
}
