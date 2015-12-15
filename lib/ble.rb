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



    def self.UUID(val)
        val.downcase
    end
    
    class UUID
        REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
    end


    

    
    

    # Check if Bluetooth API is accessible
    def self.ok?
        BLUEZ.exists?
    end
    
end

require_relative 'ble/adapter'
require_relative 'ble/device'
require_relative 'ble/service'
require_relative 'ble/characteristic'
require_relative 'ble/agent'

require_relative 'ble/db_service'
require_relative 'ble/db_characteristic'


