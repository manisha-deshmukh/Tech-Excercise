//
//  RepoTableViewCell.swift
//  BitbucketRepos
//
//  Created by Manisha Deshmukh on 8/7/21.
//

import UIKit

public class RepoTableViewCell: UITableViewCell {

    static let Identifier = "RepoTableViewCell"
   
    @IBOutlet weak var arrowImageView: UIImageView!
    
    @IBOutlet weak var ownerDetailsView: UIView!
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var ownerNameLbl: UILabel!
    @IBOutlet weak var ownerTypeLbl: UILabel!
    @IBOutlet weak var ownerCreationDateLbl: UILabel!
    @IBOutlet weak var websiteBtn: UIButton!
    
    @IBOutlet weak var repoDetailsView: UIView!
    @IBOutlet weak var projectNameLbl: UILabel!
    @IBOutlet weak var downloadsIndicatorLbl: UILabel!
    @IBOutlet weak var pullReqIndicatorLbl: UILabel!
    @IBOutlet weak var commitsIndicatorLbl: UILabel!
    @IBOutlet weak var watchersIndicatorLbl: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    public override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Initialization code
        repoDetailsView.isHidden = true
        
        //Set ownerImageView
        ownerImageView.contentMode = .scaleAspectFill
        ownerImageView.clipsToBounds = true
        ownerImageView.layer.cornerRadius = ownerImageView.bounds.height/2
        
        //Set arrowImageView
        arrowImageView.contentMode = .scaleAspectFill
        arrowImageView.clipsToBounds = true
        if let downArrow = UIImage.init(named: "expand-arrow") {
            arrowImageView.image = downArrow
        }
        
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        let isDetailViewHidden = repoDetailsView.isHidden
        if isDetailViewHidden, selected {
            repoDetailsView.isHidden = false
            if let upArrow = UIImage.init(named: "collapse-arrow") {
                arrowImageView.image = upArrow
//                UIView.animate(withDuration: 0.2) {
//                    arrowImageView.image = upArrow
//                }
            }
        }else{
            repoDetailsView.isHidden = true
            if let downArrow = UIImage.init(named: "expand-arrow") {
                arrowImageView.image = downArrow
            }
        }
    }
    
    /* Configure ownerDetails section in table cell */
    func configureOwnerDetailsView(forCell cellIndex: Int, withOwner owner: Owner) {
        
        ownerNameLbl.text = owner.name
        ownerTypeLbl.text = owner.type
        
        //Format date before setting label.
        let dateformatter =  DateFormatter()
        dateformatter.locale = Locale(identifier: "en_US_POSIX")
        dateformatter.dateFormat  = "yyyy-MM-dd'T'HH:mm:ss.SSSSZZZZZ"
        dateformatter.timeZone = TimeZone(secondsFromGMT: 0)
       
        if let date = dateformatter.date(from: owner.creationDate) {
            dateformatter.dateFormat = "MMM dd,yyyy"
            ownerCreationDateLbl.text = "Created on " + dateformatter.string(from: date)
        } else {
            debugPrint("configureOwnerDetailsView: Unable to format the dame for user:", owner.name)
            ownerCreationDateLbl.text = "Created on " + owner.creationDate
        }
        
        //Set default image to avatar.
        if let defaultImage = UIImage.init(named: "default-"+owner.type) {
            ownerImageView.image = defaultImage
        }
        
        //Show website button if website available.
        websiteBtn.tag = cellIndex
        websiteBtn.isHidden = owner.website != "" ? false : true
    }

    /* Configure repoDetails section in table cell */
    func configureRepoDetailsView(forCell cellIndex: Int, withRepo repo: Repository){
        debugPrint(repo.noOfWatchers ?? 0)
        debugPrint(repo.commits ?? 0)
        debugPrint(repo.downloads ?? 0)
        debugPrint(repo.pullrequests ?? 0)
        
        //Set project name and other detail labels
        projectNameLbl.text = repo.projectName
        downloadsIndicatorLbl.text = "0 Downloads"
        watchersIndicatorLbl.text = "0 Watchers"
        pullReqIndicatorLbl.text = "0 Pull Requests"
        commitsIndicatorLbl.text = "0 Commits"
        
        if let downloadCount = repo.downloads {
            downloadsIndicatorLbl.text = "\(downloadCount) Downloads"
        }
        
        if let commitCount = repo.commits {
            commitsIndicatorLbl.text = "\(commitCount) Commits"
        }
        
        if let pullRequestCount = repo.pullrequests {
            pullReqIndicatorLbl.text = "\(pullRequestCount) Pull Requests"
        }
        
        if let watcherCount = repo.noOfWatchers {
            watchersIndicatorLbl.text = "\(watcherCount) Watchers"
        }
        
        //Set more button tag to row index
        moreBtn.tag = cellIndex
    }
}
