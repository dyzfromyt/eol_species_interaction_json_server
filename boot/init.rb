# Then set the application root
APPROOT = File.expand_path(File.dirname(__FILE__) + "/../")

# before loading any of our own dependencies.
LOAD_PATHS = [ "/app", "/app/models", "/lib", "/vendor/{gems/,}*/lib" ]
LOAD_PATHS.each do |path|
    $:.unshift *Dir[APPROOT + path].map { |d| File.expand_path(d) }
end

require 'rubygems'
require 'sinatra'
require 'datamapper'
require 'json/pure'
require 'set'
# load models
require 'Interaction'
require 'Organism'
require 'Observation'
require 'Ecosystem'
require 'EcoToTax'
DataMapper.setup(:default, "mysql://root:@localhost/eol")

