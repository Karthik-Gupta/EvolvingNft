# Evolving NFT demonstration project

This is a sample project to demonstrate the idea of evolving NFT in its basic form.

The basic idea is:
There can be a base character, different accessories for it and the combination of them will be the new NFT being evolved. When the evolved NFT is transferred to another address, all the compositions are transferred (Evolved NFT itself, base character and the accessories)

Implementation: <br />
Character sc - ERC 721 <br />
Accessory sc - ERC 1155 <br />
Evolved sc - ERC 721 <br />
<br />
User can own the base character and accessories and can evolve them into a combined NFT with any combination of <br />
* Base character + some accessories
* Base character + all accessories
If the evolved NFT is transferred to a different address, the base with relative accessories are transferred as well

Try running some of the following tasks:

```shell
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
