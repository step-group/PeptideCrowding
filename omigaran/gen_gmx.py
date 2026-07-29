import parmed as pmd
p = pmd.load_file("pep_solv.prmtop", xyz="pep_solv.inpcrd") # load the AMBER files
p.save("pep.top", overwrite=True) # save the topology file in GROMACS format
p.save("pep.gro", overwrite=True) # save the coordinates file in GROMACS format