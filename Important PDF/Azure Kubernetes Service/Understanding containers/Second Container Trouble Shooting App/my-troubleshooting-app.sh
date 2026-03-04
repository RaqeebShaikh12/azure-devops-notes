#!/bin/bash
while true; do echo -n "$(date) "; curl -s -o /dev/null -w "%{time_total} %{http_code}\n" $HOST -k; sleep $INTERVAL; done