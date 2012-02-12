require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/unit'
require 'mocha'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mini_mongo'

MiniMongo.db = Mongo::Connection.new.db("mini_mongo_test")

class MiniTest::Unit::TestCase
  def setup
    MiniMongo.db.collections.each do |collection|
      next if collection.name =~ /^system\./
      collection.drop
    end
  end
end

MiniTest::Unit.autorun
