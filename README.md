A script to setup nbgrader with Jupyterhub using the one class one grader demo. See

`https://github.com/jupyter/nbgrader/tree/main/demos`

# Installation

`git clone https://github.com/derekyoungmath/nbgrader_jupyterhub_startup.git`
`cd nbgrader_jupyterhub_startup`

# Example

## Initializing course

Here the instructor is `jupyter-dyoung` and the course is `math232`.

`sudo ./startup.sh jupyter-dyoung math232`

Press `ok` for the 'Pending kernel upgrade' warning.
Press `ok` to restart 'Daemons using outdated libraries'.

## Adding students to course

The following line adds students that have jupyter-hub accounts by using the
default `Roster.xls` file provided by `my.mtholyoke.edu`.

`sudo ./add_students.sh jupyter-dyoung math232 Roster.xls`

### Manually adding students

In addition to the student must being added to the course from the jupyter-hub
notebook, the following lines must be run to enable the student's notebook
functionality. 

`sudo -u jupyter-student_id /opt/tljh/user/bin/jupyter nbextension enable --user assignment_list/main --section=tree`
`sudo -u jupyter-student_id /opt/tljh/user/bin/jupyter serverextension enable --user nbgrader.server_extensions.assignment_list`
