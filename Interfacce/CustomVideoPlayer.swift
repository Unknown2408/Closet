//
//  CustomVideoPlayer.swift
//  Closet
//
//  Created by Nitharsan on 18/02/26.
//


import SwiftUI
import AVFoundation

struct CustomVideoPlayer: UIViewControllerRepresentable {
    var videoName: String
    var videoExtension: String

    func makeUIViewController(context: Context) -> AVPlayerViewControllerHelper {
        return AVPlayerViewControllerHelper(videoName: videoName, videoExtension: videoExtension)
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewControllerHelper, context: Context) {}
}

class AVPlayerViewControllerHelper: UIViewController {
    var videoName: String
    var videoExtension: String
    var playerLayer = AVPlayerLayer()
    var player: AVPlayer?

    init(videoName: String, videoExtension: String) {
        self.videoName = videoName
        self.videoExtension = videoExtension
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sfondo nero per evitare flash chiari al caricamento
        view.backgroundColor = .black
        
        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else { 
            print("DEBUG: Video \(videoName).\(videoExtension) non trovato!")
            return 
        }
        
        player = AVPlayer(url: url)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        
        player?.isMuted = true
        player?.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Gestisce correttamente il frame senza usare UIScreen.main
        playerLayer.frame = view.bounds
    }
}