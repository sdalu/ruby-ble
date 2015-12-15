module BLE
# Build information about {https://developer.bluetooth.org/gatt/services/Pages/ServicesHome.aspx Bluetooth Services}
#
# To add a new service description:
#   BLE::Service.add '63a83b9c-0fa0-4d04-8ef9-23be4ed36231',
#       name: 'World domination',
#       type: 'net.cortex-minus.service.world_domination'
# 
# Returned service description will be a hash:
#   {
#      name: "Bluetooth service name",
#      type: "org.bluetooth.service.name",
#      uuid: "128bit-uuid-string"
#   }
#    
module Service
    # Notify of service not found
    class NotFound < BLE::NotFound
    end

    private
    DB_UUID     = {}
    DB_TYPE     = {}
    DB_NICKNAME = {}

    public
    # Get a service description from it's id.
    # The id could be either a uuid, a type, or a nickname
    #
    # @param id [Symbol,String] uuid, type or nickname
    # @return [Hash] service description
    def self.[](id)
        case id
        when Symbol      then DB_NICKNAME[id]
        when UUID::REGEX then DB_UUID[id]
        when String      then DB_TYPE[id]
        else raise ArgumentError, "invalid type for service id"
        end
    end

    # Get service description from nickname.
    #
    # @param id [Symbol] nickname
    # @return [Hash] service description
    def self.by_nickname(id)
        DB_NICKNAME[id]
    end

    # Get service description from uuid.
    #
    # @param id [String] uuid
    # @return [Hash] service description
    def self.by_uuid(id)
        DB_UUID[id]
    end

    # Get service description from type
    #
    # @param id [Strig] type
    # @return [Hash] service description
    def self.by_type(id)
        DB_TYPE[id]
    end
    
    # Add a service description.
    # @example Add a service description with a 16-bit uuid
    #   module Service
    #       add 0x1800,
    #           name: 'Generic Access',
    #           type: 'org.bluetooth.service.generic_access'
    #   end
    #
    # @example Add a service description with a 128-bit uuid
    #   module Service
    #       add '63a83b9c-0fa0-4d04-8ef9-23be4ed36231',
    #           name: 'World domination',
    #           type: 'net.cortex-minus.service.world_domination'
    #   end
    #
    # @param uuid [Integer, String] 16-bit, 32-bit or 128-bit uuid
    # @param name [String]
    # @param type [String]
    # @return [Hash] service description
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
        
        desc = DB_TYPE[type] = DB_UUID[uuid] = {
            name: name,
            type: type,
            uuid: uuid,
        }
        
        stype  = type.split('.')
        key    = stype.pop.to_sym
        prefix = stype.join('.')
        case prefix
        when 'org.bluetooth.service'
            if DB_NICKNAME.include?(key)
                raise ArgumentError,
                      "nickname '#{key}' already registered (type: #{type})"
            end
            DB_NICKNAME[key] = desc
        end

        desc
    end
end
end
