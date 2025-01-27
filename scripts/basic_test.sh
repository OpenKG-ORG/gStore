#!/bin/bash

#set -v

#test
db=("bbug" "lubm" "num" "small")
op=("bin/gbuild" "bin/gquery" "bin/gadd" "bin/gsub" "bin/gdrop")
path="./data/"
bbug_sql=("0" "0d" "1" "2" "3" "4" "5" "6")
lubm_sql=("_p0" "_p1" "_p2" "_p3" "_p4" "_q0" "_q1" "_q2" "_q3" "_q4" "_q5")
num_sql=("0" "1" "2" "3")
small_sql=("_dist" "_p0" "_p1" "_p2" "_p3" "_q0" "_q1" "_q2" "_q3" "_s0" "_s1")
bbug_ans=(-1 -1 297 -1 2 24 0 -1)
lubm_ans=(15 227393 0 27 5916 15 0 828 27 27 5916)
num_ans=(8 0 4 1)
small_ans=(2 2 1 27 1 1 1 4 1 5 5)
triple_num=(1988 99550 29 25 31)

#gbuild
echo "gbuild......"
for i in 0 1 2 3
do
	echo "${op[0]} -db ${db[$i]} -f ${path}${db[$i]}/${db[i]}.nt"
	${op[0]} -db ${db[$i]} -f ${path}${db[$i]}"/"${db[$i]}".nt" > "1.txt" 2>&1
	ans=$(grep "Build RDF database ${db[$i]} successfully!" 1.txt)
	echo "$ans"
	if test -z "$ans"
	then
		echo -e "\e[43;35m build ${db[$i]}.db fails \e[0m"
		exit
	else
		"rm" "1.txt"
		continue
	fi
done

#gadd and gsub
# First sub all triples from the database, then add back
echo "gsub and gadd......"
for i in 0 1 2 3
do
	for j in 3 2
	do
        ${op[$j]} -db ${db[$i]} -f ${path}${db[$i]}"/"${db[$i]}".nt" > "1.txt"
		"rm" "1.txt"
	done
	${op[1]} ${db[$i]} ${path}"all.sql" > "1.txt"
	ans=$(grep "There has answer" 1.txt)
	if [ ${ans:18:${#ans}-18} -ne ${triple_num[$i]} ]
	then
		echo ${ans}
		echo -e "\e[43;35m update triples in ${db[$i]}.db has errors \e[0m"
		"rm" "1.txt"
		exit
	fi
	"rm" "1.txt"
done

#gquery
gquery(){
# bbug
for i in 0 1 2 3 4 5 6 7
do
	echo "${op[1]} -db ${db[0]} -q ${path}${db[0]}/${db[0]}${bbug_sql[$i]}.sql"
	${op[1]} -db ${db[0]} -q ${path}${db[0]}"/"${db[0]}${bbug_sql[$i]}".sql" > "1.txt" 
	if [ ${bbug_ans[$i]} -ne -1 ]
	then
		ans=$(grep "There has answer" 1.txt)
		if [ ${ans:18:${#ans}-18} -ne ${bbug_ans[$i]} ]
		then 
			echo -e "\e[43;35m query ${db[0]}${bbug_sql[$i]}.sql in ${db[0]}.db has errors \e[0m"
			"rm" "1.txt"
			exit
		fi
	fi
	"rm" "1.txt"
done

# lubm
for i in 0 1 2 3 4 5 6 7 8 9 10
do
    echo "${op[1]} -db ${db[1]} -q ${path}${db[1]}/${db[1]}${lubm_sql[$i]}.sql"
    ${op[1]} -db ${db[1]} -q ${path}${db[1]}"/"${db[1]}${lubm_sql[$i]}".sql" > "1.txt"
	ans=$(grep "There has answer" 1.txt)
	if [ ${ans:18:${#ans}-18} -ne ${lubm_ans[$i]} ]
	then
		echo -e "\e[43;35m query ${db[1]}${lubm_sql[$i]}.sql in ${db[1]}.db has errors \e[0m"
		"rm" "1.txt"
		exit
	fi
	"rm" "1.txt"
done

# num
for i in 0 1 2 3
do
        echo "${op[1]} -db ${db[2]} -q ${path}${db[2]}/${db[2]}${num_sql[$i]}"
        ${op[1]} -db ${db[2]} -q ${path}${db[2]}"/"${db[2]}${num_sql[$i]}".sql" > "1.txt"
        ans=$(grep "There has answer" 1.txt)
        if [ ${ans:18:${#ans}-18} -ne ${num_ans[$i]} ]
        then
		echo -e "\e[43;35m query ${db[2]}${num_sql[$i]}.sql in ${db[2]}.db has errors \e[0m"
		"rm" "1.txt"
		exit
        fi
        "rm" "1.txt"
done

# small
for i in 0 1 2 3 4 5 6 7 8 9 10
do
        echo "${op[1]} -db ${db[3]} -q ${path}${db[3]}/${db[3]}${small_sql[$i]}"
        ${op[1]} -db ${db[3]} -q ${path}${db[3]}"/"${db[3]}${small_sql[$i]}".sql" > "1.txt"
        ans=$(grep "There has answer" 1.txt)
        if [ ${ans:18:${#ans}-18} -ne ${small_ans[$i]} ]
        then
		echo -e "\e[43;35m query ${db[3]}${small_sql[$i]}.sql in ${db[3]}.db has errors \e[0m"
		"rm" "1.txt"
		exit
        fi
        "rm" "1.txt"

done
}
echo "gquery......"
gquery

echo "small gadd......"
${op[2]} -db ${db[3]} -f ${path}${db[3]}"/small_add.nt" > "1.txt"
"rm" "1.txt"
${op[1]} -db ${db[3]} -q ${path}"all.sql" > "1.txt"
ans=$(grep "There has answer" 1.txt)
if [ ${ans:18:${#ans}-18} -ne ${triple_num[4]} ]
then
	echo -e "\e[43;35m update triples in ${db[3]}.db has errors \e[0m"
	"rm" "1.txt"
	exit
fi
"rm" "1.txt"

echo "small gsub......"
${op[3]} -db ${db[3]} -f ${path}${db[3]}"/small_add.nt" > "1.txt"
"rm" "1.txt"
${op[1]} -db ${db[3]} -q ${path}"all.sql" > "1.txt"
ans=$(grep "There has answer" 1.txt)
if [ ${ans:18:${#ans}-18} -ne ${triple_num[3]} ]
then
        echo -e "\e[43;35m update triples in ${db[3]}.db has errors \e[0m"
        "rm" "1.txt"
        exit
fi
"rm" "1.txt"

#gdrop
echo "gdrop......"
for i in 0 1 2 3
do
	${op[4]} -db ${db[$i]} > "1.txt" 2>&1
	ans=$(grep "${db[$i]}.db is dropped successfully!" 1.txt)
	echo "$ans"
	if test -z "$ans"
	then
		echo -e "\e[43;35m drop ${db[$i]}.db fails \e[0m"
		exit
	else
		"rm" "1.txt"
	fi
done

echo -e "\e[42m Test passed! \e[0m"