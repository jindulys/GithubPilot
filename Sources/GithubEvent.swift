//
//  GithubEvent.swift
//  Pods
//
//  Created by yansong li on 2016-02-21.
//
//

import Foundation

/// GithubEventType https://developer.github.com/v3/activity/events/types/
public enum EventType: String {
	case CreateEvent = "CreateEvent"
	case CommitCommentEvent = "CommitCommmentEvent"
	case DeleteEvent = "DeleteEvent"
	case DeploymentEvent = "DeploymentEvent"
	case DeploymentStatusEvent = "DeploymentStatusEvent"
	case DownloadEvent = "DownloadEvent"
	case FollowEvent = "FollowEvent"
	case ForkEvent = "ForkEvent"
	case ForkApplyEvent = "ForkApplyEvent"
	case GistEvent = "GistEvent"
	case GollumEvent = "GollumEvent"
	case IssueCommentEvent = "IssueCommentEvent"
	case IssuesEvent = "IssuesEvent"
	case MemberEvent = "MemberEvent"
	case MembershipEvent = "MembershipEvent"
	case PageBuildEvent = "PageBuildEvent"
	case PublicEvent = "PublicEvent"
	case PullRequestEvent = "PullRequestEvent"
	case PullRequestReviewCommentEvent = "PullRequestReviewCommentEvent"
	case PushEvent = "PushEvent"
	case ReleaseEvent = "ReleaseEvent"
	case RepositoryEvent = "RepositoryEvent"
	case StatusEvent = "StatusEvent"
	case TeamAddEvent = "TeamAddEvent"
	case WatchEvent = "WatchEvent"
	
	init?(event:String) {
		switch event {
		case "CreateEvent":
			self = .CreateEvent
		case "CommitCommentEvent":
			self = .CommitCommentEvent
		case "DeleteEvent":
			self = .DeleteEvent
		case "DeploymentEvent":
			self = .DeploymentEvent
		case "DeploymentStatusEvent":
			self = .DeploymentStatusEvent
		case "DownloadEvent":
			self = .DownloadEvent
		case "FollowEvent":
			self = .FollowEvent
		case "ForkEvent":
			self = .ForkEvent
		case "ForkApplyEvent":
			self = .ForkApplyEvent
		case "GistEvent":
			self = .GistEvent
		case "GollumEvent":
			self = .GollumEvent
		case "IssueCommentEvent":
			self = .IssueCommentEvent
		case "IssuesEvent":
			self = .IssuesEvent
		case "MemberEvent":
			self = .MemberEvent
		case "MembershipEvent":
			self = .MembershipEvent
		case "PageBuildEvent":
			self = .PageBuildEvent
		case "PublicEvent":
			self = .PublicEvent
		case "PullRequestEvent":
			self = .PullRequestEvent
		case "PullRequestReviewCommentEvent":
			self = .PullRequestReviewCommentEvent
		case "PushEvent":
			self = .PushEvent
		case "ReleaseEvent":
			self = .ReleaseEvent
		case "RepositoryEvent":
			self = .RepositoryEvent
		case "StatusEvent":
			self = .StatusEvent
		case "TeamAddEvent":
			self = .TeamAddEvent
		case "WatchEvent":
			self = .WatchEvent
		default:
			print("There has \(event)")
			return nil
		}
	}
}

/// GithubEvent represents a Github Event
open class GithubEvent {
	open let id: String
	open let type: EventType
	open let repo: GithubRepo?
	open let actor: GithubUser?
	open let createdAt: String
	
	init(id: String, type: EventType, repo: GithubRepo? = nil, actor: GithubUser? = nil, createdAt: String) {
		self.id = id
		self.type = type
		self.repo = repo
		self.actor = actor
		self.createdAt = createdAt
	}
}

/// EventSerializer GithubEvent <---> JSON
open class EventSerializer: JSONSerializer {
	let userSerializer: GithubUserSerializer
	let repoSerializer: RepoSerializer
	
	public init() {
		self.userSerializer = GithubUserSerializer()
		self.repoSerializer = RepoSerializer()
	}
	
	/**
	GithubEvent -> JSON
	*/
	open func serialize(_ value: GithubEvent) -> JSON {
		let retVal = [
			"id": Serialization._StringSerializer.serialize(value.id),
			"type": Serialization._StringSerializer.serialize(value.type.rawValue),
			"repo": NullableSerializer(self.repoSerializer).serialize(value.repo),
			"actor": NullableSerializer(self.userSerializer).serialize(value.actor),
			"created_at": Serialization._StringSerializer.serialize(value.createdAt)
		]
		return .dictionary(retVal)
	}
	
	/**
	JSON -> GithubEvent
	*/
	open func deserialize(_ json: JSON) -> GithubEvent {
		switch json {
		case .dictionary(let dict):
			let id = Serialization._StringSerializer.deserialize(dict["id"] ?? .null)
			let type = EventType(event: Serialization._StringSerializer.deserialize(dict["type"] ?? .null))!
			let repo = NullableSerializer(self.repoSerializer).deserialize(dict["repo"] ?? .null)
			let actor = NullableSerializer(self.userSerializer).deserialize(dict["actor"] ?? .null)
			let createdAt = Serialization._StringSerializer.deserialize(dict["created_at"] ?? .null)
			return GithubEvent(id: id, type: type, repo: repo, actor: actor, createdAt: createdAt)
		default:
			fatalError("Github Event JSON Type Error")
		}
	}
}

/// Event Array Serializer, which deal with array.
open class EventArraySerializer: JSONSerializer {
	let eventSerializer: EventSerializer
	init() {
		self.eventSerializer = EventSerializer()
	}
	
	/**
	[GithubEvent] -> JSON
	*/
	open func serialize(_ value: [GithubEvent]) -> JSON {
		let users = value.map { self.eventSerializer.serialize($0) }
		return .array(users)
	}
	
	/**
	JSON -> [GithubEvent]
	*/
	open func deserialize(_ json: JSON) -> [GithubEvent] {
		switch json {
		case .array(let users):
			return users.map { self.eventSerializer.deserialize($0) }
		default:
			fatalError("JSON Type should be array")
		}
	}
}

