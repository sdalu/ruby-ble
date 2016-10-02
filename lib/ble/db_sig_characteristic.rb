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

    add 0x2A07,
        name: 'Tx Power Level',
        type: 'org.bluetooth.characteristic.tx_power_level',
        vrfy: ->(x) { (-100..20).include?(c) },
          in: ->(s) { s.unpack('c').first },
         out: ->(v) { [ v ].pack('c') }

    add 0x2A23,
        name: 'System ID',
        type: 'org.bluetooth.characteristic.system_id',
        vrfy: ->(x) { (0..1099511627775).include?(x[0]) &&
                      (0..16777215     ).include?(x[1])},
          in: ->(s) { raise NotYetImplemented },
         out: ->(v) { raise NotYetImplemented }

    add 0x2A24,
        name: 'Model Number String',
        type: 'org.bluetooth.characteristic.model_number_string',
          in: ->(s) { s.force_encoding('UTF-8') },
         out: ->(v) { v.encode('UTF-8') }

    add 0x2A25,
        name: 'Serial Number String',
        type: 'org.bluetooth.characteristic.serial_number_string',
          in: ->(s) { s.force_encoding('UTF-8') },
         out: ->(v) { v.encode('UTF-8') }

    add 0x2A26,
        name: 'Firmware Revision String',
        type: 'org.bluetooth.characteristic.firmware_revision_string',
          in: ->(s) { s.force_encoding('UTF-8') },
         out: ->(v) { v.encode('UTF-8') }

    add 0x2A27,
        name: 'Hardware Revision String',
        type: 'org.bluetooth.characteristic.hardware_revision_string',
          in: ->(s) { s.force_encoding('UTF-8') },
         out: ->(v) { v.encode('UTF-8') }

    add 0x2A28,
        name: 'Software Revision String',
        type: 'org.bluetooth.characteristic.software_revision_string',
          in: ->(s) { s.force_encoding('UTF-8') },
         out: ->(v) { v.encode('UTF-8') }

    add 0x2A29,
        name: 'Manufacturer Name String',
        type: 'org.bluetooth.characteristic.manufacturer_name_string',
          in: ->(s) { s.force_encoding('UTF-8') },
         out: ->(v) { v.encode('UTF-8') }

    add 0x2A2A,
        name: 'IEEE 11073-20601 Regulatory Certification Data List',
        type: 'org.bluetooth.characteristic.ieee_11073-20601_regulatory_certification_data_list',
          in: ->(s) { raise NotYetImplemented },
         out: ->(v) { raise NotYetImplemented }

    add 0x2A50,
        name: 'PnP ID',
        type: 'org.bluetooth.characteristic.pnp_id',
         in: ->(s) { vendor_src, vendor_id,
                     product_id, product_version = s.unpack('CS<S<S<')
                     vendor_src = case vendor_src
                                  when 1 then :bluetooth_sig
                                  when 2 then :usb_forum
                                  else        :reserved
                                  end
                     [ vendor_src, vendor_id,
                       product_id, product_version ] },
         out: ->(v) { raise NotYetImplemented }


    add 0x2A6E,
        name: 'Temperature',
        type: 'org.bluetooth.characteristic.temperature',
        vrfy: ->(x) { (0..100).include?(x) },
          in: ->(s) { s.unpack('s<').first.to_f / 100 },
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
