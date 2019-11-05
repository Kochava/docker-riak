#!/bin/bash
while read VAR KEY; do
  if eval "[[ -n \$${VAR} ]]"; then
    echo "${KEY} = $(eval "echo \"\${${VAR}}\"")"
  fi
done </usr/local/riak/riak.conf.vars >>/usr/local/riak/etc/riak.conf
if [ $# -gt 0 ]; then
  exec bash -c '"$@"' _ "$@"
fi
exec /usr/bin/runsv /var/service/riak
