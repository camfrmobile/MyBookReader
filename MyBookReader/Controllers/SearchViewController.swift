//
//  SearchViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: IBOutlet
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    
    // MARK: Variables
    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Tìm kiếm"
        textField.backgroundColor = .white
        textField.clipsToBounds = true
        return textField
    } ()
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabelView()
        setupUI()
    }
    
    func setupUI() {
        searchView.addSubview(searchTextField)
        
        searchTextField.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 20).isActive = true
        searchTextField.trailingAnchor.constraint(equalTo: searchView.trailingAnchor, constant: -20).isActive = true
        searchTextField.centerYAnchor.constraint(equalTo: searchView.centerYAnchor).isActive = true
        searchTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        // prefix
        let prefix = UIImage(systemName: "magnifyingglass")
        searchTextField.addPaddingLeftIcon(prefix!, padding: 40)
        //suffix
        let suffix = UIImage(systemName: "mic.fill")
        searchTextField.addPaddingRightIcon(suffix!, padding: 40)
        // radius
        searchTextField.layer.cornerRadius = 10
    }
    
    func setupTabelView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.separatorStyle = .none
    }

}

// MARK: Extension
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sCell = UITableViewCell()
        sCell.textLabel?.text = "\(indexPath.row)"
        return sCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return 105
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}

// MARK: Extension
extension SearchViewController: UITableViewDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return headers[section]
//    }
//
//    // dat height cho header cua section
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
//        viewHeader.backgroundColor = .white
//
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: viewHeader.bounds.width, height: viewHeader.bounds.height))
//        label.text = headers[section]
//        label.textColor = .black
//        label.font = UIFont.boldSystemFont(ofSize: 32)
//
//        viewHeader.addSubview(label)
//        return viewHeader
//    }
    
}
