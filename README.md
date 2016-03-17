# GithubPilot - Github API V3 Swifty Wrapper
[![Build Status](https://travis-ci.org/jindulys/GithubPilot.svg)](https://travis-ci.org/jindulys/GithubPilot)

This is a Swift Github API Wrapper, it could make your life a little easier if you want to make an App with Github's wonderful data.

# Installation

## CocoaPods

Add a `Podfile` to your project, then edit it by adding:

    use_frameworks!
    pod 'GithubPilot', '~>1.0.3'

then, run the following command:

    $ pod install

From now on you should use `{Project}.xcworkspace` to open your project

# Before You start

## Setup Your developer applications

Go to your Github homepage, tap your avatar -> Setting, on your left choose **Applications** -> **Developer applications**, then you should tap **register a new OAuth application** on your top right side.

Remember you should use a custom **Authorization callback URL**, which will be used later, eg. FunnyGithubTest://random
After registration, you could get your **Client ID** and **Client Secret**.

## Setup Your Project

To allow your user to be re-directed back to your app after OAuth dance, you'll need to associate a custom URL scheme with your app.

Open your Xcode then open **Info.plist** of your project. copy and paste following code to your Info.plist source code.

      <key>CFBundleURLTypes</key>
      <array>
          <dict>
              <key>CFBundleURLSchemes</key>
              <array>
                  <string>your.custom.scheme(eg. FunnyGithubTest)</string>
              </array>
          <dict>
      <array>

# Usage

## Authentication
First, add `import GithubPilot` at the top of your **AppDelegate**. You could then add `application(_: didFinishLaunchingWithOptions:)` with following to authenticate your client. You also should take care of `scope` parameter that your client will use, refer to [Github Scope](https://developer.github.com/v3/oauth/#scopes)

    Github.setupClientID("YourClientID", clientSecret: "YourClientSecret", scope: ["user", "repo"], redirectURI: "YourCustomCallBackURL")
    Github.authenticate()

Second, add following code to your **AppDelegate** to get Github _**access token**_

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool 
    {
        Github.requestAccessToken(url)
        return true
    }

## Used in Code

### Users

#### Get the authenticated user

    if let client = Github.authorizedClient {
            client.users.getAuthenticatedUser().response({ user, requestError in
                if let me = user {
                    print(me.description)
                } else {
                    print(requestError?.description)
                }
            })
    }
#### Get a user with username

    if let client = Github.authorizedClient {
            client.users.getUser(username: "onevcat").response({ (githubUser, error) -> Void in
                if let user = githubUser {
                    print(user.description)
                } else {
                    print(error?.description)
                }
            })
    }

#### Get a page of users from `since` id

    if let client = Github.authorizedClient {
            client.users.getAllUsers("1209").response({ (httpResponse, users, requestError) -> Void in
                if let response = httpResponse {
                    // next `since` id
                    print("Since   :\(response)")
                }
                if let result = users {
                    for user in result {
                        print(user.description)
                    }
                } else {
                    print(requestError?.description)
                }
            })
    }
    
### Repositories

#### Get repositories of authenticated user

    if let client = Github.authorizedClient {
            client.repos.getAuthenticatedUserRepos().response({ (result, error) -> Void in
                if let repos = result {
                    print(repos.count)
                    for i in repos {
                        print(i.name)
                        print(i.stargazersCount)
                    }
                }
                if let requestError = error {
                    print(requestError.description)
                }
            })
    }
    
#### Get a repo by repo name and repo owner name

    if let client = Github.authorizedClient {
            client.repos.getRepo("Yep", owner: "CatchChat").response({ (result, error) -> Void in
                if let repo = result {
                    print(repo.name)
                }
                if let requestError = error {
                    print(requestError.description)
                }
            })
    }

#### Get repos belong to a user

    if let client = Github.authorizedClient {
        client.repos.getRepoFrom(owner: "onevcat").response({ (nextPage, result, error) -> Void in
            if let page = nextPage {
                print("Next Page is \(page)")
            }
            if let repos = result {
                print(repos.count)
                for r in repos {
                    print(r.name)
                    print(r.stargazersCount)
                }
            }
            if let requestError = error {
                print(requestError.description)
            }
        })
    }
    
### Events

#### Get received events for a user

    if let client = Github.authorizedClient {
        client.events.getReceivedEventsForUser("someUser", page: "1").response({ (nextpage, results, error) -> Void in
            if let events = results {
                // New events
            }
        })
    }

# Example 

You could refer to one of my project [GitPocket](https://github.com/jindulys/GitPocket) as an example.

# Thanks

[SwiftyDropbox](https://github.com/dropbox/SwiftyDropbox)

# Future Work

There all tons of other API I haven't implementated, like **Search**. I will continuously make this repo better. Welcome to pull request and open issues.
