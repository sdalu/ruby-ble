# ruby-ble
Bluetooth Low Energy for Ruby

## Requirements
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

# Get devise and connect to it
$d = $a['F4:AD:CB:FB:B4:85']
$d.connect

# Get temperature from the environmental sensing service
$d[:environmental_sensing, :temperature]

```
