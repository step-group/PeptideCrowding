# tleap -f -   reads its commands from stdin rather than a file;
# the heredoc below feeds them in. Quoting 'EOF' stops the shell from
# expanding anything inside, so tleap sees the text verbatim.
tleap -f - <<'EOF'
# Force field 
# Protein parameters.
source oldff/leaprc.ff99SBildn 

# Water + monovalent ion parameters. Supplies the OW/HW atom types, the
# TIP3PBOX unit used by solvateBox, and frcmod.ionsjc_tip3p for Cl-.
# Without this line solvateBox errors with "could not find vdW parameters
# for type (OW)" and addIons fails the same way on Cl-.
# Order matters: protein force field first, then water.
source leaprc.water.tip3p

# Build the peptide
# sequence{} links residue units head-to-tail into a linear chain.
# Termini are chosen by which unit you name, not by a separate command:
#   NILE  N-terminal isoleucine  -> carries the -NH3+ charges  (the "H-")
#   LYS   MID-CHAIN lysine       -> NOT CLYS, which would add -COO-
#   NHE   neutral amide cap      -> the C-terminal "-NH2"
# 12 amino acids + 1 cap = 13 units per chain.
pep = sequence { NILE LEU ARG TRP PRO TRP TRP PRO TRP ARG ARG LYS NHE }

#  Validation 
#  Must print 5.0:

charge pep

# Solvate 
# Rectangular TIP3P box with 12.0 ANGSTROM padding (tleap works in A, not nm)
# between the solute and each face. tleap picks the water count itself --
# you cannot request an exact number here, which is why the crowded system
# uses gmx solvate -maxsol instead.
solvateBox pep TIP3PBOX 12.0

# Neutralise. The trailing 0 means "add however many are needed", not
# "add zero" -- expect 5 Cl- for the +5 peptide.
addIons pep Cl- 0

# --- Write out -----------------------------------------------------------
# .prmtop = topology + all parameters,  .inpcrd = coordinates + box vectors.
# Convert to GROMACS afterwards with ParmEd (pdb2gmx cannot read NHE).
saveamberparm pep pep_solv.prmtop pep_solv.inpcrd
quit
EOF