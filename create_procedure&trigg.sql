
create or replace function fn_sync_car_status()
returns trigger
language plpgsql
as $$

begin
    if tg_op = 'insert' and new.status = 'active' then
        update cars set status = 'rented' where id = new.car_id;
    elsif tg_op = 'update' and new.status = 'completed' and old.status = 'active' then
        update cars set status = 'available' where id = new.car_id;
    end if;
    return new;
end;
$$;

create trigger trg_sync_car_status
    after insert or update on rentals
    for each row
    execute function fn_sync_car_status();

-- stored procedure: close a rental (status + payment amount in one call)
create or replace procedure sp_complete_rental(
    p_rental_id varchar(36),
    p_total_price numeric
)
language plpgsql
as $$
begin
    update rentals
       set status = 'completed',
           total_price = p_total_price
     where id = p_rental_id;

    if not found then
        raise exception 'rental % not found', p_rental_id;
    end if;

    commit;
end;
$$;
