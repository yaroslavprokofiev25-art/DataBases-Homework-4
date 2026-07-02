create or replace view rental_details as
    -- view об'єднує дані з таблиць rentals, customers і cars

select
    r.id as rental_id,
    c.first_name || ' ' || c.last_name as customer_name,
    car.make,
    car.model,
    car.license_plate,
    r.start_date,
    r.end_date,
    r.total_price,
    r.status
from rentals r
join customers c on r.customer_id = c.id
join cars car on r.car_id = car.id;

