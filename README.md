# Rainscapes

                ▲△      △△ ▲ △▲ ▲    
    △ △   △▲  ▲  △△   ▲ ▲  ▲△        
       ▲  △       ▲    △▲△ △▲        
               △   ▲  △▲      △      
     △    ▲     △    △         △△    
    ▲ △           △ ▲▲    ▲ △        
     ▲      ▲   △  ▲ △▲  △ ▲         
                        ▲▲           
     ▲       ▲△△          △ △ ▲      
    △△  △▲        △▲△          △     
    ▲ ▲            ▲ ▲ ▲     △       
    ▲     △△        △   △△     ▲     
     ▲  ▲          ▲ △ △△   △        
      △△      △▲  ▲ ▲   ▲      ▲▲    
                      ▲              
                       ▲    △        

## Contracts

### Manifold Generative Series Extension (for Rainscape)

Rainscapes uses a Manifold Creator Contract. In order to mint a generative
on-chain series on top of it, we implemented our own extension (`GenerativeSeriesExtension`).

The extension has a plugin architecture allowing custom renderers and
minters to be plugged in. In addition, there is a freeze method for
making the link between extension and a renderer immutable. The extension
also allows each creator contract admin to use reserve minting, even
in case customer minter is not provided.

### Rainscapes Renderers

Main artwork is implemented as a renderer plugins to the generative series
extension.

Before mint, the artwork was hidden using renderer that returned static
placeholder artwork (`UnrevealedRenderer`).

The actual artwork is implemented in the main renderer (`RainscapesRenderer`).
The main renderer also has extension points for gas observer, description field
and script files, with the last one allowing reusability of script assets in case of renderer updates.

Default implementation for the gas observer was implemented as observatory
plugin (`RainscapesObservatory`). It contains a naive implementation of gas
counter to allow artwork to gracefully degrate in low gas conditions.

### Rainscapes Minter

Finally a customer minter to generative series extension was implemented
(`RainscapesMinter`). The minter allows setting predefined minting period with
an allowlist phase. Addresses can be added/removed to allowlist freely.
Minter has hard-coded creator contract and extension addresses that cannot be
changed. Once a minting period has been set, it cannot be cancelled
(but creator contract admin can change minter address to deny access).

### Rainscapes Data

Manifold creator contract only exposes data through tokenURI. For make 
usability of on-chain data more convenient, a supplementary data contract
has been implemented (`RainscapesData`).

The data contract can be plugged in to creator contract and generative
series extension, and provides a layer of convenience for accessing all
on-chain assets (token data in URI, JSON, HTML and image formats).

## How to build and develop

Clone this repository

Install foundry + Forge:

        https://getfoundry.sh

Build:

        forge build

Run tests with debug info:

        forge test -vvv

## Creating a test batch

Create full test batch of 64 tokens with:

        forge script CreateTestBatch

Full test batch is generated with data stored to `generated` folder

## Deploying

### 1. Prepare configurations

Take copy of `.env.EXAMPLE` into `.env`. Fill in missing variables
using the network of your preference (Sepolia, Optimism, etc.). Note
that both RPC URLs and Etherscan API keys are network dependent.
TAKE CAUTION as you need to fill in private key of your deployer wallet.

After the file is configured, make sure to load it with:

        source .env

### 2. Deploy Manifold creator contract

Start by creating a Manifold creator contract. See Manifold's documentation
on:

https://docs.manifold.xyz/v/manifold-studio/references/creator-contract

### 3. Deploy and Register Manifold Extension

Once you have a creator contract deployed, the generative series extensions
is required. If this has been already deployed, find out the address. If
a deployment is necessary it can be done with:

        forge script DeployExtension -f $RPC_URL [--broadcast --verify]

Once extension is available, it needs to be registered into creator contract.
- Open your Manifold creator contract in Etherscan
- Call `registerExtension` with the extension address
- Leave baseURI empty (or put in single space)
- You can verify the registration was successful by calling `getExtensions`

### 4. Deploy Rainscape stack

Make sure to setup both your creator contract address and Manifold
generative series extension addresses to .env variable fields 
(`MANIFOLD_CREATOR_CONTRACT_ADDRESS`, `MANIFOLD_EXTENSION_ADDRESS`).

Deploy (or simulate without broadcast + verify):

        forge script DeployRainscapes -f $RPC_URL [--broadcast --verify]
