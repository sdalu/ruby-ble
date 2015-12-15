module BLE
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
end
