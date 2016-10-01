module BLE
module Service
    add 'ee0c2080-8786-40ba-ab96-99b91ac981d8',
        name: 'Eddystone-URL Beacon Configuration'
end
end

module BLE
class Characteristic
  add 'ee0c2081-8786-40ba-ab96-99b91ac981d8',
        name: 'Eddystone Lock State',
        nick: :esurl_lockstate

    add 'ee0c2082-8786-40ba-ab96-99b91ac981d8',
        name: 'Eddystone Lock',
        nick: :esurl_lock

    add 'ee0c2083-8786-40ba-ab96-99b91ac981d8',
        name: 'Eddystone Unlock',
        nick: :esurl_unlock

    add 'ee0c2084-8786-40ba-ab96-99b91ac981d8',
        name: 'Eddystone URL Data',
        nick: :esurl_data

    add 'ee0c2085-8786-40ba-ab96-99b91ac981d8',
        name: 'Eddystone Flags',
        nick: :esurl_flags

    add 'ee0c2086-8786-40ba-ab96-99b91ac981d8',
        name: 'Eddystone Adv Tx Power Levels',
        nick: :esurl_adv_txpower_levels

    add 'ee0c2087-8786-40ba-ab96-99b91ac981d8',
        name: 'Eddystone TX power mode',
        nick: :esurl_txpower_mode

    add 'ee0c2088-8786-40ba-ab96-99b91ac981d8',
        name: 'Eddystone Beacon period',
        nick: :esurl_beacon_period

    add 'ee0c2089-8786-40ba-ab96-99b91ac981d8',
        name: 'Eddystone Reset',
        nick: :esurl_reset

    add 'ee0c208a-8786-40ba-ab96-99b91ac981d8',
        name: 'Eddystone Radio Tx Power Levels',
        nick: :esurl_radio_txpower_levels
end
end
