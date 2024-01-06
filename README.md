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

## Contents

The project is split into separate deployments as follows

### Manifold Generative Series Extension for Rainscape

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

### Rainscapes Observatory

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

## Developer Guide

Install foundry+forge

Build:

        forge build

Run tests with debug info:

        forge test -vvv
