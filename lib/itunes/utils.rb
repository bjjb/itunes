module ITunes
  module Utils
    def stringify(symbol)
      symbol.to_s.gsub('_', ' ')
    end

    def symbolize(string)
      string.to_s.gsub(' ', '_').to_sym
    end

    def stringify_keys(hash)
      hash.inject({}) do |h, pair|
        k, v = *pair
        h[stringify(k)] = v
        h
      end
    end

    def symbolize_keys(hash)
      hash.inject({}) do |h, pair|
        k, v = *pair
        h[symbolize(k)] = v
        h
      end
    end
  end
end
