#!/bin/bash
if [ -f app.pid ]; then
  PID=$(cat app.pid)
  kill $PID
  rm app.pid
  echo "Application stopped."
else
  echo "No application running."
fi
