#!/bin/sh
#
# Perform minimisation and MD simulation to prepare the simulation box
# for TI simulation. This is done primarily to adjust the density of the
# system because leap will create a water box with too low a density.
#


pmemd=/mdcalc/eric/softwares/amber18/bin/pmemd.MPI

mpirun="mpirun -np 4"

echo "MD in Solvent..."



echo "Minimizing..."

$mpirun $pmemd -i min.in -p lig_solvated.prmtop -c lig_solvated.rst7 -ref lig_solvated.rst7 -O -o min_sol.out -e min_sol.en -inf min_sol.info -r min_sol.rst7 -l min_sol.log

echo "Heating..."
$mpirun $pmemd -i heat.in -p lig_solvated.prmtop -c min_sol.rst7 -ref min_sol.rst7 -O -o heat_sol.out -e heat_sol.en -inf heat_sol.info -r heat_sol.rst7 -x heat_sol.nc -l heat_sol.log

echo "Pressurizing..."
$mpirun $pmemd -i press.in -p lig_solvated.prmtop -c heat_sol.rst7 -ref heat_sol.rst7 -O -o press_sol.out -e press_sol.en -inf press_sol.info -r press_sol.rst7 -x press_sol.nc -l press_sol.log


