-- Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользоваетелем.
-- Запрос ниже выводит таблицу всех сообщений друзей пользователя 2. Но как вычислить самое часто встречаемое значение в ней я не догадался.

SELECT from_user_id, to_user_id FROM messages WHERE (to_user_id in
	((SELECT friend_id 
	  FROM friendship 
	  WHERE user_id = 2
		AND confirmed_at IS NOT NULL 
		AND status IS NOT NULL
	)
	UNION
	(SELECT user_id 
	  FROM friendship 
	  WHERE friend_id = 2
		AND confirmed_at IS NOT NULL 
		AND status IS NOT NULL
	))
    and from_user_id = 2) or
    (from_user_id in 
	 ((SELECT friend_id 
	  FROM friendship 
	  WHERE user_id = 2
		AND confirmed_at IS NOT NULL 
		AND status IS NOT NULL
	)
	UNION
	(SELECT user_id 
	  FROM friendship 
	  WHERE friend_id = 2
		AND confirmed_at IS NOT NULL 
		AND status IS NOT NULL
	))
    and to_user_id = 2
 );

-- Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей

SELECT COUNT(id) FROM LIKES WHERE user_id IN (
  SELECT * FROM (
    SELECT id FROM users ORDER BY birthday DESC LIMIT 10
    ) as smth
);

-- Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT IF(
	(SELECT COUNT(id) FROM LIKES WHERE user_id IN (
		SELECT id FROM users WHERE sex="m")
	) 
	> 
	(SELECT COUNT(id) FROM LIKES WHERE user_id IN (
		SELECT id FROM users WHERE sex="f")
	), 
   'male', 'female');

-- Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
-- нужно объединить таблицы по каунтам(но как?)

SELECT user_id, COUNT(*) AS count
FROM likes
GROUP BY user_id
ORDER BY count LIMIT 10;

SELECT user_id, COUNT(*) AS count
FROM media
GROUP BY user_id
ORDER BY count LIMIT 10;

SELECT from_user_id, COUNT(*) AS count
FROM messages
GROUP BY from_user_id
ORDER BY count LIMIT 10;