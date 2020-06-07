#!/bin/sh


# you need to provide the molecule sturtcure as "ligand.pdb" file 

#set up the tleap path

tleap=$AMBERHOME/bin/tleap



antechamber -i ligand.pdb -fi pdb -o ligand.mol2 -fo mol2 -c bcc -s 2

parmchk2 -i ligand.mol2 -f mol2 -o ligand.frcmod


# generate the initial prmtop and rst7 file for ligand in water

$tleap -f - <<_EOF
# load the AMBER force fields
source leaprc.protein.ff14SB
source leaprc.gaff2
source leaprc.water.tip3p
loadamberparams ligand.frcmod

# load the coordinates and create the complex
lig = loadmol2 ligand.mol2

check lig

saveoff lig ligand.lib

# create ligands in solution for vdw+bonded transformation
solvatebox lig TIP3PBOX 12.0
# The ligand should be netural or need addions
#savepdb lig lig_solvated.pdb
saveamberparm lig lig_solvated.prmtop lig_solvated.rst7
quit
_EOF


# clean the dir a little bit

rm ANTE*
rm sqm*
rm ATOM*



lig_name=$(head -n 1 ligand.pdb | awk '{print $4}')

echo " The Ligand $lig_name is successfully prepared."
