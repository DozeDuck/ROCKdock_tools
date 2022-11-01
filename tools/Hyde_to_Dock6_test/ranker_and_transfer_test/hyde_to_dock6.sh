mkdir hyde_to_dock6

/usr/bin/obabel $1 -O seesar_rescore_subset.mol2 
/usr/bin/obabel -imol2 seesar_rescore_subset.mol2 -O separated.mol2 -m

awk '/LOWER_BOUNDARY/{getline a;print a}' seesar_rescore_subset.sdf > hyde_LOWER_score
awk '/UPPER_BOUNDARY/{getline a;print a}' seesar_rescore_subset.sdf > hyde_UPPER_score
awk '/@<TRIPOS>MOLECULE/{getline a;print a}' seesar_rescore_subset.mol2 > hyde_MOL_name
sed -i 's/^/##########    HYDE_LOWER_BOUNDARY_SCORE:    /g' hyde_LOWER_score
sed -i 's/^/##########    HYDE_UPPER_BOUNDARY_SCORE:    /g' hyde_UPPER_score
sed -i 's/^/##########                         Name:    /g' hyde_MOL_name

TOTAL_MOL=`more $1 | grep LOWER | wc -l`
for i in `seq 1 $TOTAL_MOL`
do
	sed -n "$i"p hyde_MOL_name > ./hyde_to_dock6/$i	
	sed -n "$i"p hyde_LOWER_score >> ./hyde_to_dock6/$i
	sed -n "$i"p hyde_UPPER_score >> ./hyde_to_dock6/$i
	cat separated$i.mol2 >> ./hyde_to_dock6/$i
	cat ./hyde_to_dock6/$i >> hyde_score_dock6_format.mol2
done

# cat ./hyde_to_dock6/* >> hyde_score_dock6_format.mol2 # this * may output result

rm separated*mol2
rm hyde_LOWER_score
rm hyde_UPPER_score
rm seesar_rescore_subset.mol2
rm hyde_MOL_name
rm -r hyde_to_dock6
