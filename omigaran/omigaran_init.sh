

tleap -f - <<'EOF'
source oldff/leaprc.ff99SBildn
source leaprc.water.tip3p          # <- defines OW/HW and the Cl- parameters
pep = sequence { NILE LEU ARG TRP PRO TRP TRP PRO TRP ARG ARG LYS NHE }
charge pep
solvateBox pep TIP3PBOX 12.0
addIons pep Cl- 0
saveamberparm pep pep_solv.prmtop pep_solv.inpcrd
quit
EOF