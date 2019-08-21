USE vk;

SELECT * FROM like_types;
INSERT INTO like_types VALUES (1, 'media');

INSERT INTO like_types (name) VALUES ('media');

INSERT INTO like_types VALUES (DEFAULT, 'user');
INSERT INTO like_types (name) VALUES ('newsline'), ('media');
SELECT * FROM like_types;

INSERT IGNORE INTO like_types (name) VALUES ('media');
SHOW WARNINGS;

INSERT INTO like_types SET name = 'community';
 
REPLACE INTO like_types (name) VALUES ('community');

SELECT * FROM like_types;
SELECT ALL * FROM like_types;

SELECT DISTINCT * FROM like_types;

SELECT ALL * FROM like_types LIMIT 1;

UPDATE like_types SET id = id * 10;

UPDATE like_types SET name = 'group' WHERE name = 'community';

UPDATE like_types SET name = 'group' WHERE name = 'user';
UPDATE IGNORE like_types SET name = 'group' WHERE name = 'user';
SHOW WARNINGS:

DELETE FROM like_types WHERE name = 'group';

DELETE FROM like_types LIMIT 1;

DELETE FROM like_types;
INSERT INTO like_types VALUES (DEFAULT, 'media');

TRUNCATE like_types;
INSERT INTO like_types VALUES (DEFAULT, 'media');