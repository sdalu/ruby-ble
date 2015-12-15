module BLE
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
end
