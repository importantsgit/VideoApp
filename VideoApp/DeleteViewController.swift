import AVFoundation
import AVKit
import UIKit
import PhotosUI

class qViewController: UIViewController {
    
    // AVPlayer와 AVPlayerItem 객체 생성
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    
    // PlayerLayer 객체 생성
    var playerLayer: AVPlayerLayer!
    
    // PHPickerViewController 객체 생성
    var picker = PHPickerViewController(configuration: PHPickerConfiguration())
    
    // UI 요소
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    // viewDidLoad() 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 동영상 파일 경로 설정
        let videoURL = Bundle.main.url(forResource: "sample_video", withExtension: "mp4")!
        
        // AVPlayerItem 생성
        playerItem = AVPlayerItem(url: videoURL)
        
        // AVPlayer 생성 및 playerLayer에 추가
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        
        // 슬라이더 최대값 설정
        let videoDuration = playerItem.asset.duration.seconds
        videoSlider.maximumValue = Float(videoDuration)
        
        // 슬라이더 값이 변경될 때 호출되는 메서드 등록
        videoSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        // PHPickerViewController delegate 설정
        picker.delegate = self
        
        // 재생 버튼과 일시정지 버튼을 비활성화
        playButton.isEnabled = false
        pauseButton.isEnabled = false
        
        // AVPlayerItem이 준비될 때 호출되는 메서드 등록
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemReadyToPlay), name: .AVPlayerItemNewAccessLogEntry, object: playerItem)
    }
    
    @objc func playerItemReadyToPlay(_ notification: Notification) {
        playButton.isEnabled = true
        pauseButton.isEnabled = true
    }
    
    // AVPlayerItem이 준비될 때 호출되는 메서드
    @objc func playerItemReadyToPlay(_ notification: Notification) {
        playButton.isEnabled = true
    }

    // 새로운 동영상 버튼을 눌렀을 때 호출되는 메서드
    @IBAction func newVideoButtonTapped(_ sender: UIButton) {
        present(picker, animated: true)
    }
    
    // 재생 버튼이 눌렸을 때 호출되는 메서드
    @IBAction func playButtonTapped(_ sender: UIButton) {
        player.play()
        playButton.isEnabled = false
        pauseButton.isEnabled = true
    }
    
    // 일시정지 버튼이 눌렸을 때 호출되는 메서드
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        player.pause()
        playButton.isEnabled = true
        pauseButton.isEnabled = false
    }
    
    // PHPickerViewController를 통해 새로운 동영상이 선택되었을 때 호출되는 메서드
    func playerItem(for asset: PHAsset) -> AVPlayerItem? {
        let manager = PHImageManager.default()
        var playerItem: AVPlayerItem?
        let options = PHVideoRequestOptions()
        options.version = .original
        
        manager.requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
            if let avAsset = avAsset as? AVURLAsset {
                playerItem = AVPlayerItem(url: avAsset.url)
                self.player.replaceCurrentItem(with: playerItem)
            }
        }
        
        return playerItem
    }
    
    // 슬라이더 값이 변경될 때 호출되는 메서드
    @objc func sliderValueChanged(_ sender: UISlider) {
        player.pause()
        let timeScale = playerItem.asset.duration.timescale
        let time = CMTime(seconds: Double(sender.value), preferredTimescale: timeScale)
        player.seek(to: time)
    }
    
}

// PHPickerViewControllerDelegate 구현
extension qViewController: PHPickerViewControllerDelegate {
func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    dismiss(animated: true)
    guard let itemProvider = results.first?.itemProvider else {
            return
        }
        
        if itemProvider.canLoadObject(ofClass: PHAsset.self) {
            itemProvider.loadObject(ofClass: PHAsset.self) { [weak self] asset, error in
                guard let self = self, let asset = asset as? PHAsset else {
                    return
                }
                
                DispatchQueue.main.async {
                    if let playerItem = self.playerItem(for: asset) {
                        self.player.replaceCurrentItem(with: playerItem)
                    }
                }
            }
        }
    }
}



class ViewController: UIViewController {

    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerItem: AVPlayerItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPlayer(url: URL(string: "https://example.com/example.mp4")!)
    }
    
    func setupPlayer(url: URL) {
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoPlayerView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        videoPlayerView.layer.addSublayer(playerLayer!)
        addPeriodicTimeObserver()
    }
    
    func addPeriodicTimeObserver() {
        // timeSlider 업데이트
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            self.timeSlider.value = Float(time.seconds)
        }
    }
    
    @objc func playButtonTapped() {
        player?.play()
    }
    
    @objc func pauseButtonTapped() {
        player?.pause()
    }
    
    @objc func timeSliderValueChanged() {
        let seconds = Int64(timeSlider.value)
        let targetTime = CMTime(seconds: seconds, preferredTimescale: 1)
        player?.seek(to: targetTime)
    }
    
    @IBAction func changeVideoButtonTapped(_ sender: Any) {
        let picker = PHPickerViewController(configuration: .init(photoLibrary: .shared()))
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
            guard let self = self else { return }
            if let error = error {
                print("Error loading video: \(error.localizedDescription)")
                return
            }
            guard let url = url else { return }
            let newPlayerItem = AVPlayerItem(url: url)
            self.player?.replaceCurrentItem(with: newPlayerItem)
            self.playerItem = newPlayerItem
        }
    }
}
