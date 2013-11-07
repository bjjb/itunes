module ITunes
  class Record < Hash
    def initialize(properties = {})
      properties = properties.inject({}) do |h, x|
        h[x[0].to_sym] = x[1]; h
      end
      super.update(properties)
    end

    def method_missing(m, *args, &block)
      return super if block_given?
      m = m.to_s
      if m =~ /=$/ and args.size == 1
        n = m.gsub('_', ' ').chop.to_sym
        return store(n, args.first) if key?(n)
      elsif args.empty?
        n = m.gsub('_', ' ').to_sym
        return fetch(n) if key?(n)
      end
      super
    end
  end
end
