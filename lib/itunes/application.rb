require 'itunes/commands'
require 'itunes/parser'
require 'itunes/track'

module ITunes
  class Application
    include Commands

    # Make a new Application
    def initialize(config = {})
      @config = @@defaults.merge(config)
    end

    # See ITunes::Commands#osascript
    attr_accessor :callback

    # Asks iTunes for the version
    def version
      tell("get version")
    end

    def osascript(script)
      parse(super)
    end

    def parse(s)
      Parser.new(s).parse!
    end

    def add_track(file, options = {})
      puts("ADDING TRACK: #{file.inspect} (#{options.inspect})") if $debug
      file = Pathname.new(file).expand_path
      track = Track.new(add(file))
      options.each { |k, v| track.store(k, v) }
      track
    end

    def add_tracks(files, options = {})
      puts "ADDING TRACKs: #{files.inspect} (#{options.inspect})" if $debug
      files.map do |f|
        add_track(f, options)
      end
    end

    @@defaults = {
      format: :plain
    }

    # The default action is nothing.
    @@default_callback = lambda do |i, o, x, t|
    end

  end
end
