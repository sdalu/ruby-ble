module BLE
module Service
    add '00001530-1212-efde-1523-785feabcd123',
        name: 'Nordic Device Firmware Update Service'

    add '6e400001-b5a3-f393-e0a9-e50e24dcca9e',
        name: 'Nordic UART Service'
end
end


module BLE
class Characteristic
  add '00001531-1212-efde-1523-785feabcd123', # WriteWithoutResponse
        name: 'DFU Packet'

    add '00001532-1212-efde-1523-785feabcd123', # Write,Notify
        name: 'DFU Control Point'

    add '6e400002-b5a3-f393-e0a9-e50e24dcca9e',
        name: 'UART TX'

    add '6e400003-b5a3-f393-e0a9-e50e24dcca9e',
        name: 'UART RX'
end
end
