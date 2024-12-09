-- Step 1: Set up the MySQL environment
-- Create the database
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Step 2: Create the Database Schema

-- Create the `customers` table
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the `products` table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the `orders` table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Create the `order_items` table
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Step 3: Insert Sample Data

-- Insert data into the `customers` table
INSERT INTO customers (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Brown', 'charlie@example.com');

-- Insert data into the `products` table
INSERT INTO products (name, description, price, stock) VALUES
('Laptop', 'High-performance laptop', 1200.00, 50),
('Headphones', 'Noise-cancelling headphones', 150.00, 100),
('Keyboard', 'Mechanical keyboard', 80.00, 200);

-- Insert data into the `orders` table
INSERT INTO orders (customer_id, total_amount) VALUES
(1, 1350.00),
(2, 150.00);

-- Insert data into the `order_items` table
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 1200.00), -- Laptop
(1, 2, 1, 150.00),  -- Headphones
(2, 2, 1, 150.00);  -- Headphones

-- Step 4: Query the Data

-- Retrieve all orders with customer and product details
SELECT 
    o.id AS order_id,
    c.name AS customer_name,
    p.name AS product_name,
    oi.quantity,
    oi.price,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;

-- Calculate total revenue
SELECT SUM(total_amount) AS total_revenue FROM orders;

-- Calculate average order value
SELECT AVG(total_amount) AS average_order_value FROM orders;

-- Count orders per customer
SELECT 
    c.name AS customer_name,
    COUNT(o.id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.name;

-- Check products low on stock
SELECT name, stock FROM products WHERE stock < 10;

-- Step 5: Setup Web Server (using Node.js and Sequelize)

-- Node.js Setup Instructions:
-- 1. Initialize Node.js application: `npm init`
-- 2. Install required packages: `npm install sequelize mysql2 dotenv`
-- 3. Create `.env` file with database configuration:
--    DB_HOST=localhost
--    DB_PORT=3306
--    DB_NAME=ecommerce_db
--    DB_USER=root
--    DB_PASSWORD=password
--    PORT=3000

-- Example `app.mjs`:
import { Sequelize, DataTypes } from 'sequelize';
import dotenv from 'dotenv';
dotenv.config();

const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASSWORD, {
    host: process.env.DB_HOST,
    dialect: 'mysql',
});

const testConnection = async () => {
    try {
        await sequelize.authenticate();
        console.log('Connection has been established successfully.');
    } catch (error) {
        console.error('Unable to connect to the database:', error);
    }
};

testConnection();

// Define Models
const Customer = sequelize.define('Customer', {
    name: { type: DataTypes.STRING, allowNull: false },
    email: { type: DataTypes.STRING, allowNull: false, unique: true },
});

const Product = sequelize.define('Product', {
    name: { type: DataTypes.STRING, allowNull: false },
    description: { type: DataTypes.TEXT },
    price: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
    stock: { type: DataTypes.INTEGER, allowNull: false },
});

const Order = sequelize.define('Order', {
    order_date: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    total_amount: { type: DataTypes.DECIMAL(10, 2) },
});

const OrderItem = sequelize.define('OrderItem', {
    quantity: { type: DataTypes.INTEGER, allowNull: false },
    price: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
});

// Define Associations
Customer.hasMany(Order);
Order.belongsTo(Customer);
Order.hasMany(OrderItem);
OrderItem.belongsTo(Order);
Product.hasMany(OrderItem);
OrderItem.belongsTo(Product);

const syncModels = async () => {
    await sequelize.sync({ force: true });
    console.log('Database synced!');
};

syncModels();

