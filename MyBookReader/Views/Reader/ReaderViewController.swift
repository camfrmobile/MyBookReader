//
//  ReaderViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 05/02/2023.
//

import UIKit
import Alamofire
import SwiftSoup

class ReaderViewController: UIViewController {
    
    // MARK: IBOutlet
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var formatView: UIView!
    @IBOutlet weak var textLagerButton: UIButton!
    @IBOutlet weak var textSmallerButton: UIButton!
    @IBOutlet weak var nextChapterButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: Variables
    
    var iBook: Book = Book()
    var content: String = ""
    var fontSize: CGFloat = 20
    var fontName: String = "Arial"
    var lastChapter: Chapter?
    var lastPosition: CGFloat = 0
    var rightButton = UIBarButtonItem()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUser()
        
        setupUI()
        
        setupText()
        
        setupChapter()
        
        loadContentChapter()
        
        saveBookToDatabase(iBook)
    }
    
    func setupUser() {
        guard let authUser = authUser else { return }
        
        identification = authUser.uid
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
        
        hiddenNextButton()
        
        contentTextView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapTextView))
        contentTextView.addGestureRecognizer(tapGesture)

    }
    
    func setupText() {
        // book content text
        contentTextView.font = UIFont(name: fontName, size: fontSize)
        
        navigationItem.title = "Đang mở..."
    }
    
    func setupChapter() {
        
        if iBook.chapterIndex == 0 {
            iBook.status = "READING"
        }
        
        if iBook.chapterIndex >= iBook.listChapter.count {
            return // khong ton tai chapter index
        }
        lastChapter = iBook.listChapter[iBook.chapterIndex]
    }
    
    func loadContentChapter() {
        guard let thisChapter = lastChapter else { return }
        
        navigationItem.title = thisChapter.name
        
        AF.request(thisChapter.url).responseString {[weak self] response in
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
    }
    
    func nextChapter() {
        
        updateProgress()
        
        if iBook.chapterIndex >= (iBook.totalChapter - 1) {
            iBook.status = "READ_DONE"
            saveBookToDatabase(docId: iBook.id, data: ["status": iBook.status])
        }
        // get next chap
        if iBook.chapterIndex >= (iBook.listChapter.count - 1) {
            nextChapterButton.setTitle("- THE END -", for: .normal)
            return
        }
        
        iBook.chapterIndex += 1
        
        lastChapter = iBook.listChapter[iBook.chapterIndex]

        loadContentChapter()
        hiddenNextButton()
        updateProgress()
    }
    
    func showNextButton() {
        nextChapterButton.isHidden = false
    }
    
    func hiddenNextButton() {
        nextChapterButton.isHidden = true
    }
    
    func updateProgress() {
        let progress = Float(iBook.chapterIndex) / Float(iBook.listChapter.count)
        progressView.progress = progress // Tiến độ công việc chạy từ 0 - 1
    }
    
    // MARK: IBAction
    @objc func onTapBack() {
        routeToMain()
    }
    
    @objc func onTapTextView() {
        if !formatView.isHidden {
            onTapFormatText()
        }
    }
    
    @objc func onTapFormatText() {
        formatView.isHidden = !formatView.isHidden
        
        if formatView.isHidden {
            navigationItem.rightBarButtonItem?.tintColor = .black
        } else {
            navigationItem.rightBarButtonItem?.tintColor = .blue
        }
    }
    
    @IBAction func actonFormatTextLager(_ sender: UIButton) {
        if fontSize > 40 {
            return
        }
        fontSize += 2
        contentTextView.font = UIFont(name: fontName, size: fontSize)
    }
    
    @IBAction func actionFormatTextSmaller(_ sender: UIButton) {
        if fontSize < 15 {
            return
        }
        fontSize -= 2
        contentTextView.font = UIFont(name: fontName, size: fontSize)
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
        
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height - 100) {
            showNextButton()
        } else {
            hiddenNextButton()
        }
        if scrollView.contentOffset.y < lastPosition {
            return
        }

        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
            {
                lastPosition = scrollView.contentOffset.y
                nextChapter()
            }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.y)
    }
    
}
