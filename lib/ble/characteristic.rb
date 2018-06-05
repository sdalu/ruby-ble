require 'forwardable'
require 'concurrent'
module BLE
  # Build information about {https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicsHome.aspx Bluetooth Characteristics}
  #
  class Characteristic
    include CharRegistry
    extend Forwardable

    # Notify of characteristic not found
    class NotFound < BLE::NotFound
    end

    def initialize(desc)
      @dbus_obj= desc[:obj]
      @desc= CharDesc.new(desc)
    end

    def_delegators :@desc, :flag?, :uuid

    private
    FLAGS    = [ 'broadcast',
      'read',
      'write-without-response',
      'write',
      'notify',
      'indicate',
      'authenticated-signed-writes',
      'reliable-write',
      'writable-auxiliaries',
      'encrypt-read',
      'encrypt-write',
      'encrypt-authenticated-read',
      'encrypt-authenticated-write' ]


    #++++++++++++++++++++++++++++
    public
    #++++++++++++++++++++++++++++

    def write(val, raw: false)
      val= _serialize_value(val, raw: raw)
      @dbus_obj[I_GATT_CHARACTERISTIC].WriteValue(val, [])
    end

    def async_write(val, raw: false)
      val= _serialize_value(val, raw: raw)
      Concurrent::Promise.execute do
        @dbus_obj[I_GATT_CHARACTERISTIC].WriteValue(val, []) do |result|
          result
        end
      end
    end

    def read(raw: false)
      val= @dbus_obj[I_GATT_CHARACTERISTIC].ReadValue().first
      val= _deserialize_value(val, raw: raw)
    end

    def async_read(raw: false)
      return Concurrent::Promise.execute do
        @dbus_obj[I_GATT_CHARACTERISTIC].ReadValue() do |result|
          val= result.first
          val= _deserialize_value(val, raw: raw)
        end
      end
    end

    # Register to this characteristic for notifications when
    # its value changes.
    def notify!
      @dbus_obj[I_GATT_CHARACTERISTIC].StartNotify
    end

    def on_change(raw: false, &callback)
      @dbus_obj[I_PROPERTIES].on_signal('PropertiesChanged') do |intf, props|
        case intf
        when I_GATT_CHARACTERISTIC
          val= _deserialize_value(props['Value'], raw: raw)
          callback.call(val)
        end
      end
    end
    #----------------------------
    private
    #----------------------------

    # Convert Arrays of bytes returned by DBus to Strings of bytes.
    def _serialize_value(val, raw: false)
      if !raw && @desc.write_processors?
        val= @desc.pre_process(val)
      end
      val.unpack('C*')
    end

    # Convert Arrays of bytes returned by DBus to Strings of bytes.
    def _deserialize_value(val, raw: false)
      val = val.pack('C*')
      val = @desc.post_process(val) if !raw && @desc.read_processors?
      val
    end

  end
end
