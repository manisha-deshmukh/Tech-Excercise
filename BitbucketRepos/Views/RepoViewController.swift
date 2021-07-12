//
//  RepoViewController.swift
//  BitbucketRepos
//
//  Created by Manisha Deshmukh on 8/7/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import RxSwift
import RxCocoa

class RepoViewController: UIViewController {

    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var repositoryDetails:[Repository] = []
    let imageCache = NSCache<NSURL, UIImage>()
    let repoVModel = RepoViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupTableViewBinding()
        self.setupNextBtnBinding()
        
        //Send request for fetching repo details
        repoVModel.requestRepoDetails()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destinationController = segue.destination as? WebViewController, let (urlString, title) = sender as? (String, String) {
        
            //Setup WebViewControlller.
            destinationController.webViewUrl = urlString
            destinationController.title = title
        }
    }
    
    // MARK: - Utility methods
    func setupTableViewBinding() {
        
        repoVModel.repoDetails.bind(to: tableView.rx.items(cellIdentifier: RepoTableViewCell.Identifier, cellType: RepoTableViewCell.self)) { [weak self] (row,repo,cell) in
            
            //Setup ownerDetails section
            let ownerDetails = repo.owner
            cell.configureOwnerDetailsView(forCell: row, withOwner: ownerDetails)
            
            //Load webpage on tap of 'website' and 'more' button
            cell.websiteBtn.rx.tap.asObservable().subscribe { [ownerDetails](_) in
                self?.performSegue(withIdentifier: "loadWebpage", sender: (ownerDetails.website, ownerDetails.name))
            }.disposed(by: cell.disposeBag)
            cell.moreBtn.rx.tap.asObservable().subscribe { [weak self] _ in
                self?.performSegue(withIdentifier: "loadWebpage", sender: (repo.projectUrl,repo.projectName))
            }.disposed(by: cell.disposeBag)

            //Download image
            RepoService().downloadImage(ownerDetails.avatar, imageCache: self?.imageCache ) { [weak cell] (image) in
                DispatchQueue.main.async {
                    cell?.ownerImageView.image = image
                }
            }
        }.disposed(by: disposeBag)
    
       
        tableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .map { [weak self] (indexPath) -> (Repository?, RepoTableViewCell?) in
            guard let repoModel = try? self?.tableView.rx.model(at: indexPath) as Repository?,
                  let selectedCell = self?.tableView.cellForRow(at: indexPath) as? RepoTableViewCell  else {
                return (nil, nil)
            }
            return (repoModel, selectedCell)
            }.subscribe({ [weak self](selectedRepoCell) in
                guard let selectedRepoDetails = selectedRepoCell.element?.0, let selectedRepoCell = selectedRepoCell.element?.1 else{
                    return
                }
                //Configure repoDEtails section for selected row
                selectedRepoCell.configureRepoDetailsView(forCell: 0, withRepo: selectedRepoDetails)
                UIView.animate(withDuration: 0.2) {
                    self?.tableView.performBatchUpdates(nil)
                }
            }).disposed(by: disposeBag)
    }
    
    func setupNextBtnBinding() {
        
        self.nextBtn.isHidden = true
        
        repoVModel.nextUrl
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self](nextUrlElement) in
                guard let url = nextUrlElement.element else{
                    return
                }
                if url != "" {
                    self?.nextBtn.isHidden = false
                }else{
                    self?.nextBtn.isHidden = true
                }
            }.disposed(by: disposeBag)
        
        
        nextBtn.rx.tap.asObservable().subscribe { [weak self](sender) in
            self?.repoVModel.requestRepoDetails()
        }.disposed(by: disposeBag)
    }
}
