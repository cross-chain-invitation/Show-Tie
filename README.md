Create Invitation on Base Sepolia
https://base-sepolia.blockscout.com/tx/0xc8b308572af96b1e1a0ca03f0482560021503497d04f61eef15ee0f7e79de92d

Accept Invitation on Ethereum Sepolia
https://eth-sepolia.blockscout.com/tx/0xc138e2279cf23c80ca733c6be13594d0081b35f2da0a851f368a9b1eb615490e

Re: create Invitation
https://sepolia.basescan.org/tx/0xb30a15fdaa50a2d70aef02717f0f1c598669d6f8739abf604a4b121306d8648a
## Contract Addresses

### Ethereum Sepolia

| Contract       | Address                                    |
|----------------|--------------------------------------------|
| Showtie        | `0xe74562223D7ABc995Ab0703697b163431e3A0635` |
| ShowtieHook    | `0x883178d94E7cB18b4e4d077CDd0cEB98d34dAd37` |
| ShowtieERC20   | `0x6640f61BeEF7cEd4eE72A95a48d1Ce65b8ac5762` |

### Base Sepolia

| Contract       | Address                                    |
|----------------|--------------------------------------------|
| Showtie        | `0xABF8250bE844d6E88153b688A22D3030a88e42a1` |
| ShowtieHook    | `0x23a5ffb86b6c1e51dedb53681449a909a8ce2f53` |
| ShowtieERC20   | `0x7BD72b6D118F763832185744Ee054A550B6eb4cf` |


## Schemas

#### Crosschain Invitation & Captcha Schema
🌍 **Sepolia**  
[View Schema on SignScan](https://testnet-scan.sign.global/schema/onchain_evm_11155111_0x304)

🌍 **Base Sepolia**  
[View Schema on SignScan](https://testnet-scan.sign.global/schema/onchain_evm_84532_0x483)


| Field Name            | Type      | Description                                                                                      |
|------------------------|-----------|--------------------------------------------------------------------------------------------------|
| `address invitee`      | `address` | The address of the user who was invited.                                                        |
| `address inviter`      | `address` | The address of the user who issued the invitation.                                              |
| `uint256 dappsId`      | `uint256` | The identifier of the Dapp.                                                                     |
| `bytes signature`      | `bytes`   | A signature created by the Invitee, signing the Inviter's address and the Dapps ID.             |
| `bytes captchaSignature` | `bytes` | A signature created by the CAPTCHA verifier, signing the Inviter and Dapps ID.                 |
| `address captchaSigner`| `address` | The address of the CAPTCHA verifier.                                                           |
| `uint256 sourceChainSelector` | `uint256` | The chain identifier where the Inviter created the invitation (used for cross-chain invitations). |
| `uint256 targetChainSelector` | `uint256` | The chain identifier where the Invitee received the invitation (used for cross-chain invitations). |

#### Inviter Schema

🌍 **Sepolia**  
[View Schema on SignScan](https://testnet-scan.sign.global/schema/onchain_evm_11155111_0x2ed)

🌍 **Base Sepolia**  
[View Schema on SignScan](https://testnet-scan.sign.global/schema/onchain_evm_84532_0x41e)


| Name           | Type      | Description                                                                                      |
|----------------|-----------|--------------------------------------------------------------------------------------------------|
| `inviter`      | `address` | The address of the user who issued the invitation.                                              |
| `signature`    | `bytes`   | A signature created to verify the authenticity of the invitation.                               |
| `dappsId`      | `uint256` | The identifier of the Dapp.                                                                     |
| `originalChain`| `uint256` | The chain identifier where the invitation was originally created.                               |
| `targetChain`  | `uint256` | The chain identifier where the invitation was intended to be received (used for cross-chain invitations). |


#### Cross-Chain Schema
🌍 **Base Sepolia**  
[View Schema on SignScan](https://testnet-scan.sign.global/schema/onchain_evm_84532_0x423)

🌍 **Sepolia**  
[View Schema on SignScan](https://testnet-scan.sign.global/schema/onchain_evm_11155111_0x303)


| Name                  | Type      | Description                                                                                      |
|-----------------------|-----------|--------------------------------------------------------------------------------------------------|
| `inviter`             | `address` | The address of the user who issued the invitation.                                              |
| `inviterAttestationId`| `uint256` | Inviter attestation ID.                                                                          |
| `dappsId`             | `uint256` | The identifier of the Dapp.                                                                     |
| `sourceChain`         | `uint256` | The chain identifier where the Inviter created the invitation (used for cross-chain invitations).|
| `targetChain`         | `uint256` | The chain identifier where the Invitee received the invitation (used for cross-chain invitations).|
