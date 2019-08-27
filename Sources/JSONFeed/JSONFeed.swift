//  Copyright 2019 Bryant Luk
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import struct Foundation.Date
import class Foundation.DateFormatter
import struct Foundation.Locale
import struct Foundation.TimeZone
import struct Foundation.URL

import AnyCodable

// swiftlint:disable file_length type_body_length

public struct JSONFeed: Codable, Equatable {
    public struct Item: Codable, Equatable {
        // swiftlint:disable nesting

        struct CodingKeys: CodingKey {
            var stringValue: String

            var intValue: Int? {
                return nil
            }

            init?(stringValue: String) {
                self.stringValue = stringValue
            }

            init?(intValue _: Int) {
                return nil
            }

            // swiftlint:disable identifier_name
            static let id = CodingKeys(stringValue: "id")!
            // swiftlint:enable identifier_name

            static let url = CodingKeys(stringValue: "url")!
            static let externalURL = CodingKeys(stringValue: "external_url")!
            static let title = CodingKeys(stringValue: "title")!
            static let summary = CodingKeys(stringValue: "summary")!
            static let image = CodingKeys(stringValue: "image")!
            static let bannerImage = CodingKeys(stringValue: "banner_image")!
            static let datePublished = CodingKeys(stringValue: "date_published")!
            static let dateModified = CodingKeys(stringValue: "date_modified")!
            static let author = CodingKeys(stringValue: "author")!
            static let contentText = CodingKeys(stringValue: "content_text")!
            static let contentHTML = CodingKeys(stringValue: "content_html")!
            static let tags = CodingKeys(stringValue: "tags")!
            static let attachments = CodingKeys(stringValue: "attachments")!
        }

        // swiftlint:enable nesting

        // swiftlint:disable identifier_name
        public var id: String?
        // swiftlint:enable identifier_name
        public var url: URL? {
            guard let rawURL = self.rawURL else {
                return nil
            }
            return URL(string: rawURL)
        }

        public var rawURL: String?
        public var externalURL: URL? {
            guard let rawExternalURL = self.rawExternalURL else {
                return nil
            }
            return URL(string: rawExternalURL)
        }

        public var rawExternalURL: String?
        public var title: String?
        public var contentText: String?
        public var contentHTML: String?
        public var summary: String?
        public var image: URL? {
            guard let rawImage = self.rawImage else {
                return nil
            }
            return URL(string: rawImage)
        }

        public var rawImage: String?
        public var bannerImage: URL? {
            guard let rawBannerImage = self.rawBannerImage else {
                return nil
            }
            return URL(string: rawBannerImage)
        }

        public var rawBannerImage: String?
        public var datePublished: Date? {
            guard let rawDatePublished = self.rawDatePublished else {
                return nil
            }
            return self.rfc3339DateFormatter.date(from: rawDatePublished)
        }

        public var rawDatePublished: String?
        public var dateModified: Date? {
            guard let rawDateModified = self.rawDateModified else {
                return nil
            }
            return self.rfc3339DateFormatter.date(from: rawDateModified)
        }

        public var rawDateModified: String?
        public var author: Author?

        // swiftlint:disable discouraged_optional_collection
        public var tags: [String]?
        public var attachments: [Attachment]?

        public var extensions: [String: AnyCodable]?
        // swiftlint:enable discouraged_optional_collection

        private var rfc3339DateFormatter: DateFormatter {
            // See https://developer.apple.com/library/archive/qa/qa1480/_index.html
            let rfc3339DateFormatter = DateFormatter()
            rfc3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
            // This is not the only date format for RFC3339 but is a common one.
            // If other date formats are encountered, maybe change the logic
            // to try one until parsing succeeds.
            rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
            rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            return rfc3339DateFormatter
        }

        public init() {}

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            do {
                self.id = try container.decodeIfPresent(String.self, forKey: CodingKeys.id)
            } catch {
                do {
                    if let idAsInt = try container.decodeIfPresent(Int.self, forKey: CodingKeys.id) {
                        self.id = String(idAsInt)
                    }
                } catch {
                    if let idAsDouble = try container.decodeIfPresent(Double.self, forKey: CodingKeys.id) {
                        self.id = String(idAsDouble)
                    }
                }
            }
            self.rawURL = try container.decodeIfPresent(String.self, forKey: CodingKeys.url)
            self.rawExternalURL = try container.decodeIfPresent(String.self, forKey: CodingKeys.externalURL)
            self.title = try container.decodeIfPresent(String.self, forKey: CodingKeys.title)
            self.contentText = try container.decodeIfPresent(String.self, forKey: CodingKeys.contentText)
            self.contentHTML = try container.decodeIfPresent(String.self, forKey: CodingKeys.contentHTML)
            self.summary = try container.decodeIfPresent(String.self, forKey: CodingKeys.summary)
            self.rawImage = try container.decodeIfPresent(String.self, forKey: CodingKeys.image)
            self.rawBannerImage = try container.decodeIfPresent(String.self, forKey: CodingKeys.bannerImage)
            self.rawDatePublished = try container.decodeIfPresent(String.self, forKey: CodingKeys.datePublished)
            self.rawDateModified = try container.decodeIfPresent(String.self, forKey: CodingKeys.dateModified)
            self.author = try container.decodeIfPresent(Author.self, forKey: CodingKeys.author)
            self.tags = try container.decodeIfPresent([String].self, forKey: CodingKeys.tags)
            self.attachments = try container.decodeIfPresent([Attachment].self, forKey: CodingKeys.attachments)

            var extensions: [String: AnyCodable] = [:]
            for key in container.allKeys {
                guard key.stringValue.first == "_" else {
                    continue
                }

                let value = try container.decode(AnyCodable.self, forKey: key)
                extensions[key.stringValue] = value
            }
            if !extensions.isEmpty {
                self.extensions = extensions
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(self.id, forKey: CodingKeys.id)
            try container.encodeIfPresent(self.rawURL, forKey: CodingKeys.url)
            try container.encodeIfPresent(self.rawExternalURL, forKey: CodingKeys.externalURL)
            try container.encodeIfPresent(self.title, forKey: CodingKeys.title)
            try container.encodeIfPresent(self.contentText, forKey: CodingKeys.contentText)
            try container.encodeIfPresent(self.contentHTML, forKey: CodingKeys.contentHTML)
            try container.encodeIfPresent(self.summary, forKey: CodingKeys.summary)
            try container.encodeIfPresent(self.rawImage, forKey: CodingKeys.image)
            try container.encodeIfPresent(self.rawBannerImage, forKey: CodingKeys.bannerImage)
            try container.encodeIfPresent(self.rawDatePublished, forKey: CodingKeys.datePublished)
            try container.encodeIfPresent(self.rawDateModified, forKey: CodingKeys.dateModified)
            try container.encodeIfPresent(self.author, forKey: CodingKeys.author)
            try container.encodeIfPresent(self.tags, forKey: CodingKeys.tags)
            try container.encodeIfPresent(self.attachments, forKey: CodingKeys.attachments)

            if let extensions = self.extensions {
                for (key, value) in extensions {
                    guard let codingKey = CodingKeys(stringValue: key) else {
                        fatalError("Could not convert \(key) to a CodingKey")
                    }
                    try container.encode(value, forKey: codingKey)
                }
            }
        }
    }

    public struct Author: Codable, Equatable {
        // swiftlint:disable nesting

        struct CodingKeys: CodingKey {
            var stringValue: String

            var intValue: Int? {
                return nil
            }

            init?(stringValue: String) {
                self.stringValue = stringValue
            }

            init?(intValue _: Int) {
                return nil
            }

            static let name = CodingKeys(stringValue: "name")!
            static let url = CodingKeys(stringValue: "url")!
            static let avatar = CodingKeys(stringValue: "avatar")!
        }

        // swiftlint:enable nesting

        public var name: String?
        public var url: URL? {
            guard let rawURL = self.rawURL else {
                return nil
            }
            return URL(string: rawURL)
        }

        public var rawURL: String?
        public var avatar: URL? {
            guard let rawAvatar = self.rawAvatar else {
                return nil
            }
            return URL(string: rawAvatar)
        }

        public var rawAvatar: String?

        // swiftlint:disable discouraged_optional_collection
        public var extensions: [String: AnyCodable]?
        // swiftlint:enable discouraged_optional_collection

        public init() {}

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decodeIfPresent(String.self, forKey: CodingKeys.name)
            self.rawURL = try container.decodeIfPresent(String.self, forKey: CodingKeys.url)
            self.rawAvatar = try container.decodeIfPresent(String.self, forKey: CodingKeys.avatar)

            var extensions: [String: AnyCodable] = [:]
            for key in container.allKeys {
                guard key.stringValue.first == "_" else {
                    continue
                }

                let value = try container.decode(AnyCodable.self, forKey: key)
                extensions[key.stringValue] = value
            }
            if !extensions.isEmpty {
                self.extensions = extensions
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(self.name, forKey: CodingKeys.name)
            try container.encodeIfPresent(self.rawURL, forKey: CodingKeys.url)
            try container.encodeIfPresent(self.rawAvatar, forKey: CodingKeys.avatar)

            if let extensions = self.extensions {
                for (key, value) in extensions {
                    guard let codingKey = CodingKeys(stringValue: key) else {
                        fatalError("Could not convert \(key) to a CodingKey")
                    }
                    try container.encode(value, forKey: codingKey)
                }
            }
        }
    }

    public struct Hub: Codable, Equatable {
        // swiftlint:disable nesting

        struct CodingKeys: CodingKey {
            var stringValue: String

            var intValue: Int? {
                return nil
            }

            init?(stringValue: String) {
                self.stringValue = stringValue
            }

            init?(intValue _: Int) {
                return nil
            }

            static let type = CodingKeys(stringValue: "type")!
            static let url = CodingKeys(stringValue: "url")!
        }

        // swiftlint:enable nesting

        public var type: String?
        public var url: URL? {
            guard let rawURL = self.rawURL else {
                return nil
            }
            return URL(string: rawURL)
        }

        public var rawURL: String?

        // swiftlint:disable discouraged_optional_collection
        public var extensions: [String: AnyCodable]?
        // swiftlint:enable discouraged_optional_collection

        public init() {}

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decodeIfPresent(String.self, forKey: CodingKeys.type)
            self.rawURL = try container.decodeIfPresent(String.self, forKey: CodingKeys.url)

            var extensions: [String: AnyCodable] = [:]
            for key in container.allKeys {
                guard key.stringValue.first == "_" else {
                    continue
                }

                let value = try container.decode(AnyCodable.self, forKey: key)
                extensions[key.stringValue] = value
            }
            if !extensions.isEmpty {
                self.extensions = extensions
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(self.type, forKey: CodingKeys.type)
            try container.encodeIfPresent(self.rawURL, forKey: CodingKeys.url)

            if let extensions = self.extensions {
                for (key, value) in extensions {
                    guard let codingKey = CodingKeys(stringValue: key) else {
                        fatalError("Could not convert \(key) to a CodingKey")
                    }
                    try container.encode(value, forKey: codingKey)
                }
            }
        }
    }

    public struct Attachment: Codable, Equatable {
        // swiftlint:disable nesting

        struct CodingKeys: CodingKey {
            var stringValue: String

            var intValue: Int? {
                return nil
            }

            init?(stringValue: String) {
                self.stringValue = stringValue
            }

            init?(intValue _: Int) {
                return nil
            }

            static let url = CodingKeys(stringValue: "url")!
            static let mimeType = CodingKeys(stringValue: "mime_type")!
            static let title = CodingKeys(stringValue: "title")!
            static let sizeInBytes = CodingKeys(stringValue: "size_in_bytes")!
            static let durationInSeconds = CodingKeys(stringValue: "duration_in_seconds")!
        }

        // swiftlint:enable nesting

        public var url: URL? {
            guard let rawURL = self.rawURL else {
                return nil
            }
            return URL(string: rawURL)
        }

        public var rawURL: String?
        public var mimeType: String?
        public var title: String?
        public var sizeInBytes: Double?
        public var durationInSeconds: Double?

        // swiftlint:disable discouraged_optional_collection
        public var extensions: [String: AnyCodable]?
        // swiftlint:enable discouraged_optional_collection

        public init() {}

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.rawURL = try container.decodeIfPresent(String.self, forKey: CodingKeys.url)
            self.mimeType = try container.decodeIfPresent(String.self, forKey: CodingKeys.mimeType)
            self.title = try container.decodeIfPresent(String.self, forKey: CodingKeys.title)
            self.sizeInBytes = try container.decodeIfPresent(Double.self, forKey: CodingKeys.sizeInBytes)
            self.durationInSeconds = try container.decodeIfPresent(Double.self, forKey: CodingKeys.durationInSeconds)

            var extensions: [String: AnyCodable] = [:]
            for key in container.allKeys {
                guard key.stringValue.first == "_" else {
                    continue
                }

                let value = try container.decode(AnyCodable.self, forKey: key)
                extensions[key.stringValue] = value
            }
            if !extensions.isEmpty {
                self.extensions = extensions
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(self.rawURL, forKey: CodingKeys.url)
            try container.encodeIfPresent(self.mimeType, forKey: CodingKeys.mimeType)
            try container.encodeIfPresent(self.title, forKey: CodingKeys.title)
            try container.encodeIfPresent(self.sizeInBytes, forKey: CodingKeys.sizeInBytes)
            try container.encodeIfPresent(self.durationInSeconds, forKey: CodingKeys.durationInSeconds)

            if let extensions = self.extensions {
                for (key, value) in extensions {
                    guard let codingKey = CodingKeys(stringValue: key) else {
                        fatalError("Could not convert \(key) to a CodingKey")
                    }
                    try container.encode(value, forKey: codingKey)
                }
            }
        }
    }

    struct CodingKeys: CodingKey {
        var stringValue: String

        var intValue: Int? {
            return nil
        }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue _: Int) {
            return nil
        }

        static let version = CodingKeys(stringValue: "version")!
        static let title = CodingKeys(stringValue: "title")!
        static let feedURL = CodingKeys(stringValue: "feed_url")!
        static let homePageURL = CodingKeys(stringValue: "home_page_url")!
        static let description = CodingKeys(stringValue: "description")!
        static let userComment = CodingKeys(stringValue: "user_comment")!
        static let nextURL = CodingKeys(stringValue: "next_url")!
        static let icon = CodingKeys(stringValue: "icon")!
        static let favicon = CodingKeys(stringValue: "favicon")!
        static let author = CodingKeys(stringValue: "author")!
        static let expired = CodingKeys(stringValue: "expired")!
        static let items = CodingKeys(stringValue: "items")!
        static let hubs = CodingKeys(stringValue: "hubs")!
    }

    public static let version1: String = "https://jsonfeed.org/version/1"

    public var version: String?
    public var title: String?
    public var homePageURL: URL? {
        guard let rawHomePageURL = self.rawHomePageURL else {
            return nil
        }
        return URL(string: rawHomePageURL)
    }

    public var rawHomePageURL: String?
    public var feedURL: URL? {
        guard let rawFeedURL = self.rawFeedURL else {
            return nil
        }
        return URL(string: rawFeedURL)
    }

    public var rawFeedURL: String?
    public var description: String?
    public var userComment: String?
    public var nextURL: URL? {
        guard let rawNextURL = self.rawNextURL else {
            return nil
        }
        return URL(string: rawNextURL)
    }

    public var rawNextURL: String?
    public var icon: URL? {
        guard let rawIcon = self.rawIcon else {
            return nil
        }
        return URL(string: rawIcon)
    }

    public var rawIcon: String?
    public var favicon: URL? {
        guard let rawFavicon = self.rawFavicon else {
            return nil
        }
        return URL(string: rawFavicon)
    }

    public var rawFavicon: String?
    public var author: Author?
    // swiftlint:disable discouraged_optional_boolean
    public var expired: Bool?
    // swiftlint:enable discouraged_optional_boolean

    // swiftlint:disable discouraged_optional_collection
    public var items: [Item]?
    public var hubs: [Hub]?

    public var extensions: [String: AnyCodable]?
    // swiftlint:enable discouraged_optional_collection

    public init() {}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decodeIfPresent(String.self, forKey: CodingKeys.version)
        self.title = try container.decodeIfPresent(String.self, forKey: CodingKeys.title)
        self.rawHomePageURL = try container.decodeIfPresent(String.self, forKey: CodingKeys.homePageURL)
        self.rawFeedURL = try container.decodeIfPresent(String.self, forKey: CodingKeys.feedURL)
        self.description = try container.decodeIfPresent(String.self, forKey: CodingKeys.description)
        self.userComment = try container.decodeIfPresent(String.self, forKey: CodingKeys.userComment)
        self.rawNextURL = try container.decodeIfPresent(String.self, forKey: CodingKeys.nextURL)
        self.rawIcon = try container.decodeIfPresent(String.self, forKey: CodingKeys.icon)
        self.rawFavicon = try container.decodeIfPresent(String.self, forKey: CodingKeys.favicon)
        self.author = try container.decodeIfPresent(Author.self, forKey: CodingKeys.author)
        self.expired = try container.decodeIfPresent(Bool.self, forKey: CodingKeys.expired)
        self.items = try container.decodeIfPresent([Item].self, forKey: CodingKeys.items)
        self.hubs = try container.decodeIfPresent([Hub].self, forKey: CodingKeys.hubs)

        var extensions: [String: AnyCodable] = [:]
        for key in container.allKeys {
            guard key.stringValue.first == "_" else {
                continue
            }

            let value = try container.decode(AnyCodable.self, forKey: key)
            extensions[key.stringValue] = value
        }
        if !extensions.isEmpty {
            self.extensions = extensions
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.version, forKey: CodingKeys.version)
        try container.encodeIfPresent(self.title, forKey: CodingKeys.title)
        try container.encodeIfPresent(self.rawHomePageURL, forKey: CodingKeys.homePageURL)
        try container.encodeIfPresent(self.rawFeedURL, forKey: CodingKeys.feedURL)
        try container.encodeIfPresent(self.description, forKey: CodingKeys.description)
        try container.encodeIfPresent(self.userComment, forKey: CodingKeys.userComment)
        try container.encodeIfPresent(self.rawNextURL, forKey: CodingKeys.nextURL)
        try container.encodeIfPresent(self.rawIcon, forKey: CodingKeys.icon)
        try container.encodeIfPresent(self.rawFavicon, forKey: CodingKeys.favicon)
        try container.encodeIfPresent(self.author, forKey: CodingKeys.author)
        try container.encodeIfPresent(self.expired, forKey: CodingKeys.expired)
        try container.encodeIfPresent(self.items, forKey: CodingKeys.items)
        try container.encodeIfPresent(self.hubs, forKey: CodingKeys.hubs)

        if let extensions = self.extensions {
            for (key, value) in extensions {
                guard let codingKey = CodingKeys(stringValue: key) else {
                    fatalError("Could not convert \(key) to a CodingKey")
                }
                try container.encode(value, forKey: codingKey)
            }
        }
    }
}
