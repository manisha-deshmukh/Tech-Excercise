//
//  Webservices.swift
//  BitbucketRepos
//
//  Created by Manisha Deshmukh on 9/7/21.
//

import Foundation
import Alamofire
import SwiftyJSON

class RepoService {
    
    /*Fetch no of watchers, pull requests, commits and downloads count for each repo*/
    fileprivate func genericRequest(_ requestUrl: String, onCompletion: @escaping (Int)-> Void){
        
        AF.request(requestUrl).responseJSON { (response) in
            //print(response)
            guard let _ = response.value, let responseData = response.data else {
                print("error: ", response.error.debugDescription)
                onCompletion(0)
                return
            }
            
            if let jsonData = try? JSON.init(data: responseData) {
                
                if let values = jsonData["values"].array {
                    onCompletion(values.count)
                }
            }
        }
    }
    
    /*Download images and save in Cache for future use*/
    func downloadImage(_ requestUrl: String, imageCache:NSCache<NSURL, UIImage>?, onCompletion: @escaping (UIImage)-> Void) {
        
        if let imageUrl = NSURL.init(string: requestUrl), let image = imageCache?.object(forKey: imageUrl) {
            debugPrint("downloadImage: No need to convert: using alredy present one")
            onCompletion(image)
        }else{
            AF.download(requestUrl).responseData { [imageCache](responseData) in
                guard let imageData = responseData.value else {
                    debugPrint("downloadImage: error: ", responseData.error.debugDescription)
                    return
                }
                if let imageUrl = NSURL.init(string: requestUrl),  let downloadedImage = UIImage(data:imageData) {
                    imageCache?.setObject(downloadedImage, forKey: imageUrl)
                    onCompletion(downloadedImage)
                }else{
                    debugPrint("downloadImage: Error while converting image")
                }
            }
        }
    }
    
    /*Fetch repo details and next url for repositories*/
    func requestRepositories(_ requestUrl: String, onCompletion: @escaping ([Repository]?, String)-> Void)  {
        
        var repositoryDetails: [Repository] = []
        AF.request(requestUrl).responseJSON(completionHandler: { (response) in
            debugPrint("requestRepositories: ", response)
            guard let _ = response.value, let responseData = response.data else {
                debugPrint("requestRepositories: error: ", response.error.debugDescription)
                onCompletion(nil, "")
                return
            }
            
            if let jsonData = try? JSON.init(data: responseData) {
                
                print("json : ", jsonData["values"])
                
                //Extract Owner details
                if let repoDetails = jsonData["values"].array {
                    for repo in repoDetails {
                        var repository: Repository
                        if let watcherUrl = repo["links"]["watchers"]["href"].string,
                           let downloadsUrl = repo["links"]["downloads"]["href"].string,
                           let commitsUrl = repo["links"]["commits"]["href"].string,
                           let pullRequestsUrl = repo["links"]["pullrequests"]["href"].string,
                           let projectUrl = repo["links"]["html"]["href"].string,
                           let projectName = repo["name"].string {
                            
                            if let displayName = repo["owner"]["display_name"].string,
                               let type = repo["owner"]["type"].string,
                               let avatar = repo["owner"]["links"]["avatar"]["href"].string,
                               let website = repo["website"].string,
                               let updatedDate = repo["created_on"].string {
                                
                                //Create owner
                               let owner = Owner(avatar: avatar, name: displayName, type: type, website: website, creationDate: updatedDate)
                                
                                //Create repository and asynchronously download other parameters.
                                repository = Repository.init(withOwner: owner, projName: projectName, andProjUrl: projectUrl)
                                let repoService = RepoService()
                                repoService.genericRequest(watcherUrl) { [weak repository] (count) in
                                    repository?.noOfWatchers = count
                                }
                                repoService.genericRequest(downloadsUrl) { [weak repository] (count) in
                                    repository?.downloads = count
                                }
                                repoService.genericRequest(commitsUrl) { [weak repository] (count) in
                                    repository?.commits = count
                                }
                                repoService.genericRequest(pullRequestsUrl) { [weak repository] (count) in
                                    repository?.pullrequests = count
                                }
                                repositoryDetails.append(repository)
                            }
                        }
                    }
                }
                
                //Extract next url
                var nextUrl = ""
                if let nextUrlString = jsonData["next"].string {
                    nextUrl = nextUrlString
                }
                onCompletion(repositoryDetails, nextUrl)
            }
        })
    }
}
