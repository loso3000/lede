'use strict';
'require baseclass';
'require rpc';
'require network';

var callOnlineUsers = rpc.declare({
    object: 'luci',
    method: 'getOnlineUsers'
});

var callOnlineUserlist = rpc.declare({
    object: 'luci',
    method: 'getOnlineUserlist',
    expect: { result: [] }
});

function getlanip(networks) {
    for (var i = 0; i < networks.length; i++) {
        var networkName = networks[i].getName();
        if (networkName === 'lan') {
            var l3dev = networks[i].getDevice();
            if (l3dev) {
                var ipadd = l3dev.getIPAddrs()[0];
                return ipadd;
            }
        }
    }
    return null;
}

return baseclass.extend({
    title: _('Online Users'),
    load: function() {
		return Promise.all([
			L.resolveDefault(callOnlineUserlist(), {}),
			L.resolveDefault(callOnlineUsers(), {}),
			network.getNetworks()
        ]);
    },

    render: function(data) {
        var onlineuserlist = Array.isArray(data[0]) ? data[0] : [],
         fields = [_('Online Users'), data[1].onlineusers || '0'],
         networks = data[2];
        var lanIP = getlanip(networks);
        var usestatus = E('table', { 'class': 'table' });
        if (fields[0] == _('Online Users')) {
            usestatus.appendChild(E('tr', { 'class': 'tr' }, [
                E('td', { 'class': 'td left', 'width': '33%' }, [fields[0]]),
                E('td', { 'class': 'td left' }, [
                    (fields[1] != null) ? fields[1] : '0'
                ])
            ]));
        }

        var table = E('table', { 'class': 'table' }, [
            E('tr', { 'class': 'tr table-titles' }, [
                E('th', { 'class': 'th', 'width': '20%' }, _('Hostname')),
                E('th', { 'class': 'th', 'width': '40%' }, _('IP Address')),
                E('th', { 'class': 'th', 'width': 'auto' }, _('MAC address')),
                E('th', { 'class': 'th', 'width': 'auto' }, _('Interface'))
            ])
        ]);

        var filteredUsers = onlineuserlist.filter(function(info) {
            return info.ipaddr !== lanIP;
        });

        filteredUsers.sort(function(a, b) {
            return L.naturalCompare(a.ipaddr, b.ipaddr);
        });

        filteredUsers.forEach(function(info) {
            var row = E('tr', { 'class': 'tr' }, [
                E('td', { 'class': 'td left' }, info.hostname),
                E('td', { 'class': 'td left' }, info.ipaddr),
                E('td', { 'class': 'td left' }, info.macaddr),
                E('td', { 'class': 'td left' }, info.device)
            ]);
            table.appendChild(row);
        });

        return E([
            table,
            usestatus
        ]);
    }
});
