#!/bin/bash

src_dir="/usr/local/src/mdb-backup"

source "${src_dir}/config.sh"

dump_dir="${parent_dir}/dump"
log_file="${dump_dir}/mysqldump-progress.log"
now="$(date +%m-%d-%Y_%H-%M-%S)"

source "${src_dir}/lib.sh"

set_options() {
    # List the mysqldump arguments
    mysqldump_args=(
        "--defaults-file=${defaults_file}"
        "--insert-ignore"
        "--skip-lock-tables"
        "--single-transaction=TRUE"
    )

   if [ $1 ]; then
     mysqldump_args+=( "--databases" )

     for db_name in "$@"; do
        mysqldump_args+=( "${db_name}" )
     done
   else
     mysqldump_args+=( "--all-databases" )
   fi
}

prepare_dump_dir() {
        run mkdir --verbose -p "${dump_dir}" >&$log || error "mkdir ${dump_dir} failed"
}

take_dump() {
        run mysqldump "${mysqldump_args[@]}" | gzip > "${dump_dir}/mysqldump-${now}.sql.qz" \
        || error "mysqldump failed"
}

check_backup_user && set_options "$@" && prepare_dump_dir && take_dump 2>&$log

printf "MysqlDump successful!\n"
printf "MysqlDump created at %s/mysqldump-%s.sql.gz\n" "${dump_dir}" "${now}"

exit 0
