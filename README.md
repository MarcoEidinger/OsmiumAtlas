# Osmium Atlas

Project `Osmium Atlas` provides Command-Line Tool `iosdevdirectory` to verify the activities of feeds listed on the [iOS Dev Directory](https://iosdevdirectory.com/).

## Usage

```
$ swift run iosdevdirectory check-en-dev
```

will print english development feeds (a.k.a blogs) listed in [iOS Dev Directory](https://iosdevdirectory.com/) with their most recent feed item (a.k.a blog post) information. Blogs without Atom/RSS/JSON feed will not be included in the result set. The result set is sorted by date in descending order.

Sub command `check-en-dev` can be ommited as it is the default.

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

Per default only errors are logged into the log file. Enable detailed logging with argument `--debug`.

You can tail the log file with `tail -f /tmp/iosdevdirectory.log`

## Notes

- `AsyncCompatibilityKit` framework is needed to avoid compiler issue: URLSession 'data(from:delegate:)' is only available in macOS 12.0 or newer
