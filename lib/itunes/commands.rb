module ITunes
  # A simple module for performing basic once-off operations on iTunes (via
  # osascript(1)).
  module Commands
    # Searches for a term in iTunes. Options available:
    # playlist:: a ref to the playlist to search (default: 'the first playlist')
    # only:: may be one of albums,artists,songs,composers,displayed or all
    def search(term, options = {})
      options[:playlist] ||= "the first playlist"
      search = "search #{options[:playlist]} for \"#{term}\""
      search << " only #{options[:only]}" if options.key?(:only)
      tell(search)
    end

    # Add files to iTunes (the default playlist).
    def add(*files)
      files = files.map do |file|
        file = Pathname.new(file).expand_path
        "POSIX file \"#{file}\""
      end
      files = "{#{files.join(', ')}}"
      tell("add #{files}")
    end

    # Remove a track from iTunes - expects the persistent ID of the track
    def delete(ref)
      tell("delete #{ref}")
    end

    # Modify track properties. Expects a ref to a track, and a hash of properties
    # to be modified. Strings values will be quoted for you.
    def edit(ref, properties = {})
      assignments = properties.map do |k, v|
        k = k.to_s.gsub(/_/, ' ') if k.is_a?(Symbol)
        v = "\"#{v}\"" if v.is_a?(String)
        "set its #{k} to #{v}"
      end.join("\n")
      tell(<<-APPLESCRIPT)
        tell #{ref}
          #{assignments}
        end tell
      APPLESCRIPT
    end

  private
    def try(command)
      <<-APPLESCRIPT
        try
          #{command}
        end try
      APPLESCRIPT
    end

    def tell(command)
      osascript(<<-APPLESCRIPT)
        tell application "iTunes"
          #{command}
        end tell
      APPLESCRIPT
    end

    def osascript(command)
      %x[osascript -ss -e '#{command}'].strip
    end
  end
end
