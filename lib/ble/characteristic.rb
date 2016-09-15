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
        when Integer     then DB_UUID[BLE::UUID(id)]
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
    # @option opts :type [String] type
    # @option opts :nick [Symbol] nickname
    # @option opts :in   [Proc] convert to ruby
    # @option opts :out  [Proc] convert to bluetooth data
    # @option opts :vry  [Proc] verify
    # @return [Hash] characteristic description
    def self.add(uuid, name:, **opts)
        uuid = BLE::UUID(uuid)
        type =  opts.delete :type
        nick = opts.delete :nick
        _in  = opts.delete :in
        _out = opts.delete :out
        vrfy = opts.delete :vrfy            
        if opts.first 
            raise ArgumentError, "unknown keyword: #{opts.first[0]}" 
        end
        
        
        desc = DB_UUID[uuid] = {
            uuid: uuid,
            name: name,
              in: _in,
             out: _out,
            vrfy: vrfy
        }
        
        # Add type if specified
        if type
            type = type.downcase
            desc.merge!(type: type)
            DB_TYPE[type] = desc
        end

        # Add nickname if specified or can be derived from type
        if nick.nil? && type && type =~ /\.(?<key>[^.]+)$/
            nick = $1.to_sym if type.start_with? 'org.bluetooth.characteristic'
        end
        if nick
            if DB_NICKNAME.include?(nick)
                raise ArgumentError,
                      "nickname '#{nick}' already registered (uuid: #{uuid})"
            end
            DB_NICKNAME[nick] = desc
        end
    end
end
end
