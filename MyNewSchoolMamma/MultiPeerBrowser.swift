//
//  MultiPeerHost.swift
//  MyNewSchoolMamma
//
//  Created by Barbara on 05/02/24.
//

import Foundation
import MultipeerConnectivity

class MultiPeerBrowser: NSObject, ObservableObject {
    private let serviceType = "mns-service"
    private var myPeerID: MCPeerID
    
    //public let serviceAdvertiser: MCNearbyServiceAdvertiser
    public let serviceBrowser: MCNearbyServiceBrowser
    public let session: MCSession
    
    @Published var availablePeers: [MCPeerID] = []
    @Published var paired = false
    @Published var receivedCurrentPoints = 0
    
    override init() {
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        print("😀 start browsing")
    }
    
    deinit {
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func sendData(data: String) {
        if !session.connectedPeers.isEmpty {
            print("😀 sto mandando \"\(data)\" a \(self.session.connectedPeers[0].displayName)")
            do {
                try session.send(data.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("🤬 errore durante l'invio: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: Session Methods

extension MultiPeerBrowser: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("😀 non connesso: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.paired = false
            }
        case .connecting:
            print("😀 in connessione: \(peerID.displayName)")
        case .connected:
            print("😀 connesso: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.paired = true
            }
        @unknown default:
            fatalError()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let string = String(data: data, encoding: .utf8), let points = Int(string) {
            print("😀 ricevuto il punteggio attuale di \(points) punti")
            // abbiamo ricevuto il punteggio attuale, diciamolo alla View
            DispatchQueue.main.async {
                self.receivedCurrentPoints = points
            }
        } else {
            print("🤬 errore durante la ricezione del punteggio attuale.")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("🤬 errore la ricezione di streams non è supportata!")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("🤬 errore la ricezione di resources non è supportata!")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("🤬 errore la ricezione di resources non è supportata!")
    }
    
    public func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}

// MARK: Browser Methods

extension MultiPeerBrowser: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("😀 ServiceBrowser ha trovato un peer: \(peerID.displayName)")
        // Add the peer to the list of available peers
        DispatchQueue.main.async {
            self.availablePeers.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("😀 ServiceBrowser ha perso un peer: \(peerID.displayName)")
        // Remove lost peer from list of available peers
        DispatchQueue.main.async {
            self.availablePeers.removeAll(where: {
                $0 == peerID
            })
        }
    }
}
