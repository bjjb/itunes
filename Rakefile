require "bundler/gem_tasks"
require "rake/testtask"
require "rake/clean"
require 'base64'

file "test/tmp/sample.mp3" do |t|
  mkdir('test/tmp') unless File.directory?('test/tmp')
  mp3 = Base64.decode64(<<-BASE64)
    SUQzBAAAAAAAdFRJVDIAAAAUAAADX19fc2FtcGxlX3RpdGxlX19fAFRQRTEA
    AAAVAAADX19fc2FtcGxlX2FydGlzdF9fXwBUQUxCAAAAFAAAA19fX3NhbXBs
    ZV9hbGJ1bV9fXwBUU1NFAAAADwAAA0xhdmY1NC42My4xMDQA/+M4wAAAAAAA
    AAAAAEluZm8AAAAHAAAAAwAAAbAAqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
    qqqqqqqqqqqq1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV1dXV////
    ////////////////////////////////////////TGF2ZjU0LjYzLjEwNAAA
    AAAAAAAAJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/+MYxAAAAANIAAAAAExBTUUz
    Ljk5LjVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    VVVVVVVVVVVV/+MYxDsAAANIAAAAAFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV/+MYxHYAAANI
    AAAAAFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    VVVVVVVVVVVVVVVVVVVVVVVV
  BASE64
  File.open(t.name, 'wb') { |f| f.print(mp3) }
end

CLEAN << FileList["test/tmp/**"]

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList["test/**/*_test.rb"]
end

task :test => "test/tmp/sample.mp3"

task :default => :test
