# ruby-ble
Bluetooth Low Energy for Ruby
[![Gem Version](https://badge.fury.io/rb/ble.svg)](https://badge.fury.io/rb/ble)

## Requirements
* ruby >= 2.3
* Dbus
* bluez >= 5.36 (available on debian testing)
* `bluetoothd` started with option `-E` (experimental)

## Examples
```ruby
# Selecter adapter
$a = BLE::Adapter.new('hci0')
puts "Info: #{$a.iface} #{$a.address} #{$a.name}"

# Run discovery
$a.start_discovery
sleep(2)
$a.stop_discovery

# Get device and connect to it
$d = $a['F4:AD:CB:FB:B4:85']
$d.connect

# Get temperature from the environmental sensing service
$d[:environmental_sensing, :temperature]

# Dump device information
srv = :device_information
$d.characteristics(srv).each {|uuid|
    info  = BLE::Characteristic[uuid]
    name  = info.nil? ? uuid : info[:name]
    value = $d[srv, uuid] rescue '/!\\ not-readable /!\\'
    puts "%-30s: %s" % [ name, value ]
}

```

## Contributors
* Oliver Valls (tramuntanal): Bug fixes / BLE Notification support
