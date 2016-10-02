//
//  User.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-16.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

/// GithubUser represents a Github user.
open class GithubUser {
    /// The user's login name
    open let login: String
    /// The user's id
    open let id: Int32
    open let avatarURL: String
    open let url: String
    open let name: String?
    open let htmlURL: String?
    open let type: String?
    open let followersURL: String?
    open let followingURL: String?
    open let gistsURL: String?
    open let starredURL: String?
    open let subscriptionsURL: String?
    open let organizationsURL: String?
    open let reposURL: String?
    open let eventsURL: String?
    open let receivedEventsURL: String?
    open let siteAdmin: Bool?
    open let company: String?
    open let blog: String?
    open let location: String?
    open let email: String?
    open let hireable: Bool?
    open let bio: String?
    open let publicRepos: Int32?
    open let publicGists: Int32?
    open let followers: Int32?
    open let following: Int32?
    open let createdAt: String?
    open let updatedAt: String?
    
    init(login: String, id: Int32, avatarURL: String, url: String, name: String?, htmlURL: String? = nil, type: String? = nil, followersURL: String? = nil, followingURL: String? = nil, gistsURL: String? = nil, starredURL: String? = nil, subscriptionsURL: String? = nil, organizationsURL: String? = nil, reposURL: String? = nil, eventsURL: String? = nil, receivedEventsURL: String? = nil, siteAdmin: Bool? = nil, company: String? = nil, blog: String? = nil, location: String? = nil, email: String? = nil, hireable: Bool? = nil, bio: String? = nil, publicRepos: Int32? = nil, publicGists: Int32? = nil, followers: Int32? = nil, following: Int32? = nil, createdAt: String? = nil, updatedAt: String? = nil) {
        self.login        = login
        self.id           = id
        self.avatarURL    = avatarURL
        self.url          = url
        self.name         = name
        self.htmlURL      = htmlURL
        self.type         = type
        self.followersURL = followersURL
        self.followingURL = followingURL
        self.gistsURL     = gistsURL
        self.starredURL = starredURL
        self.subscriptionsURL = subscriptionsURL
        self.organizationsURL = organizationsURL
        self.reposURL = reposURL
        self.eventsURL = eventsURL
        self.receivedEventsURL = receivedEventsURL
        self.siteAdmin = siteAdmin
        self.company = company
        self.blog = blog
        self.location = location
        self.email = email
        self.hireable = hireable
        self.bio = bio
        self.publicRepos = publicRepos
        self.publicGists = publicGists
        self.followers = followers
        self.following = following
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension GithubUser: CustomStringConvertible {
    public var description: String {
        var retVal = "{\n"
        retVal += "\tlogin : \(self.login)\n"
        retVal += "\tid    : \(self.id)\n"
        retVal += "\tavatarURL : \(self.avatarURL)\n"
        retVal += "\turl   : \(self.url)\n"
        retVal += "\tname  : \(self.name ?? "")\n"
        retVal += "\thtmlURL: \(self.htmlURL ?? "")\n"
        retVal += "\ttype   : \(self.type ?? "")\n"
        retVal += "\tfollowersURL : \(self.followersURL ?? "")\n"
        retVal += "\tfollowingURL : \(self.followingURL ?? "")\n"
        retVal += "\tgistsURL : \(self.gistsURL ?? "")\n"
        retVal += "\tstarredURL : \(self.starredURL ?? "")\n"
        retVal += "\tsubscriptionsURL : \(self.subscriptionsURL ?? "")\n"
        retVal += "\torganizationsURL : \(self.organizationsURL ?? "")\n"
        retVal += "\treposURL : \(self.reposURL ?? "")\n"
        retVal += "\teventsURL : \(self.eventsURL ?? "")\n"
        retVal += "\treceivedEventsURL : \(self.receivedEventsURL ?? "")\n"
        retVal += "\tsiteAdmin : \(self.siteAdmin ?? false)\n"
        retVal += "\tcompany : \(self.company ?? "")\n"
        retVal += "\tblog : \(self.blog ?? "")\n"
        retVal += "\tlocation : \(self.location ?? "")\n"
        retVal += "\temail : \(self.email ?? "")\n"
        retVal += "\thireable : \(self.hireable ?? false)\n"
        retVal += "\tbio : \(self.bio ?? "")\n"
        retVal += "\tpublicRepos : \(self.publicRepos ?? -1)\n"
        retVal += "\tpublicGists : \(self.publicGists ?? -1)\n"
        retVal += "\tfollowers : \(self.followers ?? -1)\n"
        retVal += "\tfollowing : \(self.following ?? -1)\n"
        retVal += "\tcreatedAt : \(self.createdAt ?? "")\n"
        retVal += "\tupdatedAt : \(self.updatedAt ?? "")\n"
        retVal += "}"
        return retVal
    }
}

/// GithubUserSerializer
open class GithubUserSerializer: JSONSerializer {
    public init() {}
    open func serialize(_ value: GithubUser) -> JSON {
        let retVal = [
            "login": Serialization._StringSerializer.serialize(value.login),
            "id": Serialization._Int32Serializer.serialize(value.id),
            "avatar_url": Serialization._StringSerializer.serialize(value.avatarURL),
            "url": Serialization._StringSerializer.serialize(value.url),
            "name": NullableSerializer(Serialization._StringSerializer).serialize(value.name),
            "html_url": NullableSerializer(Serialization._StringSerializer).serialize(value.htmlURL),
            "type": NullableSerializer(Serialization._StringSerializer).serialize(value.type),
            "followers_url": NullableSerializer(Serialization._StringSerializer).serialize(value.followersURL),
            "following_url": NullableSerializer(Serialization._StringSerializer).serialize(value.followingURL),
            "gists_url": NullableSerializer(Serialization._StringSerializer).serialize(value.gistsURL),
            "starred_url": NullableSerializer(Serialization._StringSerializer).serialize(value.starredURL),
            "subscriptions_url": NullableSerializer(Serialization._StringSerializer).serialize(value.subscriptionsURL),
            "organizations_url": NullableSerializer(Serialization._StringSerializer).serialize(value.organizationsURL),
            "repos_url": NullableSerializer(Serialization._StringSerializer).serialize(value.reposURL),
            "events_url": NullableSerializer(Serialization._StringSerializer).serialize(value.eventsURL),
            "received_events_url": NullableSerializer(Serialization._StringSerializer).serialize(value.receivedEventsURL),
            "site_admin": NullableSerializer(Serialization._BoolSerializer).serialize(value.siteAdmin),
            "company": NullableSerializer(Serialization._StringSerializer).serialize(value.company),
            "blog": NullableSerializer(Serialization._StringSerializer).serialize(value.blog),
            "location": NullableSerializer(Serialization._StringSerializer).serialize(value.location),
            "email": NullableSerializer(Serialization._StringSerializer).serialize(value.email),
            "hireable": NullableSerializer(Serialization._BoolSerializer).serialize(value.hireable),
            "bio": NullableSerializer(Serialization._StringSerializer).serialize(value.bio),
            "public_repos": NullableSerializer(Serialization._Int32Serializer).serialize(value.publicRepos),
            "public_gists": NullableSerializer(Serialization._Int32Serializer).serialize(value.publicGists),
            "followers": NullableSerializer(Serialization._Int32Serializer).serialize(value.followers),
            "following": NullableSerializer(Serialization._Int32Serializer).serialize(value.following),
            "created_at": NullableSerializer(Serialization._StringSerializer).serialize(value.createdAt),
            "updated_at": NullableSerializer(Serialization._StringSerializer).serialize(value.updatedAt)
        ]
        return .dictionary(retVal)
    }
    
    open func deserialize(_ json: JSON) -> GithubUser {
        switch json {
            case .dictionary(let dict):
                let login = Serialization._StringSerializer.deserialize(dict["login"] ?? .null)
                let id = Serialization._Int32Serializer.deserialize(dict["id"] ?? .null)
                let avatarURL = Serialization._StringSerializer.deserialize(dict["avatar_url"] ?? .null)
                let url = Serialization._StringSerializer.deserialize(dict["url"] ?? .null)
                let name = NullableSerializer(Serialization._StringSerializer).deserialize(dict["name"] ?? .null)
                let htmlURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["html_url"] ?? .null)
                let type = NullableSerializer(Serialization._StringSerializer).deserialize(dict["type"] ?? .null)
                let followersURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["followers_url"] ?? .null)
                let followingURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["following_url"] ?? .null)
                let gistsURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["gists_url"] ?? .null)
                let starredURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["starred_url"] ?? .null)
                let subscriptionsURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["subscriptions_url"] ?? .null)
                let organizationsURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["organizations_url"] ?? .null)
                let reposURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["repos_url"] ?? .null)
                let eventsURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["events_url"] ?? .null)
                let receivedEventsURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["received_events_url"] ?? .null)
                let siteAdmin = NullableSerializer(Serialization._BoolSerializer).deserialize(dict["site_admin"] ?? .null)
                let company = NullableSerializer(Serialization._StringSerializer).deserialize(dict["company"] ?? .null)
                let blog = NullableSerializer(Serialization._StringSerializer).deserialize(dict["blog"] ?? .null)
                let location = NullableSerializer(Serialization._StringSerializer).deserialize(dict["location"] ?? .null)
                let email = NullableSerializer(Serialization._StringSerializer).deserialize(dict["email"] ?? .null)
                let hireable = NullableSerializer(Serialization._BoolSerializer).deserialize(dict["hireable"] ?? .null)
                let bio = NullableSerializer(Serialization._StringSerializer).deserialize(dict["bio"] ?? .null)
                let publicRepos = NullableSerializer(Serialization._Int32Serializer).deserialize(dict["public_repos"] ?? .null)
                let publicGists = NullableSerializer(Serialization._Int32Serializer).deserialize(dict["public_gists"] ?? .null)
                let followers = NullableSerializer(Serialization._Int32Serializer).deserialize(dict["followers"] ?? .null)
                let following = NullableSerializer(Serialization._Int32Serializer).deserialize(dict["following"] ?? .null)
                let createdAt = NullableSerializer(Serialization._StringSerializer).deserialize(dict["created_at"] ?? .null)
                let updatedAt = NullableSerializer(Serialization._StringSerializer).deserialize(dict["updated_at"] ?? .null)
                return GithubUser(login: login, id: id, avatarURL: avatarURL, url: url, name: name, htmlURL: htmlURL, type: type, followersURL: followersURL, followingURL: followingURL, gistsURL: gistsURL, starredURL: starredURL, subscriptionsURL: subscriptionsURL, organizationsURL: organizationsURL, reposURL: reposURL, eventsURL: eventsURL, receivedEventsURL: receivedEventsURL, siteAdmin: siteAdmin, company: company, blog: blog, location: location, email: email, hireable: hireable, bio: bio, publicRepos: publicRepos, publicGists: publicGists, followers: followers, following: following, createdAt: createdAt, updatedAt: updatedAt)
            default:
                fatalError("JSON Type Error")
        }
    }
}

/// UserArraySerializer
open class UserArraySerializer: JSONSerializer {
    let userSerializer: GithubUserSerializer
    init() {
        self.userSerializer = GithubUserSerializer()
    }
    
    /**
     [GithubUser] -> JSON
     */
    open func serialize(_ value: [GithubUser]) -> JSON {
        let users = value.map { self.userSerializer.serialize($0) }
        return .array(users)
    }
    
    /**
     JSON -> [GithubUser]
     */
    open func deserialize(_ json: JSON) -> [GithubUser] {
        switch json {
        case .array(let users):
            return users.map { self.userSerializer.deserialize($0) }
        default:
            fatalError("JSON Type should be array")
        }
    }
}
