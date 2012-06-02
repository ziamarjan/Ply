# This file is used by Rack-based servers to start the application.

puts "SEEING #{ENV.inspect}"

require ::File.expand_path('../config/environment',  __FILE__)
run Ply::Application