#!/usr/bin/bash

mysqldump example > dump.sql

mysqladmin CREATE sample

mysql sample < dump.sql
