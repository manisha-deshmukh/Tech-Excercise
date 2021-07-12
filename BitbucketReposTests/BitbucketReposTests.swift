//
//  BitbucketReposTests.swift
//  BitbucketReposTests
//
//  Created by Manisha Deshmukh on 8/7/21.
//

import XCTest
@testable import BitbucketRepos

class BitbucketReposTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testREpositoryRequest() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var repositories: [Repository]?
        
        let expection = self.expectation(description: "loading repos")
        
        RepoService().requestRepositories("https://api.bitbucket.org/2.0/repositories") { (repositoryList, nextUrl) in
            
            guard let _ = repositoryList else {
                expection.fulfill()
                return
            }
            repositories = repositoryList!
            expection.fulfill()
        }
        wait(for: [expection], timeout: 3)
        XCTAssertNotNil(repositories)
        XCTAssertTrue(repositories!.count > 0, "Repositories not present")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
