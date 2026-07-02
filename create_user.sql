create role car_rental_admin login password 'adm1n_pass!23';

grant connect on database car_rental_db to car_rental_admin;
grant usage, create on schema public to car_rental_admin;
grant all privileges on all tables in schema public to car_rental_admin;


-- this user can work with customers, rentals and cars

create role rental_agent login password 'agent_pass!23';

grant connect on database car_rental_db to rental_agent;
grant usage on schema public to rental_agent;

grant select, insert, update
on customers, customer_profiles, rentals
to rental_agent;

grant select
on cars, car_features, car_feature_map
to rental_agent;


-- this user can only read the reporting view

create role analytics_reader login password 'read0nly_pass!23';

grant connect on database car_rental_db to analytics_reader;
grant usage on schema public to analytics_reader;

grant select
on public.rental_details
to analytics_reader;