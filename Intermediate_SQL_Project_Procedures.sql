--set serveroutput on;

--Feature 1
CREATE OR REPLACE 
    PROCEDURE addCustomer(c_name varchar, c_address varchar, c_state varchar, c_zip number, c_email varchar) 
as
v_count int; 
begin 

    --checks whether customer with email exists 
    select count(*) into v_count from customer where cust_email = c_email;
    
    if v_count > 0 then
        dbms_output.put_line('The Client already exists');
        
        update customer
        set cust_address = c_address, cust_state = c_state, cust_zip_code = c_zip
        where cust_email = c_email;
        
    elsif v_count = 0 then
    
        --creates new customer  
        dbms_output.put_line('New Customer ID: ' || newcustomerID.nextval);
        
        insert into customer 
            values(newcustomerID.currval, c_name, c_address, c_zip, c_state, c_email,0);
        
    end if;
end; 
/

    --Valid existing customer
    select * from customer;
    exec addCustomer('Tom', 'Bald Hill Road', 'DC', 26578, 'tomt@gmail.com');
    select * from customer;
    
    --Valid new customer
    select * from customer;
    exec addCustomer('Greg', 'Boston Circle', 'DC', 21222, 'gregg@gmail.com');
    select * from customer;
    
--Feature 2
create or replace
    procedure PrintCustomerProfile(email in varchar2)
as
    cust_count number;
    order_count number;
    order_total decimal(5,2);
    
    Cursor c1 is SELECT cust_name, cust_address, cust_state, cust_zip_code, cust_credit
    from customer
    where cust_email = email;
    
    custname customer.cust_name%type;
    custaddress customer.cust_address%type;
    custstate customer.cust_state%type;
    custzip customer.cust_zip_code%type;
    custcredit customer.cust_credit%type;
    
BEGIN
    
    SELECT count(*)
    into cust_count 
    FROM customer 
    WHERE cust_email like '%' || email || '%';
    
    IF cust_count = 0 THEN
        dbms_output.put_line('No such customer');
   ELSE
        
        select count(*)
        into order_count
        from customer c, customer_order co
        where c.cust_email = email
        and c.cust_id = co.cust_id
        and co_status = 'delivered'
        and co_time_delivered >= add_months(sysdate, -6);
        
        select sum(co_total_cost)
        into order_total
        from customer c, customer_order co
        where c.cust_email = email
        and c.cust_id = co.cust_id
        and co_status = 'delivered'
        and co_time_delivered >= add_months(sysdate, -6);
        
        open c1;
            loop
                fetch c1 into custname, custaddress, custstate, custzip, custcredit; 
                exit when c1%NOTFOUND;
                dbms_output.put_line('Name: ' || custname || chr(10) || 'Address: ' || custaddress || chr(10) || 'State: ' || custstate
                || chr(10) || 'Zipcode: ' || custzip || chr(10) || 'Email: ' || email || chr(10) || 'Credit: $' || custcredit || chr(10) || 'Number of Orders: ' || order_count
                || chr(10) || 'Total cost of all orders: $' || order_total);
            end loop;
        close c1;
    END IF;
END;
/

    --Invalid
    select * from customer;
    select * from customer_order;
    exec PrintCustomerProfile('gregg@gmail.com');
    
    --Valid(does not have order with status 2)
    select * from customer;
    select * from customer_order;
    exec PrintCustomerProfile('tomt@gmail.com');
    
    --Valid(has order with status 2)
    select * from customer;
    select * from customer_order;
    exec PrintCustomerProfile('johnj@gmail.com');
    
    
--Feature Three
CREATE OR REPLACE 
PROCEDURE search_restaurant_by_category (p_category_name IN VARCHAR2) 
AS

    CURSOR c1 IS
    SELECT r.rest_name, r.rest_avg_review_score, r.rest_avg_wait_time, r.rest_zip, r.rest_current_status
    FROM restaurant r, categories c, restaurant_categories rc 
    where c.cat_name LIKE '%' || p_category_name || '%'
    and c.cat_id = rc.cat_id
    and rc.rest_id = r.rest_id;

    restname restaurant.rest_name%type;
    restaverage restaurant.rest_avg_review_score%type;
    restaveragewaittime restaurant.rest_avg_wait_time%type;
    restzip restaurant.rest_zip%type;
    reststatus restaurant.rest_current_status%type;
    
    
BEGIN
    reststatus := 'empty';
    OPEN c1;
        LOOP
            FETCH c1 INTO restname, restaverage, restaveragewaittime, restzip, reststatus;
            exit when c1%NOTFOUND;
            if reststatus = 'open' then
                DBMS_OUTPUT.PUT_LINE('Name: ' || restname || chr(13)||
                                    'Avg. Review Score: ' || restaverage || chr(13) ||
                                    'Avg. Wait Time: ' || restaveragewaittime ||'min(s)'|| chr(13) ||
                                    'Zip Code: ' || restzip);
            elsif reststatus = 'closed' then
                dbms_output.put_line('Restaurant is currently closed');
            end if;
        END LOOP;
    CLOSE c1;
    if reststatus = 'empty' then
        dbms_output.put_line('No restaurants matching your description');
    end if;
END;
/
    --Invalid Input
    exec search_restaurant_by_category('Fast');
    
    --Valid Input(Returns 'Restaurant is currently closed')
    exec search_restaurant_by_category('Mexican');

    --Valid Input(Returns required output)
    exec search_restaurant_by_category('Italian');

--Feature 4
create or replace
    procedure PrintRestaurantMenu(restid number)
as

    cursor c1 is select dish_name, dish_price
        from restaurant r, restaurant_dishes rd
        where r.rest_id = restid
        and r.rest_id = rd.rest_id;
        
    --Explicit    
    dishname restaurant_dishes.dish_name%type;
    dishprice restaurant_dishes.dish_price%type;
    
    --Implicit
    rest_count number;
begin
    
    --Checks restid is valid
    select count(*)
    into rest_count
    from restaurant
    where rest_id = restid;
    
    if rest_count = 0 then
        dbms_output.put_line('No such restaurant');
    else
        open c1;
        loop
    
            fetch c1 into dishname, dishprice;
            exit when c1%notfound;
            dbms_output.put_line('Dish: ' || dishname || ', Price: $' || dishprice);
        
        end loop;
        close c1;
    end if;
end;
/

    --Valid input
    select * from restaurant_dishes;
    exec PrintRestaurantMenu(9); 
    
    --Invalid input
    exec PrintRestaurantMenu(12);
    
--Feature 5
create or replace procedure ShowCart(cartid in number) as

    dishname restaurant_dishes.dish_name%type;
    dishprice restaurant_dishes.dish_price%type;
    listquantity cart_list.list_quantity%type;
    temp_cartid cart.cart_id%TYPE;
    
BEGIN
        SELECT cart_id INTO temp_cartid
        FROM cart
        WHERE cart_id = cartid;
        
        for row in (
        select cl.list_quantity, rd.dish_name, rd.dish_price
        from cart_list cl
        inner join restaurant_dishes rd on cl.dish_id = rd.dish_id
        where cl.cart_id = cartid
    ) loop
        --Assign values to variables
        listquantity := row.list_quantity;
        dishname := row.dish_name;
        dishprice := row.dish_price;
        
        --Print out dish information
        dbms_output.put_line('Dish Name: ' || dishname);
        dbms_output.put_line('Price: $' || dishprice);
        dbms_output.put_line('Quantity: ' || listquantity);
    end loop;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('Invalid cart ID');
            RETURN;
END;
/

    --Invalid Input
    exec ShowCart(14);
    
    --Valid Input
    exec ShowCart(20);

--Feature 6
create or replace
    procedure RemoveDish(cartid in number, dishid in number)
as

    --implicit
    checkdish number;
    quantity number;

begin

    --Checks dishid input is valid
    select count(*)
    into checkdish
    from cart_list
    where cart_id = cartid
    and dish_id = dishid;
    
    if checkdish = 0 then
        dbms_output.put_line('Invalid input');
    else
        select list_quantity
        into quantity
        from cart_list
        where cart_id = cartid
        and dish_id = dishid;
        
        if quantity > 1 then
        
            update cart_list
            set list_quantity = list_quantity - 1
            where cart_id = cartid
            and dish_id = dishid;
        
            dbms_output.put_line('Quantity Reduced');
        else
            delete cart_list
            where cart_id = cartid
            and dish_id = dishid;
            
            dbms_output.put_line('Dish Removed');
        end if;
    end if;
end;
/

    --Invalid input
    exec RemoveDish(18, 13);
    
    --Quantity reduced
    select * from cart_list;
    exec RemoveDish(20, 14);
    select * from cart_list;
    
    --Dish Removed
    select * from cart;
    select * from cart_list;
    exec RemoveDish(18, 12);
    select * from cart_list;
    
    --Please refresh database after execution
    
--Feature 7

create or replace
    procedure UpdateOrderStatus(coid in number, status in number, inputtime timestamp)
as

    --implicit
    custid number;
    checkid number;
    
    --sequences
    insert_message_id_value number;
    insert_payment_id_value number;


    Cursor c1 is Select p.p_amount, p.p_method
        from customer_order co, payment p
        where co.co_id = coid
        and co.co_id = p.co_id;
    
    --Explicit
    amount payment.p_amount%type;
    paymentmethod payment.p_method%type;
begin
    
    --Checks coid input is valid
    select count(*)
    into checkid
    from customer_order
    where co_id = coid;
    
    if checkid = 0 then
    
        dbms_output.put_line('Invalid Order ID');
        
    else
        
        --Grabs the next value in the sequence
        select insert_message_id.nextval 
        into insert_message_id_value 
        from dual;
        
        --Grabs the customer ID
        select cust_id 
        into custid
        from customer_order
        where co_id = coid;
        
        if status = 2 then
            
            update customer_order
            set co_status = 'delivered'
            where co_id = coid;
            
            insert into message(m_id, cust_id, m_time, m_body)
                values(insert_message_id_value, custid, inputtime,'Your order '|| coid ||' has been delivered!');
                
        elsif status = 3 then
            
            --Grabs the next value in the sequence
            select insert_payment_id.nextval 
            into insert_payment_id_value 
            from dual;
            
            open c1;
                loop
                    fetch c1 into amount, paymentmethod; 
                    exit when c1%NOTFOUND; 
                END LOOP;
            Close c1; -- close cursor
        
            update customer_order
            set co_status = 'canceled'
            where co_id = coid;
            
            insert into message(m_id, cust_id, m_time, m_body)
                values(insert_message_id_value, custid, inputtime,'Your order '|| coid ||' has been canceled and refund issued!');
                
            insert into payment(p_id, cust_id, co_id, p_time, p_amount, p_method)
                values(insert_payment_id_value, custid, coid, inputtime, -amount, paymentmethod);
                
        else
            update customer_order
            set co_status = 'in progress'
            where co_id = coid;
        end if;
    end if;
end;
/

    --in progress
    select * from customer_order;
    select * from message;
    exec UpdateOrderStatus(23, 1, systimestamp);
    select * from customer_order;
    select * from message;
    
    --delivered
    select * from customer_order;
    select * from message;
    exec UpdateOrderStatus(21, 2, systimestamp);
    select * from customer_order;
    select * from message;
    
    --canceled
    select * from customer_order;
    select * from message;
    select * from payment;
    exec UpdateOrderStatus(21, 3, systimestamp);
    select * from customer_order;
    select * from message;
    select * from payment;
    
    --Please refresh database after execution
    
--Feature 8
create or replace
    procedure AddCustomerReview(custid in number, restid in number, revdate in date, revscore in number, revcomment in varchar2)
as

    --Implicit
    c_custid number;
    c_restid number;
    avg_rating number;
    
    --Sequence value
    insert_review_value number;
begin
    
    --Check customer is valid
    select count(*)
    into c_custid
    from customer
    where cust_id = custid;
    
    --Check restaurant is valid
    select count(*)
    into c_restid
    from restaurant
    where rest_id = restid;
    
    if c_custid = 0 then
        dbms_output.put_line('Invalid customer id');
    elsif c_restid = 0 then
        dbms_output.put_line('Invalid restaurant id');
    else
        
        --Grabs next sequence value
        select insert_review_id.nextval into insert_review_value from dual;
        
        insert into reviews(rev_id, cust_id, rest_id, rev_date, rev_score, comments)
            values(insert_review_value, custid, restid, revdate, revscore, revcomment);
            
        update restaurant 
        set rest_avg_review_score = (select avg(rev_score) from reviews where rest_id = restid)
        where rest_id = restid;
        
    end if;
end;
/

--Feature 9 
create or replace
    procedure PrintRestaurantReviews(restid number)
as

    cursor c1 is select rev_date, rev_score, comments
    from restaurant r, reviews rv
    where r.rest_id = restid
    and r.rest_id = rv.rest_id;
    
    --Explicit
    revdate reviews.rev_date%type;
    revscore reviews.rev_score%type;
    revcomments reviews.comments%type;
    
    --Implicit
    rest_count number;
begin

    --Checks that restid is valid
    select count(*)
    into rest_count
    from restaurant
    where rest_id = restid;
    
    if rest_count = 0 then
        dbms_output.put_line('No such restaurant');
    else
        open c1;
        loop
            
            fetch c1 into revdate, revscore, revcomments;
            exit when c1%notfound;
            dbms_output.put_line('Date: ' || revdate || ', Score: ' || revscore || ', Comments: ' || revcomments);
        
        end loop;
        close c1;
    end if;
end;
/

    --Valid input
    exec PrintRestaurantReviews(9);
    
    --Invalid input
    exec PrintRestaurantReviews(12);

--Feature 10
create or replace
    procedure AddDishToCart(custid in number, restid in number, dishid in number)
as
    --Implicit
    c_custid number;
    c_restid number;
    c_restopen varchar2(10);
    c_dishid number;
    c_cartid number;
    cartid number;
    dishquantity number;
    
    --Sequence value
    insert_cart_value number;
begin
    
    --Checks custid is valid
    select count(*)
    into c_custid
    from customer
    where cust_id = custid;
    
    --Checks restid is valid
    select count(*)
    into c_restid
    from restaurant
    where rest_id = restid;
    
    --Checks that the restaurant is not closed
    select rest_current_status
    into c_restopen
    from restaurant
    where rest_id = restid;
    
    --Checks that dishid is valid
    select count(*)
    into c_dishid
    from restaurant_dishes
    where dish_id = dishid
    and rest_id = restid;
    
    if c_custid = 0 then
        dbms_output.put_line('No such customer');
    elsif c_restid = 0 then
        dbms_output.put_line('Invalid restaurant id');
    elsif c_restopen = 'closed' then
        dbms_output.put_line('Restaurant is closed');
    elsif c_dishid = 0 then
        dbms_output.put_line('Invalid dish id');
    else
    
        --Checks that cartid exists
        select count(*)
        into c_cartid
        from cart
        where cust_id = custid
        and rest_id = restid;
        
        if c_cartid = 0 then
            
            --Grabs next sequence value
            select insert_cart_id.nextval into insert_cart_value from dual;
            
            --Creates new cart row
            insert into cart(cart_id, cust_id, rest_id)
                values(insert_cart_value, custid, restid);
            
            --Creates new cart_list row    
            insert into cart_list(cart_id, dish_id, list_quantity)
                values(insert_cart_value, dishid, 1);
                
            dbms_output.put_line('New cart created with ID: ' || insert_cart_value);
        else
            select cart_id
            into cartid
            from cart
            where cust_id = custid
            and rest_id = restid;
            
            select list_quantity
            into dishquantity
            from cart_list cl, cart c
            where c.cust_id = custid
            and c.cart_id = cl.cart_id
            and cl.dish_id = dishid;
            
            update cart_list
            set list_quantity = dishquantity + 1
            where cart_id = cartid
            and dish_id = dishid;
            
        end if;
    end if;
end;
/

    --Add to cart
    exec AddDishToCart(0,9,12);
    
    select * from cart_list;
    
    --Create new cart
    Delete from cart_list
    where cart_id = 19
    and dish_id = 13;
    
    Delete from cart
    where cart_id = 19;
    
    select * from cart;
    select * from cart_list;
    exec AddDishToCart(1,10,13);   
    select * from cart;
    select * from cart_list;   
    
    --Invalid dish id
    exec AddDishToCart(1,10,15);
    
    --Restaurant is closed
    exec AddDishToCart(1,11,13);
    
    --No such customer
    exec AddDishToCart(4,11,13);