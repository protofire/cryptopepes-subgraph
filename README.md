## CryptoPepes

[This](https://thegraph.com/explorer/subgraph/protofire/cryptopepes) is the subgraph for CryptoPepes.

### About Pepes

CryptoPepes is a game that allows breeding on the blockchain. The Pepes can be collected and if you select a mother and a father, they can breed. You can start a pepe family. You can choose to trade offspring Pepes, collect them and or let them battle against each other. Since you own the private key all the Pepes are 100% owned by you!

### About the entities

NfpStat is a single entity that contains counters about Cryptopepes. So, you are able to determine how many Pepes are born, how many of them were burned, etc... Notice that pepe's minted counter is the same as pepe's born because is the same.

Pepes are all the Nft's, you are able to query about it's name, ownership and it's father and mother and if it was reborn or not. Notice you are able to query mother's mother and mother's father and so on. So you can travel along each pepe's genealogy. You are also able to query down it's genealogy asking for it's siblings as a mother and it's siblings as a father. 

Finally, Users is the entity where all the accounts are indexed with they own pepes.

|