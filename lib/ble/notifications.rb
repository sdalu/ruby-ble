module BLE
  module Notifications

    # Registers current device for notifications of the given _characteristic_.
    # Synonym for 'subscribe' or 'activate'.
    # This step is required in order to later receive notifications.
    # @param service [String, Symbol]
    # @param characteristic [String, Symbol]
    #
    def start_notify!(service, characteristic)
      char= _find_characteristic(service, characteristic)
      if char.flag?('notify')
        char.notify!
      else
        raise OperationNotSupportedError.new("No notifications available for characteristic #{characteristic}")
      end
    end

    #
    # Registers the callback to be invoked when a notification from the given _characteristic_ is received.
    #
    # NOTE: Requires the device to be subscribed to _characteristic_ notifications.
    # @param service [String, Symbol]
    # @param characteristic [String, Symbol]
    # @param raw [Boolean] When raw is true the value (set/get) is a binary string, instead of an object corresponding to the decoded characteristic (float, integer, array, ...)
    # @param callback [Proc] This callback will have the notified value as argument.
    #
    def on_notification(service, characteristic, raw: false, &callback)
      _require_connection!
      char= _find_characteristic(service, characteristic)
      if char.flag?('notify')
        char.on_change(raw: raw) { |val|
          callback.call(val)
        }
      elsif char.flag?('encrypt-read') ||
          char.flag?('encrypt-authenticated-read')
        raise NotYetImplemented
      else
        raise AccessUnavailable
      end
    end

  end
end
