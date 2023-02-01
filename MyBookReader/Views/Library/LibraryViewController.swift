//
//  LibraryViewController.swift
//  MyBookReader
//
//  Created by Trần Văn Cam on 01/02/2023.
//

import UIKit

class LibraryViewController: UIViewController {

    @IBOutlet weak var newBookCollectionView: UICollectionView!
    @IBOutlet weak var topBookTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topBookTableView.delegate = self
        topBookTableView.dataSource = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tbCell = UITableViewCell()
        tbCell.textLabel?.text = "ok"
        
        return tbCell
    }
    
    
}
