# MACsec
Lo standard **IEEE 802.1AE**, anche noto come **MACsec**, è uno standard di sicurezza di rete progettato per operare al livello di controllo degli accessi ai mezzi fisici, e definisce un approccio alla sicurezza di rete che include confidenzialità, integrità e protezione dal replay dei dati senza connessione. Il formato del frame MACsec è simile a quello di Ethernet con dei campi addizionali:
* *Security tag*: dopo aver settato il campo *EtherType* al valore relativo a MACsec (```0x88e5```), i successivi byte vengono interprati come byte dell'header 802.1AE. Tra i vari campi è importante segnalare il campo **Packet Number** che serve a prevenire *replay attacks*.
* *Integrity Check Value* (*ICV*): garantisce l'integrità del frame.

MACsec prevede gruppi di stazioni connesse mediante canali sicuri unidirezionali, **Secure Connectivity Associations**. Ciascuna associazione contiene una **Security Associations**, ovvero ogni associazione utilizza la propria chiave segreta (*SAK*). Un aspetto importante da sottolineare è che la gestione delle chiavi esula dallo scopo dello standard 802.1AE e viene definita da altri standard come lo standard **802.1x-2010**.

In Linux è stato aggiunto un supporto per MACsec a partire dal kernel 4.6. Esistono due modi per implementare MACsec:
1. Configurazione manuale (statica) dei canali sicuri (SC), delle security associations (SA) e delle chiavi;
2. Utilizzo dello standard 802.1x con l'estensione MACsec che consente la scoperta dinamica dei peer MACsec, il setup dei SC e delle SA, la generazione e la distribuzione delle chiavi.

# Laboratorio

## Configurazione del router
La prima cosa da fare è configurare una nuova interfaccia di rete di tipo bridge per poter mettere in comunicazione le interfacce di rete ```eth0```, ```eth1```, ```eth2``` come se fossero tutte collegate allo stesso segmento di rete (scripts/router/initbridge.sh):
```
ip link add name bridge type bridge
ip link set bridge up
ip link set dev eth0 master bridge
ip link set dev eth1 master bridge
ip link set dev eth2 master bridge
```

## Configurazione dei client
Configuriamo gli indirizzi MAC ed IP delle interfacce di rete dei tre client (scripts/clientX/initaddr.sh):
```
ip link set dev eth0 address xy:xy:xy:xy:xy:xy
ip addr add 10.0.0.z/24 dev eth0
```
dove, ```xy``` va sostituito con ```a0``` per il client 1, con ```b0``` per il client 2 e con ```c0``` per il client 3, e ```z``` va sostituito con ```1```, ```2```, ```3``` rispettivamente per il client 1, 2 e 3. 

A questo punto procediamo con la configurazione dell'interfaccia MACsec per il canale sicuro bidirezionale tra il client 1 ed il client 2. 

Per il client 1 (scripts/client1/initmacsec.sh):
```
ip link add link eth0 macsec0 type macsec
ip macsec add macsec0 tx sa 0 pn 1 on key 01 09876543210987654321098765432109
ip macsec add macsec0 rx address b0:b0:b0:b0:b0:b0 port 1
ip macsec add macsec0 rx address b0:b0:b0:b0:b0:b0 port 1 sa 0 pn 1 on key 02 12345678901234567890123456789012
ip link set macsec0 up
ip addr add 10.100.0.1/24 dev macsec
```

Per il client 2 (scripts/client2/initmacsec.sh):
```
ip link add link eth0 macsec0 type macsec
ip macsec add macsec0 tx sa 0 pn 1 on key 02 12345678901234567890123456789012
ip macsec add macsec0 rx address a0:a0:a0:a0:a0:a0 port 1
ip macsec add macsec0 rx address a0:a0:a0:a0:a0:a0 port 1 sa 0 pn 1 on key 01 09876543210987654321098765432109
ip link set macsec0 up
ip addr add 10.100.0.2/24 dev macsec0

# with this conf only integrity is on
# to encrypt: ip link set macsec0 type macsec encrypt on
# for antireply: ip link set macsec0 type macsec replay on 
# to test the configuration: ping 10.100.0.3 (check wireshark)
```

I comandi forniti configurano un'interfaccia MACsec su Linux. In particolare:
1. Il primo comando crea un'interfaccia MACsec denominata *macsec0* collegata all'interfaccia di rete **eth0**.
2. Il secondo comando aggiunge una *security association* per la trasmissione su *macsec0*.
3. Il terzo comando aggiunge una configurazione per la ricezione su *macsec0* e specifica l'indirizzo MAC della sorgente.
4. Il quarto comando completa la configurazione del canale di ricezione su *macsec0* e specifica la chiave sul canale di ricezione (notare che deve essere la stessa chiave utilizzata nel canale di trasmissione del mittente).
5. Il quinto comando abilita l'interfaccia MACsec *macsec0*.
6. Il sesto comando assegna l'indirizzo IP **10.100.0.x** con una subnetmask **/24** all'interfaccia *macsec0* (questo consente al client in questione di poter continuare a comunicare anche senza MACsec).

La configurazione effettuata fino a questo momento garantisce solamente integrità dei dati. Per garantire anche cifratura e antireplay è possibile dare sul client in questione i seguenti comandi aggiuntivi:
```
ip link set macsec0 type macsec encrypt on
ip link set macsec0 type macsec replay on
```