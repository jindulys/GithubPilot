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
open class GithubRepo {
    open let id: Int32
    open let owner: GithubUser?
    open let name: String?
    open let fullName: String?
    open let descriptions: String?
    open let isPrivate: Bool?
    open let isFork: Bool?
    open let url: String?
    open let htmlURL: String?
    open let cloneURL: String?
    open let collaboratorsURL: String?
    open let commentsURL: String?
    open let homepage: String?
    open let language: String?
    open let stargazersURL: String?
    open let forksCount: Int32?
    open let stargazersCount: Int32?
    open let watchersCount: Int32?
    open let createdAt: String?
    open let updatedAt: String?
    
    init(id: Int32, owner: GithubUser? = nil, name: String? = nil, fullName: String? = nil, descriptions: String? = nil, isPrivate: Bool? = nil, isFork: Bool? = nil, url: String? = nil, htmlURL: String? = nil, cloneURL: String? = nil, collaboratorsURL: String? = nil, commentsURL: String? = nil, homepage: String? = nil, language: String? = nil, forksCount: Int32? = nil, stargazersCount: Int32? = nil, watchersCount: Int32? = nil, createdAt: String? = nil, updatedAt: String? = nil, stargazersURL: String? = nil) {
        self.id = id
        self.owner = owner
        self.name = name
        self.fullName = fullName
        self.descriptions = descriptions
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

extension GithubRepo: CustomStringConvertible {
    public var description: String {
        var retVal = "{\n"
        retVal += "\tname   : \(self.name ?? "")\n"
        retVal += "\tid     : \(self.id)\n"
        retVal += "\tfullName   : \(self.fullName ?? "")\n"
        retVal += "\tdescription    : \(self.descriptions ?? "")\n"
        retVal += "\towner      : \(self.owner?.description ?? "")\n"
        retVal += "\tstars  : \(self.stargazersCount ?? -1)\n"
        retVal += "\tlanguage   : \(self.language ?? "")\n"
        retVal += "\tforks  : \(self.forksCount ?? -1)\n"
        return retVal
    }
}

/// RepoSerializer
open class RepoSerializer: JSONSerializer {
    let userSerializer: GithubUserSerializer
    
    public init() {
        self.userSerializer = GithubUserSerializer()
    }
    
    /**
     GithubRepo -> JSON
     */
    open func serialize(_ value: GithubRepo) -> JSON {
        let retVal = [
            "id": Serialization._Int32Serializer.serialize(value.id),
            "owner": NullableSerializer(self.userSerializer).serialize(value.owner),
            "name": NullableSerializer(Serialization._StringSerializer).serialize(value.name),
            "full_name": NullableSerializer(Serialization._StringSerializer).serialize(value.fullName),
            "description": NullableSerializer(Serialization._StringSerializer).serialize(value.descriptions),
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
        return .dictionary(retVal)
    }
    
    /**
     JSON -> GithubRepo
     */
    open func deserialize(_ json: JSON) -> GithubRepo {
        switch json {
            case .dictionary(let dict):
                let id = Serialization._Int32Serializer.deserialize(dict["id"] ?? .null)
                let owner = NullableSerializer(self.userSerializer).deserialize(dict["owner"] ?? .null)
                let name = NullableSerializer(Serialization._StringSerializer).deserialize(dict["name"] ?? .null)
                let fullName = NullableSerializer(Serialization._StringSerializer).deserialize(dict["full_name"] ?? .null)
                let description = NullableSerializer(Serialization._StringSerializer).deserialize(dict["description"] ?? .null)
                let isPrivate = NullableSerializer(Serialization._BoolSerializer).deserialize(dict["private"] ?? .null)
                let isFork = NullableSerializer(Serialization._BoolSerializer).deserialize(dict["fork"] ?? .null)
                let url = NullableSerializer(Serialization._StringSerializer).deserialize(dict["url"] ?? .null)
                let htmlURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["html_url"] ?? .null)
                let cloneURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["clone_url"] ?? .null)
                let collaboratorsURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["collaborators_url"] ?? .null)
                let commentsURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["comments_url"] ?? .null)
                let homePage = NullableSerializer(Serialization._StringSerializer).deserialize(dict["homepage"] ?? .null)
                let language = NullableSerializer(Serialization._StringSerializer).deserialize(dict["language"] ?? .null)
                let forskCount = NullableSerializer(Serialization._Int32Serializer).deserialize(dict["forks_count"] ?? .null)
                let stargazersCount = NullableSerializer(Serialization._Int32Serializer).deserialize(dict["stargazers_count"] ?? .null)
                let watchersCount = NullableSerializer(Serialization._Int32Serializer).deserialize(dict["watchers_count"] ?? .null)
                let createdAt = NullableSerializer(Serialization._StringSerializer).deserialize(dict["created_at"] ?? .null)
                let updatedAt = NullableSerializer(Serialization._StringSerializer).deserialize(dict["updated_at"] ?? .null)
                let stargazersURL = NullableSerializer(Serialization._StringSerializer).deserialize(dict["stargazers_url"] ?? .null)
                return GithubRepo(id: id, owner: owner, name: name, fullName: fullName, descriptions: description, isPrivate: isPrivate, isFork: isFork, url: url, htmlURL: htmlURL, cloneURL: cloneURL, collaboratorsURL: collaboratorsURL, commentsURL: commentsURL, homepage: homePage, language: language, forksCount: forskCount, stargazersCount: stargazersCount, watchersCount: watchersCount, createdAt: createdAt, updatedAt: updatedAt, stargazersURL: stargazersURL)
            default:
                fatalError("GitHub Repo JSON Type Error")
        }
    }
}

/// RepoArraySerializer
open class RepoArraySerializer: JSONSerializer {
    let repoSerializer: RepoSerializer
    init() {
        self.repoSerializer = RepoSerializer()
    }
    
    /**
     [GithubRepo] -> JSON
     */
    open func serialize(_ value: [GithubRepo]) -> JSON {
        let users = value.map { self.repoSerializer.serialize($0) }
        return .array(users)
    }
    
    /**
     JSON -> [GithubRepo]
     */
    open func deserialize(_ json: JSON) -> [GithubRepo] {
        switch json {
        case .array(let users):
            return users.map { self.repoSerializer.deserialize($0) }
        default:
            fatalError("JSON Type should be array")
        }
    }
}

