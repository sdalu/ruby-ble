# coding: utf-8
require 'dbus'
require 'logger'

# https://github.com/mvidner/ruby-dbus/blob/master/doc/Tutorial.md
# https://kernel.googlesource.com/pub/scm/bluetooth/bluez/+/refs/heads/master/doc/


#
module BLE
    

    private
    I_ADAPTER              = 'org.bluez.Adapter1'
    I_DEVICE               = 'org.bluez.Device1'
    I_AGENT_MANAGER        = 'org.bluez.AgentManager1'
    I_AGENT                = 'org.bluez.Agent1'
    I_GATT_CHARACTERISTIC  = 'org.bluez.GattCharacteristic1'
    I_GATT_SERVICE         = 'org.bluez.GattService1'
    I_PROXIMITY_REPORTER   = 'org.bluez.ProximityReporter1'
    I_PROPERTIES           = 'org.freedesktop.DBus.Properties'
    I_INTROSPECTABLE       = 'org.freedesktop.DBus.Introspectable'

    E_IN_PROGRESS          = 'org.bluez.Error.InProgress'
    E_FAILED               = 'org.bluez.Error.Failed'
    E_NOT_READY            = 'org.bluez.Error.NotReady'
    E_ALREADY_CONNECTED    = 'org.bluez.Error.AlreadyConnected'
    E_NOT_CONNECTED        = 'org.bluez.Error.NotConnected'
    E_DOES_NOT_EXIST       = 'org.bluez.Error.DoesNotExist'
    E_NOT_SUPPORTED        = 'org.bluez.Error.NotSupported'
    E_NOT_AUTHORIZED       = 'org.bluez.Error.NotAuthorized'
    E_INVALID_ARGUMENTS    = 'org.bluez.Error.InvalidArguments'
    E_ALREADY_EXISTS       = 'org.bluez.Error.AlreadyExists'
    E_AUTH_CANCELED        = 'org.bluez.Error.AuthenticationCanceled'
    E_AUTH_FAILED          = 'org.bluez.Error.AuthenticationFailed'
    E_AUTH_REJECTED        = 'org.bluez.Error.AuthenticationRejected'
    E_AUTH_TIMEOUT         = 'org.bluez.Error.AuthenticationTimeout'
    E_AUTH_ATTEMPT_FAILED  = 'org.bluez.Error.ConnectionAttemptFailed'

    E_UNKNOWN_OBJECT       = 'org.freedesktop.DBus.Error.UnknownObject'
    E_INVALID_ARGS         = 'org.freedesktop.DBus.Error.InvalidArgs'
    E_INVALID_SIGNATURE    = 'org.freedesktop.DBus.Error.InvalidSignature'

    DBUS  = DBus.system_bus
    BLUEZ = DBUS.service('org.bluez')

    public
    class Error                  < StandardError ; end
    class NotYetImplemented      < Error         ; end
    class StalledObject          < Error         ; end
    class NotReady               < Error         ; end
    class NotAuthorized          < Error         ; end
    class NotConnected           < Error         ; end
    class NotFound               < Error         ; end
    class ServiceNotFound        < NotFound      ; end
    class CharacteristicNotFound < NotFound      ; end
    class AccessUnavailable      < Error         ; end
    

    GATT_BASE_UUID="00000000-0000-1000-8000-00805F9B34FB"

    #"DisplayOnly", "DisplayYesNo", "KeyboardOnly",
    # "NoInputNoOutput" and "KeyboardDisplay" which


    def self.registerAgent(agent, service, path)
        raise NotYetImplemented
        bus = DBus.session_bus
        service = bus.request_service("org.ruby.service")
        
        service.export(BLE::Agent.new(agent_path))
        
        o_bluez = BLUEZ.object('/org/bluez')
        o_bluez.introspect
        o_bluez[I_AGENT_MANAGER].RegisterAgent(agent_path, "NoInputNoOutput")
    end

    
    class Agent < DBus::Object
        @log = Logger.new($stdout)
        # https://kernel.googlesource.com/pub/scm/bluetooth/bluez/+/refs/heads/master/doc/agent-api.txt
        dbus_interface I_AGENT do
            dbus_method :Release do
                @log.debug "Release()"
                exit false
            end
            
            dbus_method :RequestPinCode, "in device:o, out ret:s" do |device|
                @log.debug{ "RequestPinCode(#{device})" }
                ["0000"]
            end
            
            dbus_method :RequestPasskey, "in device:o, out ret:u" do |device|
                @log.debug{ "RequestPasskey(#{device})" }
                raise DBus.error("org.bluez.Error.Rejected")
            end
            
            dbus_method :DisplayPasskey, "in device:o, in passkey:u, in entered:y" do |device, passkey, entered|
                @log.debug{ "DisplayPasskey(#{device}, #{passkey}, #{entered})" }
                raise DBus.error("org.bluez.Error.Rejected")
            end
            
            dbus_method :RequestConfirmation, "in device:o, in passkey:u" do |device, passkey|
                @log.debug{ "RequestConfirmation(#{device}, #{passkey})" }
                raise DBus.error("org.bluez.Error.Rejected")
            end
            
            dbus_method :Authorize, "in device:o, in uuid:s" do |device, uuid|
                @log.debug{ "Authorize(#{device}, #{uuid})" }
            end
            
            dbus_method :ConfirmModeChange, "in mode:s" do |mode|
                @log.debug{ "ConfirmModeChange(#{mode})" }
                raise DBus.error("org.bluez.Error.Rejected")
            end
            
            dbus_method :Cancel do
                @log.debug "Cancel()"
                raise DBus.error("org.bluez.Error.Rejected")
            end
        end
    end


    # Adapter class
    #   Adapter.list
    #   a = Adapter.new('hci0')
    #   a.start_discover ; sleep(10) ; a.stop_discovery
    #   a.devices
    #
    class Adapter
        # Return a list of available unix device name for the
        # adapter installed on the system.
        # @return [Array<String>] list of unix device name
        def self.list
            o_bluez = BLUEZ.object('/org/bluez')
            o_bluez.introspect
            o_bluez.subnodes.reject {|adapter| ['test'].include?(adapter) }
        end

        # Create a new Adapter
        #
        # @param iface [String] name of the Unix device
        def initialize(iface)
            @iface     = iface.dup.freeze
            @o_adapter = BLUEZ.object("/org/bluez/#{@iface}")
            @o_adapter.introspect
            
            @o_adapter[I_PROPERTIES]
                .on_signal('PropertiesChanged') do |intf, props|
                puts "#{intf}: #{props.inspect}"
                case intf
                when I_ADAPTER
                    case props['Discovering']
                    when true 
                    when false
                    end
                end
            end
        end

        # The Bluetooth interface name
        # @return [String] name of the Unix device
        def iface
            @iface
        end

        # The Bluetooth device address.
        # @return [String] MAC address of the adapter
        def address
            @o_adapter[I_ADAPTER]['Address']
        end

        # The Bluetooth system name (pretty hostname).
        # @return [String]
        def name
            @o_adapter[I_ADAPTER]['Name']
        end

        # The Bluetooth friendly name.
        # In case no alias is set, it will return the system provided name.
        # @return [String]
        def alias
            @o_adapter[I_ADAPTER]['Alias']
        end

        # Set the alias name.
        #
        # When resetting the alias with an empty string, the
        # property will default back to system name
        #
        # @param val [String] new alias name.
        # @return [void]
        def alias=(val)
            @o_adapter[I_ADAPTER]['Alias'] = val.nil? ? '' : val.to_str
            nil
        end

        # Return the device corresponding to the given address.
        # @note The device object returned has a dependency on the adapter.
        #
        # @param address MAC address of the device
        # @return [Device] a device 
        def [](address)
            Device.new(@iface, address)
        end

        # This method sets the device discovery filter for the caller.
        # When this method is called with nil or an empty list of UUIDs,
        # filter is removed.
        #
        # @param uuids     a list of uuid to filter on
        # @param rssi      RSSI threshold
        # @param pathloss  pathloss threshold
        # @param transport [:auto, :bredr, :le]
        #                  type of scan to run (default: :le)
        # @note need to sync with the adapter-api.txt
        def filter(uuids, rssi: nil, pathloss: nil, transport: :le)
            unless [:auto, :bredr, :le].include?(transport)
                raise ArgumentError,
                      "transport must be one of :auto, :bredr, :le"
            end
            filter = { }

            unless uuids.nil? || uuids.empty?
                filter['UUIDs'    ] = DBus.variant('as', uuids)
            end
            unless rssi.nil?
                filter['RSSI'     ] = DBus.variant('n',  rssi)
            end
            unless pathloss.nil?
                filter['Pathloss' ] = DBus.variant('q',  pathloss)
            end
            unless transport.nil?
                filter['Transport'] = DBus.variant('s',  transport.to_s) 
            end

            @o_adapter[I_ADAPTER].SetDiscoveryFilter(filter)

            self
        end

        # Starts the device discovery session.
        # This includes an inquiry procedure and remote device name resolving.
        # Use stop_discovery to release the sessions acquired.
        # This process will start creating device objects as new devices
        # are discovered.
        #
        # @return [Boolean]
        def start_discovery
            @o_adapter[I_ADAPTER].StartDiscovery
            true
        rescue DBus::Error => e
            case e.name
            when E_IN_PROGRESS then true
            when E_FAILED      then false
            else raise ScriptError
            end
        end

        # This method will cancel any previous #start_discovery
        # transaction.
        # @note The discovery procedure is shared
        # between all discovery sessions thus calling stop_discovery
        # will only release a single session.
        #
        # @return [Boolean]
        def stop_discovery
            @o_adapter[I_ADAPTER].StopDiscovery
            true
        rescue DBus::Error => e
            case e.name
            when E_FAILED         then false
            when E_NOT_READY      then false
            when E_NOT_AUTHORIZED then raise NotAuthorized
            else raise ScriptError
            end

        end

        # List of devices MAC address that have been discovered.
        #
        # @return [Array<String>] List of devices MAC address.
        def devices
            @o_adapter.introspect # Force refresh
            @o_adapter.subnodes.map {|dev| # Format: dev_aa_bb_cc_dd_ee_ff
                dev[4..-1].tr('_', ':') }
        end
    end

    # Create de Device object
    #   d = Device::new('hci0', 'aa:bb:dd:dd:ee:ff')
    #   d = Adapter.new('hci0')['aa:bb:dd:dd:ee:ff']
    #
    #   d.services
    #   d.characteristics(:environmental_sensing)
    #   d[:environmental_sensing, :temperature]
    #
    class Device
        # @param adapter
        # @param dev
        # @param auto_refresh
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
                puts "#{intf}: #{props.inspect}"
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
        # @return [Boolean]
        def pair
            @o_dev[I_DEVICE].Pair
            true
        rescue DBus::Error => e
            case e.name
            when E_INVALID_ARGUMENTS      then false
            when E_FAILED                 then false
            when E_ALREADY_EXISTS         then true
            when E_AUTH_CANCELED          then raise NotAutorized
            when E_AUTH_FAILED            then raise NotAutorized
            when E_AUTH_REJECTED          then raise NotAutorized
            when E_AUTH_TIMEOUT           then raise NotAutorized
            when E_AUTH_ATTEMPT_FAILED    then raise NotAutorized
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
                raise NotSuppported
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
            else raise
            end
        end

        # List of available services as UUID
        #
        # @raise [NotConnected] if device is not in a connected state
        # @note The list is retrieve once when object is
        #       connected if auto_refresh is enable, otherwise
        #       you need to call #refresh
        # @note This is the list of UUID for which we have an entry
        #       in the bluez-dbus
        # @return [Array<String>] List of service UUID
        def services
            raise NotConnected unless is_connected?
            @services.keys
        end

        # Check if service is available on the device
        # @return [Boolean]
        def has_service?(service)
            @service.key?(_uuid_service(service))
        end
        
        # List of available characteristics UUID for a service
        #
        # @param service service can be a UUID, a service type or
        #               a service nickname
        # @return [Array<String>, nil] list of characteristics or nil if the
        #                      service doesn't exist
        # @raise [NotConnected] if device is not in a connected state
        # @note The list is retrieve once when object is
        #       connected if auto_refresh is enable, otherwise
        #       you need to call #refresh
        def characteristics(service)
            raise NotConnected unless is_connected?
            if chars = _characteristics(service)
                chars.keys
            end
        end

        # The Bluetooth device address of the remote device
        # @return [String]
        def address
            @o_dev[I_DEVICE]['Address']
        end

        # The Bluetooth remote name.
        # It is better to always use the #alias when displaying the
        # devices name. 
        # @return [String]
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

        # if set to true any incoming connections from the
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
            raise NotConnected unless is_connected?
            max_wait ||= 1.5  # Use ||= due to the retry
            @services = Hash[@o_dev[I_DEVICE]['GattServices'].map {|p_srv|
                o_srv = BLUEZ.object(p_srv)
                o_srv.introspect
                srv = o_srv[I_PROPERTIES].GetAll(I_GATT_SERVICE).first
                char = Hash[srv['Characteristics'].map {|p_char|
                    o_char = BLUEZ.object(p_char)
                    o_char.introspect
                    uuid  = o_char[I_GATT_CHARACTERISTIC]['UUID' ].downcase
                    flags = o_char[I_GATT_CHARACTERISTIC]['Flags']
                    [ uuid, { :uuid => uuid, :flags => flags, :obj => o_char } ]
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

        # @param service [String, Symbol]
        # @param characteristic [String, Symbol]
        # @param raw [Boolean]
        # @raise [NotYetImplemented, NotConnected, ServiceNotFound,
        #         CharacteristicNotFound, AccessUnavailable ]
        def [](service, characteristic, raw: false)
            raise NotConnected unless is_connected?
            uuid  = _uuid_characteristic(characteristic)
            chars = _characteristics(service)
            raise ServiceNotFound,        service        if chars.nil?
            char  = chars[uuid]
            raise CharacteristicNotFound, characteristic if char.nil?
            flags = char[:flags]
            obj   = char[:obj]
            info  = Characteristic[uuid]

            if flags.include?('read')
                val = obj[I_GATT_CHARACTERISTIC].ReadValue().first
                val = val.pack('C*')
                val = info[:in].call(val) if !raw && info && info[:in]
                val
            elsif flags.include?('encrypt-read') ||
                  flags.include?('encrypt-authenticated-read')
                raise NotYetImplemented
            else
                raise AccessUnavailable
            end
        end

        # @param service [String, Symbol]
        # @param characteristic [String, Symbol]
        # @param val [Boolean]
        # @raise [NotYetImplemented, NotConnected, ServiceNotFound,
        #         CharacteristicNotFound, AccessUnavailable ]
        def []=(service, characteristic, val, raw: false)
            raise NotConnected unless is_connected?
            uuid  = _uuid_characteristic(characteristic)
            chars = _characteristics(service)
            raise ServiceNotFound,        service        if chars.nil?
            char  = chars[uuid]
            raise CharacteristicNotFound, characteristic if char.nil?
            flags = char[:flags]
            obj   = char[:obj]
            info  = Characteristic[uuid]

            if flags.include?('write') ||
               flags.include?('write-without-response')
                if !raw && info
                    if info[:vrfy] && !info[:vrfy].call(vall)
                        raise ArgumentError,
                              "bad value for characteristic '#{characteristic}'"
                    end
                    val = info[:out].call(val) if info[:out]
                end
                val = val.unpack('C*')
                obj[I_GATT_CHARACTERISTIC].WriteValue(val)
            elsif flags.include?('encrypt-write') ||
                  flags.include?('encrypt-authenticated-write')
                raise NotYetImplemented
            else
                raise AccessUnavailable
            end
        end

        private

        def _characteristics(service)
            if srv = @services[_uuid_service(service)]
                srv[:characteristics]
            end
        end
        def _uuid_service(service)
            uuid = case service
                   when Symbol
                       if i = Service::NICKNAME[service]
                           i[:uuid]
                       end
                   when UUID::REGEX
                       service.downcase
                   when String
                       if i = Service::TYPE[service]
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
                   when Symbol
                       if i = Characteristic::NICKNAME[characteristic]
                           i[:uuid]
                       end
                   when UUID::REGEX
                       characteristic.downcase
                   when String
                       if i = Characteristic::TYPE[characteristic]
                           i[:uuid]
                       end
                   end
            if uuid.nil?
                raise ArgumentError, "unable to get UUID for service"
            end

            uuid
        end


    end

    def self.UUID(val)
        val.downcase
    end
    
    class UUID
        REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
    end

    class Service
        UUID     = {}
        TYPE     = {}
        NICKNAME = {}

        # Get a service description from it's id
        # @param id [Symbol,String]
        # @return [Hash]
        def self.[](id)
            case id
            when Symbol      then NICKNAME[id]
            when UUID::REGEX  then UUID[id]
            when String      then TYPE[id]
            else raise ArgumentError, "invalid type for service id"
            end
        end

        # Add a service description
        # @param uuid [String]
        # @param name [String]
        # @param type [String]
        def self.add(uuid, name:, type:, **opts)
            if opts.first 
                raise ArgumentError, "unknown keyword: #{opts.first[0]}" 
            end

            uuid = case uuid
                   when Integer
                       if !(0..4294967296).include?(uuid)
                           raise ArgumentError, "not a 16bit or 32bit uuid"
                       end
                       ([uuid].pack("L>").unpack('H*').first +
                           "-0000-1000-8000-00805F9B34FB")
                       
                   when String
                       if uuid !~ UUID::REGEX
                           raise ArgumentError, "not a 128bit uuid string"
                       end
                       uuid
                   else raise ArgumentError, "invalid uuid type"
                   end
            uuid = uuid.downcase
            type = type.downcase

            TYPE[type] = UUID[uuid] = {
                name: name,
                type: type,
                uuid: uuid,
            }

            stype  = type.split('.')
            key    = stype.pop.to_sym
            prefix = stype.join('.')
            case prefix
            when 'org.bluetooth.service'
                if NICKNAME.include?(key)
                    raise ArgumentError,
                          "nickname '#{key}' already registered (type: #{type})"
                end
                NICKNAME[key] = UUID[uuid]
            end
        end
        
        def initialize(service)
            @o_srv = BLUEZ.object(service)
            @o_srv.introspect
        end


    end

    

    
    class Characteristic
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


        UUID     = {}
        TYPE     = {}
        NICKNAME = {}
        
        # Get a characteristic description from it's id
        # @param id [Symbol,String]
        # @return [Hash]
        def self.[](id)
            case id
            when Symbol      then NICKNAME[id]
            when UUID::REGEX  then UUID[id]
            when String      then TYPE[id]
            else raise ArgumentError, "invalid type for characteristic id"
            end
        end
        

        # Add a characteristic description
        # @param uuid [String]
        # @param name [String]
        # @param type [String]
        # @option opts :in  [Proc] convert to ruby
        # @option opts :out [Proc] convert to bluetooth data
        # @option opts :vry [Proc] verify
        def self.add(uuid, name:, type:, **opts)
            _in   = opts.delete :in
            _out  = opts.delete :out
            vrfy  = opts.delete :vrfy            
            if opts.first 
                raise ArgumentError, "unknown keyword: #{opts.first[0]}" 
            end

            uuid = case uuid
                   when Integer
                       if !(0..4294967296).include?(uuid)
                           raise ArgumentError, "not a 16bit or 32bit uuid"
                       end
                       ([uuid].pack("L>").unpack('H*').first +
                           "-0000-1000-8000-00805F9B34FB")
                       
                   when String
                       if uuid !~ UUID::REGEX
                           raise ArgumentError, "not a 128bit uuid string"
                       end
                       uuid
                   else raise ArgumentError, "invalid uuid type"
                   end
            uuid = uuid.downcase
            type = type.downcase

            TYPE[type] = UUID[uuid] = {
                name: name,
                type: type,
                uuid: uuid,
                  in: _in,
                 out: _out,
                vrfy: vrfy
            }

            stype  = type.split('.')
            key    = stype.pop.to_sym
            prefix = stype.join('.')
            case prefix
            when 'org.bluetooth.characteristic'
                if NICKNAME.include?(key)
                    raise ArgumentError,
                          "nickname '#{key}' already registered (type: #{type})"
                end
                NICKNAME[key] = UUID[uuid]
            end
        end
    end
    

    # Check if Bluetooth API is accessible
    def self.ok?
        BLUEZ.exists?
    end
    
end

require_relative 'ble/db_service'
require_relative 'ble/db_characteristic'


