#!/bin/bash

sleep 10
mysql -h $PG_HOST -u $PG_USERNAME -D $PG_DATABASE --password=$PG_PASSWORD < migrations/nuwmhostels_30.10.sql

node index.js
