![image](https://user-images.githubusercontent.com/65929678/216216243-440bcb5c-5052-4946-9cad-47a98842e363.png)

---
# Aptoplay-Move
[Aptos Seoul Hack 2023](https://aptosfoundation.org/events/seoul-hack-2023) Buidl

>Effortless Integration, Seamless Experience in Aptos gaming solutions for game builders

Smart contract part of minting an simple NFT from gamedata by interacting Aptos blockchain.

Sample NFT Image on IPFS

![ghost image](https://mzhaorpkzvuazm42fk7kxqw56fhnhgex6vhyz4mwydoqz3s57kha.arweave.net/Zk4HRerNaAyzmiq-q8Ld8U7TmJf1T4zxlsDdDO5d-o4?ext=png)

## Currnet State
Showing gaming data persistently secured on the Aptos blockchain by minting a simple NFT to keep import gaming data to users' end.


## Implementation in progress
Our team has been developed a game for a long time.
To do what are usually expected by gamers
[e.g. Account-Bounded Items(non-transferable or semi-transferable), Reinforcing Items(has a chance to lose everything) ] 
* Semi-transferable
it means item can be traded(transferred) only certain amount of times.

To provide expected actions to the users, We'd like to sugges concept
FSBT - Fungible Soul Bound Token 
it sounds like a contradiction
But, Fungible or Non-fungible or Soul-Bounded at times by the status of user's action, 
We're convinced that game devs can offer users expected gaming experience.

by leveraging Token Model of Aptos, 
it's being easier to implement FSBT model by adding Capability Resource on the TokenStore Resource.

The sort of FSBT we suggest to game developers could be deeper like below.
- PFSBT - it's like a Normal PFP but can't be transffered. linking Achievement FSBT, Item FBST 
- AAFBST - Achievement FSBT,  
- IAFBST - Item FSBT