//
//  SearchViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    
    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Tìm kiếm"
        textField.backgroundColor = .white
        textField.clipsToBounds = true
        return textField
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTableView.delegate = self
        searchTableView.dataSource = self
        
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

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sCell = UITableViewCell()
        sCell.textLabel?.text = "\(indexPath.row)"
        return sCell
    }
    
    
}
