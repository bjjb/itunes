require 'itunes/utils'

module ITunes
  class Record < Hash
    include Utils

    def initialize(properties = {})
      super.update(symbolize_keys(properties))
    end

    def method_missing(m, *args, &block)
      return super if block_given?
      if m.to_s =~ /=$/ and args.size == 1 and key?(symbolize($`))
        return store(symbolize($`), args.first)
      end
      if args.empty? and key?(m)
        return fetch(m)
      end
      super
    end
  end
end
