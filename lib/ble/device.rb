module BLE
  # Create de Device object
  #   d = Device::new('hci0', 'aa:bb:dd:dd:ee:ff')
  #   d = Adapter.new('hci0')['aa:bb:dd:dd:ee:ff']
  #
  #   d.services
  #   d.characteristics(:environmental_sensing)
  #   d[:environmental_sensing, :temperature]
  #
  class Device
    include Notifications
    # Notify that you need to have the device in a connected state
    class NotConnected           < Error         ; end

    # @param adapter      [String]  adapter unix device name
    # @param dev          [String]  device MAC address
    # @param auto_refresh [Boolean] gather information about device
    #                               on connection
    def initialize(adapter, dev, auto_refresh: true)
      @adapter, @dev = adapter, dev
      @auto_refresh  = auto_refresh
      @services      = {}

      @n_adapter = adapter
      @p_adapter = "/org/bluez/#{@n_adapter}"
      @o_adapter = BLUEZ.object(@p_adapter)
      @o_adapter.introspect

      @n_dev     = 'dev_' + dev.tr(':', '_')
      @p_dev     = "/org/bluez/#{@n_adapter}/#{@n_dev}"
      @o_dev     = BLUEZ.object(@p_dev)
      @o_dev.introspect

      self.refresh if @auto_refresh

      @o_dev[I_PROPERTIES]
      .on_signal('PropertiesChanged') do |intf, props|
        case intf
        when I_DEVICE
          case props['Connected']
          when true
            self.refresh if @auto_refresh
          end
        end
      end
    end

    # This removes the remote device object.
    # It will remove also the pairing information.
    # @return [Boolean]
    def remove
      @o_adapter[I_ADAPTER].RemoveDevice(@p_dev)
      true
    rescue DBus::Error => e
      case e.name
      when E_FAILED         then false
      when E_DOES_NOT_EXIST then raise StalledObject
      when E_UNKNOWN_OBJECT then raise StalledObject
      else raise ScriptError
      end
    end


    # This method will connect to the remote device,
    # initiate pairing and then retrieve all SDP records
    # (or GATT primary services).
    # If the application has registered its own agent,
    # then that specific agent will be used. Otherwise
    # it will use the default agent.
    # Only for applications like a pairing wizard it
    # would make sense to have its own agent. In almost
    # all other cases the default agent will handle this just fine.
    # In case there is no application agent and also
    # no default agent present, this method will fail.
    #
    # @return [Boolean]
    def pair
      @o_dev[I_DEVICE].Pair
      true
    rescue DBus::Error => e
      case e.name
      when E_INVALID_ARGUMENTS      then false
      when E_FAILED                 then false
      when E_ALREADY_EXISTS         then true
      when E_AUTH_CANCELED          then raise NotAuthorized
      when E_AUTH_FAILED            then raise NotAuthorized
      when E_AUTH_REJECTED          then raise NotAuthorized
      when E_AUTH_TIMEOUT           then raise NotAuthorized
      when E_AUTH_ATTEMPT_FAILED    then raise NotAuthorized
      else raise ScriptError
      end
    end

    # This method can be used to cancel a pairing
    # operation initiated by the Pair method.
    # @return [Boolean]
    def cancel_pairing
      @o_dev[I_DEVICE].CancelPairing
      true
    rescue DBus::Error => e
      case e.name
      when E_DOES_NOT_EXIST then true
      when E_FAILED         then false
      else raise ScriptError
      end
    end

    # This connect to the specified profile UUID or to any (:all)
    # profiles the remote device supports that can be connected to
    # and have been flagged as auto-connectable on our side.  If
    # only subset of profiles is already connected it will try to
    # connect currently disconnected ones.  If at least one
    # profile was connected successfully this method will indicate
    # success.
    # @return [Boolean]
    def connect(profile=:all)
      case profile
      when UUID::REGEX
        @o_dev[I_DEVICE].ConnectProfile(profile)
      when :all
        @o_dev[I_DEVICE].Connect()
      else raise ArgumentError, "profile uuid or :all expected"
      end
      true
    rescue DBus::Error => e
      case e.name
      when E_NOT_READY
      when E_FAILED
      when E_IN_PROGRESS
        false
      when E_ALREADY_CONNECTED
        true
      when E_UNKNOWN_OBJECT
        raise StalledObject
      else raise ScriptError
      end
    end

    # This method gracefully disconnects :all connected profiles
    # and then terminates low-level ACL connection.
    # ACL connection will be terminated even if some profiles
    # were not disconnected properly e.g. due to misbehaving device.
    # This method can be also used to cancel a preceding #connect
    # call before a reply to it has been received.
    # If a profile UUID is specified, only this profile is disconnected,
    # and as their is no connection tracking for a profile, so
    # as long as the profile is registered this will always succeed
    # @return [Boolean]
    def disconnect(profile=:all)
      case profile
      when UUID::REGEX
        @o_dev[I_DEVICE].DisconnectProfile(profile)
      when :all
        @o_dev[I_DEVICE].Disconnect()
      else raise ArgumentError, "profile uuid or :all expected"
      end
      true
    rescue DBus::Error => e
      case e.name
      when E_FAILED
      when E_IN_PROGRESS
        false
      when E_INVALID_ARGUMENTS
        raise ArgumentError, "unsupported profile (#{profile})"
      when E_NOT_SUPPORTED
        raise NotSupported
      when E_NOT_CONNECTED
        true
      when E_UNKNOWN_OBJECT
        raise StalledObject
      else raise ScriptError
      end
    end

    # Indicates if the remote device is paired
    def is_paired?
      @o_dev[I_DEVICE]['Paired']
    rescue DBus::Error => e
      case e.name
      when E_UNKNOWN_OBJECT
        raise StalledObject
      else raise ScriptError
      end
    end

    # Indicates if the remote device is currently connected.
    def is_connected?
      @o_dev[I_DEVICE]['Connected']
    rescue DBus::Error => e
      case e.name
      when E_UNKNOWN_OBJECT
        raise StalledObject
      else raise ScriptError
      end
    end

    # List of available services as UUID.
    #
    # @raise [NotConnected] if device is not in a connected state
    # @note The list is retrieve once when object is
    #       connected if auto_refresh is enable, otherwise
    #       you need to call {#refresh}.
    # @note This is the list of UUIDs for which we have an entry
    #       in the underlying api (bluez-dbus), which can be less
    #       that the list of advertised UUIDs.
    # @example list available services
    #   $d.services.each {|uuid|
    #     info = BLE::Service[uuid]
    #     name = info.nil? ? uuid : info[:name]
    #     puts name
    #   }
    #
    # @return [Array<String>] List of service UUID
    def services
      _require_connection!
      @services.keys
    end

    # Check if service is available on the device
    # @return [Boolean]
    def has_service?(service)
      @service.key?(_uuid_service(service))
    end

    # List of available characteristics UUID for a service.
    #
    # @param service service can be a UUID, a service type or
    #               a service nickname
    # @return [Array<String>, nil] list of characteristics or +nil+ if the
    #                      service doesn't exist
    # @raise [NotConnected] if device is not in a connected state
    # @note The list is retrieve once when object is
    #       connected if auto_refresh is enable, otherwise
    #       you need to call {#refresh}.
    def characteristics(service)
      _require_connection!
      if chars = _characteristics(service)
        chars.keys
      end
    end

    # The Bluetooth device address of the remote device.
    # @return [String] MAC address
    def address
      @o_dev[I_DEVICE]['Address']
    end

    # The Bluetooth remote name.
    # It is better to always use the {#alias} when displaying the
    # devices name.
    # @return [String] name
    def name # optional
      @o_dev[I_DEVICE]['Name']
    end

    # The name alias for the remote device.
    # The alias can be used to have a different friendly name for the
    # remote device.
    # In case no alias is set, it will return the remote device name.
    # @return [String]
    def alias
      @o_dev[I_DEVICE]['Alias']
    end
    # Setting an empty string or nil as alias will convert it
    # back to the remote device name.
    # @param val [String, nil]
    # @return [void]
    def alias=(val)
      @o_dev[I_DEVICE]['Alias'] = val.nil? ? "" : val.to_str
    end

    # Is the device trusted?
    # @return [Boolean]
    def is_trusted?
      @o_dev[I_DEVICE]['Trusted']
    end

    # Indicates if the remote is seen as trusted. This
    # setting can be changed by the application.
    # @param val [Boolean]
    # @return [void]
    def trusted=(val)
      if ! [ true, false ].include?(val)
        raise ArgumentError, "value must be a boolean"
      end
      @o_dev[I_DEVICE]['Trusted'] = val
    end

    # Is the device blocked?
    # @return [Boolean]
    def is_blocked?
      @o_dev[I_DEVICE]['Blocked']
    end

    # If set to true any incoming connections from the
    # device will be immediately rejected. Any device
    # drivers will also be removed and no new ones will
    # be probed as long as the device is blocked
    # @param val [Boolean]
    # @return [void]
    def blocked=(val)
      if ! [ true, false ].include?(val)
        raise ArgumentError, "value must be a boolean"
      end
      @o_dev[I_DEVICE]['Blocked'] = val
    end

    # Received Signal Strength Indicator of the remote
    # device (inquiry or advertising).
    # @return [Integer]
    def rssi # optional
      @o_dev[I_DEVICE]['RSSI']
    rescue DBus::Error => e
      case e.name
      when E_INVALID_ARGS then raise NotSupported
      else raise ScriptError
      end
    end

    # Advertised transmitted power level (inquiry or advertising).
    # @return [Integer]
    def tx_power # optional
      @o_dev[I_DEVICE]['TxPower']
    rescue DBus::Error => e
      case e.name
      when E_INVALID_ARGS then raise NotSupported
      else raise ScriptError
      end
    end


    # Refresh list of services and characteristics
    # @return [Boolean]
    def refresh
      refresh!
      true
    rescue NotConnected, StalledObject
      false
    end

    # Refresh list of services and characteristics
    # @raise [NotConnected] if device is not in a connected state
    # @return [self]
    def refresh!
      _require_connection!
      max_wait ||= 1.5  # Use ||= due to the retry
      @services = Hash[@o_dev[I_DEVICE]['GattServices'].map {|p_srv|
          o_srv = BLUEZ.object(p_srv)
          o_srv.introspect
          srv   = o_srv[I_PROPERTIES].GetAll(I_GATT_SERVICE).first
          char  = Hash[srv['Characteristics'].map {|p_char|
              o_char = BLUEZ.object(p_char)
              o_char.introspect
              uuid  = o_char[I_GATT_CHARACTERISTIC]['UUID' ].downcase
              flags = o_char[I_GATT_CHARACTERISTIC]['Flags']
              [ uuid, Characteristic.new({ :uuid => uuid, :flags => flags, :obj => o_char }) ]
            }]
          uuid = srv['UUID'].downcase
          [ uuid, { :uuid            => uuid,
              :primary         => srv['Primary'],
              :characteristics => char } ]
        }]
      self
    rescue DBus::Error => e
      case e.name
      when E_UNKNOWN_OBJECT
        raise StalledObject
      when E_INVALID_ARGS
        # That's probably because all the bluez information
        # haven't been collected yet on dbus for GattServices
        if max_wait > 0
          sleep(0.25) ; max_wait -= 0.25 ; retry
        end
        raise NotReady

      else raise ScriptError
      end
    end

    # Get value for a service/characteristic.
    #
    # @param service [String, Symbol]
    # @param characteristic [String, Symbol]
    # @param raw [Boolean] When raw is true the value get is a binary string, instead of an object corresponding to the decoded characteristic (float, integer, array, ...)
    # @raise [NotConnected] if device is not in a connected state
    # @raise [NotYetImplemented] encryption is not implemented yet
    # @raise [Service::NotFound, Characteristic::NotFound] if service/characteristic doesn't exist on this device
    # @raise [AccessUnavailable] if not available for reading
    # @return [Object]
    def [](service, characteristic, raw: false)
      _require_connection!
      uuid  = _uuid_characteristic(characteristic)
      chars = _characteristics(service)
      raise Service::NotFound,        service        if chars.nil?
      char  = chars[uuid]
      raise Characteristic::NotFound, characteristic if char.nil?

      if char.flag?('read')
        char.read(raw: raw)
      elsif char.flag?('encrypt-read') ||
          char.flag?('encrypt-authenticated-read')
        raise NotYetImplemented
      else
        raise AccessUnavailable
      end
    end

    # Set value for a service/characteristic
    #
    # @param service [String, Symbol]
    # @param characteristic [String, Symbol]
    # @param val [Boolean]
    # @param raw [Boolean] When raw is true the value set is a binary string, instead of an object corresponding to the decoded characteristic (float, integer, array, ...).
    # @raise [NotConnected] if device is not in a connected state
    # @raise [NotYetImplemented] encryption is not implemented yet
    # @raise [Service::NotFound, Characteristic::NotFound] if service/characteristic doesn't exist on this device
    # @raise [AccessUnavailable] if not available for writing
    # @return [void]
    def []=(service, characteristic, val, raw: false)
      _require_connection!
      uuid  = _uuid_characteristic(characteristic)
      chars = _characteristics(service)
      raise ServiceNotFound,        service        if chars.nil?
      char  = chars[uuid]
      raise CharacteristicNotFound, characteristic if char.nil?

      if char.flag?('write') ||
          char.flag?('write-without-response')
        char.write(val, raw: raw)
      elsif char.flag?('encrypt-write') ||
          char.flag?('encrypt-authenticated-write')
        raise NotYetImplemented
      else
        raise AccessUnavailable
      end
      nil
    end

    #---------------------------------
    private
    #---------------------------------
    def _require_connection!
      raise NotConnected unless is_connected?
    end

    def _find_characteristic(service_id, char_id)
      uuid= _uuid_characteristic(char_id)
      chars= _characteristics(service_id)
      raise Service::NotFound, service_id if chars.nil?
      char= chars[uuid]
      raise Characteristic::NotFound, char_id if char.nil?
      char
    end

    # @param service [String, Symbol] The id of the service.
    # @return [Hash] The descriptions of the characteristics for the given service.
    def _characteristics(service)
      if srv = @services[_uuid_service(service)]
        srv[:characteristics]
      end
    end
    def _uuid_service(service)
      uuid = case service
      when UUID::REGEX
        service.downcase
      else
        if i = Service[service]
          i[:uuid]
        end
      end
      if uuid.nil?
        raise ArgumentError, "unable to get UUID for service"
      end

      uuid
    end
    def _uuid_characteristic(characteristic)
      uuid = case characteristic
             when UUID::REGEX
                 characteristic.downcase
             else
                 if char = Characteristic[characteristic]
                     char.uuid
                 end
             end
      if uuid.nil?
          raise ArgumentError, "unable to get UUID for characteristic"
      end

      uuid
    end

  end
end
