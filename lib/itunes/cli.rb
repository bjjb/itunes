require 'commander/import'
require 'itunes'
require 'mustache'

def quit(message = "The program exited unexpectedly!", retval = -1)
  STDERR.puts message
  exit retval
end

program :version, ITunes::VERSION
program :description, 'Interact with iTunes via the command-line on OSX'

global_option("-V", "--verbose", "Work noisily") { $verbose = true }
global_option("--no-op", "Don't actually make any changes") { $noop = true }

# Common options, for setting meta-data with add/edit
track_options = [
  ["-t", "--title NAME", String, "sets the track title"],
  ["-a", "--artist NAME", String, "sets the track's artist "],
  ["-y", "--year DATE", "set the year"],
  [       "--album-artist NAME", String, "sets the album artist name"],
  ["-n", "--track-number N", Integer, "set the track number"],
  ["-N", "--total-track-number N", Integer, "set the number of tracks on the disc"],
  ["-A", "--album NAME", String, "sets the album name"],
  ["-d", "--disc-number N", Integer, "set the disc number"],
  ["-D", "--total-disc-number N", Integer, "set the number of discs in the album"],
  ["-G", "--grouping STRING", String, "sets the grouping field"],
  ["-b", "--bpm N", Integer, "sets the BPM field"],
  ["-c", "--composer NAME", String, "sets the composer"],
  ["-C", "--comments COMMENT", String, "adds a comment"],
  ["-g", "--genre GENRE", String, "set the genre (see `list` for genres)"],
  [      "--compilation", "flag to indicate that the track is part of a compilation"],
  ["-s", "--show NAME", String, "sets the TV show name"],
  ["-S", "--season-number N", Integer, "sets the TV show's season number"],
  ["-E", "--episode-id STRING", String, "adds an episode ID"],
  ["-e", "--episode-number N", Integer, "sets the show's episode number"],
  [      "--description DESC", String, "adds a description of the episode"],
  [      "--sort-name STRING", String, "sets the sort name field"],
  [      "--sort-artist STRING", String, "sets the sort artist field"],
  [      "--sort-album-artist STRING", String, "sets the sort album artist field"],
  [      "--sort-album STRING", String, "sets the sort album field"],
  [      "--sort-composer STRING", String, "sets the sort composer field"],
  [      "--sort-show STRING", String, "sets the sort show field"],
  [      "--volume PERCENT", Integer, "adjusts the playback volume"],
  [      "--equalizer-preset X", String, "sets the equalizer preset (see `list`)"],
  ["-k", "--media-kind KIND", String, "sets the media kind (see `list` - default is 'auto')"],
  ["-R", "--rating STARS", /[1-5]/, "Rate the track"],
  [      "--artwork FILES", Array, "adds an artwork image - you may specify multiple"],
  [      "--json FILE", "a JSON file (- means STDIN) containing the metadata"],
  [      "--convert", "convert tracks using iTunes"],
  [      "--consolidate", "copy files into the iTunes directory"]
]
 
command :add do |c|
  c.syntax = 'itunes add FILES [options]'
  c.summary = 'Add a file (or multiple files) to iTunes'
  c.description = <<-DESC
Adds the files specified as a new track to iTunes, optionally passing in
meta-data as options. Prints nothing if successful, unless the verbose switch is
supplied.

You may specify multiple files here, and they will all receive the same
metadata, though itunes will try to intelligently guess things like the name and
the track numbers, provided those options are left out. Alternatively, you can
pass in a JSON file which contains objects for each file specified.

See `help edit` for a more detailed description of how to use JSON and the
meta-data switches.
  DESC
  c.example 'Adds a song, with some meta-data and artwork', 'itunes add agatha.mp3 -a Pond -A Pond -y 1993 -n 4 -N 10 -t Agatha --artwork cdcover.png'
  c.example 'Add all episodes of a TV show in a folder', 'itunes add HouseOfCards/*.mp4 -s "House of Cards" -y 1991 -k "TV Show" -e "Episode {{track_number}}" --description "A British miniseries about a machiavellian politician"'
  track_options.each { |o| c.option(*o) }
  c.action ITunes, :add
end

command :edit do |c|
  c.syntax = 'itunes edit TRACKS [options]'
  c.summary = 'Edit a track in iTunes'
  c.description = <<-DESCRIPTION
Find a track (see below) and modify its metadata. See the options list for the
types of metadata that can be modified.

You may specify a track with a persistent ID (which you can get from the `show`
command), or by its path on disk (if you know it), or by an AppleScript
specifier which is applicable to iTunes, such as 'the first track of the last
playlist whose name contains "X"'. Track specifiers containing spaces must be
quoted, and quotes within the specifier escaped, of course.

JSON may be used (though options will take precedence), either from a file
specified or read from STDIN. The JSON objects should be something like

{ "title": "Come As You Are", "album": "Nevermind", "track_number": 3 }

However, if you leave out the track specifier, then the JSON should specify
tracks as keys:

{
  "track 2 of tracks whose album is "Nevermind": { "title": "In Bloom" },
  "track 4 of tracks whose album is "Nevermind": { "title": "Breed" }
}

Generally, it will try to do the sensible thing. You can run with --verbose and
--no-op to see exactly what would get modified if you are unsure.

This command is silent if it succeeds and --verbose is not set.
  DESCRIPTION
  c.example 'Give a movie 4 stars', 'itunes edit \'track 1 of playlist "Movies"\' -R 4'
  c.example 'Fill in metadata from JSON', 'yaimdb lookup -0 -Fjson "Pulp Fiction" | itunes edit "~/Movies/PulpFiction.m4v" --json'
  track_options.each { |o| c.option *o }
  c.action ITunes, :edit
end

command :remove do |c|
  c.syntax = 'itunes remove TRACKS [options]'
  c.summary = 'Delete a track from iTunes.'
  c.description = <<-DESCRIPTION
Removes tracks from iTunes. See `edit` for how you can specify multiple tracks.
A couple of extra specifiers are available - namely 'missing' (for all tracks
with no file on disk), and 'duplicates' (which tries to find multiple copies of
tracks, and removes all but the first one).

You may also like to delete the files on disk (even if they aren't in the iTunes
directory) - to do this, pass along the --delete flag. The files will be moved
to Trash, unless you also specify --hard, in which case they are gone forever.

This command is silent if it succeeds and --verbose is not set.
DESCRIPTION
  c.example 'Delete all tracks who no longer have files on disk', 'itunes delete missing'
  c.example 'Delete a TV series', 'itunes delete "show=Columbo"'
  c.example 'Show which files would be deleted', 'itunes delete --verbose --no-op "playlist:Disco"'
  c.option '--delete', 'trash the files as well as removing the tracks'
  c.option '--hard', '(used with delete) - permanently delete the files'
  c.action ITunes, :remove
end

command :show do |c|
  c.syntax = 'itunes show TRACKS [PROPERTIES] [options]'
  c.summary = 'Display information for tracks'
  c.description = <<-DESCRIPTION
Prints out various information about the meta-data contained within a track. You
can limit what gets displayed by passing a comma-seperated list of properties,
which roughly correspond to the types of meta-data that you can modify.
Alternatively, you can pass in a simple template, which would look like:

"Name: {{title}}\\nLast played: {{played_date}}"

By default, it will print out just the persistent IDs of the matching tracks,
separated by new-lines (most useful for scripting in shells with `for` loops).

The full list of available properties is available with `list --properties`
  DESCRIPTION
  c.example "Show who composed various pieces of music", "itunes show 'all tracks in user playlist \"Classical\"' -T'{{title}}:{{composer}}'"
  c.example "See which song is playing", "itunes show current title"
  c.example "Display some general info", "itunes show"
  c.option '-T', '--template FILE', 'get the format from a template file (- is STDIN)'
  c.option '--json', 'output in JSON (cannot be used with --template)'
  c.action ITunes, :show
end

command :list do |c|
  c.syntax = 'itunes list [STUFF]'
  c.summary = "List various things such as video-types or playlists"
  c.description = <<-DESCRIPTION
Outputs various lists, depending the arguments. You can list more than one
thing at a time.
DESCRIPTION
  c.example "List all available playlists", "itunes list playlists"
  c.example "Get the IDs of all tracks in a playlist", "itunes list \"Movies\""
  c.example "List all availeble lists. :)", "itunes list lists"
  c.option '--json', 'output a JSON array (or object, for multiple lists)'
end

command :play do |c|
  c.syntax = 'itunes play [TRACKS]'
  c.summary = "Plays tracks"
  c.description = <<-DESCRIPTION
With no track specified, it will play whatever was selected, or the first track
it can find. If you specify one track, it will play it, and any other tracks
specified will be queued to be played next.
DESCRIPTION
  c.action ITunes, :play
end

command :pause do |c|
  c.syntax = 'itunes pause'
  c.summary = "Pauses iTunes."
  c.description = "Just pauses iTunes. You can start it again with 'play'."
  c.action ITunes, :pause
end

command :pp do |c|
  c.syntax = 'itunes pp'
  c.summary = "Plays or pauses iTunes"
  c.description = <<-DESCRIPTION
If iTunes is playing, this is the same as 'pause', otherwise, it's the sane as 'play'.
  DESCRIPTION
  c.action ITunes, :pp
end
