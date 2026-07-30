#!/bin/bash
# MD production run of omigaran + post-processing (trajectory fixing, RMSD, Rg)
set -eo pipefail

mkdir -p Solvated 
# for solvated structure
mkdir -p Ionized
# for the ionized structure <- Is the one that is taken for the energy min

{
    echo "Crowding of Omigaran"
    echo "--------------------------------"
    echo "PACKMOL crowding"
    packmol < packmol_files/omi_40.inp
    # this should produced the omigaran_crowded.pdb in structures   
    echo "Crowding complete"
    echo "--------------------------------"
    echo "GROMACS editconf"
    gmx editconf -f structures/omigaran_crowded.pdb \
                -o structures/omigaran_crowded.gro \
                -box 12.5 12.5 12.5 \
                -c
    # editconf: sets up the simulation box
    # -f : input structure file (.pdb)
    # -o : output structure file (.gro)
    # -c : center the system in the box
    # -box : box dimensions (15 nm x 15 nm x 15 nm)
    echo "--------------------------------"
    echo "GROMACS solvate"
    gmx solvate -cp structures/omigaran_crowded.gro\
                -cs spc216.gro \
                -o Solvated/solv.gro \
                -maxsol 61921 \
                -p structures/omigaran_crowded.top
    # solvate: adds water molecules to the simulation box
    # -cp : input structure file (.gro)
    # -cs : input solvent structure file (.gro)
    # -o : output structure file (.gro)
    # -maxsol : maximum number of solvent molecules to add
    # -p : input topology file (.top)
    echo "--------------------------------"
    echo "GROMACS genion"
    gmx grompp -f mdp_files/ion_gen.mdp \
            -c Solvated/solv.gro \
            -p structures/omigaran_crowded.top \
            -o Ionized/ionized.tpr\
            -maxwarn 1
    # grompp: pre-processes the input files for GROMACS
    # -f : input mdp file (parameters for the simulation) <- In this case the parameters for ionization
    # -c : input structure file (.gro)
    # -p : input topology file (.top)
    # -o : output file for the pre-processed input (.tpr)
    echo "SOL" | gmx genion -s Ionized/ionized.tpr \
                -o Ionized/ionized.gro \
                -p structures/omigaran_crowded.top \
                -nname Cl- -neutral
    # genion: replaces solvent molecules with ions to neutralize the system
    # -s : input structure + mass file (.tpr)
    # -o : output structure file (.gro)     
    # -p : input topology file (.top)
    # -pname : name of the positive ion (NA+)
    # -nname : name of the negative ion (CL-)
    # -neutral : neutralize the system by adding ions
    
    # copy the ionized structure to the structures folder
    cp Ionized/ionized.gro structures/omigaran_crowded_f.gro
    echo "Ionization complete"

} 2>&1 | tee structures/omigaran_crowded_f.log