# FoodWalk Database (v1.1)

Thư mục này chứa:
- `schemas/postgres_schema.sql` — DDL cho PostgreSQL
- `schemas/mysql_schema.sql` — DDL cho MySQL
- `schemas/firestore_sample.json` — mẫu cấu trúc Firestore cho MVP
- `seed/*.csv` — dữ liệu mẫu
- `FoodWalk_ERD_v1.1.png` — sơ đồ ERD trực quan

## Import nhanh

### PostgreSQL
```bash
createdb foodwalk
psql foodwalk -f schemas/postgres_schema.sql

# Import CSV (ví dụ users)
\copy users(id,role,name,phone,email,rating) FROM 'seed/users.csv' CSV HEADER;
\copy restaurants(id,name,address,lat,lng,is_open,rating) FROM 'seed/restaurants.csv' CSV HEADER;
\copy menus(id,restaurant_id,name,price,available) FROM 'seed/menus.csv' CSV HEADER;
\copy orders(id,customer_id,restaurant_id,driver_id,address_text,lat,lng,items_amount,delivery_fee,discount,total_amount,status,payment_method) FROM 'seed/orders.csv' CSV HEADER;
\copy order_items(id,order_id,menu_id,name,qty,unit_price,subtotal) FROM 'seed/order_items.csv' CSV HEADER;
\copy payments(id,order_id,provider,amount,status,txn_ref) FROM 'seed/payments.csv' CSV HEADER;
```

### MySQL
```bash
mysql -u root -p -e "CREATE DATABASE foodwalk;"
mysql -u root -p foodwalk < schemas/mysql_schema.sql
# Import CSV dùng công cụ GUI (TablePlus, DBeaver) hoặc LOAD DATA INFILE
```

### Firestore
- Xem `schemas/firestore_sample.json` để tham khảo cấu trúc documents/collections.
- Có thể dùng script Cloud Functions để đồng bộ dữ liệu mẫu.

## Ghi chú
- Đơn vị tiền tệ dùng **VND** (BIGINT).
- Bảng vị trí tài xế nên partition theo thời gian (PostgreSQL) để dễ bảo trì.
- Với MVP dùng Firestore, chỉ giữ **driverLocations** mới nhất; lịch sử nên TTL 7–14 ngày.
