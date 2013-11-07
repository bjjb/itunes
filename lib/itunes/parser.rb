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

    def parse!(glob = /.+/)
      %w[string float integer date boolean missing_value record list].each do |t|
        return send(:"#{t}!") if send(:"#{t}?")
      end
      scan(glob) # Everything else (types, etc)
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
      scan(@@missing_value)
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
        break if scan(/}/)
        k = scan(/[^:]+/)
        scan(/:\s*/)
        v = parse!(/[^,}]+/)
        record[k] = v
        scan(/\s*,\s*/)
      end
      record
    end

    def list?
      check(@@list)
    end

    def list!
      list = []
      raise "Not a list! (#{inspect})" unless scan(/{/)
      loop do
        break if scan(/}/)
        list << parse!(/\s?[^,}]+/)
        scan(/\s?,\s?/)
      end
      list
    end
  end
end
