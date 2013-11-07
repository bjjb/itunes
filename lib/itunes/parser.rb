require 'strscan'
require 'date'

module ITunes
  class Parser < StringScanner
    @@string = /"(?:[^"\\]|\\.)*"/
    @@float = /\d+\.\d+/
    @@integer = /\d+/
    @@date = /date "[^"]+"/
    @@boolean = /(true|false)/
    @@missing_value = /missing value/

    @@record = /{[\w ]+:/
    @@list = /{/

    def parse!
      %w[string float integer date boolean missing_value record list].each do |t|
        return send(:"#{t}!") if send(:"#{t}?")
      end
      scan(/[^,;:"]+/) # Everything else (types, etc)
    end

    def string?
      check(@@string)
    end

    def string!
      scan(@@string)[1...-1]
    end

    def float?
      check(@@float)
    end

    def float!
      Float(scan(@@float))
    end

    def integer?
      check(@@integer)
    end

    def integer!
      Integer(scan(@@integer))
    end

    def missing_value?
      check(@@missing_value)
    end
    
    def missing_value!
      skip(@@missing_value)
      nil
    end

    def boolean?
      check(@@boolean)
    end

    def boolean!
      scan(@@boolean) == "true"
    end

    def date?
      check(@@date)
    end

    def date!
      d = scan(@@date).scan(/"(.+)"/)[0][0]
      DateTime.parse(d)
    end

    def record?
      check(@@record)
    end

    def record!
      record = {}
      raise "Not a record!" unless scan(/{/)
      loop do
        k = scan(/[^:]+/)
        skip(/:\s?/)
        v = parse!
        record[k] = v
        break if scan(/\s*}/)
        raise "Error parsing record: #{inspect}" unless scan(/,\s*/)
      end
      record
    end

    def list?
      check(@@list)
    end

    def list!
      list = []
      raise "Not a list!" unless scan(/{/)
      loop do
        list << parse!
        break if scan(/\s*}/)
        raise "Invalid list! (#{rest})" unless scan(/,\s*/)
      end
      list
    end
  end
end
