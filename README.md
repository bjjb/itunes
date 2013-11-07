# iTunes (from Ruby)

A CLI and library for manipulating iTunes and your iTunes library on OSX.

It can be useful for bulk-importing or editing tracks, particularly when you
don't like mucking around with AppleScript (though it does use osascript(1) for
its heavy lifting).

Also useful is the ability to control iTunes from another multi-media manager
which might be using ruby, or for writing scripts to help you get things done.

It speaks JSON, which makes it relatively painless to transport iTunes meta-data
around, and uses [Mustache][] for some templating, so you could pretty much
export your library to anything you like.

This will be of very limited use on any machine other than a Mac (or something
which has an OSA bridge), but users of other OSs tend to have decent media
management tools available to them anyway.

## Installation

Add this line to your application's Gemfile:

    gem 'itunes'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install itunes

## Usage

The CLI is pretty thoroughly documented - run `itunes help` to get started.

For `ITunes` library docs, read the [source][] (or the [RDocs][]).

## Testing

There's a Rakefile which runs tests. It _will_ pollute your iTunes while
running, as it adds a sample file to the library, and mucks around with it.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Requesto

## Thanks

[Yehuda Katz](http://yehudakatz.com/) for [Thor][],
[Chris Wanstrath](https://github.com/defunkt) for [Mustache][],
and everyone else involved in any of the super open-source software that makes
building tools like this a breeze.

[source]: http://github.com/bjjb/itunes/
[RDocs]: http://rdoc.info/github/bjjb/itunes/
[Mustache]: http://mustache.github.io/
[Thor]: http://whatisthor.com
