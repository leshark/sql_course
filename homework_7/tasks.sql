 -- 1) Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине

 -- Вариант 1 (через вложенные запросы)
 SELECT name FROM users WHERE id IN (SELECT user_id FROM orders);

 -- Вариант 2 (через join)
SELECT DISTINCT name 
  FROM users 
  INNER JOIN orders  
    ON users.id = orders.user_id;

-- 2) Выведите список товаров products и разделов catalogs, который соответствует товару
SELECT products.name AS product_name, catalogs.name AS product_type 
  FROM products 
  LEFT JOIN catalogs 
    ON products.catalog_id = catalogs.id;

-- 3)  Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов
SELECT flights.id, flights.from, flights.to
  FROM flights
  LEFT JOIN cities
    ON cities.label = flights.from
  LEFT JOIN cities as c
    ON c.label = flights.to
