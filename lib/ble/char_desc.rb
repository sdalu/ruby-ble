# Encapsulates Characteristic descriptors and offers easy
# access to characteristic related information.
#
module BLE
  class CharDesc
    attr_reader :desc
    # @param desc [Hash] Descriptors.
    def initialize(desc)
      @desc= desc
    end
    def flags
      @flags||= @desc[:flags]
    end
    def config
      @config||= Characteristic[@desc[:uuid]]
    end

    def uuid
      @desc[:uuid]
    end
    def flag?(flag_name)
      flags.include?(flag_name)
    end

    # Does outgoing values have processors configured?
    # If yes, the value needs to be pre-processed before being send.
    def write_processors?
      verifier? or write_pre_processor?
    end
    # Does incoming values have processors configured?
    # If yes, the value needs to be post-processed after being received.
    def read_processors?
      config && read_post_processor?
    end
    # It has been configured a verifier preprocessor to check
    # outgoing data?
    def verifier?
      config[:vrfy]
    end
    def write_pre_processor?
      config[:out]
    end
    def read_post_processor?
      config[:in]
    end
    # Is the received value verified by the verifier?
    def verifies?(val)
      config[:vrfy].call(val)
    end
    def pre_process(val)
      if verifier? && !verifies?(val)
        raise ArgumentError,
          "bad value for characteristic '#{uuid}'"
      end
      val = config[:out].call(val) if write_pre_processor?
    end

    def post_process(val)
      val = config[:in].call(val) if read_post_processor?
    end

  end
end
