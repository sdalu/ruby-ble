module BLE
    # Cast value to a well-formatted 128bit UUID string
    # @param [String, Integer] val uuid
    # @return [String] well formated 128bit UUID
    def self.UUID(val)
        case val
        when Integer
            if !(0..4294967295).include?(val)  # 2**32-1
                raise ArgumentError, "not a 16-bit or 32-bit UUID"
            end
            ([val].pack("L>").unpack('H*').first + GATT_BASE_UUID[8..-1])
        when String
            if val !~ UUID::REGEX
                raise ArgumentError, "not a 128bit uuid string"
            end
            val.downcase
        else raise ArgumentError, "invalid uuid type"
        end
    end
    
    class UUID
        # Regular expression for matching UUID 128-bit string
        REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
    end
end
