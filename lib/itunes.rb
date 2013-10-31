require "itunes/version"

module ITunes
  # Add tracks to iTunes. `tracks` should be an array of Strings, representing
  # file paths (such as those passed on the command-line). Options will most
  # likely come from Commander, but an OpenStruct will work as well. See
  # `add_track` for the real implementation.
  def add(tracks, options = {})
    paths = tracks.map { |f| Pathname.new(f).expand_path }
    paths.each do |path|
      puts "Couldn't read file #{path}!" and exit -1 unless path.readable?
      add_track(path, options.dup)
    end
  end

  # Remove tracks from iTunes.

  # Adds a single track to iTunes. `path` is a Pathname object, representing a
  # real readable file.
  def add_track(path, options = {})
    properties = properties_from(options)
    track = tell('add POSIX file "%s"' % path)
    raise "Failed to add track" if track.empty?
    uuid = tell('get persistent ID of %s' % track)
  end

  # Looks up a track from its path on disk. This is very slow, because I
  # couldn't figure out how to do a neat list filter based on the POSIX path of
  # locations of tracks, so the script loops over all tracks. You can limit this
  # by specifying a playlist as the second option.
  # Returns a reference to the track.
  def find_track_by_path(path, playlist = nil)
    filter = "in playlist \"#{playlist}\"" unless playlist.nil?
    path = Pathname.new(path).expand_path
    if respond_to?(:db) and db.ready?
    else
      applescript <<-APPLESCRIPT
        on findByPath(thePath)
          tell application "iTunes"
            repeat with aTrack in tracks #{filter}
              set aLocation to the location of aTrack
              if aLocation is not missing value
                if the POSIX path of aLocation is equal to thePath
                  set anID to the persistent ID of aTrack
                  return the first track whose persistent ID is equal to anID
                end if
              end if
            end repeat
          end tell
        end findByPath
        my findByPath("#{path}")
      APPLESCRIPT
    end
  end

  # Remove a track (see `specify_track`).
  def delete_track(track)
    tell('delete %s' % track)
  end

  # Tell iTunes to do something.
  def tell(command)
    applescript('tell application "iTunes" to %s' % command).strip
  end

  # Extract track properties from the options (add/edit commands)
  def properties_from(options)
    options
  end

  # Converts a HSA path or a location, or an alias (etc) to a POSIX path
  def posix_path_of(hsa_path)
    applescript('get POSIX path of "%s"' % hsa_file)
  end

  # Convert a POSIX path to a HSA path
  def hsa_path_of(posix_path)
    applescript('get POSIX FILE "%s"' % posix_path)
  end

  # Run an applescript, and return the result.
  # Might be specified globally by Commander, or defined here.
  def applescript(script)
    %x[osascript -e "#{ script.gsub('"', '\"') }"]
  end unless defined?(applescript)

  extend self
end
