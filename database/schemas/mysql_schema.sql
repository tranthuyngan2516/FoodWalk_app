-- FoodWalk MySQL Schema (v1.1)
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  role ENUM('customer','driver','admin') NOT NULL,
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(32) UNIQUE,
  email VARCHAR(120) UNIQUE,
  avatar_url TEXT,
  rating DECIMAL(3,2),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE restaurants (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  address TEXT,
  lat DOUBLE,
  lng DOUBLE,
  is_open BOOLEAN DEFAULT TRUE,
  categories JSON,
  rating DECIMAL(3,2),
  owner_user_id BIGINT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (owner_user_id) REFERENCES users(id)
);

CREATE TABLE menus (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id BIGINT NOT NULL,
  name VARCHAR(160) NOT NULL,
  description TEXT,
  price BIGINT NOT NULL,
  image_url TEXT,
  available BOOLEAN DEFAULT TRUE,
  options_json JSON,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_menus_restaurant_available (restaurant_id, available),
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE TABLE orders (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id BIGINT NOT NULL,
  restaurant_id BIGINT NOT NULL,
  driver_id BIGINT NULL,
  address_text TEXT NOT NULL,
  lat DOUBLE,
  lng DOUBLE,
  distance_km DOUBLE,
  items_amount BIGINT NOT NULL,
  delivery_fee BIGINT NOT NULL,
  discount BIGINT DEFAULT 0,
  total_amount BIGINT NOT NULL,
  status ENUM('PENDING_CONFIRM','WAITING_DRIVER','DRIVER_ASSIGNED','PICKED_UP','DELIVERING','DELIVERED','CANCELLED') NOT NULL DEFAULT 'PENDING_CONFIRM',
  payment_method VARCHAR(16) NOT NULL DEFAULT 'COD',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_orders_customer_created (customer_id, created_at),
  INDEX idx_orders_driver_status (driver_id, status),
  FOREIGN KEY (customer_id) REFERENCES users(id),
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
  FOREIGN KEY (driver_id) REFERENCES users(id)
);

CREATE TABLE order_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  menu_id BIGINT NOT NULL,
  name VARCHAR(160) NOT NULL,
  qty INT NOT NULL,
  unit_price BIGINT NOT NULL,
  options_json JSON,
  subtotal BIGINT NOT NULL,
  INDEX idx_order_items_order (order_id),
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (menu_id) REFERENCES menus(id)
);

CREATE TABLE payments (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL UNIQUE,
  provider VARCHAR(16) NOT NULL,
  amount BIGINT NOT NULL,
  status ENUM('PENDING','SUCCESS','FAILED') NOT NULL DEFAULT 'PENDING',
  txn_ref VARCHAR(128),
  raw_payload JSON,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Optional driver shifts
CREATE TABLE driver_shifts (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  driver_id BIGINT NOT NULL,
  start_at DATETIME NOT NULL,
  end_at DATETIME NULL,
  INDEX idx_driver_shifts_driver (driver_id, start_at),
  FOREIGN KEY (driver_id) REFERENCES users(id)
);

-- Simplified driver_locations (no partition in MySQL Community)
CREATE TABLE driver_locations (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  driver_id BIGINT NOT NULL,
  lat DOUBLE NOT NULL,
  lng DOUBLE NOT NULL,
  speed DOUBLE,
  heading DOUBLE,
  ts DATETIME NOT NULL,
  INDEX idx_driver_locations_driver_ts (driver_id, ts),
  FOREIGN KEY (driver_id) REFERENCES users(id)
);
