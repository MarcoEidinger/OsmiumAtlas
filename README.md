<div>
  <p align="center">
    <img width=40% src="https://user-images.githubusercontent.com/4176826/148623885-7c6278c1-9a63-4547-83ea-10940f41549e.jpg" alt="Atlas" />
    </br>
  </p>
  <hr>
</div>

Codename *Osmium Atlas* represents my work creating a command line tool, written in Swift,  to verify the feeds listed in the [iOS Dev Directory](https://iosdevdirectory.com/).

The command line tool is named `iosdevdirectory` and part of the Swift package stored in this repository.

## Usage

```
$ swift run iosdevdirectory check-en-dev
```

The command above will print a JSON object containing development feeds (a.k.a blogs), written in the English language and listed in the [iOS Dev Directory](https://iosdevdirectory.com/) with their most recent feed item (a.k.a blog post or article).

Blogs without Atom/RSS/JSON feed will not be included in the result set. 

The result set is sorted by date in descending order.

You can pipe the results into a new file

```
$ swift run iosdevdirectory > latestBlogs.json
```

Example of result set (in January 2022)

```json
{
  "sites": [
    {
      "author": "Marco Eidinger",
      "title": "SwiftyTech",
      "site_url": "https://blog.eidinger.info/",
      "feed_url": "https://blog.eidinger.info/rss.xml",
      "most_recent_article": {
        "title": "Visualize your keystrokes on screenshots or videos",
        "url": "https://blog.eidinger.info/visualize-your-keystrokes-on-screenshots-or-videos",
        "published_date": "01/06/2022"
      }
    }
  ],
  "stats": {
    "sites_total": 1,
    "sites_active_60d": 1,
    "sites_active_60d_in_percentage": 100,
    "sites_active_90d": 1,
    "sites_active_90d_in_percentage": 100,
    "sites_active_30d": 1,
    "sites_active_30d_in_percentage": 100
  }
}
```

P.S.: Sub command `check-en-dev` can be ommited as it is the default.

### Twitter List

I am able to update Twitter List [Active iOS Dev Bloggers](https://twitter.com/i/lists/1490025783963754502) with

```
swift run iosdevdirectory update-twitterlist <API-Key> <API-Secret> <Access-Token> <Access-Token-Secret>
```

Those keys and secrets are only known to me :)

## Installation
### Using [Mint](https://github.com/yonaskolb/mint)

```
$ mint install MarcoEidinger/OsmiumAtlas
```

### Installing from source

You can also build and install from source by cloning this project and running
`make install` (Xcode 13.2 or later).

Manually
Run the following commands to build and install manually:

```
$ git clone https://github.com/MarcoEidinger/OsmiumAtlas.git
$ cd OsmiumAtlas
$ make install
```

## Logging

Per default only errors are logged into the log file. You can enable detailed logging with argument `--debug`.

```
$ swift run iosdevdirectory check-en-dev --debug
```

You can tail the log file with `tail -f /tmp/iosdevdirectory.log`

## Credits

Special thanks to
- [Dave Verwer](https://twitter.com/daveverwer) who put together and maintains the iOS Dev Directory
- [Nuno Dias](https://github.com/nmdias) who created `FeedKit`
- [John Sundell](https://twitter.com/johnsundell) who created `AsyncCompatibilityKit` 

## License

This project is released under the MIT license.
