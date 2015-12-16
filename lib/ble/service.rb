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
        when Integer     then DB_UUID[BLE::UUID(id)]
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
    # @option opts :type [String] type
    # @option opts :nick [Symbol] nickname
    # @return [Hash] service description
    def self.add(uuid, name:, **opts)
        uuid = BLE::UUID(uuid)
        type = opts.delete :type
        nick = opts.delete :nick
        if opts.first 
            raise ArgumentError, "unknown keyword: #{opts.first[0]}" 
        end
        
        desc = DB_UUID[uuid] = {
            uuid: uuid,
            name: name,
        }

        # Add type if specified
        if type
            type = type.downcase
            desc.merge!(type: type)
            DB_TYPE[type] = desc
        end

        # Add nickname if specified or can be derived from type
        if nick.nil? && type && type =~ /\.(?<key>[^.]+)$/
            nick = $1.to_sym if type.start_with? 'org.bluetooth.service'
        end
        if nick
            if DB_NICKNAME.include?(nick)
                raise ArgumentError,
                      "nickname '#{nick}' already registered (uuid: #{uuid})"
            end
            DB_NICKNAME[nick] = desc
        end
        
        desc
    end
end
end
