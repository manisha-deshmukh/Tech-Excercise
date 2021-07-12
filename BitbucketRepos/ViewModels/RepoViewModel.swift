//
//  RepoViewModel.swift
//  BitbucketRepos
//
//  Created by Manisha Deshmukh on 12/7/21.
//

import Foundation
import RxSwift
import RxCocoa

class RepoViewModel {
    
    //Represents tableView and 'next' button
    public let repoDetails: BehaviorRelay<[Repository]> = BehaviorRelay.init(value: [])
    public let nextUrl: BehaviorRelay<String> = BehaviorRelay.init(value: "https://api.bitbucket.org/2.0/repositories")
    
    private let disposeBag = DisposeBag()
    
    /*Send request to fetch the repo details*/
    public func requestRepoDetails() {
        
        RepoService().requestRepositories(nextUrl.value){ [weak self] (response, nextUrlString) in
            
            //Check reponse
            guard let repoDetails = response else {
                return
            }
            
            //Update values of nextUrl and repoDetails
            if nextUrlString != self?.nextUrl.value && nextUrlString != "" {
                self?.nextUrl.accept(nextUrlString)
            }
            self?.repoDetails.accept(repoDetails)
        }
    }
}
