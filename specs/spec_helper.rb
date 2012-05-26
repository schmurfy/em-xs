require 'rubygems'
require 'bundler/setup'

require 'bacon'

if ENV['COVERAGE']
  Bacon.allow_focused_run = false
  
  require 'simplecov'
  SimpleCov.start do
    add_filter ".*_spec"
    add_filter "/helpers/"
  end
  
end

$LOAD_PATH.unshift( File.expand_path('../../lib' , __FILE__) )
require 'em-xs'

require 'bacon/ext/mocha'
require 'bacon/ext/em'

Thread.abort_on_exception = true

Bacon.summary_on_exit()

ENDPOINTS = {
  'inproc'  => 'inproc://socket',
  'ipc'     => 'ipc:///tmp/socket',
  'tcp'     => 'tcp://127.0.0.1:1234'
}.freeze
