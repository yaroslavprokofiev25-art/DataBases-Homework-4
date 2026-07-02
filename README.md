# DataBases-Homework-4 - Car Rental Service

# Вигляд структури бази даних:
<img width="624" height="741" alt="image" src="https://github.com/user-attachments/assets/5526d95d-7764-43a9-a026-d9c6e695af1c" />

# Опис бази даних:
Це база даних для сервісу прокату автомобілів, де є такі таблиці: customers, там зберігається основна інформація про клієнтів; 
customer_profiles - вона зберігає додаткову інформацію про клієнта; 
cars містить інформацію про марку, модель, рік випуску і тд.;
car_features зберігає список можливих характеристик автомобіля; 
car_feature_map зв’язує автомобілі з їхніми характеристиками (проміжна таблиця); 
і rentals це основна таблиця де вся інформація про оренди

# Використані зв'язки

1) 1:1 - кожен співробітник має щонайбільше один контракт.
2) 1:many - від rentals до customers бо один клієнт може оформити багато оренд
3) many:many — між cars та car_features тому що один автомобіль може мати багато характеристик таких як gps, кондиціонер і так далі


# Також перевірка роботи індексів:
# До:
<img width="1036" height="385" alt="image" src="https://github.com/user-attachments/assets/65be125e-a599-4da5-b7e1-5fccf6c64c80" />

# Після:
<img width="1110" height="376" alt="image" src="https://github.com/user-attachments/assets/dc61d975-66ce-4a9d-8432-9915c6bf69be" />
