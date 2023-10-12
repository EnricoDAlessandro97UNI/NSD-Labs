# MACsec
Lo standard **IEEE 802.1AE**, anche noto come **MACsec**, è uno standard di sicurezza di rete progettato per operare al livello di controllo degli accessi ai mezzi fisici, e definisce un approccio alla sicurezza di rete che include confidenzialità, integrità e protezione dal replay dei dati senza connessione. Il formato del frame MACsec è simile a quello di Ethernet con dei campi addizionali:
* *Security tag*: dopo aver settato il campo *EtherType* al valore relativo a MACsec (```0x88e5```), i successivi byte vengono interprati come byte dell'header 802.1AE. Tra i vari campi è importante segnalare il campo **Packet Number** che serve a prevenire *replay attacks*.
* *Integrity Check Value* (*ICV*): garantisce l'integrità del frame.

MACsec prevede gruppi di stazioni connesse mediante canali sicuri unidirezionali, **Secure Connectivity Associations**. Ciascuna associazione contiene una **Security Associations**, ovvero ogni associazione utilizza la propria chiave segreta (*SAK*). Un aspetto importante da sottolineare è che la gestione delle chiavi esula dallo scopo dello standard 802.1AE e viene definita da altri standard come lo standard **802.1x-2010**.

In Linux è stato aggiunto un supporto per MACsec a partire dal kernel 4.6. Esistono due modi per implementare MACsec:
1. Configurazione manuale (statica) dei canali sicuri (SC), delle security associations (SA) e delle chiavi;
2. Utilizzo dello standard 802.1x con l'estensione MACsec che consente la scoperta dinamica dei peer MACsec, il setup dei SC e delle SA, la generazione e la distribuzione delle chiavi.