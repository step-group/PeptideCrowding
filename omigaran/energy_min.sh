
#!/bin/bash
# redirect stdout/stderr to a file
set -e
mkdir -p em_sd
{
    echo "ENERGY MINIMIZATION WITH STEEPES DESCENT"
    gmx grompp -f mdp_files/em_sd.mdp \
            -c structure/omigaran.gro \
            -p structure/omigaran.top \
            -o em_sd/em.tpr
    # grompp: pre-processes the input files for GROMACS
    # -f : input mdp file (parameters for the simulation) <- In this case the parameters 
    #                                                        for energy minimization with steepest descent
    # -c : input structure file (.gro)
    # -p : input topology file (.top)
    # -o : output file for the pre-processed input (.tpr)
    gmx mdrun -v -deffnm em_sd/em
    # mdrun: runs the simulation
    # -v : verbose output
    # -deffnm : default filename for input/output files (em_sd/em)
    ### get energy

    echo "ENERGY MINIMIZATION COMPLETE"
    echo -e "Potential" | gmx energy -f em_sd/em.edr \
                                    -o em_sd/potential.xvg
    # energy: extracts energy data from the energy file (.edr)
    # -f : input energy file (.edr)
    # -o : output file for the energy data (.xvg)
    # echo "Potential" to select the potential energy from the list of available energy terms in the .edr file
    # Plot the energy
    python ploting.py --file em_sd/potential.xvg \
        --title "Potential Energy" --folder em_sd --log_scale
    # plot the energy using the ploting.py script
} 2>&1 | tee nvt_eq/em_sd.log