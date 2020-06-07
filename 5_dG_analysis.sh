#!bin/bsh

getdvdl=/home/eric/amber_TI/scripts/getdvdl.py

for system in dual_decouple
do
	cd $system

	for lambda in [0,1]*
	do
		cp $lambda/eric*/ti*en $lambda/
	done

	python $getdvdl 5 ti001.en [01].* > dvdl.dat

	echo "Solvation Free Energy: "
	
	dG=$(tail -n 1 dvdl.dat | awk '{print $4}')
	
	# Solovation Free energy is the reverse of decoupling 

	echo "0.0 $dG" | awk '{print $1-$2}'

	cd ..
done
