CREATE DATABASE IF NOT EXISTS telegram;
USE telegram;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  firstname VARCHAR(100) NULL, 
  lastname VARCHAR(100) NULL,
  username VARCHAR(100) UNIQUE NULL COMMENT 'Users are searched by @username',
  about VARCHAR(66) NULL,
  phone VARCHAR(100) NOT NULL UNIQUE,
  photo_id BIGINT UNSIGNED NULL,
  is_bot BOOLEAN NOT NULL DEFAULT FALSE,
  proxy_settings JSON,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

-- connection between media content and its types
DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(255) NOT NULL UNIQUE
);


DROP TABLE IF EXISTS media;
CREATE TABLE media (
  id SERIAL PRIMARY KEY,
  name TEXT NULL,
  size INT UNSIGNED,
  user_id BIGINT UNSIGNED NOT NULL,
  CONSTRAINT media_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id),
  media_type_id INT UNSIGNED NOT NULL,
  CONSTRAINT media_type_id_fk FOREIGN KEY (media_type_id) REFERENCES media_types(id)
    ON DELETE RESTRICT,
  metadata JSON,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

ALTER TABLE users ADD 
  CONSTRAINT users_photo_id_fk FOREIGN KEY (photo_id) REFERENCES media(id)
    ON DELETE SET NULL;

DROP TABLE IF EXISTS channels;
CREATE TABLE channels(
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  link VARCHAR(100) UNIQUE NULL COMMENT 'Link is auto-generated for private channels',
  is_public BOOLEAN NOT NULL DEFAULT FALSE,
  about VARCHAR(255) NULL,
  photo_id BIGINT UNSIGNED NULL,
  CONSTRAINT channels_photo_id_fk FOREIGN KEY (photo_id) REFERENCES media(id)
    ON DELETE SET NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

DELIMITER //

DROP FUNCTION IF EXISTS gen_link//
CREATE FUNCTION gen_link() RETURNS TEXT NO SQL
BEGIN
  RETURN CONCAT("https://t.me/joinchat/", LEFT(UUID(), 22));
END //

-- auto generate link for channels
DROP TRIGGER IF EXISTS before_insert_channels//
CREATE TRIGGER before_insert_channels BEFORE INSERT ON channels FOR EACH ROW
BEGIN
  IF NEW.link IS NULL
    THEN SET NEW.link = gen_link();
  END IF;
END //

DELIMITER ;

-- table of user roles in communities
DROP TABLE IF EXISTS user_roles;
CREATE TABLE user_roles (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_role VARCHAR(30) NOT NULL COMMENT 'admin, creator or participant'
);


-- connection between users and channels
DROP TABLE IF EXISTS channels_users;
CREATE TABLE channels_users (
  channel_id BIGINT NOT NULL COMMENT 'is < 0',
  user_id BIGINT UNSIGNED NOT NULL,
  user_role INT UNSIGNED NOT NULL,
  user_permissions SET('no_rights', 'change_chanel_info', 'post_messages', 'edit_messages_of_others', 'delete_messages_of_others', 'add_subscribers', 'add_new_admins'),
  CONSTRAINT channels_users_channel_id_fk FOREIGN KEY (channel_id) REFERENCES channels(id)
    ON DELETE CASCADE,
  CONSTRAINT channels_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT channels_users_user_role_fk FOREIGN KEY (user_role) REFERENCES user_roles(id)
    ON DELETE RESTRICT,
  PRIMARY KEY (channel_id, user_id)
);


DROP TABLE IF EXISTS chats;
CREATE TABLE chats(
  id SERIAL PRIMARY KEY,
  title VARCHAR(200) NULL COMMENT 'title in chat is CONCAT(firstname, lastname) of user',
  photo_id BIGINT UNSIGNED NULL COMMENT 'photo in chat is user photo',
  CONSTRAINT chats_photo_id_fk FOREIGN KEY (photo_id) REFERENCES media(id)
    ON DELETE SET NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);


-- connection between users and chats
DROP TABLE IF EXISTS chats_users;
CREATE TABLE chats_users (
  chat_id BIGINT UNSIGNED NOT NULL,
  from_user_id BIGINT UNSIGNED NOT NULL,
  to_user_id BIGINT UNSIGNED NOT NULL,
  CONSTRAINT chats_users_chat_id_fk FOREIGN KEY (chat_id) REFERENCES chats(id)
    ON DELETE CASCADE,
  CONSTRAINT chats_users_from_user_id_fk FOREIGN KEY (from_user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT chats_users_to_user_id_fk FOREIGN KEY (to_user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  PRIMARY KEY (chat_id, from_user_id, to_user_id)
);


DELIMITER //

-- auto generate link for groups
DROP TRIGGER IF EXISTS before_insert_groups//
CREATE TRIGGER before_insert_groups BEFORE INSERT ON `groups` FOR EACH ROW
BEGIN
  IF NEW.link IS NULL
    THEN SET NEW.link = gen_link();
  END IF;
END //

DELIMITER ;

DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups`(
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  link VARCHAR(100) UNIQUE NULL COMMENT 'Link is auto-generated for private groups',
  is_public BOOLEAN NOT NULL DEFAULT FALSE,
  about VARCHAR(255) NULL,
  photo_id BIGINT UNSIGNED NULL,
  CONSTRAINT groups_photo_id_fk FOREIGN KEY (photo_id) REFERENCES media(id)
    ON DELETE SET NULL,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

-- connection between users and groups
DROP TABLE IF EXISTS groups_users;
CREATE TABLE groups_users (
  group_id BIgINT UNSIGNED NOT NULL,
  user_id BigINT UNSIGNED NOT NULL,
  user_role INT UNSIGNED NOT NULL,
  user_permissions SET('send_messages', 'send_media', 'send_stickers', 'embed_links', 'send_polls', 'add_members', 'pin_messages', 'change_group_info', 'delete_messages', 'ban_users'),
  CONSTRAINT groups_users_group_id_fk FOREIGN KEY (group_id) REFERENCES `groups`(id)
    ON DELETE CASCADE,
  CONSTRAINT groups_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT groups_users_user_role_fk FOREIGN KEY (user_role) REFERENCES user_roles(id)
    ON DELETE RESTRICT,
  PRIMARY KEY (group_id, user_id)
);



DROP TABLE IF EXISTS channels_messages;
CREATE TABLE channels_messages (
  id SERIAL PRIMARY KEY,
  from_channel_id BIGINT NULL,
  from_auther_id BIGINT UNSIGNED NULL,
  reply_to_user_id BIGINT UNSIGNED NULL,
  message TEXT NOT NULL,
  delivered BOOLEAN,
  views_count INT UNSIGNED NOT NULL DEFAULT 1,
  media_id BIGINT UNSIGNED NULL,
  CONSTRAINT channels_messages_from_channel_id_fk FOREIGN KEY (from_channel_id) REFERENCES channels(id)
    ON DELETE SET NULL,
  CONSTRAINT channels_messages_from_auther_id_fk  FOREIGN KEY (from_auther_id) REFERENCES users(id)
    ON DELETE SET NULL,
  CONSTRAINT channels_messages_reply_to_user_id_fk  FOREIGN KEY (reply_to_user_id) REFERENCES users(id)
    ON DELETE SET NULL,
  CONSTRAINT groups_users_media_id_fk FOREIGN KEY (media_id) REFERENCES media(id)
    ON DELETE SET NULL,
  INDEX channels_messages_from_auther_id_idx (from_auther_id) COMMENT 'you can search messages by auther',
  created_at DATETIME DEFAULT NOW(),
  edited_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

DELIMITER //

DROP TRIGGER IF EXISTS group_id_and_chat_id_check;
CREATE TRIGGER group_id_and_chat_id_check BEFORE INSERT ON groups_and_chats_messages FOR EACH ROW
BEGIN
  IF NEW.from_group_id IS NULL AND NEW.from_chat_id IS NULL
    THEN SIGNAL sqlstate '45001' SET message_text = "from_group_id and from_chat_id can not be both NULL"; 
  END IF;
END //

DELIMITER ;

DROP TABLE IF EXISTS groups_and_chats_messages;
CREATE TABLE groups_and_chats_messages (
  id SERIAL PRIMARY KEY,
  from_group_id BIGINT UNSIGNED NULL,
  from_chat_id BIGINT UNSIGNED NULL,
  from_user_id BIGINT UNSIGNED NULL,
  to_user_id BIGINT UNSIGNED NULL COMMENT 'If this field is speciefied message is from chat and from group either way',
  reply_to_user_id BIGINT UNSIGNED NULL,
  message TEXT NOT NULL,
  delivered BOOLEAN,
  media_id BIGINT UNSIGNED NULL,
  CONSTRAINT groups_and_chats_messages_from_group_id_fk FOREIGN KEY (from_group_id) REFERENCES `groups`(id)
    ON DELETE SET NULL,
  CONSTRAINT groups_and_chats_messages_from_chat_id_fk  FOREIGN KEY (from_chat_id) REFERENCES chats(id)
    ON DELETE SET NULL,
  CONSTRAINT groups_and_chats_messages_from_user_id_fk  FOREIGN KEY (from_user_id) REFERENCES users(id)
    ON DELETE SET NULL,
  CONSTRAINT groups_and_chats_messages_to_user_id_fk FOREIGN KEY (to_user_id) REFERENCES users(id)
    ON DELETE SET NULL,
  CONSTRAINT groups_and_chats_messages_reply_to_user_id_fk  FOREIGN KEY (reply_to_user_id) REFERENCES users(id)
    ON DELETE SET NULL,
  CONSTRAINT groups_and_chats_messages_media_id_fk FOREIGN KEY (media_id) REFERENCES media(id)
    ON DELETE SET NULL,
  INDEX groups_and_chats_messages_from_user_id_idx (from_user_id) COMMENT 'you can search messages by user',
  created_at DATETIME DEFAULT NOW(),
  edited_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

/* for educational purposes only

in groups and channels:
total_participants INT UNSIGNED NOT NULL DEFAULT 1
total_subscribers INT UNSIGNED NOT NULL DEFAULT 1

CREATE TRIGGER channels_subscribers_increaser AFTER INSERT ON channels_users 
  FOR EACH ROW
    UPDATE channels SET total_subscribers = total_subscribers + 1 WHERE id = NEW.channel_id;

CREATE TRIGGER groups_total_participants_increaser AFTER INSERT ON groups_users 
  FOR EACH ROW
    UPDATE groups SET total_participants = total_participants + 1 WHERE id = NEW.group_id;

CREATE TRIGGER channels_subscribers_decreaser AFTER DELETE ON channels_users 
  FOR EACH ROW
    UPDATE channels SET total_subscribers = total_subscribers - 1 WHERE id = OLD.channel_id;

CREATE TRIGGER groups_total_participants_decreaser AFTER DELETE ON groups_users 
  FOR EACH ROW
    UPDATE groups SET total_participants = total_participants - 1 WHERE id = OLD.group_id;
*/ 
