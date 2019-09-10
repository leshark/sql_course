 -- Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользоваетелем.
 SELECT COUNT(*) FROM 
	(SELECT to_user_id, from_user_id FROM messages m
		JOIN friendship f1
			ON f1.user_id = m.from_user_id
		JOIN friendship f2
			ON f2.friend_id = m.from_user_id
		WHERE (m.to_user_id = 2 OR m.from_user_id = 2) AND (f1.friend_id = m.to_user_id OR f2.user_id = m.to_user_id) 
	) as agg;

-- Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей

-- 10 самых молодых юзеров
SELECT CONCAT(firstname, " ", lastname) as user, TIMESTAMPDIFF(YEAR, birthday, NOW()) as age 
  FROM users as u
    JOIN profiles as p
      ON u.id = p.user_id
        ORDER BY age LIMIT 10;

-- ON u.id = l.reciever_id где reciever_id - id юзера получившего лайк
SELECT COUNT(l.id)
  FROM users as u
    LEFT JOIN profiles as p
      ON u.id = p.user_id
	JOIN likes as l
      ON u.id = l.reciever_id
	ORDER BY TIMESTAMPDIFF(YEAR, birthday, NOW()) LIMIT 10;

-- Определить кто больше поставил лайков (всего) - мужчины или женщины?
SELECT CASE(p.sex)
      WHEN 'm' THEN 'male'
      WHEN 'f' THEN 'female'
    END as sex, COUNT(*) as likes_count
  FROM profiles as p
    JOIN likes as l
      ON p.user_id = l.user_id
  GROUP BY sex;

-- Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
SELECT CONCAT(firstname, ' ', lastname) as user, GREATEST(IFNULL(MAX(likes.created_at), 0), IFNULL(MAX(media.created_at),0), IFNULL(MAX(messages.created_at),0)) as activity
  FROM users
  JOIN likes
    ON likes.user_id = users.id
  JOIN media
    ON media.user_id = users.id
  JOIN messages
    ON messages.from_user_id = users.id
  ORDER BY activity
  LIMIT 10;