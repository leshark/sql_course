-- Проверить, исправить при необходимости и оптимизировать следующий запрос

SELECT CONCAT(u.firstname, ' ', u.lastname) AS user,
COUNT(l.id) + COUNT(m.id) + COUNT(t.id) AS overall_activity
FROM users AS u
LEFT JOIN
likes AS l
ON l.user_id = u.id
LEFT JOIN
media AS m
ON m.user_id = u.id
LEFT JOIN
messages AS t
ON t.from_user_id = u.id
GROUP BY u.id
ORDER BY overall_activity
LIMIT 10;

-- 1) Запрос работает правильно (только у меня нет t.id -> t.from_user_id)

SELECT CONCAT(u.firstname, ' ', u.lastname) AS user,
COUNT(l.id) + COUNT(m.id) + COUNT(t.from_user_id) AS overall_activity
FROM users AS u
LEFT JOIN
likes AS l
ON l.user_id = u.id
LEFT JOIN
media AS m
ON m.user_id = u.id
LEFT JOIN
messages AS t
ON t.from_user_id = u.id
GROUP BY u.id
ORDER BY overall_activity
LIMIT 10;

-- 2) можно добавить индексы на имя и фамилию юзера или просто выводить его id

CREATE INDEX users_firstname_idx ON users(firstname);
CREATE INDEX users_lastname_idx ON users(lastname);

-- Ну и если не создавать дополнительных таблиц, то запрос достаточно оптимизирован ( если анализировать в Workbench то все джойны оптимизированы - лукап по индексам, а order by по создаваемому полю оптимизировать вряд ли удастся)