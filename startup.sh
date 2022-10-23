#!/usr/bin/env bash

# script must be run with sudo
#
#
# this directory and files need to be removed
#
#/etc/jupyter
#/srv/nbgrader/
#/usr/local/share/nbgrader/
#
# the following files need to be in the same directory as script 
#
#jupyterhub_config.py
#instructor_nbgrader_config.py
#

teacher=$1
course=$2

echo "Installing dependencies..."
apt install -y npm
npm install -g configurable-http-proxy

echo "Creating directory '/srv/nbgrader' with permissions 'ugo+r'"
mkdir -p /srv/nbgrader
chmod ugo+r /srv/nbgrader

# pip install nbgrader

jupyter nbextension install --symlink --sys-prefix --py nbgrader --overwrite
jupyter nbextension disable --sys-prefix --py nbgrader
jupyter serverextension disable --sys-prefix --py nbgrader

jupyter nbextension enable --sys-prefix validate_assignment/main --section=notebook
jupyter serverextension enable --sys-prefix nbgrader.server_extensions.validate_assignment

echo "Creating dir '/usr/local/share/nbgrader/exchange' with permissions 'ugo+rwx'"
mkdir -p /usr/local/share/nbgrader/exchange
chmod ugo+rwx /usr/local/share/nbgrader/exchange


echo "Setting up nbgrader for user $teacher"
mkdir /home/$teacher/.jupyter
cp instructor_nbgrader_config.py /home/$teacher/.jupyter/nbgrader_config.py
chown $teacher:$teacher /home/$teacher/.jupyter/nbgrader_config.py

cd /home/$teacher
runas="sudo -u $teacher"

# restart server and the following lines won't be needed
nbgrader='/opt/tljh/user/bin/nbgrader'
jupyter='/opt/tljh/user/bin/jupyter'

$runas $nbgrader quickstart $course

$runas $jupyter nbextension enable --user create_assignment/main

$runas $jupyter nbextension enable --user formgrader/main --section=tree
$runas $jupyter serverextension enable --user nbgrader.server_extensions.formgrader

$runas $jupyter nbextension enable --user assignment_list/main --section=tree
$runas $jupyter serverextension enable --user nbgrader.server_extensions.assignment_list
cd -

# The following needs to be run to add student
#
# nbgrader db student import students.csv
#
# where the columns of the csv should be 
# id,first_name,last_name,email
# id = student's user name
#
# The following needs to be run to add student extensions
#
# $student $jupyter nbextension enable --user assignment_list/main --section=tree
# $student $jupyter labextension disable --level=user nbgrader/assignment-list
# $student $jupyter labextension enable --level=user nbgrader/assignment-list
# $student $jupyter serverextension enable --user nbgrader.server_extensions.assignment_list
