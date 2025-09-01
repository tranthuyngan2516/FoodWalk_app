-- FoodWalk PostgreSQL Schema (v1.1)

CREATE TYPE order_status AS ENUM ('PENDING_CONFIRM','WAITING_DRIVER','DRIVER_ASSIGNED','PICKED_UP','DELIVERING','DELIVERED','CANCELLED');
CREATE TYPE payment_status AS ENUM ('PENDING','SUCCESS','FAILED');

CREATE TABLE users (
  id            BIGSERIAL PRIMARY KEY,
  role          VARCHAR(16) NOT NULL CHECK (role IN ('customer','driver','admin')),
  name          VARCHAR(120) NOT NULL,
  phone         VARCHAR(32) UNIQUE,
  email         VARCHAR(120) UNIQUE,
  avatar_url    TEXT,
  rating        NUMERIC(3,2),
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE restaurants (
  id            BIGSERIAL PRIMARY KEY,
  name          VARCHAR(160) NOT NULL,
  address       TEXT,
  lat           DOUBLE PRECISION,
  lng           DOUBLE PRECISION,
  is_open       BOOLEAN DEFAULT true,
  categories    TEXT[],
  rating        NUMERIC(3,2),
  owner_user_id BIGINT REFERENCES users(id),
  created_at    TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE menus (
  id             BIGSERIAL PRIMARY KEY,
  restaurant_id  BIGINT NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
  name           VARCHAR(160) NOT NULL,
  description    TEXT,
  price          BIGINT NOT NULL,       -- VND
  image_url      TEXT,
  available      BOOLEAN DEFAULT true,
  options_json   JSONB,
  created_at     TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_menus_restaurant_available ON menus(restaurant_id, available);

CREATE TABLE orders (
  id              BIGSERIAL PRIMARY KEY,
  customer_id     BIGINT NOT NULL REFERENCES users(id),
  restaurant_id   BIGINT NOT NULL REFERENCES restaurants(id),
  driver_id       BIGINT REFERENCES users(id),
  address_text    TEXT NOT NULL,
  lat             DOUBLE PRECISION,
  lng             DOUBLE PRECISION,
  distance_km     DOUBLE PRECISION,
  items_amount    BIGINT NOT NULL,
  delivery_fee    BIGINT NOT NULL,
  discount        BIGINT DEFAULT 0,
  total_amount    BIGINT NOT NULL,
  status          order_status NOT NULL DEFAULT 'PENDING_CONFIRM',
  payment_method  VARCHAR(16) NOT NULL DEFAULT 'COD',
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_orders_customer_created ON orders(customer_id, created_at DESC);
CREATE INDEX idx_orders_driver_status ON orders(driver_id, status);

CREATE TABLE order_items (
  id           BIGSERIAL PRIMARY KEY,
  order_id     BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  menu_id      BIGINT NOT NULL REFERENCES menus(id),
  name         VARCHAR(160) NOT NULL,
  qty          INTEGER NOT NULL CHECK (qty > 0),
  unit_price   BIGINT NOT NULL,
  options_json JSONB,
  subtotal     BIGINT NOT NULL
);
CREATE INDEX idx_order_items_order ON order_items(order_id);

CREATE TABLE payments (
  id            BIGSERIAL PRIMARY KEY,
  order_id      BIGINT NOT NULL UNIQUE REFERENCES orders(id) ON DELETE CASCADE,
  provider      VARCHAR(16) NOT NULL,
  amount        BIGINT NOT NULL,
  status        payment_status NOT NULL DEFAULT 'PENDING',
  txn_ref       VARCHAR(128),
  raw_payload   JSONB,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- Driver shifts (optional)
CREATE TABLE driver_shifts (
  id          BIGSERIAL PRIMARY KEY,
  driver_id   BIGINT NOT NULL REFERENCES users(id),
  start_at    TIMESTAMPTZ NOT NULL,
  end_at      TIMESTAMPTZ
);
CREATE INDEX idx_driver_shifts_driver ON driver_shifts(driver_id, start_at DESC);

-- Driver locations (time-series) with monthly partition template
CREATE TABLE driver_locations (
  id          BIGSERIAL PRIMARY KEY,
  driver_id   BIGINT NOT NULL REFERENCES users(id),
  lat         DOUBLE PRECISION NOT NULL,
  lng         DOUBLE PRECISION NOT NULL,
  speed       DOUBLE PRECISION,
  heading     DOUBLE PRECISION,
  ts          TIMESTAMPTZ NOT NULL
) PARTITION BY RANGE (ts);

-- Example partition for Aug 2025
CREATE TABLE driver_locations_2025_08 PARTITION OF driver_locations
FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

CREATE INDEX idx_driver_locations_driver_ts ON driver_locations(driver_id, ts DESC);
