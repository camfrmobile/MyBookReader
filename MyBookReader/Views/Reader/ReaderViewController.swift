//
//  ReaderViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 05/02/2023.
//

import UIKit
import Alamofire
import SwiftSoup
import FirebaseAuth

class ReaderViewController: UIViewController {
    
    // MARK: IBOutlet
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var formatView: UIView!
    @IBOutlet weak var textLagerButton: UIButton!
    @IBOutlet weak var textSmallerButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: Variables
    
    let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.style = .large
        return activity
    } ()
    let loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Đang tải..."
        return label
    } ()
    let loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    } ()
    
    var iBook: Book = Book()
    var content: String = ""
    var fontName: String = "Arial"
    var lastChapter: Chapter?
    var lastPosition: CGFloat = 1
    var lastHeight: CGFloat = 0
    var numberLoad: Int = 0
    var tempPos: CGFloat = 0
    var isLoading = false
    var listPositon: [Int: CGFloat] = [:]
    
    var timerClock: Timer?
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUser()
        
        setupUI()
        
        setupLoadingView()
        
        setupText()
        
        setupChapter()
        
        loadContentChapter()
        
        saveBookToFirebase(iBook)
        
        savePositon()
    }
    
    func setupUser() {
        guard let user = Auth.auth().currentUser else { return }
        
        identification = user.uid
    }
    
    func setupUI() {
        contentTextView.delegate = self
        contentTextView.isEditable = false
        contentTextView.textContainerInset = UIEdgeInsets.zero
        contentTextView.textContainer.lineFragmentPadding = 20
        // ko bounce de cuon xuong cuoi(load chap tiep theo) khong load nhieu lan
        contentTextView.bounces = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        // left button
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(onTapBack))
        // right button
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(systemName: "textformat"), style: .done, target: self, action: #selector(onTapFormatText))
        
        // format text
        textLagerButton.layer.cornerRadius = 10
        textSmallerButton.layer.cornerRadius = 10
        formatView.isHidden = true
        formatView.layer.cornerRadius = 5
        
//        contentTextView.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapTextView))
//        contentTextView.addGestureRecognizer(tapGesture)

    }
    
    func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)
        
        loadingView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        
        loadingLabel.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        loadingLabel.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor, constant: 10).isActive = true
        
        activityIndicator.startAnimating()
    }
    func hideLoadingView() {
        loadingView.removeFromSuperview()
    }
    func showNotifition(_ msg: String) {
        view.addSubview(loadingView)
        loadingLabel.text = msg
        activityIndicator.stopAnimating()
    }
    
    func setupText() {
        contentTextView.font = UIFont(name: fontName, size: iBook.fontSize)
    }
    
    func saveFontSize() {
        saveBookToFirebase(docId: iBook.id, data: [
            "fontSize": iBook.fontSize
        ])
        iBook.chapterOffSet = 0
    }
    
    func savePositon() {
        // luu vi tri dang doc vao database
        timerClock = Timer.scheduledTimer(withTimeInterval: 3, repeats: true)  {[weak self]_ in
            guard let self = self else { return }
            
            let inteval = self.iBook.chapterOffSet - self.tempPos
            if inteval > 100 || inteval < -100 {
                self.tempPos = self.iBook.chapterOffSet
                
                self.iBook.desc = "\(self.iBook.chapterIndex * 100 / self.iBook.totalChapter)%"
                
                saveBookToFirebase(docId: self.iBook.id, data: [
                    "chapterOffSet": self.iBook.chapterOffSet,
                    "chapterIndex": self.iBook.chapterIndex,
                    "desc": self.iBook.desc
                ])
                
                print("POS", self.iBook.chapterOffSet)
//                print("HEIGHT", self.contentTextView.contentSize.height, self.contentTextView.bounds.height)
            }
        }
    }
    
    func readDone() {
        timerClock?.invalidate()
        
        showNotifition("- THE END -")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        iBook.desc = formatter.string(from: Date())
        
        iBook.status = "READ_DONE"
        
        saveBookToFirebase(docId: iBook.id, data: [
            "desc": self.iBook.desc,
            "status": iBook.status
        ])
    }
    
    func setupChapter() {
        if iBook.chapterIndex == 0 {
            iBook.status = "READING"
        }
        
        if iBook.chapterIndex >= iBook.listChapter.count {
            return // khong ton tai chapter index
        }
        lastChapter = iBook.listChapter[iBook.chapterIndex]

        self.iBook.desc = "\(self.iBook.chapterIndex * 100 / self.iBook.totalChapter)%"
    }
    
    func loadContentChapter() {
        
        // check internet
        if !isConnectedToNetwork() {
            showNotifition("Không có Internet!")
            return
        }
        
        guard let lastChapter = lastChapter else { return }
        
        navigationItem.title = lastChapter.name
        
        AF.request(lastChapter.url).responseString {[weak self] response in
            //debugPrint("Response: \(response)")
            
            guard let self = self else { return }
            
            guard let html = response.value else { return }
            
            do {
                let doc: Document = try SwiftSoup.parse(html)
                
                // get content chapter
                let text = try doc.select("#box-content div.c-content").text()

                // refill data
                self.fillContentBook(text)
                
            } catch Exception.Error(let type, let message) {
                print("ERROR: ", type, message)
            } catch {
                print("error")
            }
        }
        //end
    }
    
    func fillContentBook(_ text: String) {
        content.append(text)
        content.append("\n\n")
        contentTextView.text = content
        
        // load vi tri doc lan truoc khi moi mo sach
        if numberLoad == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.contentTextView.contentOffset = .init(x: 0, y: self.iBook.chapterOffSet)
            }
        }
        listPositon[iBook.chapterIndex] = contentTextView.contentSize.height
//        for item in listPositon {
//            print("LSIT", item.key, item.value)
//        }
//        print("----------")
        
        isLoading = false
        
        hideLoadingView()
        
        if contentTextView.contentSize.height <= contentTextView.bounds.height {
            nextChapter()
        }
    }
    
    func nextChapter() {
        
        if iBook.chapterIndex >= (iBook.listChapter.count - 1) {
            readDone()
            return
        }
        
        setupLoadingView()
        
        updateProgress()
        
        // get next chap
        iBook.chapterIndex += 1
        iBook.chapterOffSet = 0
        
        lastChapter = iBook.listChapter[iBook.chapterIndex]

        loadContentChapter()
        
        updateProgress()
        
        numberLoad += 1
    }
    
    func updateProgress() {
        let progress = Float(iBook.chapterIndex) / Float(iBook.listChapter.count)
        progressView.progress = progress // Tiến độ công việc chạy từ 0 - 1
    }
    
    // MARK: IBAction
    @objc func onTapBack() {
        routeToMain()
    }
    
//    @objc func onTapTextView() {
//        if !formatView.isHidden {
//            onTapFormatText()
//        }
//    }
    
    @objc func onTapFormatText() {
        formatView.isHidden = !formatView.isHidden
        
        if formatView.isHidden {
            navigationItem.rightBarButtonItem?.tintColor = .black
        } else {
            navigationItem.rightBarButtonItem?.tintColor = .blue
        }
    }
    
    @IBAction func actonFormatTextLager(_ sender: UIButton) {
        if iBook.fontSize > 36 {
            return
        }
        iBook.fontSize += 2
        
        setupText()
        saveFontSize()
    }
    
    @IBAction func actionFormatTextSmaller(_ sender: UIButton) {
        if iBook.fontSize < 12 {
            return
        }
        iBook.fontSize -= 2
        
        setupText()
        saveFontSize()
    }
    
    @IBAction func actionNextChapter(_ sender: UIButton) {
        nextChapter()
    }
}

extension ReaderViewController: RouteBook {
    
    func routeToMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homePageVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarController")
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        keyWindow?.rootViewController = homePageVC
        //keyWindow?.makeKeyAndVisible()
    }
}

extension ReaderViewController: UITextViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // lay vi tri dang doc
        if scrollView.contentOffset.y > 1 {
            iBook.chapterOffSet = scrollView.contentOffset.y - lastPosition
        }
        
        // load nex chap content
        if isLoading || scrollView.contentOffset.y < lastPosition {
            return
        }
        
        // phat hien scroll to bottom -> load next chap
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height - 100) {
            isLoading = true
            lastHeight = scrollView.contentSize.height
            lastPosition = scrollView.contentOffset.y
            nextChapter()
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
    }
    
}
