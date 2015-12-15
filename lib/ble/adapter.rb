module BLE
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
        
        # @o_adapter[I_PROPERTIES]
        #     .on_signal('PropertiesChanged') do |intf, props|
        #     end
        # end
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
    # When this method is called with +nil+ or an empty list of UUIDs,
    # filter is removed.
    #
    # @todo Need to sync with the adapter-api.txt
    #
    # @param uuids     a list of uuid to filter on
    # @param rssi      RSSI threshold
    # @param pathloss  pathloss threshold
    # @param transport [:auto, :bredr, :le]
    #                  type of scan to run (default: :le)
    # @return [self]
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
    # Use {#stop_discovery} to release the sessions acquired.
    # This process will start creating device in the underlying api
    # as new devices are discovered.
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
    
    # This method will cancel any previous {#start_discovery}
    # transaction.
    # @note The discovery procedure is shared
    # between all discovery sessions thus calling {#stop_discovery}
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
end
