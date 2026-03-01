#!/bin/bash
pg_restore --dbname=pr_tracker_development --verbose --clean --if-exists --no-owner --no-privileges --format=directory $1
