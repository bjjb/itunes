require 'itunes/commands'

module ITunes
  class Application
    include Commands

    @@defaults = {
      format: :plain
    }

    def initialize(config = {})
      @config = @@defaults.merge(config)
    end

    def osascript(script)
      parse(super)
    end

    def parse(s)
      string    = /"([^"]|\\")*"/
      property  = /[^:]+/
      reference = /.+/
      value     = /(#{string}|#{reference})/
      tuple     = /#{property}: #{value}/
      record    = /{(#{tuple}, )*#{tuple}}/
      s
    end
  end
end
