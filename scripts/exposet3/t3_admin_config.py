admin_pod_name = sys.argv[1]
admin_port = sys.argv[2]
user_name = sys.argv[3]
password = sys.argv[4]
listen_port = sys.argv[5]
public_port = sys.argv[6]
public_address = sys.argv[7]
AdminServerName = sys.argv[8]
channelType = sys.argv[9]
print('custom admin_pod_name : [%s]' % admin_pod_name);
print('custom admin_port : [%s]' % admin_port);
print('custom user_name : [%s]' % user_name);
print('custom password : ********');
print('public address : [%s]' % public_address);
print('channel listen port : [%s]' % listen_port);
print('channel public listen port : [%s]' % public_port);
connect(user_name, password, 't3://' + admin_pod_name + ':' + admin_port)
edit()
startEdit()
cd('/')
cd('Servers/%s/' % AdminServerName )
if channelType == 't3':
   create('T3Channel_AS','NetworkAccessPoint')
   cd('NetworkAccessPoints/T3Channel_AS')
   set('Protocol','t3')
   set('ListenPort',int(listen_port))
   set('PublicPort',int(public_port))
   set('PublicAddress', public_address)
   print('Channel T3Channel_AS added')
elif channelType == 't3s':	  
   create('T3SChannel_AS','NetworkAccessPoint')
   cd('NetworkAccessPoints/T3SChannel_AS')
   set('Protocol','t3s')
   set('ListenPort',int(listen_port))
   set('PublicPort',int(public_port))
   set('PublicAddress', public_address)
   set('HttpEnabledForThisProtocol', true)
   set('OutboundEnabled', false)
   set('Enabled', true)
   set('TwoWaySSLEnabled', true)
   set('ClientCertificateEnforced', false)
else:
   print('channelType [%s] not supported',channelType)  
activate()
disconnect()