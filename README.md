<div align="center">

[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fschang412%2Ftypst-whalogen%2Fmaster%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/whalogen)
[![MIT License](https://img.shields.io/badge/license-apache%202.0-blue)](https://github.com/schang412/typst-whalogen/blob/master/LICENSE)
[![User Manual](https://img.shields.io/badge/manual-.pdf-purple)](https://raw.githubusercontent.com/schang412/typst-whalogen/master/manual.pdf)

</div>

# Whalogen

Whalogen is a library for typsetting chemical formulae and reactions with Typst, inspired by mhchem.

## Usage
```typst
#import "@preview/whalogen:0.3.0": ce

This is the formula for water: #ce("H2O")
This is a chemical reaction: #ce("HCl + H2O -> H3O+ + Cl-")
Whalogen aligns properly in math mode:
$
#ce("CO2 + C &-> 2CO")\
#ce("CH4 + 2O2 &-> CO2 + 2H2O")
$
Charges apply correctly: #ce("H+ + [AgCl2]-")
Nuclides and isotopes: #ce("@Th,227,90@^+")
Different reaction arrows: #ce("A <=> B ->[H2O] C")
Oxidation number support: #ce("|Mn,+II|")

```

![](gallery/example.png)


See the [manual](manual.pdf) for more details and examples.
