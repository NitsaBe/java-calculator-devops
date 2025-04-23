#!/bin/bash
nohup java -jar calculator-0.0.1-SNAPSHOT.jar --server.port=8080 > app.log 2>&1 &
echo $! > app.pid
echo "Application started on port 8080. PID: $(cat app.pid)"
