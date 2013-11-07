require 'minitest/autorun'
require 'pathname'
require 'digest/md5'
require 'yaml'

def `(*args)
  path = Pathname.new(__FILE__).join("../.record").expand_path
  record = YAML.load(path.read) rescue {}
  key = Digest::MD5::hexdigest(args.join)
  record[key] ||= super
  path.open('w') { |f| YAML.dump(record, f) }
  record[key]
end
