# coding: utf-8
require 'dbus'
require 'logger'

# https://github.com/mvidner/ruby-dbus/blob/master/doc/Tutorial.md
# https://kernel.googlesource.com/pub/scm/bluetooth/bluez/+/refs/heads/master/doc/


#
module BLE
    private
    # Interfaces
    I_ADAPTER              = 'org.bluez.Adapter1'
    I_DEVICE               = 'org.bluez.Device1'
    I_AGENT_MANAGER        = 'org.bluez.AgentManager1'
    I_AGENT                = 'org.bluez.Agent1'
    I_GATT_CHARACTERISTIC  = 'org.bluez.GattCharacteristic1'
    I_GATT_SERVICE         = 'org.bluez.GattService1'
    I_PROXIMITY_REPORTER   = 'org.bluez.ProximityReporter1'
    I_PROPERTIES           = 'org.freedesktop.DBus.Properties'
    I_INTROSPECTABLE       = 'org.freedesktop.DBus.Introspectable'

    # Errors
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

    # Bus
    DBUS                   = DBus.system_bus
    BLUEZ                  = DBUS.service('org.bluez')

    public
    # Generic Error class
    class Error                  < StandardError ; end
    # Notify of unimplemented part
    class NotYetImplemented      < Error         ; end
    # Notify that the underlying API object is dead
    class StalledObject          < Error         ; end
    # Notify that execution wass not able to fulill as some requirement
    # was not ready. Usually you can wait a little and restart the action.
    class NotReady               < Error         ; end
    # Notify that you don't have the necessary authorization to perfrom
    # the operation
    class NotAuthorized          < Error         ; end
    # Notify that some service/characteristic/... is not found
    # on this device
    class NotFound               < Error         ; end
    class AccessUnavailable      < Error         ; end
    class NotSupported      < Error         ; end


    # Base UUID for GATT services defined with 16bit or 32bit UUID
    GATT_BASE_UUID="00000000-0000-1000-8000-00805f9b34fb"

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




    # Check if Bluetooth underlying API is accessible
    def self.ok?
        BLUEZ.exists?
    end

end

require_relative 'ble/version'
require_relative 'ble/uuid'
require_relative 'ble/adapter'
require_relative 'ble/char_desc'
require_relative 'ble/notifications'
require_relative 'ble/device'
require_relative 'ble/service'
require_relative 'ble/char_registry'
require_relative 'ble/characteristic'
require_relative 'ble/agent'

require_relative 'ble/db_sig_service'
require_relative 'ble/db_sig_characteristic'
require_relative 'ble/db_eddystone'
require_relative 'ble/db_nordic'
require_relative 'ble/db_ollie'


