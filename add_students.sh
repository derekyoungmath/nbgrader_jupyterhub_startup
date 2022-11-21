#!/usr/bin/env bash

teacher=$1
course=$2
xls_file=$3

nbgrader='/opt/tljh/user/bin/nbgrader'
jupyter='/opt/tljh/user/bin/jupyter'

student_csv="/home/$teacher/$course/students.csv"
echo "id,last_name,first_name,email" > $students_csv
sed -r '/@mtholyoke.edu/!d; s/([^\t]*)\t([^\t]*)\t([^\t]*).*/\1,\2,\3/; s/ ([^(])/\1/g' $xls_file >> $students_csv
$nbgrader db student import $students_csv

while read i; do
	sudo -u jupyter-$i $jupyter nbextension enable --user assignment_list/main --section=tree
	sudo -u jupyter-$i $jupyter serverextension enable --user nbgrader.server_extensions.assignment_list
	# sudo -u jupyter-$i $jupyter labextension disable --level=user nbgrader/assignment-list
	# sudo -u jupyter-$i $jupyter labextension enable --level=user nbgrader/assignment-list
done < <(sed -r '/@mtholyoke.edu/!d; s/.*[\t ]([^ ]*)@mtholyoke.edu.*/\1/g' $xls_file)
