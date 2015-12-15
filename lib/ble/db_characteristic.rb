module BLE
class Characteristic
    #   C         | Integer | 8-bit unsigned (unsigned char)
    #   S         | Integer | 16-bit unsigned, native endian (uint16_t)
    #   L         | Integer | 32-bit unsigned, native endian (uint32_t)
    #   Q         | Integer | 64-bit unsigned, native endian (uint64_t)
    #             |         |
    #   c         | Integer | 8-bit signed (signed char)
    #   s         | Integer | 16-bit signed, native endian (int16_t)
    #   l         | Integer | 32-bit signed, native endian (int32_t)
    #   q         | Integer | 64-bit signed, native endian (int64_t)
    #
    #   <         | Little endian
    #   >         | Big endian

    
    
    add 0x2A6E,
        name: 'Temperature',
        type: 'org.bluetooth.characteristic.temperature',
        vrfy: ->(x) { (0..100).include?(x) },
          in: ->(s) { puts s.inspect ; s.unpack('s<').first.to_f / 100 },
         out: ->(v) { [ v*100 ].pack('s<') }

    add 0x2A76,
        name: 'UV Index',
        type: 'org.bluetooth.characteristic.uv_index',
          in: ->(s) { s.unpack('C').first },
         out: ->(v) { [ v ].pack('C') }

    add 0x2A77,
        name: 'Irradiance',
        type: 'org.bluetooth.characteristic.irradiance',
          in: ->(s) { s.unpack('S<').first.to_f / 10 },
         out: ->(v) { [ v*10 ].pack('S<') }

    add 0x2A7A,
        name: 'Heat Index',
        type: 'org.bluetooth.characteristic.heat_index',
          in: ->(s) { s.unpack('c').first },
         out: ->(v) { [ v ].pack('c') }

    add 0x2A19,
        name: 'Battery Level',
        type: 'org.bluetooth.characteristic.battery_level',
        vrfy: ->(x) { (0..100).include?(x) },
          in: ->(s) { s.unpack('C').first },
         out: ->(v) { [ v ].pack('C') }

    add 0x2A6F,
        name: 'Humidity',
        type: 'org.bluetooth.characteristic.humidity',
        vrfy: ->(x) { (0..100).include?(x) },
          in: ->(s) { s.unpack('S<').first.to_f / 100 },
         out: ->(v) { [ v*100 ].pack('S<') }

    add 0x2A6D,
        name: 'Pressure',
        type: 'org.bluetooth.characteristic.pressure',
        vrfy: ->(x) { x >= 0 },
          in: ->(s) { s.unpack('L<').first.to_f / 10 },
         out: ->(v) { [ v*10 ].pack('L<') }

    add 0x2AB3,
        name: 'Altitude',
        type: 'org.bluetooth.characteristic.altitude',
        vrfy: ->(x) { x >= 0 },
          in: ->(s) { s.unpack('S<').first },
         out: ->(v) { [ v ].pack('S<') }
end
end
