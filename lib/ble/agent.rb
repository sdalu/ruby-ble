module BLE
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
end
