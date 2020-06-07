#!/bin/sh
#
# Setup for the free energy simulations: creates and links to the input file as
# necessary.  Two alternative for the de- and recharging step can be used.
#

#vdw_steps=15
#vdw_bonded_lamda=(0.0 0.1 0.2 0.3 0.4 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.94 0.985 1.0) 
#if modify lamda, then the ti.in should also be modified
vdw_bonded_lamda=(0 0.05 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.85 0.90 0.95 1.0)


#decharge_steps=15
#decharge_lamda=(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)
#decharge_lamda=(0 0.05 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.85 0.90 0.95 1.0)


# partial removal/addition of charges: softcore atoms only


#transform=" ifsc=1, scmask1=':1', scmask2='',"

#mkdir TI

#cp /mdcalc/eric/Free_energy/amber_TI/input_templ/*tmpl .




#cd TI
#cp /mdcalc/eric/Free_energy/amber_TI/input_templ/*dG_analysis.sh .
#cp /mdcalc/eric/Free_energy/amber_TI/input_templ/*submit*.sh .

echo "Setting dir for decoupling in Solvent..."



for step in dual_decouple
do
        mkdir $step

	cd $step
	for w in ${vdw_bonded_lamda[@]}
	do
		mkdir $w
		#FE=$(eval "echo \${$step}")
		cp ../lig_solvated.prmtop $w/ti.prmtop
		cp ../press_sol.rst7 $w/ti.rst7
		sed -e "s/%L%/$w/" -e "s/%FE%/$transform/" ../ht.tmpl > $w/ht.in
		sed -e "s/%L%/$w/" -e "s/%FE%/$transform/" ../eq.tmpl > $w/eq.in
		sed -e "s/%L%/$w/" -e "s/%FE%/$transform/" ../ti.tmpl > $w/ti.in
	done
	cd ..
done

