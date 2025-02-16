#import "@local/whalogen:0.3.0": ce

#set page(width: auto, height: auto)

$
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
$

