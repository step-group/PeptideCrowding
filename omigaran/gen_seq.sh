### create structure

#!/bin/bash
# redirect stdout/stderr to a file
set -e
mkdir -p nvt_eq
{
    echo " CREATING STRUCTURE FILES"
    bash omigaran_init.sh
    python3 gen_gmx.py
    rm -f pep_solv.inpcrd pep_solv.prmtop
    mv pep.top structure/omigaran.top
    mv pep.gro structure/omigaran.gro
    ### restrain file
    echo "CREATING POSITION RESTRAINT FILE"
    echo "You have to edit the structure/omigaran.top file and include the following line after
        [ dihedrals ] and before the next [ moleculretypes ] section:"
    echo "#ifdef POSRES"
    echo "#include \"posre.itp\""
    echo "#endif"
    echo "After editing the file, you can proceed with the next steps."
    echo -e "Protein" | gmx genrestr -f structure/omigaran.gro -o structure/posre.itp
} 2>&1 | tee omigaran_init.log