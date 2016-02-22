//
//  GithubRepo.swift
//  Pods
//
//  Created by yansong li on 2016-02-21.
//
//

import Foundation

/**
 SortType, **Default**: FullName
 */
public enum RepoSortType: String {
    case Created = "created"
    case Updated = "updated"
    case Pushed = "pushed"
    case FullName = "full_name"
}

/**
 SortDirectionType, **Default**: when using full_name: `Asc`; otherwise `Desc`
 */
public enum RepoSortDirection: String {
    case Asc = "asc"
    case Desc = "desc"
}

/**
 RepoType, **Default**: All
 */
public enum RepoType: String {
    case All = "all"
    case Owner = "owner"
    case Public = "public"
    case Private = "private"
    case member = "Member"
}


/// GithubRepo represents a Github Repo
public class GithubRepo {
    public let id: Int32
    public let owner: GithubUser?
    public let name: String?
    public let fullName: String?
    public let description: String?
    public let isPrivate: Bool?
    public let isFork: Bool?
    public let url: String?
    public let htmlURL: String?
    public let cloneURL: String?
    public let collaboratorsURL: String?
    public let commentsURL: String?
    public let homepage: String?
    public let language: String?
    public let stargazersURL: String?
    public let forksCount: Int32?
    public let stargazersCount: Int32?
    public let watchersCount: Int32?
    public let createdAt: String?
    public let updatedAt: String?
    
    init(id: Int32, owner: GithubUser? = nil, name: String? = nil, fullName: String? = nil, description: String? = nil, isPrivate: Bool? = nil, isFork: Bool? = nil, url: String? = nil, htmlURL: String? = nil, cloneURL: String? = nil, collaboratorsURL: String? = nil, commentsURL: String? = nil, homepage: String? = nil, language: String? = nil, forksCount: Int32? = nil, stargazersCount: Int32? = nil, watchersCount: Int32? = nil, createdAt: String? = nil, updatedAt: String? = nil, stargazersURL: String? = nil) {
        self.id = id
        self.owner = owner
        self.name = name
        self.fullName = fullName
        self.description = description
        self.isPrivate = isPrivate
        self.isFork = isFork
        self.url = url
        self.htmlURL = htmlURL
        self.cloneURL = cloneURL
        self.collaboratorsURL = collaboratorsURL
        self.commentsURL = commentsURL
        self.homepage = homepage
        self.language = language
        self.stargazersURL = stargazersURL
        self.forksCount = forksCount
        self.stargazersCount = stargazersCount
        self.watchersCount = watchersCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public class RepoSerializer: JSONSerializer {
    let userSerializer: GithubUserSerializer
    public init() {
        self.userSerializer = GithubUserSerializer()
    }
    public func serialize(value: GithubRepo) -> JSON {
        let retVal = [
            "id": Serialization._Int32Serializer.serialize(value.id),
            "owner": NullableSerializer(self.userSerializer).serialize(value.owner),
            "name": NullableSerializer(Serialization._StringSerializer).serialize(value.name),
            "full_name": NullableSerializer(Serialization._StringSerializer).serialize(value.fullName),
            "description": NullableSerializer(Serialization._StringSerializer).serialize(value.description),
            "private": NullableSerializer(Serialization._BoolSerializer).serialize(value.isPrivate),
            "fork": NullableSerializer(Serialization._BoolSerializer).serialize(value.isFork),
            "url": NullableSerializer(Serialization._StringSerializer).serialize(value.url),
            "html_url": NullableSerializer(Serialization._StringSerializer).serialize(value.htmlURL),
            "clone_url": NullableSerializer(Serialization._StringSerializer).serialize(value.cloneURL),
            "collaborators_url": NullableSerializer(Serialization._StringSerializer).serialize(value.collaboratorsURL),
            "comments_url": NullableSerializer(Serialization._StringSerializer).serialize(value.commentsURL),
            "homepage": NullableSerializer(Serialization._StringSerializer).serialize(value.homepage),
            "language": NullableSerializer(Serialization._StringSerializer).serialize(value.language),
            "forks_count": NullableSerializer(Serialization._Int32Serializer).serialize(value.forksCount),
            "stargazers_count": NullableSerializer(Serialization._Int32Serializer).serialize(value.stargazersCount),
            "watchers_count": NullableSerializer(Serialization._Int32Serializer).serialize(value.watchersCount),
            "created_at": NullableSerializer(Serialization._StringSerializer).serialize(value.createdAt),
            "updated_at": NullableSerializer(Serialization._StringSerializer).serialize(value.updatedAt),
            "stargazers_url": NullableSerializer(Serialization._StringSerializer).serialize(value.stargazersURL)
        ]
        return .Dictionary(retVal)
    }
    
    public func deserialize(json: JSON) -> GithubRepo {
        switch json {
            case .Dictionary(let dict):
                let id = Serialization._Int32Serializer.deserialize(dict["id"] ?? .Null)
                let owner = NullableSerializer(self.userSerializer).deserialize(dict["owner"] ?? .Null)
                let name = NullableSerializer(Serialization._StringSerializer).deserialize(dict["name"] ?? .Null)
                let fullName = NullableSerializer(Serialization._StringSerializer).deserialize(dict["full_name"] ?? .Null)
                let description = NullableSerializer(Serialization._StringSerializer).deserialize(dict["description"] ?? .Null)
                let isPrivate = NullableSerializer(Serialization._BoolSerializer).deserialize(dict["private"] ?? .Null)
                let isFork = NullableSerializer(Serialization._BoolSerializer).deserialize(dict["fork"] ?? .Null)
                let url = NullableSerializer(Serialization._StringSerializer).deserialize(dict["url"] ?? .Null)
                let htmlURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["html_url"] ?? .Null)
                let cloneURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["clone_url"] ?? .Null)
                let collaboratorsURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["collaborators_url"] ?? .Null)
                let commentsURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["comments_url"] ?? .Null)
                let homePage = NullableSerializer(Serialization._StringSerializer).deserialize(dict["homepage"] ?? .Null)
                let language = NullableSerializer(Serialization._StringSerializer).deserialize(dict["language"] ?? .Null)
                let forskCount = NullableSerializer(Serialization._Int32Serializer).deserialize(dict["forks_count"] ?? .Null)
                let stargazersCount = NullableSerializer(Serialization._Int32Serializer).deserialize(dict["stargazers_count"] ?? .Null)
                let watchersCount = NullableSerializer(Serialization._Int32Serializer).deserialize(dict["watchers_count"] ?? .Null)
                let createdAt = NullableSerializer(Serialization._StringSerializer).deserialize(dict["created_at"] ?? .Null)
                let updatedAt = NullableSerializer(Serialization._StringSerializer).deserialize(dict["updated_at"] ?? .Null)
                let stargazersURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["stargazers_url"] ?? .Null)
                return GithubRepo(id: id, owner: owner, name: name, fullName: fullName, description: description, isPrivate: isPrivate, isFork: isFork, url: url, htmlURL: htmlURL, cloneURL: cloneURL, collaboratorsURL: collaboratorsURL, commentsURL: commentsURL, homepage: homePage, language: language, forksCount: forskCount, stargazersCount: stargazersCount, watchersCount: watchersCount, createdAt: createdAt, updatedAt: updatedAt, stargazersURL: stargazersURL)
            default:
                fatalError("GitHub Repo JSON Type Error")
        }
    }
}

public class RepoArraySerializer: JSONSerializer {
    let repoSerializer: RepoSerializer
    init() {
        self.repoSerializer = RepoSerializer()
    }
    
    public func serialize(value: [GithubRepo]) -> JSON {
        let users = value.map { self.repoSerializer.serialize($0) }
        return .Array(users)
    }
    
    public func deserialize(json: JSON) -> [GithubRepo] {
        switch json {
        case .Array(let users):
            return users.map { self.repoSerializer.deserialize($0) }
        default:
            fatalError("JSON Type should be array")
        }
    }
}

