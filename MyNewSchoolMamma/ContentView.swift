//
//  ContentView.swift
//  MyNewSchoolMamma
//
//  Created by Barbara on 05/02/24.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    @StateObject var session: MultiPeerBrowser
    @State private var audioPlayer: AVAudioPlayer!
    
    enum PuntiBonus: Int, CaseIterable {
        case uno = 1
        case dieci = 10
        case cento = 100
        case mille = 1_000
        case diecimila = 10_000
        case centomila = 100_000
    }
    
    enum PuntiMalus: Int, CaseIterable {
        case uno = -1
        case dieci = -10
        case cento = -100
        case mille = -1_000
        case diecimila = -10_000
        case centomila = -100_000
    }
    
    var body: some View {
        VStack {
            Text(session.paired ? "CONNESSO" : "NON CONNESSO")
            
            List(session.availablePeers, id: \.self) { peer in
                Button(peer.displayName) {
                    session.serviceBrowser.invitePeer(peer, to: session.session, withContext: nil, timeout: 30)
                }
            }
            
            Text("Punti attuali: \(session.receivedCurrentPoints)")
                .font(.title)
            
            Button("0") {
                session.sendData(data: "0")
            }
            .buttonStyle(.borderedProminent)
            .font(.title)
            .padding()
            
            HStack {
                
                VStack {
                    ForEach(PuntiBonus.allCases.reversed(), id: \.self) { punti in
                        Button("\(punti.rawValue)") {
                            session.sendData(data: String(punti.rawValue))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .font(.title)
                    }
                }
                
                VStack {
                    ForEach(PuntiMalus.allCases, id: \.self) { punti in
                        Button("\(punti.rawValue)") {
                            session.sendData(data: String(punti.rawValue))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .font(.title)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView(session: MultiPeerBrowser())
}
