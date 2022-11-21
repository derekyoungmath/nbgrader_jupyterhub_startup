#!/usr/bin/env bash

teacher=$1
course=$2

echo "Installing dependencies..."
apt install -y npm
npm install -g configurable-http-proxy

echo "Creating directory '/srv/nbgrader' with permissions 'ugo+r'"
mkdir -p /srv/nbgrader
chmod ugo+r /srv/nbgrader

pip install nbgrader
nbgrader='/opt/tljh/user/bin/nbgrader'
jupyter='/opt/tljh/user/bin/jupyter'

rm -rf /opt/tljh/user/etc/jupyter

$jupyter nbextension install --symlink --sys-prefix --py nbgrader --overwrite
$jupyter nbextension disable --sys-prefix --py nbgrader
$jupyter serverextension disable --sys-prefix --py nbgrader

$jupyter nbextension enable --sys-prefix validate_assignment/main --section=notebook
$jupyter serverextension enable --sys-prefix nbgrader.server_extensions.validate_assignment

echo "Creating dir '/usr/local/share/nbgrader/exchange' with permissions 'ugo+rwx'"
mkdir -p /usr/local/share/nbgrader/exchange
chmod ugo+rwx /usr/local/share/nbgrader/exchange

rm -f /etc/jupyter/nbgrader_config.py
echo "Setting up JupyterHub to run in '/srv/nbgrader/jupyterhub'"
mkdir -p /srv/nbgrader/jupyterhub
rm -f /srv/nbgrader/jupyterhub/jupyterhub.sqlite
rm -f /srv/nbgrader/jupyterhub/jupyterhub.cookie_secret
echo "c=get_config()" > /srv/nbgrader/jupyterhub/jupyterhub_config.py
echo "c.Authenticator.allowed_users = ['$teacher',]" >> /srv/nbgrader/jupyterhub/jupyterhub_config.py

echo "Setting up nbgrader for user $teacher"
mkdir /home/$teacher/.jupyter
echo "c = get_config()'" > /home/$teacher/.jupyter/nbgrader_config.py
echo "c.CourseDirectory.root = '/home/jupyter-$teacher/$course' >> /home/$teacher/.jupyter/nbgrader_config.py"
echo "c.CourseDirectory.course_id = '$course' >> /home/$teacher/.jupyter/nbgrader_config.py"
chown $teacher:$teacher /home/$teacher/.jupyter/nbgrader_config.py

cd /home/$teacher
runas="sudo -u $teacher"

$runas $nbgrader quickstart $course

$runas $jupyter nbextension enable --user create_assignment/main

$runas $jupyter nbextension enable --user formgrader/main --section=tree
$runas $jupyter serverextension enable --user nbgrader.server_extensions.formgrader

$runas $jupyter nbextension enable --user assignment_list/main --section=tree
$runas $jupyter serverextension enable --user nbgrader.server_extensions.assignment_list
