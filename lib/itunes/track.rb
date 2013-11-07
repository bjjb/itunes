require 'itunes/record'
require 'itunes/commands'
require 'itunes/parser'

module ITunes
  class Track < Record
    include Commands

    def initialize(ref)
      @ref = ref
      properties = tell("get properties of #{@ref}")
      properties = Parser.new(properties).record!
      super(properties)
    end

    def store(k, v)
      result = super
      k = stringify(k)
      v = "\"#{v}\"" if v.is_a?(String) and v !~ /^".*"$/
      command = "set #{k} of #{@ref} to #{v}"
      tell(command)
      puts("SETTING #{k} to #{v}") if $debug
      result
    end
  end
end
