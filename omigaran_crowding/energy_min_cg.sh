
#!/bin/bash
# redirect stdout/stderr to a file
set -e
mkdir -p em_cg
{
    echo "ENERGY MINIMIZATION WITH CONJUGATE GRADIENT"
    gmx grompp -f mdp_files/em_cg.mdp \
            -c em_sd/em.gro \
            -p structure/omigaran.top \
            -o em_cg/em.tpr
    # grompp: pre-processes the input files for GROMACS
    # -f : input mdp file (parameters for the simulation) <- In this case the parameters 
    #                                                        for energy minimization with steepest descent
    # -c : input structure file (.gro)
    # -p : input topology file (.top)
    # -o : output file for the pre-processed input (.tpr)
    gmx mdrun -v -deffnm em_cg/em
    # mdrun: runs the simulation
    # -v : verbose output
    # -deffnm : default filename for input/output files (em_cg/em)
    ### get energy

    echo "ENERGY MINIMIZATION COMPLETE"
    echo -e "Potential" | gmx energy -f em_cg/em.edr \
                                    -o em_cg/potential.xvg
    # energy: extracts energy data from the energy file (.edr)
    # -f : input energy file (.edr)
    # -o : output file for the energy data (.xvg)
    # echo "Potential" to select the potential energy from the list of available energy terms in the .edr file
    # Plot the energy
    python ploting.py --file em_cg/potential.xvg \
        --title "Potential Energy" --folder em_cg --log_scale
    # plot the energy using the ploting.py script
} 2>&1 | tee em_cg/em_cg.log