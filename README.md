# Free Solvation Energy Calculation Using Amber

Tutorial and automated scripts to calculate the free solvation energy using Amber Double Decoupling Method. 

Requirements:

1. Amber Package with pmemd.cuda installed 

2. Python3

## Step 1: Prepare the system

Here we take the benzne molecule for example and the ligand was fixed during MD.

1.1  Using antechamber and parmchk2 to generate the mol2 and parameter file from the ligand initial structure file (ligand.pdb).

``` 
antechamber -i ligand.pdb -fi pdb -o ligand.mol2 -fo mol2 -c bcc -s 2 -nc 0
parmchk2 -i ligand.mol2 -f mol2 -o ligand.frcmod
```

1.2 Generate the prmtop and rst7 file 

Bellow this the input for tleap

```
source leaprc.protein.ff14SB
source leaprc.gaff2
source leaprc.water.tip3p
loadamberparams ligand.frcmod
lig = loadmol2 ligand.mol2
check lig
saveoff lig ligand,lib
sovatebox lig TIP3PBOX 12.0
saveamberparm lig lig_solvated.prmtop lig_solvated.rst7
```

## Step 2: Run a short cycle of MD to prepare the system into the one with resonable coordinates

In short, the cycle includes minimizing, heating and pressurizing

```
pmemd -i min.in -p lig_solvated.prmtop -c lig_solvated.rst7 -ref lig_solvated.rst7 -O -o min_sol.out -e min_sol.en -inf min_sol.info -r min_sol.rst7 -l min_sol.log
pmemd.cuda -i heat.in -p lig_solvated.prmtop -c min_sol.rst7 -ref min_sol.rst7 -O -o heat_sol.out -e heat_sol.en -inf heat_sol.info -r heat_sol.rst7 -x heat_sol.nc -l heat_sol.log
pmemd.cuda  -i press.in -p lig_solvated.prmtop -c heat_sol.rst7 -ref heat_sol.rst7 -O -o press_sol.out -e press_sol.en -inf press_sol.info -r press_sol.rst7 -x press_sol.nc -l press_sol.log

```
## Step 3: Setup the lambda windows and get the files ready in each lambda

Here we have 15 lambda states, and we will modify the the lambda values in the template parameter file 

```
lambda_states=(0 0.05 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.85 0.90 0.95 1.0)

mkdir dual_decouple

cd dual_decouple

for w in ${lambda_states}
do
    mkdir $w
    cp lig_solvated.prmtop $w/ti.prmtop
    cp lig_solvated.rst7 $w/ti.rst7
    sed -e "s/%L%/$w/" ht.tmpl > $w/ht.in
    sed -e "s/%L%/$w/" eq.tmpt > $w/eq.in
    sed -e "s/%L%/$w/" ti.tmpl > $w/ti.in
done

cd ..
```
## Step 4: run each lambda states 

By now, you have all the files in each lambda directory, just run the follow three steps. Please note in the heating step, we just use the coordinate not the velocity and in the case when your system is too small for regular pmemd.cuda, using the "-AllowSmallBox" label: pmemd.cuda -AllowSmallBox:

```
# heating
pmemd.cuda -i ht.in -c ti.rst7 -ref ti.rst7 -p ti.prmtop -O -o ht.out -inf ht.info -e ht.en -r ht.rst7 -x ht.nc -l ht.log

#equilbrium 
pmemd.cuda -i eq.in -c ht.rst7 -ref ht.rst7 -p ti.prmtop -O -o eq.out -inf eq.info -e eq.en -r eq.rst7 -x eq.nc -l eq.log

# double decoupling TI
pmemd.cuda -i -i ti.in -c eq.rst7 -ref eq.rst7 -p ti.prmtop -O -o ti001.out -inf ti001.info -e ti001.en -r ti001.rst7 -x ti001.nc -l ti001.log
```

## Step 5: Get the solvation free energy result

After all lambda state calculations are completed, use the following python script to get the dG value:

```
python getdvdl 5 ti001.en [01].* > dvdl.dat

```
The dG (~1.03664 Kcal/mol in this benzene example) value will be shown at the last line of the generated dvdl.dat file. Since we the dG is decoupling the ligand from water, the solvation free energy is the reverse process, therefore the solvation free energy is -dG, which is -1.03664 Kcal/mol.

*We thanks Thomas Steinbrecher's free energy calculation tutorial at http://ambermd.org/tutorials/advanced/tutorial9/. The script and template files in this tutorial were adpated from his work. 






