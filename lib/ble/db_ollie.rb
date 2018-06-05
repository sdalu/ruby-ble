module BLE
  module Service
    add '22bb746f-2bb0-7554-2d6f-726568705327',
        name: 'Sphero Ollie (BB-8) BLE Service',
        nick: :ollie_ble_service
    add '22bb746f-2ba0-7554-2d6f-726568705327',
        name: 'Sphero Ollie (BB-8) Robot Control Service',
        nick: :ollie_robot_control_service
  end
  class Characteristic
    add '22bb746f-2bbf-7554-2d6f-726568705327',
        name: 'Ollie Wake',
        nick: :ollie_wake

    add '22bb746f-2bb2-7554-2d6f-726568705327',
        name: 'Ollie TX Power',
        nick: :ollie_tx_power

    add '22bb746f-2bbd-7554-2d6f-726568705327',
        name: 'Ollie AntiDOS',
        nick: :ollie_antidos

    add '22bb746f-2ba1-7554-2d6f-726568705327',
        name: 'Ollie Commands',
        nick: :ollie_commands

    add '22bb746f-2ba6-7554-2d6f-726568705327',
        name: 'Ollie Response',
        nick: :ollie_response
  end
end
