import uuid
import random
from datetime import timedelta

import psycopg2
from psycopg2 import Error
from psycopg2.extras import execute_values
from faker import Faker

HOST = 'localhost'
USER = 'postgres'
PASSWORD = '1'
DATABASE = 'car_rental_db'
PORT = '5432'

NUM_CUSTOMERS = 5_000
NUM_CARS = 300
NUM_RENTALS = 500_000
BATCH_SIZE = 5_000

fake = Faker()


def create_connection():
    try:
        connection = psycopg2.connect(
            host=HOST, port=PORT, user=USER, password=PASSWORD, dbname=DATABASE
        )
        print("Connection to PostgreSQL DB successful")
        return connection
    except Error as e:
        print(f"The error '{e}' occurred")
        return None


def execute_batch(connection, query, rows):
    try:
        with connection.cursor() as cursor:
            execute_values(cursor, query, rows, page_size=BATCH_SIZE)
        connection.commit()
    except Error as e:
        connection.rollback()
        print(f"The error '{e}' occurred")


def seed_customers(connection):
    customers, profiles = [], []
    for _ in range(NUM_CUSTOMERS):
        cid = str(uuid.uuid4())
        customers.append((cid, fake.first_name(), fake.last_name(), fake.unique.email(), fake.phone_number()[:20], True))
        profiles.append((cid, fake.unique.bothify(text="??######"), fake.date_of_birth(minimum_age=19, maximum_age=75), random.randint(0, 500)))

    execute_batch(connection,
        "INSERT INTO customers (id, first_name, last_name, email, phone, active) VALUES %s ON CONFLICT (id) DO NOTHING",
        customers)
    execute_batch(connection,
        "INSERT INTO customer_profiles (customer_id, driver_license_number, date_of_birth, loyalty_points) VALUES %s ON CONFLICT (customer_id) DO NOTHING",
        profiles)
    return customers


def seed_cars(connection):
    makes_models = [
        ("Toyota", "Corolla"), ("Toyota", "RAV4"), ("Volkswagen", "Golf"),
        ("Skoda", "Octavia"), ("BMW", "3 Series"), ("Ford", "Focus"),
        ("Hyundai", "Tucson"), ("Renault", "Duster"), ("Kia", "Sportage"),
    ]
    cars = []
    for _ in range(NUM_CARS):
        make, model = random.choice(makes_models)
        cars.append((
            str(uuid.uuid4()), make, model, random.randint(2015, 2025),
            fake.unique.bothify(text="??####??"), round(random.uniform(20, 120), 2), "available",
        ))
    execute_batch(connection,
        "INSERT INTO cars (id, make, model, year, license_plate, daily_rate, status) VALUES %s ON CONFLICT (id) DO NOTHING",
        cars)

    features = [(1, "GPS Navigation"), (2, "Bluetooth"), (3, "Child Seat"), (4, "Sunroof"), (5, "All-Wheel Drive")]
    execute_batch(connection, "INSERT INTO car_features (id, name) VALUES %s ON CONFLICT (id) DO NOTHING", features)

    feature_map = []
    for car in cars:
        for feature in random.sample(features, k=random.randint(1, 3)):
            feature_map.append((car[0], feature[0]))
    execute_batch(connection, "INSERT INTO car_feature_map (car_id, feature_id) VALUES %s ON CONFLICT DO NOTHING", feature_map)

    return cars


def seed_rentals(connection, customers, cars):
    print(f"Generating {NUM_RENTALS} rentals in batches of {BATCH_SIZE}...")
    inserted = 0
    while inserted < NUM_RENTALS:
        batch_size = min(BATCH_SIZE, NUM_RENTALS - inserted)
        batch = []
        for _ in range(batch_size):
            start = fake.date_time_between(start_date="-3y", end_date="now")
            end = start + timedelta(days=random.randint(1, 14))
            batch.append((
                str(uuid.uuid4()), random.choice(customers)[0], random.choice(cars)[0],
                start, end, round(random.uniform(50, 1500), 2), "completed",
            ))
        execute_batch(connection,
            "INSERT INTO rentals (id, customer_id, car_id, start_date, end_date, total_price, status) VALUES %s ON CONFLICT (id) DO NOTHING",
            batch)
        inserted += batch_size
        print(f"  inserted {inserted}/{NUM_RENTALS}")


def insert_data():
    connection = create_connection()
    if connection is None:
        return
    customers = seed_customers(connection)
    cars = seed_cars(connection)
    seed_rentals(connection, customers, cars)
    connection.close()
    print("Done.")


if __name__ == "__main__":
    insert_data()
