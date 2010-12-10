require File.dirname(__FILE__) + '/boot/init'
require File.dirname(__FILE__) + '/app/EolVisualizerJsonServer'

use Rack::ShowExceptions
run EolVisualizerJsonServer.new

