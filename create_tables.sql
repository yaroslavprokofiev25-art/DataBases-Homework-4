
drop table if exists rentals cascade;
drop table if exists car_feature_map cascade;
drop table if exists car_features cascade;
drop table if exists cars cascade;
drop table if exists customer_profiles cascade;
drop table if exists customers cascade;

create table customers (
    id varchar(36) primary key,
    first_name varchar(200) not null,
    last_name varchar(200) not null,
    email varchar(200) not null unique,
    phone varchar(20) not null,
    active boolean default true
);
comment on table customers is 'people who rent cars';

-- 1:1 бо для кожного клієнта існує рівно один профіль
create table customer_profiles (
    customer_id varchar(36) primary key references customers(id) on delete cascade,
    driver_license_number varchar(50) not null unique,
    date_of_birth date,
    loyalty_points int default 0 check (loyalty_points >= 0)
);
comment on table customer_profiles is '1:1 extension of customers with license/loyalty data';

create table cars (
    id varchar(36) primary key,
    make varchar(100) not null,
    model varchar(100) not null,
    year int check (year >= 1980),
    license_plate varchar(20) not null unique,
    daily_rate numeric(8, 2) check (daily_rate > 0),
    status varchar(20) default 'available' check (status in ('available', 'rented', 'maintenance'))
);
comment on table cars is 'rental fleet';

create table car_features (
    id int primary key,
    name varchar(100) not null unique
);
comment on table car_features is 'lookup: gps, sunroof, child seat, etc.';

-- many:many тому що один автомобіль може мати кілька фіч, а одна фіча може бути в багатьох автомобілях
create table car_feature_map (
    car_id varchar(36) not null references cars(id) on delete cascade,
    feature_id int not null references car_features(id) on delete cascade,
    primary key (car_id, feature_id)
);
comment on table car_feature_map is 'many:many between cars and car_features';
-- 1:many, бо один клієнт може оформити багато оренд,
-- і один автомобіль може бути в багатьох орендах у різний час.
create table rentals (
    id varchar(36) primary key,
    customer_id varchar(36) not null references customers(id),
    car_id varchar(36) not null references cars(id),
    start_date timestamp not null,
    end_date timestamp not null,
    total_price numeric(10, 2) check (total_price >= 0),
    status varchar(20) default 'active' check (status in ('active', 'completed', 'cancelled')),
    check (end_date > start_date)
);
comment on table rentals is 'one row per rental; 1:many from customers and from cars';

-- індекси для оптимізації запитів
create index idx_rentals_customer_id on rentals(customer_id);
create index idx_rentals_car_id on rentals(car_id);
create index idx_rentals_start_date on rentals(start_date);
create index idx_cars_status on cars(status);
