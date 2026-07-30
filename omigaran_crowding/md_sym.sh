#!/bin/bash
# MD production run of omigaran + post-processing (trajectory fixing, RMSD, Rg)
set -eo pipefail

mkdir -p md_sym

{
    echo "MD SYM of omigaran"
    echo "Hope you are ready for a long run :P"

    # binary gen
    gmx grompp -f mdp_files/md_sym.mdp \
        -c npt_eq/npt.gro \
        -r npt_eq/npt.gro \
        -t npt_eq/npt.cpt \
        -p structures/omigaran_crowded.top \
        -o md_sym/md.tpr
        # -f : mdp file with simulation parameters
        # -c : structure of the system to start sim
        # -r : restraint reference structure
        # -t : checkpoint file (carries over velocities/thermostat state)
        # -p : topology file
        # -o : output .tpr for mdrun

    # run sym
    gmx mdrun -v -deffnm md_sym/md
    # -v : verbose output
    # -deffnm : default filename for output files (md_sym/md.tpr -> md_sym/md.xtc, md_sym/md.edr, etc.)
    echo "MD SYM COMPLETE - starting post-processing"
} 2>&1 | tee md_sym/md_sym.log