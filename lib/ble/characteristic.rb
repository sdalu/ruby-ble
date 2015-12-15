module BLE
# Build information about {https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicsHome.aspx Bluetooth Characteristics}
#
# To add a new characteristic description:
#   BLE::Characteristic.add 'c4935338-4307-47cf-ae1f-feac9e2b3ae7',
#       name: 'Controlled mind',
#       type: 'net.cortex-minus.characteristic.controlled_mind'
#       vrfy: ->(x) { x >= 0 },
#         in: ->(s) { s.unpack('s<').first },
#        out: ->(v) { [ v ].pack('s<') }    
# 
# Returned characteristic description will be a hash:
#   {
#      name: "Bluetooth characteristic name",
#      type: "org.bluetooth.characteristic.name",
#      uuid: "128bit-uuid-string",
#      vrfy: ->(x) { verify_value(x) },
#        in: ->(s) { s.unpack(....) ... },
#       out: ->(v) { [ v ].pack(....) ... }    
#   }
#    
module Characteristic
    # Notify of characteristic not found
    class NotFound < BLE::NotFound 
    end

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
    
    DB_UUID     = {}
    DB_TYPE     = {}
    DB_NICKNAME = {}
    
    public
    # Get characteristic description from nickname.
    #
    # @param id [Symbol] nickname
    # @return [Hash] characteristic description
    def self.by_nickname(id)
        DB_NICKNAME[id]
    end

    # Get characteristic description from uuid.
    #
    # @param id [String] uuid
    # @return [Hash] characteristic description
    def self.by_uuid(id)
        DB_UUID[id]
    end

    # Get characteristic description from type
    #
    # @param id [Strig] type
    # @return [Hash] characteristic description
    def self.by_type(id)
        DB_TYPE[id]
    end
    
    # Get a characteristic description from it's id
    # @param id [Symbol,String]
    # @return [Hash]
    def self.[](id)
        case id
        when Symbol      then DB_NICKNAME[id]
        when UUID::REGEX then DB_UUID[id]
        when String      then DB_TYPE[id]
        else raise ArgumentError, "invalid type for characteristic id"
        end
    end
    

    # Add a characteristic description.
    # @example Add a characteristic description with a 16-bit uuid
    #   module Characteristic
    #       add 0x2A6E,
    #           name: 'Temperature',
    #           type: 'org.bluetooth.characteristic.temperature',
    #           vrfy: ->(x) { (0..100).include?(x) },
    #             in: ->(s) { s.unpack('s<').first.to_f / 100 },
    #            out: ->(v) { [ v*100 ].pack('s<') }
    #   end
    #
    # @example Add a characteristic description with a 128-bit uuid
    #   module Characteristic
    #       add 'c4935338-4307-47cf-ae1f-feac9e2b3ae7',
    #           name: 'Controlled mind',
    #           type: 'net.cortex-minus.characteristic.controlled_mind',
    #           vrfy: ->(x) { x >= 0 },
    #             in: ->(s) { s.unpack('s<').first },
    #            out: ->(v) { [ v ].pack('s<') }    
    #   end
    #
    # @param uuid [Integer, String] 16-bit, 32-bit or 128-bit uuid
    # @param name [String]
    # @param type [String]
    # @option opts :in  [Proc] convert to ruby
    # @option opts :out [Proc] convert to bluetooth data
    # @option opts :vry [Proc] verify
    # @return [Hash] characteristic description
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
        
        DB_TYPE[type] = DB_UUID[uuid] = {
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
            if DB_NICKNAME.include?(key)
                raise ArgumentError,
                      "nickname '#{key}' already registered (type: #{type})"
            end
            DB_NICKNAME[key] = DB_UUID[uuid]
        end
    end
end
end
