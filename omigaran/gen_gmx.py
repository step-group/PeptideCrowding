import parmed as pmd
p = pmd.load_file("pep_solv.prmtop", xyz="pep_solv.inpcrd")
p.save("pep.top", overwrite=True)
p.save("pep.gro", overwrite=True)