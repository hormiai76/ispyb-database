#!/usr/bin/env bash

# Script to create the database from the ${project_root}/schema .sql files and identify any
# update .sql files that haven't been run. Also generate documentation from
# inline comments in the ${project_root}/schema.

# Some code borrowed from Stefan Buck's gist file at:
# https://gist.github.com/stefanbuck/ce788fee19ab6eb0b4447a85fc99f447

# Author: Karl Levik

set -e

# Get this scripts dir
dir=$(dirname $(realpath ${0}))

# Get the project'r root dir
project_root=$(dirname "${dir}")
echo ${project_root}

scripts_folder=${project_root}/scripts
echo ${scripts_folder}

mycnf=${scripts_folder}/.my.cnf
echo ${mycnf}

dfp="--defaults-file="
df=${dfp}${project_root}/scripts/.my.cnf
echo ${df}

source ${dir}/functions.sh

if [ -z "${DB}" ]
then
  DB="test"
fi


echo "Dropping + creating build database"
echo "Database to be created:$DB"
mysql ${df} -e "DROP DATABASE IF EXISTS $DB; CREATE DATABASE $DB; SET GLOBAL log_bin_trust_function_creators=ON; USE $DB;"

echo "database $DB created"
if [[ $? -eq 0 ]]
then
  echo 'tables'
  mysql $df -D $DB < ${project_root}/schema/1_tables.sql
  echo 'lookups'
  mysql $df -D $DB < ${project_root}/schema/2_lookups.sql
  echo 'data'
  mysql $df -D $DB < ${project_root}/schema/3_data.sql
  if [ -z "${NO_USERPORTAL_DATA}" ]
  then
    echo "Importing User Portal Data"
    mysql $df -D $DB < ${project_root}/schema/4_data_user_portal.sql
    echo "User Portal Data imported"
  fi
  mysql $df -D $DB < ${project_root}/schema/5_routines.sql
  echo "Creating users to be used in the following import scripts"
  mysql $df -D $DB < ${project_root}/grants/ispyb_users.sql
  echo "User created"
  echo "Importing Acquisition"
  mysql $df -D $DB < ${project_root}/grants/ispyb_acquisition.sql
  echo "Acquisitions imported"
  echo "Importing Processing"
  mysql $df -D $DB < ${project_root}/grants/ispyb_processing.sql
  echo "Processing imported"
  echo "Importing Web"
  mysql $df -D $DB < ${project_root}/grants/ispyb_web.sql
  echo "Web imported"
  mysql $df -D $DB < ${project_root}/grants/ispyb_import.sql
  echo "All ${project_root}/grants scripts executed correctly"
  arr=$(${dir}/missed_updates.sh)

  if [ -n "$arr" ]; then
    echo "Running ${project_root}/schema/updates/*.sql files that haven't yet been run:"
    for sql_file in ${arr[@]}; do
      echo "$sql_file"
      #echo "file path:${project_root}/schema/updates/${sql_file}"
      insert_to_find="INSERT INTO SchemaStatus (scriptName, schemaStatus) VALUES ('${sql_file}', 'ONGOING');"
      file_to_be_checked="${project_root}/schema/updates/${sql_file}"
      update_to_find="UPDATE SchemaStatus SET schemaStatus = 'DONE' WHERE scriptName = '${sql_file}';"

      #echo "insert to be found:${insert_to_find}"
      #echo "update to be found:${update_to_find}"
      #echo "file to be checked:${file_to_be_checked}"
      #echo "command to be executed to find the INSERT:grep -Fxq \"${insert_to_find}\" < \"${file_to_be_checked}\""
      if ! grep -Fxq "${insert_to_find}" < "${file_to_be_checked}"; then
        echo "** ${sql_file} does not match schemaStatus.scriptName INSERT value **"
        echo "  Looking for: INSERT INTO schemaStatus (scriptName, schemaStatus) VALUES ('${sql_file}', 'ONGOING');"
        exit 1
      fi
      #echo "command to be executed to find the UPDATE:grep -Fxq \"${update_to_find}\" < \"${file_to_be_checked}\""
      if ! grep -Fxq "${update_to_find}" < "${file_to_be_checked}"; then
        echo "** ${sql_file} does not match schemaStatus.scriptName UPDATE value **"
        echo "  Looking for: UPDATE schemaStatus SET schemaStatus = 'DONE' WHERE scriptName = '${sql_file}';"        
        exit 1
      fi
      mysql $df -D $DB < ${project_root}/schema/updates/${sql_file}
    done
  else
    echo "No new ${project_root}/schema/updates/*.sql files."
  fi

  echo "$PWD"
  # Generate table and sproc documentation
  if ! hash pandoc 2>/dev/null; then
    echo "'pandoc' was not found in PATH"
    apt update
    apt install pandoc -y
  elif [ -d "bin" ]; then
    cd bin
    if ! [ -d "/tmp/html" ]; then
      mkdir "/tmp/html"
    fi
    ./db_procs_to_rst.sh $DB > /tmp/html/list_of_procs.rst
    pandoc -o /tmp/html/list_of_procs.html /tmp/html/list_of_procs.rst
    ./db_tables_to_rst.sh $DB > /tmp/html/list_of_tables_and_columns.rst
    pandoc -o /tmp/html/list_of_tables_and_columns.html /tmp/html/list_of_tables_and_columns.rst
    echo "HTML documentation written to files in /tmp/html/"
    cd ..
    cp /tmp/html/*.html ./html/
    cp /tmp/html/*.rst ./html/
    echo "HTML documentation copied to the html folder"
  fi

fi
