#!/bin/bash
if [ -f app.pid ]; then
  PID=$(cat app.pid)
  if ps -p $PID > /dev/null; then
    kill $PID
    rm app.pid
    echo "Application stopped."
  else
    echo "No running process found with PID: $PID"
  fi
else
  echo "No application running."
fi
