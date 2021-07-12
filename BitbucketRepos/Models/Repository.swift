//
//  Repository.swift
//  BitbucketRepos
//
//  Created by Manisha Deshmukh on 9/7/21.
//

import Foundation

class Repository {
    
    let owner: Owner
    
    var projectName: String
    var projectUrl: String
    var noOfWatchers: Int?
    var pullrequests: Int?
    var commits: Int?
    var downloads: Int?
    
    init(withOwner owner: Owner,projName projectName: String,andProjUrl projectUrl: String) {
        self.owner = owner
        self.projectName = projectName
        self.projectUrl = projectUrl
    }
}

struct Owner {
    let avatar: String
    let name: String
    let type: String
    let website: String
    let creationDate:String
}
