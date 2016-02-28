//
//  StarsRoutes.swift
//  Pods
//
//  Created by yansong li on 2016-02-22.
//
//

import Foundation

public class StarsRoutes {
    public unowned let client: GithubNetWorkClient
    // This queue is used for some long time task to stay around, espicially pagination operation.
    let longTimeWaitQueue: dispatch_queue_t
    
    init(client: GithubNetWorkClient) {
        self.client = client
        self.longTimeWaitQueue = dispatch_queue_create("com.githubpilot.stargazersRoutes.waitingQueue", DISPATCH_QUEUE_SERIAL)
    }
    
    /**
     Users that stars a repo belongs to a user.
     
     - parameter repo: repo name
     - parameter name: owner
     - parameter page: when user has a lot of repos, pagination will be applied.
     
     - returns: an RpcRequest, whose response result contains `[GithubUser]`, if pagination is applicable, response result contains `nextpage`.
     */
    public func getStargazersFor(repo repo: String, owner: String, page: String = "1", defaultResponseQueue: dispatch_queue_t? = nil) -> RpcCustomResponseRequest<UserArraySerializer, StringSerializer, String> {
        precondition((repo.characters.count != 0 && owner.characters.count != 0), "Invalid Input")
        
        let httpResponseHandler:((NSHTTPURLResponse?)->String?)? = { (response: NSHTTPURLResponse?) in
            if let nonNilResponse = response,
                link = (nonNilResponse.allHeaderFields["Link"] as? String),
                sinceRange = link.rangeOfString("page=") {
                    var retVal = ""
                    var checkIndex = sinceRange.endIndex
                    
                    while checkIndex != link.endIndex {
                        let character = link.characters[checkIndex]
                        let characterInt = character.zeroCharacterBasedunicodeScalarCodePoint()
                        if characterInt>=0 && characterInt<=9 {
                            retVal += String(character)
                        } else {
                            break
                        }
                        checkIndex = checkIndex.successor()
                    }
                    return retVal
            }
            return nil
        }
        
        return RpcCustomResponseRequest(client: self.client, host: "api", route: "/repos/\(owner)/\(repo)/stargazers", method: .GET, params: ["page":page], postParams: nil, postData: nil,customResponseHandler:httpResponseHandler, defaultResponseQueue: defaultResponseQueue, responseSerializer: UserArraySerializer(), errorSerializer: StringSerializer())
    }
    
    /**
     Get all the stargazers belong to a owner's repo.
     
     - note: This request is time consuming if this repo is a quite popular one. but it will run on a private serial queue and will not block main queue.
     
     - parameter repo:              repo's name.
     - parameter owner:             owner's name.
     - parameter complitionHandler: callback that call on main thread.
     */
    private func getAllStargazersOldFor(repo repo: String, owner: String, complitionHandler:([GithubUser]?, String?)-> Void) {
        dispatch_async(self.longTimeWaitQueue) { () -> Void in
            let privateQueue = dispatch_queue_create("com.githubpilot.stargazersRoutes.responseQueue", DISPATCH_QUEUE_SERIAL)
            var retVal: [GithubUser] = []
            var retError: String?
            let semaphore = dispatch_semaphore_create(0)
            var recursiveStargazers: (String, String, String, dispatch_queue_t?) -> Void = {_, _, _, _ in }
            recursiveStargazers = {
                repo, owner, page, queue in
                self.getStargazersFor(repo: repo, owner: owner, page: page, defaultResponseQueue: queue).response {
                    (nextPage, result, error) -> Void in
                    if let error = error {
                        retError = error.description
                        dispatch_semaphore_signal(semaphore)
                    }
                    
                    if let users = result {
                        retVal.appendContentsOf(users)
                    }
                    
                    if let vpage = nextPage {
                        if vpage == "1" {
                            dispatch_semaphore_signal(semaphore)
                        } else {
                            recursiveStargazers(repo, owner, vpage, queue)
                        }
                    }
                }
            }
            
            recursiveStargazers(repo, owner, "1", privateQueue)
            let timeoutTime = dispatch_time(DISPATCH_TIME_NOW, Int64(100 * NSEC_PER_SEC))
            if dispatch_semaphore_wait(semaphore, timeoutTime) != 0 {
                retError = Constants.ErrorInfo.GithubRequestOverTime
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                complitionHandler(retVal, retError)
            })
        }
    }
    
    /**
     Get all the stargazers belong to a owner's repo.
     
     - note: This request is time consuming if this repo is a quite popular one. but it will run on a private serial queue and will not block main queue.
     
     - parameter repo:              repo's name.
     - parameter owner:             owner's name.
     - parameter complitionHandler: callback that call on main thread.
     */
    public func getAllStargazersFor(repo repo: String, owner: String, complitionHandler:([GithubUser]?, String?)-> Void) {
        var recursiveStargazers: (String, String, String) -> Void = {_, _, _ in }
        var retVal: [GithubUser] = []
        recursiveStargazers = {
            repo, owner, page in
            self.getStargazersFor(repo: repo, owner: owner, page: page).response {
                (nextPage, result, error) -> Void in
                guard let users = result, vpage = nextPage else {
                    complitionHandler(nil, error?.description ?? "Error,Could not finish this request")
                    return
                }

                retVal.appendContentsOf(users)
                if vpage == "1" {
                    complitionHandler(retVal, nil)
                } else {
                    recursiveStargazers(repo, owner, vpage)
                }
            }
        }
        
        recursiveStargazers(repo, owner, "1")
    }
}