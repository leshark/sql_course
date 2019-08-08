#!/usr/bin/bash

mysqldump --where="1 LIMIT 100"  mysql help_keyword > help_keyword_dump.sql
