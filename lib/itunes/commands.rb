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
      files = Array(files).flatten.uniq.map do |file|
        "POSIX file \"#{file}\""
      end
      files = "{#{files.join(', ')}}"
      tell("add #{files}")
    end

    # Remove tracks from iTunes - it must be able to resolve the references
    def delete(*refs)
      instructions = refs.map { |ref| "delete #{ref}" }.join("\n")
      tell(instructions)
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
    # Convenience method to wrap a script in a "try" block.
    def try(command)
      <<-APPLESCRIPT
        try
          #{command}
        end try
      APPLESCRIPT
    end

    # Convenience method to call `osascript` targeting the iTunes application
    def tell(command)
      osascript(<<-APPLESCRIPT)
        tell application "iTunes"
          #{command}
        end tell
      APPLESCRIPT
    end

    # Executes the OSA script. Will call @callback if there's one specified,
    # with the script, result, return value, and the time it started. This is
    # handy for testing, and might also be useful for logging or whatever. If
    # `osascript(1)` doesn't exit with 0, a RuntimeError will be raised (the
    # callback is still called first). Otherwise, it returns the output from
    # `osascript(1)`.
    def osascript(script)
      script = script.split("\n").map(&:strip).join("\n")
      command = "osascript -ss -e '#{script}'"
      puts("EXECUTUNG: ---\n#{command}\n---") if $debug
      timestamp = Time.now
      result = %x[#{command}].strip
      @callback.call(script, result, $?, timestamp) if @callback
      puts("[#$?] ===\n#{result}\n===") if $debug
      raise("Error (#$?) running script") unless $? == 0
      result
    end
  end
end
