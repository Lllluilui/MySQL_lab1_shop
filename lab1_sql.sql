-- ==========================================
-- 1. 建库建表
-- ==========================================
CREATE DATABASE IF NOT EXISTS shop_lab CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shop_lab;

CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'новый',
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ==========================================
-- 2. 创建 20 个存储过程
-- ==========================================
DELIMITER $$

-- categories
CREATE PROCEDURE IF NOT EXISTS sp_category_insert(IN p_name VARCHAR(100), IN p_description VARCHAR(255))
BEGIN INSERT INTO categories(name, description) VALUES(p_name, p_description); END$$
CREATE PROCEDURE IF NOT EXISTS sp_category_select_by_name(IN p_name VARCHAR(100))
BEGIN SELECT category_id, name, description FROM categories WHERE name LIKE CONCAT('%', p_name, '%'); END$$
CREATE PROCEDURE IF NOT EXISTS sp_category_update(IN p_category_id INT, IN p_name VARCHAR(100), IN p_description VARCHAR(255))
BEGIN UPDATE categories SET name = p_name, description = p_description WHERE category_id = p_category_id; END$$
CREATE PROCEDURE IF NOT EXISTS sp_category_delete(IN p_category_id INT)
BEGIN DELETE FROM categories WHERE category_id = p_category_id; END$$

-- products
CREATE PROCEDURE IF NOT EXISTS sp_product_insert(IN p_name VARCHAR(200), IN p_category_id INT, IN p_price DECIMAL(10,2), IN p_stock INT)
BEGIN INSERT INTO products(name, category_id, price, stock_quantity) VALUES(p_name, p_category_id, p_price, p_stock); END$$
CREATE PROCEDURE IF NOT EXISTS sp_product_select_by_name(IN p_name VARCHAR(200))
BEGIN SELECT product_id, name, category_id, price, stock_quantity FROM products WHERE name LIKE CONCAT('%', p_name, '%'); END$$
CREATE PROCEDURE IF NOT EXISTS sp_product_update(IN p_product_id INT, IN p_price DECIMAL(10,2), IN p_stock INT)
BEGIN UPDATE products SET price = p_price, stock_quantity = p_stock WHERE product_id = p_product_id; END$$
CREATE PROCEDURE IF NOT EXISTS sp_product_delete(IN p_product_id INT)
BEGIN DELETE FROM products WHERE product_id = p_product_id; END$$

-- customers
CREATE PROCEDURE IF NOT EXISTS sp_customer_insert(IN p_first_name VARCHAR(50), IN p_last_name VARCHAR(50), IN p_email VARCHAR(100), IN p_phone VARCHAR(20))
BEGIN INSERT INTO customers(first_name, last_name, email, phone) VALUES(p_first_name, p_last_name, p_email, p_phone); END$$
CREATE PROCEDURE IF NOT EXISTS sp_customer_select_by_email(IN p_email VARCHAR(100))
BEGIN SELECT customer_id, first_name, last_name, email, phone FROM customers WHERE email LIKE CONCAT('%', p_email, '%'); END$$
CREATE PROCEDURE IF NOT EXISTS sp_customer_update(IN p_customer_id INT, IN p_phone VARCHAR(20))
BEGIN UPDATE customers SET phone = p_phone WHERE customer_id = p_customer_id; END$$
CREATE PROCEDURE IF NOT EXISTS sp_customer_delete(IN p_customer_id INT)
BEGIN DELETE FROM customers WHERE customer_id = p_customer_id; END$$

-- orders
CREATE PROCEDURE IF NOT EXISTS sp_order_insert(IN p_customer_id INT, IN p_status VARCHAR(20), IN p_total_amount DECIMAL(10,2))
BEGIN INSERT INTO orders(customer_id, status, total_amount) VALUES(p_customer_id, p_status, p_total_amount); END$$
CREATE PROCEDURE IF NOT EXISTS sp_order_select_by_customer(IN p_customer_id INT)
BEGIN SELECT order_id, customer_id, order_date, status, total_amount FROM orders WHERE customer_id = p_customer_id; END$$
CREATE PROCEDURE IF NOT EXISTS sp_order_update_status(IN p_order_id INT, IN p_status VARCHAR(20))
BEGIN UPDATE orders SET status = p_status WHERE order_id = p_order_id; END$$
CREATE PROCEDURE IF NOT EXISTS sp_order_delete(IN p_order_id INT)
BEGIN DELETE FROM orders WHERE order_id = p_order_id; END$$

-- order_items
CREATE PROCEDURE IF NOT EXISTS sp_order_item_insert(IN p_order_id INT, IN p_product_id INT, IN p_quantity INT, IN p_price_at_purchase DECIMAL(10,2))
BEGIN INSERT INTO order_items(order_id, product_id, quantity, price_at_purchase) VALUES(p_order_id, p_product_id, p_quantity, p_price_at_purchase); END$$
CREATE PROCEDURE IF NOT EXISTS sp_order_item_select_by_order(IN p_order_id INT)
BEGIN SELECT order_item_id, order_id, product_id, quantity, price_at_purchase FROM order_items WHERE order_id = p_order_id; END$$
CREATE PROCEDURE IF NOT EXISTS sp_order_item_update_quantity(IN p_order_item_id INT, IN p_quantity INT)
BEGIN UPDATE order_items SET quantity = p_quantity WHERE order_item_id = p_order_item_id; END$$
CREATE PROCEDURE IF NOT EXISTS sp_order_item_delete(IN p_order_item_id INT)
BEGIN DELETE FROM order_items WHERE order_item_id = p_order_item_id; END$$

DELIMITER ;

-- ==========================================
-- 3. 插入 75 行数据（通过存储过程）
-- ==========================================
-- 类别
CALL sp_category_insert('Электроника', 'Смартфоны, ноутбуки и т.д.');
CALL sp_category_insert('Одежда', 'Мужская и женская одежда');
CALL sp_category_insert('Книги', 'Художественная и учебная литература');
CALL sp_category_insert('Продукты', 'Еда и напитки');
CALL sp_category_insert('Спорт', 'Спортивный инвентарь');
-- 商品
CALL sp_product_insert('Смартфон Samsung', 1, 59999.00, 10);
CALL sp_product_insert('Ноутбук Lenovo', 1, 75000.00, 5);
CALL sp_product_insert('Наушники Sony', 1, 15000.00, 20);
CALL sp_product_insert('Футболка Nike', 2, 2500.00, 50);
CALL sp_product_insert('Джинсы Levi''s', 2, 6000.00, 30);
CALL sp_product_insert('Книга Мастер и Маргарита', 3, 800.00, 100);
CALL sp_product_insert('Книга Преступление и наказание', 3, 750.00, 80);
CALL sp_product_insert('Молоко 3.2%', 4, 80.00, 200);
CALL sp_product_insert('Хлеб Бородинский', 4, 45.00, 150);
CALL sp_product_insert('Сыр Российский', 4, 550.00, 40);
CALL sp_product_insert('Велосипед горный', 5, 35000.00, 8);
CALL sp_product_insert('Гантели 5кг', 5, 3000.00, 25);
CALL sp_product_insert('Скакалка', 5, 500.00, 60);
CALL sp_product_insert('Планшет iPad', 1, 45000.00, 12);
CALL sp_product_insert('Кроссовки Adidas', 2, 8000.00, 40);
-- 顾客
CALL sp_customer_insert('Иван', 'Иванов', 'ivanov@mail.ru', '+79001112233');
CALL sp_customer_insert('Анна', 'Петрова', 'petrova@mail.ru', '+79002223344');
CALL sp_customer_insert('Олег', 'Сидоров', 'sidorov@mail.ru', '+79003334455');
CALL sp_customer_insert('Мария', 'Кузнецова', 'kuznetsova@mail.ru', '+79004445566');
CALL sp_customer_insert('Павел', 'Смирнов', 'smirnov@mail.ru', '+79005556677');
CALL sp_customer_insert('Ольга', 'Волкова', 'volkova@mail.ru', '+79006667788');
CALL sp_customer_insert('Дмитрий', 'Морозов', 'morozov@mail.ru', '+79007778899');
CALL sp_customer_insert('Елена', 'Новикова', 'novikova@mail.ru', '+79008889900');
CALL sp_customer_insert('Сергей', 'Фёдоров', 'fedorov@mail.ru', '+79009990011');
CALL sp_customer_insert('Дарья', 'Соколова', 'sokolova@mail.ru', '+79001001122');
-- 订单
CALL sp_order_insert(1, 'новый', 59999.00); CALL sp_order_insert(2, 'оплачен', 75000.00);
CALL sp_order_insert(3, 'доставлен', 2500.00); CALL sp_order_insert(4, 'новый', 6000.00);
CALL sp_order_insert(5, 'оплачен', 800.00); CALL sp_order_insert(6, 'доставлен', 80.00);
CALL sp_order_insert(7, 'новый', 35000.00); CALL sp_order_insert(8, 'оплачен', 3000.00);
CALL sp_order_insert(9, 'доставлен', 500.00); CALL sp_order_insert(10, 'новый', 45000.00);
CALL sp_order_insert(1, 'оплачен', 15000.00); CALL sp_order_insert(2, 'доставлен', 750.00);
CALL sp_order_insert(3, 'новый', 550.00); CALL sp_order_insert(4, 'оплачен', 8000.00);
CALL sp_order_insert(5, 'доставлен', 45.00);
-- 订单明细
CALL sp_order_item_insert(1, 1, 1, 59999.00); CALL sp_order_item_insert(2, 2, 1, 75000.00);
CALL sp_order_item_insert(3, 4, 2, 2500.00); CALL sp_order_item_insert(4, 5, 1, 6000.00);
CALL sp_order_item_insert(5, 6, 3, 800.00); CALL sp_order_item_insert(6, 8, 5, 80.00);
CALL sp_order_item_insert(7, 11, 1, 35000.00); CALL sp_order_item_insert(8, 12, 2, 3000.00);
CALL sp_order_item_insert(9, 13, 1, 500.00); CALL sp_order_item_insert(10, 14, 1, 45000.00);
CALL sp_order_item_insert(1, 3, 2, 15000.00); CALL sp_order_item_insert(2, 7, 1, 750.00);
CALL sp_order_item_insert(3, 10, 2, 550.00); CALL sp_order_item_insert(4, 15, 1, 8000.00);
CALL sp_order_item_insert(5, 9, 3, 45.00); CALL sp_order_item_insert(6, 1, 1, 59999.00);
CALL sp_order_item_insert(7, 2, 1, 75000.00); CALL sp_order_item_insert(8, 4, 1, 2500.00);
CALL sp_order_item_insert(9, 5, 2, 6000.00); CALL sp_order_item_insert(10, 6, 1, 800.00);
CALL sp_order_item_insert(11, 8, 10, 80.00); CALL sp_order_item_insert(12, 11, 1, 35000.00);
CALL sp_order_item_insert(13, 12, 2, 3000.00); CALL sp_order_item_insert(14, 13, 3, 500.00);
CALL sp_order_item_insert(15, 14, 1, 45000.00); CALL sp_order_item_insert(1, 15, 1, 8000.00);
CALL sp_order_item_insert(2, 1, 1, 59999.00); CALL sp_order_item_insert(3, 2, 1, 75000.00);
CALL sp_order_item_insert(4, 4, 1, 2500.00); CALL sp_order_item_insert(5, 5, 1, 6000.00);

-- ==========================================
-- 4. 创建用户并授权
-- ==========================================
DROP USER IF EXISTS 'admin_user'@'localhost';
DROP USER IF EXISTS 'service_user'@'localhost';
DROP USER IF EXISTS 'user_user'@'localhost';

CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'AdminPass123!';
CREATE USER 'service_user'@'localhost' IDENTIFIED BY 'ServicePass123!';
CREATE USER 'user_user'@'localhost' IDENTIFIED BY 'UserPass123!';

GRANT USAGE ON shop_lab.* TO 'admin_user'@'localhost';
GRANT USAGE ON shop_lab.* TO 'service_user'@'localhost';
GRANT USAGE ON shop_lab.* TO 'user_user'@'localhost';

GRANT EXECUTE ON shop_lab.* TO 'admin_user'@'localhost';

-- service_user 授权（无 DELETE）
GRANT EXECUTE ON PROCEDURE shop_lab.sp_category_insert TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_category_select_by_name TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_category_update TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_product_insert TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_product_select_by_name TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_product_update TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_customer_insert TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_customer_select_by_email TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_customer_update TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_order_insert TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_order_select_by_customer TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_order_update_status TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_order_item_insert TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_order_item_select_by_order TO 'service_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_order_item_update_quantity TO 'service_user'@'localhost';

-- user_user 授权（仅 SELECT）
GRANT EXECUTE ON PROCEDURE shop_lab.sp_category_select_by_name TO 'user_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_product_select_by_name TO 'user_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_customer_select_by_email TO 'user_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_order_select_by_customer TO 'user_user'@'localhost';
GRANT EXECUTE ON PROCEDURE shop_lab.sp_order_item_select_by_order TO 'user_user'@'localhost';

FLUSH PRIVILEGES;

-- ==========================================
-- 5. 创建日志表和 15 个触发器
-- ==========================================
CREATE TABLE IF NOT EXISTS categories_log (log_id INT AUTO_INCREMENT PRIMARY KEY, category_id INT, name VARCHAR(100), description VARCHAR(255), user_name VARCHAR(100), update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, action VARCHAR(10));
CREATE TABLE IF NOT EXISTS products_log (log_id INT AUTO_INCREMENT PRIMARY KEY, product_id INT, name VARCHAR(200), category_id INT, price DECIMAL(10,2), stock_quantity INT, user_name VARCHAR(100), update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, action VARCHAR(10));
CREATE TABLE IF NOT EXISTS customers_log (log_id INT AUTO_INCREMENT PRIMARY KEY, customer_id INT, first_name VARCHAR(50), last_name VARCHAR(50), email VARCHAR(100), phone VARCHAR(20), user_name VARCHAR(100), update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, action VARCHAR(10));
CREATE TABLE IF NOT EXISTS orders_log (log_id INT AUTO_INCREMENT PRIMARY KEY, order_id INT, customer_id INT, order_date DATETIME, status VARCHAR(20), total_amount DECIMAL(10,2), user_name VARCHAR(100), update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, action VARCHAR(10));
CREATE TABLE IF NOT EXISTS order_items_log (log_id INT AUTO_INCREMENT PRIMARY KEY, order_item_id INT, order_id INT, product_id INT, quantity INT, price_at_purchase DECIMAL(10,2), user_name VARCHAR(100), update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, action VARCHAR(10));

DELIMITER $$

-- categories 触发器
CREATE TRIGGER trg_categories_after_insert AFTER INSERT ON categories FOR EACH ROW BEGIN INSERT INTO categories_log(category_id, name, description, user_name, action) VALUES(NEW.category_id, NEW.name, NEW.description, USER(), 'INSERT'); END$$
CREATE TRIGGER trg_categories_after_update AFTER UPDATE ON categories FOR EACH ROW BEGIN INSERT INTO categories_log(category_id, name, description, user_name, action) VALUES(NEW.category_id, NEW.name, NEW.description, USER(), 'UPDATE'); END$$
CREATE TRIGGER trg_categories_after_delete AFTER DELETE ON categories FOR EACH ROW BEGIN INSERT INTO categories_log(category_id, name, description, user_name, action) VALUES(OLD.category_id, OLD.name, OLD.description, USER(), 'DELETE'); END$$

-- products 触发器
CREATE TRIGGER trg_products_after_insert AFTER INSERT ON products FOR EACH ROW BEGIN INSERT INTO products_log(product_id, name, category_id, price, stock_quantity, user_name, action) VALUES(NEW.product_id, NEW.name, NEW.category_id, NEW.price, NEW.stock_quantity, USER(), 'INSERT'); END$$
CREATE TRIGGER trg_products_after_update AFTER UPDATE ON products FOR EACH ROW BEGIN INSERT INTO products_log(product_id, name, category_id, price, stock_quantity, user_name, action) VALUES(NEW.product_id, NEW.name, NEW.category_id, NEW.price, NEW.stock_quantity, USER(), 'UPDATE'); END$$
CREATE TRIGGER trg_products_after_delete AFTER DELETE ON products FOR EACH ROW BEGIN INSERT INTO products_log(product_id, name, category_id, price, stock_quantity, user_name, action) VALUES(OLD.product_id, OLD.name, OLD.category_id, OLD.price, OLD.stock_quantity, USER(), 'DELETE'); END$$

-- customers 触发器
CREATE TRIGGER trg_customers_after_insert AFTER INSERT ON customers FOR EACH ROW BEGIN INSERT INTO customers_log(customer_id, first_name, last_name, email, phone, user_name, action) VALUES(NEW.customer_id, NEW.first_name, NEW.last_name, NEW.email, NEW.phone, USER(), 'INSERT'); END$$
CREATE TRIGGER trg_customers_after_update AFTER UPDATE ON customers FOR EACH ROW BEGIN INSERT INTO customers_log(customer_id, first_name, last_name, email, phone, user_name, action) VALUES(NEW.customer_id, NEW.first_name, NEW.last_name, NEW.email, NEW.phone, USER(), 'UPDATE'); END$$
CREATE TRIGGER trg_customers_after_delete AFTER DELETE ON customers FOR EACH ROW BEGIN INSERT INTO customers_log(customer_id, first_name, last_name, email, phone, user_name, action) VALUES(OLD.customer_id, OLD.first_name, OLD.last_name, OLD.email, OLD.phone, USER(), 'DELETE'); END$$

-- orders 触发器
CREATE TRIGGER trg_orders_after_insert AFTER INSERT ON orders FOR EACH ROW BEGIN INSERT INTO orders_log(order_id, customer_id, order_date, status, total_amount, user_name, action) VALUES(NEW.order_id, NEW.customer_id, NEW.order_date, NEW.status, NEW.total_amount, USER(), 'INSERT'); END$$
CREATE TRIGGER trg_orders_after_update AFTER UPDATE ON orders FOR EACH ROW BEGIN INSERT INTO orders_log(order_id, customer_id, order_date, status, total_amount, user_name, action) VALUES(NEW.order_id, NEW.customer_id, NEW.order_date, NEW.status, NEW.total_amount, USER(), 'UPDATE'); END$$
CREATE TRIGGER trg_orders_after_delete AFTER DELETE ON orders FOR EACH ROW BEGIN INSERT INTO orders_log(order_id, customer_id, order_date, status, total_amount, user_name, action) VALUES(OLD.order_id, OLD.customer_id, OLD.order_date, OLD.status, OLD.total_amount, USER(), 'DELETE'); END$$

-- order_items 触发器
CREATE TRIGGER trg_order_items_after_insert AFTER INSERT ON order_items FOR EACH ROW BEGIN INSERT INTO order_items_log(order_item_id, order_id, product_id, quantity, price_at_purchase, user_name, action) VALUES(NEW.order_item_id, NEW.order_id, NEW.product_id, NEW.quantity, NEW.price_at_purchase, USER(), 'INSERT'); END$$
CREATE TRIGGER trg_order_items_after_update AFTER UPDATE ON order_items FOR EACH ROW BEGIN INSERT INTO order_items_log(order_item_id, order_id, product_id, quantity, price_at_purchase, user_name, action) VALUES(NEW.order_item_id, NEW.order_id, NEW.product_id, NEW.quantity, NEW.price_at_purchase, USER(), 'UPDATE'); END$$
CREATE TRIGGER trg_order_items_after_delete AFTER DELETE ON order_items FOR EACH ROW BEGIN INSERT INTO order_items_log(order_item_id, order_id, product_id, quantity, price_at_purchase, user_name, action) VALUES(OLD.order_item_id, OLD.order_id, OLD.product_id, OLD.quantity, OLD.price_at_purchase, USER(), 'DELETE'); END$$

DELIMITER ;