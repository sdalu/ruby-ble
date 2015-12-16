module BLE
module Service
    add 0x1800,
        name: 'Generic Access',
        type: 'org.bluetooth.service.generic_access'

    add 0x1801,
        name: 'Generic Attribute',
        type: 'org.bluetooth.service.generic_attribute' 

    add 0x1802,
        name: 'Immediate Alert',
        type: 'org.bluetooth.service.immediate_alert'

    add 0x1803,
        name: 'Link Loss',
        type: 'org.bluetooth.service.link_loss'

    add 0x1804,
        name: 'Tx Power',
        type: 'org.bluetooth.service.tx_power'
    
    add 0x1805,
        name: 'Current Time Service',
	type: 'org.bluetooth.service.current_time'

    add 0x180A,
        name: 'Device Information',
	type: 'org.bluetooth.service.device_information'
    
    add 0x180F,
        name: 'Battery Service',
        type: 'org.bluetooth.service.battery_service'

    add	0x1811,
        name: 'Alert Notification Service',
        type: 'org.bluetooth.service.alert_notification'

    add 0x1812,
        name: 'Human Interface Device',
        type: 'org.bluetooth.service.human_interface_device'

    add 0x1819,
        name: 'Location and Navigation',
        type: 'org.bluetooth.service.location_and_navigation'

    add 0x181A,
        name: 'Environmental Sensing',
        type: 'org.bluetooth.service.environmental_sensing'

    add 0x181C,
        name: 'User Data',
        type: 'org.bluetooth.service.user_data'

    add 0x181D,
        name: 'Weight Scale',
        type: 'org.bluetooth.service.weight_scale'
end
end
