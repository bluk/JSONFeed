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

import XCTest

import AnyCodable
import JSONFeed

// swiftlint:disable file_length type_body_length

internal final class JSONFeedTests: XCTestCase {
    func testDecodeMinimalValidVersion1Feed() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "items": []
        }
        """
        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.version, JSONFeed.version1)
        XCTAssertEqual(feed.title, "Example.org Feed")
        XCTAssertEqual(feed.items?.count, 0)
    }

    func testDecodeSimpleExample() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "home_page_url": "https://example.org/",
            "feed_url": "https://example.org/feed.json",
            "items": [
                {
                    "id": "2",
                    "content_text": "This is text content.",
                    "url": "https://example.org/posts/2"
                },
                {
                    "id": "0356e593-a029-4b35-9e49-b533243392fa",
                    "content_html": "<p>This is HTML content.</p>",
                    "url": "https://example.org/first_post"
                }
            ]
        }
        """

        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.version, JSONFeed.version1)
        XCTAssertEqual(feed.title, "Example.org Feed")
        XCTAssertEqual(feed.rawHomePageURL, "https://example.org/")
        XCTAssertEqual(feed.homePageURL, URL(string: "https://example.org/"))
        XCTAssertEqual(feed.rawFeedURL, "https://example.org/feed.json")
        XCTAssertEqual(feed.feedURL, URL(string: "https://example.org/feed.json"))

        XCTAssertEqual(feed.items?.count, 2)

        XCTAssertEqual(feed.items?[0].id, "2")
        XCTAssertEqual(feed.items?[0].contentText, "This is text content.")
        XCTAssertNil(feed.items?[0].contentHTML)
        XCTAssertEqual(feed.items?[0].rawURL, "https://example.org/posts/2")
        XCTAssertEqual(feed.items?[0].url, URL(string: "https://example.org/posts/2"))

        XCTAssertEqual(feed.items?[1].id, "0356e593-a029-4b35-9e49-b533243392fa")
        XCTAssertNil(feed.items?[1].contentText)
        XCTAssertEqual(feed.items?[1].contentHTML, "<p>This is HTML content.</p>")
        XCTAssertEqual(feed.items?[1].rawURL, "https://example.org/first_post")
        XCTAssertEqual(feed.items?[1].url, URL(string: "https://example.org/first_post"))
    }

    func testDecodeMetainfo() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "home_page_url": "https://example.org/",
            "feed_url": "https://example.org/feeds/feed.json",
            "description": "An example feed.",
            "user_comment": "Used for testing.",
            "next_url": "https://example.org/feeds/2/feed.json",
            "icon": "https://example.org/feeds/icon.png",
            "favicon": "https://example.org/favicon.png",
            "expired": true,
            "items": []
        }
        """
        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.version, JSONFeed.version1)
        XCTAssertEqual(feed.title, "Example.org Feed")
        XCTAssertEqual(feed.rawHomePageURL, "https://example.org/")
        XCTAssertEqual(feed.homePageURL, URL(string: "https://example.org/"))
        XCTAssertEqual(feed.rawFeedURL, "https://example.org/feeds/feed.json")
        XCTAssertEqual(feed.feedURL, URL(string: "https://example.org/feeds/feed.json"))
        XCTAssertEqual(feed.description, "An example feed.")
        XCTAssertEqual(feed.userComment, "Used for testing.")
        XCTAssertEqual(feed.rawNextURL, "https://example.org/feeds/2/feed.json")
        XCTAssertEqual(feed.nextURL, URL(string: "https://example.org/feeds/2/feed.json"))
        XCTAssertEqual(feed.rawIcon, "https://example.org/feeds/icon.png")
        XCTAssertEqual(feed.icon, URL(string: "https://example.org/feeds/icon.png"))
        XCTAssertEqual(feed.rawFavicon, "https://example.org/favicon.png")
        XCTAssertEqual(feed.favicon, URL(string: "https://example.org/favicon.png"))
        XCTAssertEqual(feed.expired, true)

        XCTAssertEqual(feed.items?.count, 0)
    }

    func testDecodeAuthor() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "author": {
                "name": "Jane Doe",
                "url": "https://example.org/jane_doe",
                "avatar": "https://example.org/images/jane_doe.png"
            },
            "items": []
        }
        """
        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.author?.name, "Jane Doe")
        XCTAssertEqual(feed.author?.rawURL, "https://example.org/jane_doe")
        XCTAssertEqual(feed.author?.url, URL(string: "https://example.org/jane_doe"))
        XCTAssertEqual(feed.author?.rawAvatar, "https://example.org/images/jane_doe.png")
        XCTAssertEqual(feed.author?.avatar, URL(string: "https://example.org/images/jane_doe.png"))
    }

    func testDecodeHubs() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "hubs": [
                {
                    "type": "rssCloud",
                    "url": "https://example.org/rss_cloud_sub"
                },
                {
                    "type": "WebSub",
                    "url": "https://example.org/pshb"
                }
            ],
            "items": []
        }
        """
        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.hubs?.count, 2)

        XCTAssertEqual(feed.hubs?[0].type, "rssCloud")
        XCTAssertEqual(feed.hubs?[0].rawURL, "https://example.org/rss_cloud_sub")
        XCTAssertEqual(feed.hubs?[0].url, URL(string: "https://example.org/rss_cloud_sub"))

        XCTAssertEqual(feed.hubs?[1].type, "WebSub")
        XCTAssertEqual(feed.hubs?[1].rawURL, "https://example.org/pshb")
        XCTAssertEqual(feed.hubs?[1].url, URL(string: "https://example.org/pshb"))
    }

    func testPublicInit() throws {
        _ = JSONFeed()
        _ = JSONFeed.Author()
        _ = JSONFeed.Item()
        _ = JSONFeed.Hub()
        _ = JSONFeed.Attachment()
    }

    func testDecodeItemWithIDAsIntNotString() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "items": [
                {
                    "id": 12
                }
            ]
        }
        """
        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.items?.count, 1)

        XCTAssertEqual(feed.items?[0].id, "12")
    }

    func testDecodeItemWithIDAsDoubleNotString() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "items": [
                {
                    "id": 14.2
                }
            ]
        }
        """
        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.items?.count, 1)

        XCTAssertEqual(feed.items?[0].id, "14.2")
    }

    // swiftlint:disable function_body_length

    func testDecodeItem() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "items": [
                {
                    "id": "https://example.org/posts/1",
                    "url": "https://example.org/posts/1.html",
                    "external_url": "https://example.org/other/1",
                    "title": "Example Title",
                    "content_text": "This is text content.",
                    "content_html": "<p>This is HTML content.</p>",
                    "summary": "Summarizing the content.",
                    "image": "https://example.org/posts/1/image/1.png",
                    "banner_image": "https://example.org/posts/1/banner_image/1.png",
                    "date_published": "2010-02-07T14:04:00-05:00",
                    "date_modified": "2019-08-26T14:24:00-05:00",
                    "author": {
                      "name": "Bob Smith",
                      "url": "https://example.org/bob_smith",
                      "avatar": "https://example.org/images/bob_smith.png"
                    },
                    "tags": [
                        "test tag",
                        "news",
                    ],
                    "attachments": [
                        {
                            "url": "https://example.org/posts/1/attachments/1.mp3",
                            "mime_type": "audio/mpeg",
                            "title": "Audio Version",
                            "size_in_bytes": 12000000,
                            "duration_in_seconds": 7200
                        }
                    ]
                }
            ]
        }
        """
        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.items?.count, 1)

        XCTAssertEqual(feed.items?[0].id, "https://example.org/posts/1")
        XCTAssertEqual(feed.items?[0].rawURL, "https://example.org/posts/1.html")
        XCTAssertEqual(feed.items?[0].url, URL(string: "https://example.org/posts/1.html"))
        XCTAssertEqual(feed.items?[0].rawExternalURL, "https://example.org/other/1")
        XCTAssertEqual(feed.items?[0].externalURL, URL(string: "https://example.org/other/1"))
        XCTAssertEqual(feed.items?[0].title, "Example Title")
        XCTAssertEqual(feed.items?[0].contentHTML, "<p>This is HTML content.</p>")
        XCTAssertEqual(feed.items?[0].contentText, "This is text content.")
        XCTAssertEqual(feed.items?[0].summary, "Summarizing the content.")
        XCTAssertEqual(feed.items?[0].rawImage, "https://example.org/posts/1/image/1.png")
        XCTAssertEqual(feed.items?[0].image, URL(string: "https://example.org/posts/1/image/1.png"))
        XCTAssertEqual(feed.items?[0].rawBannerImage, "https://example.org/posts/1/banner_image/1.png")
        XCTAssertEqual(feed.items?[0].bannerImage, URL(string: "https://example.org/posts/1/banner_image/1.png"))
        XCTAssertEqual(feed.items?[0].rawDatePublished, "2010-02-07T14:04:00-05:00")
        XCTAssertEqual(feed.items?[0].datePublished, Date(timeIntervalSince1970: 1_265_569_440.0))
        XCTAssertEqual(feed.items?[0].rawDateModified, "2019-08-26T14:24:00-05:00")
        XCTAssertEqual(feed.items?[0].dateModified, Date(timeIntervalSince1970: 1_566_847_440.0))
        XCTAssertEqual(feed.items?[0].author?.name, "Bob Smith")
        XCTAssertEqual(feed.items?[0].author?.rawURL, "https://example.org/bob_smith")
        XCTAssertEqual(feed.items?[0].author?.url, URL(string: "https://example.org/bob_smith"))
        XCTAssertEqual(feed.items?[0].author?.rawAvatar, "https://example.org/images/bob_smith.png")
        XCTAssertEqual(feed.items?[0].author?.avatar, URL(string: "https://example.org/images/bob_smith.png"))

        XCTAssertEqual(feed.items?[0].tags?.count, 2)
        XCTAssertEqual(feed.items?[0].tags?[0], "test tag")
        XCTAssertEqual(feed.items?[0].tags?[1], "news")

        XCTAssertEqual(feed.items?[0].attachments?.count, 1)
        XCTAssertEqual(feed.items?[0].attachments?[0].rawURL, "https://example.org/posts/1/attachments/1.mp3")
        XCTAssertEqual(feed.items?[0].attachments?[0].url, URL(string: "https://example.org/posts/1/attachments/1.mp3"))
        XCTAssertEqual(feed.items?[0].attachments?[0].mimeType, "audio/mpeg")
        XCTAssertEqual(feed.items?[0].attachments?[0].title, "Audio Version")
        XCTAssertEqual(feed.items?[0].attachments?[0].sizeInBytes, 12_000_000)
        XCTAssertEqual(feed.items?[0].attachments?[0].durationInSeconds, 7200)
    }

    // swiftlint:enable function_body_length

    func testDecodeTopLevelExtensions() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "items": [],
            "_test_extension_number": 12,
            "_test_extension_object": {
                "about": "https://example.org/json-feed-extension",
                "expired": true,
                "random_number": 13.2
            }
        }
        """
        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.version, JSONFeed.version1)
        XCTAssertEqual(feed.title, "Example.org Feed")
        XCTAssertEqual(feed.items?.count, 0)

        XCTAssertEqual(feed.extensions?.count, 2)
        XCTAssertEqual(feed.extensions?["_test_extension_number"], 12)

        guard let extensionObject = feed.extensions?["_test_extension_object"]?.value as? [String: Any] else {
            XCTFail("Not expected test extension object type")
            return
        }
        XCTAssertEqual(extensionObject["about"] as? String, "https://example.org/json-feed-extension")
        XCTAssertEqual(extensionObject["expired"] as? Bool, true)
        XCTAssertEqual(extensionObject["random_number"] as? Double, 13.2)
    }

    // swiftlint:disable function_body_length

    func testDecodeItemsExtensions() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "items": [
                {
                    "id": "2",
                    "content_text": "This is text content.",
                    "url": "https://example.org/posts/2",
                    "_test_extension_number": 12,
                    "_test_extension_object": {
                        "about": "https://example.org/json-feed-extension",
                        "expired": true,
                        "random_number": 13.2
                    },
                    "attachments": [
                        {
                            "url": "https://example.org/posts/1/attachments/1.mp3",
                            "mime_type": "image/jpeg",
                            "title": "Audio Version",
                            "size_in_bytes": 12000000,
                            "duration_in_seconds": 7200,
                            "_test_extension_number": 12.4,
                            "_test_extension_object": {
                                "about": "https://example.org/json-feed-extension-attachments",
                                "expired": false,
                                "random_number": 14.3
                            },
                        }
                    ]
                }
            ]
        }
        """
        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.version, JSONFeed.version1)
        XCTAssertEqual(feed.title, "Example.org Feed")
        XCTAssertEqual(feed.items?.count, 1)

        XCTAssertEqual(feed.items?[0].extensions?.count, 2)

        XCTAssertEqual(feed.items?[0].extensions?["_test_extension_number"], 12)

        guard let extensionObject = feed.items?[0].extensions?["_test_extension_object"]?.value as? [String: Any] else {
            XCTFail("Not expected test extension object type")
            return
        }
        XCTAssertEqual(extensionObject["about"] as? String, "https://example.org/json-feed-extension")
        XCTAssertEqual(extensionObject["expired"] as? Bool, true)
        XCTAssertEqual(extensionObject["random_number"] as? Double, 13.2)

        XCTAssertEqual(feed.items?[0].attachments?[0].extensions?.count, 2)

        XCTAssertEqual(feed.items?[0].attachments?[0].extensions?["_test_extension_number"], 12.4)

        guard let attachmentExtensionObject = feed.items?[0].attachments?[0]
            .extensions?["_test_extension_object"]?.value as? [String: Any] else {
            XCTFail("Not expected test extension object type")
            return
        }
        XCTAssertEqual(
            attachmentExtensionObject["about"] as? String,
            "https://example.org/json-feed-extension-attachments"
        )
        XCTAssertEqual(attachmentExtensionObject["expired"] as? Bool, false)
        XCTAssertEqual(attachmentExtensionObject["random_number"] as? Double, 14.3)
    }

    // swiftlint:enable function_body_length

    func testDecodeAuthorExtensions() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "author": {
                "name": "Jane Doe",
                "url": "https://example.org/jane_doe",
                "avatar": "https://example.org/images/jane_doe.png",
                "_test_extension_number": 12,
                "_test_extension_object": {
                    "about": "https://example.org/json-feed-extension",
                    "expired": true,
                    "random_number": 13.2
                }
            },
            "items": []
        }
        """
        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.author?.name, "Jane Doe")

        XCTAssertEqual(feed.author?.extensions?.count, 2)

        XCTAssertEqual(feed.author?.extensions?["_test_extension_number"], 12)

        guard let extensionObject = feed.author?.extensions?["_test_extension_object"]?.value as? [String: Any] else {
            XCTFail("Not expected test extension object type")
            return
        }
        XCTAssertEqual(extensionObject["about"] as? String, "https://example.org/json-feed-extension")
        XCTAssertEqual(extensionObject["expired"] as? Bool, true)
        XCTAssertEqual(extensionObject["random_number"] as? Double, 13.2)
    }

    func testDecodeHubsExtensions() throws {
        let jsonFeed = """
        {
            "version": "https://jsonfeed.org/version/1",
            "title": "Example.org Feed",
            "hubs": [
                {
                    "type": "rssCloud",
                    "url": "https://example.org/rss_cloud_sub",
                    "_test_extension_number": 12,
                    "_test_extension_object": {
                        "about": "https://example.org/json-feed-extension",
                        "expired": true,
                        "random_number": 13.2
                    }
                }
            ],
            "items": []
        }
        """
        let jsonDecoder = JSONDecoder()
        let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeed.data(using: .utf8)!)

        XCTAssertEqual(feed.hubs?.count, 1)

        XCTAssertEqual(feed.hubs?[0].extensions?["_test_extension_number"], 12)

        guard let extensionObject = feed.hubs?[0].extensions?["_test_extension_object"]?.value as? [String: Any] else {
            XCTFail("Not expected test extension object type")
            return
        }
        XCTAssertEqual(extensionObject["about"] as? String, "https://example.org/json-feed-extension")
        XCTAssertEqual(extensionObject["expired"] as? Bool, true)
        XCTAssertEqual(extensionObject["random_number"] as? Double, 13.2)
    }
}
