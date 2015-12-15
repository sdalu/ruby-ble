# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "ble/version"

Gem::Specification.new do |s|
  s.name          = "ble"
  s.version       = BLE::VERSION
  s.authors       = [ "Stephane D'Alu" ]
  s.email         = [ "stephane.dalu@gmail.com" ]
  s.homepage      = "http://github.com/sdalu/ruby-ble"
  s.summary       = "Bluetooth Low Energy API"
  s.description   = "Allow access to BLE device from ruby"

  s.add_dependency "ruby-dbus"
  
  s.add_development_dependency "yard"
  s.add_development_dependency "rake"

  s.has_rdoc      = 'yard'

  s.license       = 'MIT'
  

  s.files         = %w[ LICENSE Gemfile ble.gemspec ] 	+ 
		     Dir['lib/**/*.rb'] 
  #s.require_path  = 'lib'
end
