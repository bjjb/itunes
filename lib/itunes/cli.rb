require 'itunes'

module ITunes
  module CLI
    PROGRAM = {
      version: ITunes::VERSION,
      description: 'Interact with iTunes via the command-line on OSX',
      help_formatter: :compact
    }

    # Common options, for setting meta-data with add/edit
    TRACK_PROPERTIES = {
      :name => ["--name NAME", String, "the track name"],
      :artist => ["--artist NAME", String, "the track's artist "],
      :year => ["--year DATE", "the year"],
      :album_artist => ["--album-artist NAME", String, "the album artist name"],
      :track_number => ["--track-number N", Integer, "the track number"],
      :track_count => ["--track-count N", Integer, "the number of tracks on the disc"],
      :album => ["--album NAME", String, "the album name"],
      :disc_number => ["--disc-number N", Integer, "the disc number"],
      :disc_count => ["--disc-count N", Integer, "the number of discs in the album"],
      :grouping => ["--grouping STRING", String, "the grouping field"],
      :bpm => ["--bpm N", Integer, "the BPM field"],
      :composer => ["--composer NAME", String, "the composer"],
      :comments => ["--comments COMMENT", String, "a comment"],
      :genre => ["--genre GENRE", String, "the genre (see `list` for genres)"],
      :compilation => ["--compilation", "the track is part of a compilation"],
      :show => ["--show NAME", String, "the TV show name"],
      :season_number => ["--season-number N", Integer, "the TV show's season number"],
      :episode_ID => ["--episode-id STRING", String, "adds an episode ID"],
      :episode_number => ["--episode-number N", Integer, "the show's episode number"],
      :description => ["--description DESC", String, "adds a description of the episode"],
      :sort_name => ["--sort-name STRING", String, "the sort name field"],
      :sort_artist => ["--sort-artist STRING", String, "the sort artist field"],
      :sort_album_artist => ["--sort-album-artist STRING", String, "the sort album artist field"],
      :sort_album => ["--sort-album STRING", String, "the sort album field"],
      :sort_composer => ["--sort-composer STRING", String, "the sort composer field"],
      :sort_show => ["--sort-show STRING", String, "the sort show field"],
      :volume => ["--volume PERCENT", Integer, "adjusts the playback volume"],
      :EQ => ["--EQ X", String, "the equalizer preset (see `list`)"],
      :media_kind => ["--media-kind KIND", String, "the media kind (see `list`)"],
      :rating => ["--rating STARS", /[1-5]/, "the track rating"],
    }

    TRACK_OPTIONS = TRACK_PROPERTIES.values + [
      ["--artwork FILES", Array, "adds an artwork image - you may specify multiple"],
      ["--json FILE", "a JSON file (- means STDIN) containing the metadata"],
      ["--convert", "convert tracks using iTunes"],
      ["--consolidate", "copy files into the iTunes directory"]
    ]

    COMMANDS = {
      add: {
        syntax: 'itunes add FILES [options]',
        summary: 'Add a file (or multiple files) to iTunes',
        description: (<<-DESCRIPTION),
Adds the files specified as a new track to iTunes, optionally passing in
  meta-data as options. Prints nothing if successful, unless the verbose switch is
  supplied.

  You may specify multiple files here, and they will all receive the same
  metadata, though itunes will try to intelligently guess things like the name and
  the track numbers, provided those options are left out. Alternatively, you can
  pass in a JSON file which contains objects for each file specified.

  See `help edit` for a more detailed description of how to use JSON and the
  meta-data switches.
        DESCRIPTION
        examples: [
          [
            'Adds a song, with some meta-data and artwork',
            'itunes add agatha.mp3 -a Pond -A Pond -y 1993 -n 4 -N 10 -t Agatha --artwork cdcover.png'
          ],
          [
            'Add all episodes of a TV show in a folder',
            'itunes add HouseOfCards/*.mp4 -s "House of Cards" -y 1991 -k "TV Show" -e "Episode {{track_number}}" --description "A British miniseries about a machiavellian politician"'
          ]
        ],
        options: TRACK_OPTIONS,
        action: :add
      },
      edit: {
        syntax: 'itunes edit TRACKS [options]',
        summary: 'Edit a track in iTunes',
        description: (<<-DESCRIPTION),
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
        examples: [
          [
            'Give a movie 4 stars',
            'itunes edit \'track 1 of playlist "Movies"\' -R 4'
          ],
          [
            'Fill in metadata from JSON',
            'yaimdb lookup -0 -Fjson "Pulp Fiction" | itunes edit "~/Movies/PulpFiction.m4v" --json'
          ]
        ],
        options: TRACK_OPTIONS,
        action: :edit
      },
      remove: {
        syntax: 'itunes remove TRACKS [options]',
        summary: 'Delete a track from iTunes.',
        description: (<<-DESCRIPTION),
Removes tracks from iTunes. See `edit` for how you can specify multiple tracks.
  A couple of extra specifiers are available - namely 'missing' (for all tracks
  with no file on disk), and 'duplicates' (which tries to find multiple copies of
  tracks, and removes all but the first one).

  You may also like to delete the files on disk (even if they aren't in the iTunes
  directory) - to do this, pass along the --delete flag. The files will be moved
  to Trash, unless you also specify --hard, in which case they are gone forever.

  This command is silent if it succeeds and --verbose is not set.
        DESCRIPTION
        examples: [
          [
            'Delete all tracks who no longer have files on disk',
            'itunes delete missing'
          ],
          [
            'Delete a TV series',
            'itunes delete "show=Columbo"'
          ],
          [
            'Show which files would be deleted',
            'itunes delete --verbose --no-op "playlist:Disco"'
          ]
        ],
        options: [
          ['--delete', 'trash the files as well as removing the tracks'],
          ['--hard', '(used with delete) - permanently delete the files']
        ],
        action: :remove
      },
      show: {
        syntax: 'itunes show TRACKS [properties] [options]',
        summary: 'Display information for tracks',
        description: (<<-DESCRIPTION),
Prints out various information about the meta-data contained within a track. You
  can limit what gets displayed by passing a comma-seperated list of properties,
  which roughly correspond to the types of meta-data that you can modify.
  Alternatively, you can pass in a simple template, which would look like:
  
  "Name: {{title}}\\nLast played: {{played_date}}"
  
  By default, it will print out just the persistent IDs of the matching tracks,
  separated by new-lines (most useful for scripting in shells with `for` loops).
  
  The full list of available properties is available with `list --properties`
        DESCRIPTION
        examples: [
          [
            "Show who composed various pieces of music",
            "itunes show 'all tracks in user playlist \"Classical\"' -T'{{title}}:{{composer}}'"
          ],
          [
            "See which song is playing",
            "itunes show current title"
          ],
          [
            "Display some general info",
            "itunes show"
          ]
        ],
        options: [
          ['-T', '--template FILE', 'get the format from a template file (- is STDIN)'],
          ['--json', 'output in JSON (cannot be used with --template)']
        ],
        action: :show
      },
      list: {
        syntax: 'itunes list [STUFF]',
        summary: "List various things such as video-types or playlists",
        description: (<<-DESCRIPTION),
Outputs various lists, depending the arguments. You can list more than one
  thing at a time.
        DESCRIPTION
        examples: [
          [
            "List all available playlists",
            "itunes list playlists"
          ],
          [
            "Get the IDs of all tracks in a playlist",
            "itunes list \"Movies\""
          ],
          [
            "List all availeble lists. :)",
            "itunes list lists"
          ]
        ],
        options: [
          ['--json', 'output a JSON array (or object, for multiple lists)']
        ],
        action: :list
      },
      play: {
        syntax: 'itunes play [TRACKS]',
        summary: "Plays tracks",
        description: (<<-DESCRIPTION),
With no track specified, it will play whatever was selected, or the first track
  it can find. If you specify one track, it will play it, and any other tracks
  specified will be queued to be played next.
        DESCRIPTION
        action: :play
      },
      pause: {
        syntax: 'itunes pause',
        summary: "Pauses iTunes.",
        description: "Just pauses iTunes. You can start it again with 'play'.",
        action: :pause
      },
      pp: {
        syntax: 'itunes pp',
        summary: "Plays or pauses iTunes",
        description: (<<-DESCRIPTION),
If iTunes is playing, this is the same as 'pause', otherwise, it's the sane as 'play'.
        DESCRIPTION
        action: :pp
      }
    }

    def start
      require 'commander/import'
      setup
    end

    def setup
      PROGRAM.each { |k, v| program(k, v) }
      global_option("--verbose", "be noisier") { $verbose = true }
      global_option("--dry-run", "don't actually talk to iTunes") { $dry_run = true }
      global_option("--debug", "print out debugging hints") { $debug = true }
      COMMANDS.each do |name, x|
        command(name) do |c|
          c.syntax = x[:syntax]
          c.summary = x[:summary]
          c.description = x[:description]
          x[:examples].each do |example|
            c.example *example
          end if x[:examples]
          x[:options].each do |option|
            c.option *option
          end if x[:options]
          c.action self, name
        end
      end
    end

    def add(files, options = {})
      quit("No files specified - see `help add` for usage", 1) if files.empty?

      files = files.map do |f|
        Dir[f].map do |f|
          Pathname.new(f).expand_path
        end
      end.flatten.uniq

      properties = get_properties(options)

      tracks = app.add_tracks(files, properties)
      puts "Added #{tracks.count} tracks" if $verbose
    end

    def search(term, options ={})
      debug "SEARCHING: #{term} (#{options})"
    end

    def quit(message, code = -1)
      $stderr.puts message
      exit code
    end

    def debug(*infos)
      return unless $debug
      infos.each { |s| puts(s.to_s) }
    end

    def app
      @app ||= ITunes::Application.new
    end

    def get_properties(options)
      properties = {}
      TRACK_PROPERTIES.keys.each do |prop|
        v = eval("options.#{prop}")
        properties[prop] = v if v
      end
      properties
    end

    extend self
  end
end
