//
//  RepoViewController.swift
//  BitbucketRepos
//
//  Created by Manisha Deshmukh on 8/7/21.
//

import UIKit
import Alamofire
import SwiftyJSON

class RepoViewController: UIViewController {

    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var repositoryDetails:[Repository] = []
    let imageCache = NSCache<NSURL, UIImage>()
    var nextUrl = "https://api.bitbucket.org/2.0/repositories"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nextBtn.isHidden = true
        self.initiateRequest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.reloadData()
    }
    
    /*Requestion to get repo details*/
    private func initiateRequest(){
        
        RepoService().requestRepositories(nextUrl){ [weak self] (response, nextUrlString) in
            guard let repoDetails = response else {
                return
            }
            
            self?.repositoryDetails = repoDetails
            
            //Update next button visibility and reload table view.
            DispatchQueue.main.async {
                if nextUrlString != self?.nextUrl && nextUrlString != "" {
                    self?.nextUrl = nextUrlString
                    self?.nextBtn.isHidden = false
                    self?.tableView.reloadData()
                }else{
                    self?.nextBtn.isHidden = true
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 */
    
    // MARK: - Actions
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        self.initiateRequest()
    }
}

// MARK: - Table view data source

extension RepoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryDetails.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepoTableViewCell.Identifier, for: indexPath) as? RepoTableViewCell else {
            //Something went wrong with the identifier.
            return UITableViewCell()
        }
        //Setup ownerDetails section
        let ownerDetails = repositoryDetails[indexPath.row].owner
        cell.configureOwnerDetailsView(forCell: indexPath.row, withOwner: ownerDetails)
        
        //Download image
        RepoService().downloadImage(ownerDetails.avatar, imageCache: imageCache) { [weak cell] (image) in
            DispatchQueue.main.async {
                cell?.ownerImageView.image = image
            }
        }
   
        return cell
  }
}

// MARK: - Table view delegate

extension RepoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Configure repoDEtails section for selected row
        if let cell = tableView.cellForRow(at: indexPath) as? RepoTableViewCell {
            let rowIndex = indexPath.row
            cell.configureRepoDetailsView(forCell: rowIndex, withRepo: repositoryDetails[rowIndex])
        }
        UIView.animate(withDuration: 0.2) {
            tableView.performBatchUpdates(nil)
        }
    }
}
