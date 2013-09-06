## JSON Templates Expander (JTE)

JSON Templates Expander (JTE) is an NSDictionary category that allows you to
easily parse incoming representation documents that have the JSON API URL-Based
[format](http://www.jsonapi.org/format/) and output *expanded* NSDictionaries in
iOS or OS X.

### Usage

It's quite simple, assuming that you get a response like the ones on the examples
below, you could do something in the lines of:

```objc

#import "NSDictionary+JTE.h"

NSDictionary *jsonResponse = [ApiClient getJSONDocument];

[[jsonResponse expandedTemplates][@"posts"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *_stop) {
    LocalModel *model = [[LocalModel alloc] initWithDictionary:obj];
}];


```

### Example

Let's say that we have a JSON server response that looks like:

```json

{
    "links": {
        "posts.comments": "http://example.com/posts/{posts.id}/comments"
    },
    "posts": [
        {
            "id": "1",
            "title": "Rails is Omakase"
        },
        {
            "id": "2",
            "title": "The Parley Letter"
        }
    ]
}

```

JTE can then expand this response to look like this:

```json

{
    "posts": [{
        "id": "1",
        "title": "Rails is Omakase",
        "comments" : {
            "href": "http://example.com/posts/1/comments"
        }
    }, {
        "id": "2",
        "title": "The Parley Letter",
        "comments" : {
            "href": "http://example.com/posts/2/comments"
        }
    }
    ]
}

```

As you can see you can now traverse the `posts` array so that you can build your
models client-side, right now you're responsible for querying the *hypermedia*
links that are could be added to the *expanded models* with the `href` key
in the expanded response.

### Example 2

Let's say that we're working with compound documents, (taken from JSON API [format
docs](http://www.jsonapi.org/format))

```json

{
    "links": {
        "posts.author": {
            "href": "http://example.com/people/{posts.author}",
            "type": "author"
        },
        "posts.comments": {
            "href": "http://example.com/comments/{posts.comments}",
            "type": "comments"
        }
    },
    "posts": [
    {
        "id": "1",
        "title": "rails is omakase",
        "links": {
            "author": "9",
            "comments": [
                "1",
            "2",
            "3"
                ]
        }
    },
    {
        "id": "2",
        "title": "the parley letter",
        "links": {
            "author": "9",
            "comments": [
                "4",
            "5"
                ]
        }
    },
    {
        "id": "3",
        "title": "Awesome & Fantastic title",
        "links": {
            "author": "10",
            "comments": [
                "6",
				"7"
                ]
        }
    }
    ],
        "author": [
        {
            "id": "9",
            "name": "@d2h"
        }, {
            "id" : "10",
            "name" : "@ngoles"
        }
    ],
        "comments": [
        {
            "id": "1",
            "body": "mmmmmakase"
        },
        {
            "id": "2",
            "body": "i prefer unagi"
        },
        {
            "id": "3",
            "body": "what's omakase?"
        },
        {
            "id": "4",
            "body": "parley is a discussion, especially one between enemies"
        },
        {
            "id": "5",
            "body": "the parsley letter"
        },
        {
            "id": "6",
            "body": "dependency injection is not a vice"
        },
        {
            "id": "7",
            "body": "awesome & fantastic comment 2"
        }
    ]
}
```

The expanded templates would look like this:

```json

{
    "posts": [
        {
            "id": "1",
            "title": "rails is omakase",
            "author": {
                "name": "@d2h",
                "id": "9",
                "href": "http://example.com/people/9"
            },
            "comments": [
                {
                    "href": "http://example.com/comments/1",
                    "id": "1",
                    "body": "mmmmmakase"
                },
                {
                    "href": "http://example.com/comments/2",
                    "id": "2",
                    "body": "i prefer unagi"
                },
                {
                    "href": "http://example.com/comments/3",
                    "id": "3",
                    "body": "what's omakase?"
                }
            ]
        },
        {
            "id": "2",
            "title": "the parley letter",
            "author": {
                "name": "@d2h",
				"id": "9",
                "href": "http://example.com/people/9"
            },
            "comments": [
                {
                    "href": "http://example.com/comments/4",
                    "id": "4",
                    "body": "parley is a discussion, especially one between enemies"
                },
                {
                    "href": "http://example.com/comments/5",
                    "id": "5",
                    "body": "the parsley letter"
                }
            ]
        },
        {
            "id": "3",
            "title": "Awesome & Fantastic title",
            "author": {
                "name": "@ngoles",
                "id": "10",
                "href": "http://example.com/people/10"
            },
            "comments": [
                {
                    "href": "http://example.com/comments/6",
                    "id": "6",
                    "body": "dependency injection is not a vice"
                },
                {
                    "href": "http://example.com/comments/7",
                    "id": "7",
                    "body": "awesome & fantastic comment 2"
                }
            ]
        }
    ]
}

```

You can then just traverse the posts array in your client and query the hypermedia
as needed.

### More information

Take a look at the project integration tests, you can run them by opening the
sample project and running the suite with `Cmd+U`.

### Issues & Pull Requests

I'm more than willing to help anyone out with issues or to quickly integrate
pull requests.

To create an issue just create a test to replicate your problem on your own fork
and then send me a pull requests so that I can take a look and then include your
test in the suite

### Todo

* Add Cocoapods
* Add Better Examples
* Provide more integration tests (currently there are ~5)
* Provide more unit tests to ease refactoring.
* Optimize.

## Credits

JSON Template Expander (JTE) was created by [Nicolas Goles](http://twitter.com/ngoles)
in the development of [HopIn](http://hop.in) for iOS.

