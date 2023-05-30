drop table customer cascade constraints;
drop table discounts cascade constraints;
drop table sales_tax cascade constraints;
drop table available_discounts cascade constraints;
drop table categories cascade constraints;
drop table restaurant cascade constraints;
drop table restaurant_categories cascade constraints;
drop table restaurant_dishes cascade constraints;
drop table reviews cascade constraints;
drop table cart cascade constraints;
drop table cart_list cascade constraints;
drop table customer_order cascade constraints;
drop table order_list cascade constraints;
drop table payment cascade constraints;
drop table message cascade constraints;

--drop sequences will go here when needed
drop sequence insert_message_id;
drop sequence insert_payment_id;
drop sequence insert_review_id;
drop sequence insert_cart_id;
drop sequence newcustomerID;

create sequence insert_message_id
    start with 30;
    
create sequence insert_payment_id
    start with 27;

create sequence insert_review_id
    start with 18;
    
create sequence insert_cart_id
    start with 21;
    
create sequence newcustomerID 
    start with 4 
    increment by 1; 

create table customer (
  cust_id number,
  cust_name varchar(255),
  cust_address varchar(255),
  cust_zip_code number,
  cust_state varchar(2),
  cust_email varchar(255),
  cust_credit number,
  primary key (cust_id)
);

insert into customer(cust_id, cust_name, cust_address, cust_zip_code, cust_state, cust_email, cust_credit)
    values (0, 'Tom', 'Lake Shore Dr.', 25046, 'MD', 'tomt@gmail.com', 0);

insert into customer(cust_id, cust_name, cust_address, cust_zip_code, cust_state, cust_email, cust_credit)
    values (1, 'Bob', 'Washington Blvd.', 24519, 'DC', 'bobb@gmail.com', 0);

insert into customer(cust_id, cust_name, cust_address, cust_zip_code, cust_state, cust_email, cust_credit)
    values (2, 'John', 'Hilltop Circle', 23804, 'MD', 'johnj@gmail.com', 20);

create table discounts(
  d_id number,
  d_description varchar(255),
  d_discount_type number check (d_discount_type between 1 and 3),
  d_amount decimal(4,2),
  primary key (d_id)
);

insert into discounts(d_id, d_description, d_discount_type, d_amount)
    values (3, 'Order more than $40 and get a free dessert', 1, null);

insert into discounts(d_id, d_description, d_discount_type, d_amount)
    values (4, 'Employee food', 2, .1);
    
insert into discounts(d_id, d_description, d_discount_type, d_amount)
    values (5,'$10 off Coupon', 3, 10.00);

create table categories(
  cat_id number,
  cat_name varchar(255),
  primary key(cat_id)
);

insert into categories(cat_id, cat_name)
    values(6, 'Seafood');
    
insert into categories(cat_id, cat_name)
    values(7, 'Italian');

insert into categories(cat_id, cat_name)
    values(8, 'Mexican');

create table restaurant(
  rest_id number,
  rest_name varchar(255),
  rest_address varchar(255),
  rest_phone_number varchar(20),
  rest_current_status varchar(20),
  rest_state varchar(2),
  rest_avg_wait_time number,
  rest_avg_review_score decimal(5,1),
  rest_zip number,
  primary key (rest_id)
);

insert into restaurant (rest_id, rest_name, rest_address, 
rest_phone_number, rest_current_status, rest_state, rest_avg_wait_time, rest_avg_review_score, rest_zip) 
    values (9, 'la pizzeria', '789 elm st', '410-555-9012', 'open', 'MD', 20, 4.1, 21822);

insert into restaurant (rest_id, rest_name, rest_address, 
rest_phone_number, rest_current_status, rest_state, rest_avg_wait_time, rest_avg_review_score, rest_zip) 
    values (10, 'the blue door cafe', '123 main street', '202-555-1234', 'open', 'DC', 10, 4.3, 21804);


insert into restaurant (rest_id, rest_name, rest_address, 
rest_phone_number, rest_current_status, rest_state, rest_avg_wait_time, rest_avg_review_score, rest_zip) 
    values (11, 'sushi house', '456 1st ave', '276-555-5678', 'closed', 'VA', 30, 3.8, 25051);

create table sales_tax(
  s_id number,
  s_state_id varchar(2),
  tax decimal(1,2),
  primary key (s_id)
);

insert into sales_tax(s_id, s_state_id, tax)
    values (12, 'MD', .06);
    
insert into sales_tax(s_id, s_state_id, tax)
    values (13, 'DC', .06);

insert into sales_tax(s_id, s_state_id, tax)
    values (14, 'VA', .053);

create table available_discounts (
  cust_id number,
  d_id number,
  a_start_date date,
  a_end_date date,
  primary key (cust_id, d_id),
  foreign key (cust_id) references customer(cust_id),
  foreign key (d_id) references discounts(d_id)
);

insert into available_discounts(cust_id, d_id, a_start_date, a_end_date)
    values (0, 3, date '2023-03-01', date '2023-03-31');
    
insert into available_discounts(cust_id, d_id, a_start_date, a_end_date)
    values (1, 4, date '2023-02-01', date '2023-02-28');
    
insert into available_discounts(cust_id, d_id, a_start_date, a_end_date)
    values (2, 5, date '2022-12-01', date '2022-12-31');

create table restaurant_categories (
  rest_id number,
  cat_id number,
  primary key (rest_id, cat_id),
  foreign key (rest_id) references restaurant(rest_id),
  foreign key (cat_id) references categories(cat_id)
);

insert into restaurant_categories(rest_id, cat_id) 
    values (9, 6);

insert into restaurant_categories(rest_id, cat_id) 
    values (10, 7);

insert into restaurant_categories(rest_id, cat_id) 
    values (11, 8);

create table restaurant_dishes (
  dish_id number ,
  rest_id number,
  dish_name varchar(255),
  dish_price decimal(5,2),
  primary key (dish_id),
  foreign key (rest_id) references restaurant(rest_id)
);

insert into restaurant_dishes(dish_id, rest_id, dish_name, dish_price) 
    values (12, 9, 'Spaghetti', 15.99);

insert into restaurant_dishes(dish_id, rest_id, dish_name, dish_price) 
    values (40, 9, 'Scallops', 34.99);

insert into restaurant_dishes(dish_id, rest_id, dish_name, dish_price) 
    values (13, 10, 'Pizza', 18.99);

insert into restaurant_dishes(dish_id, rest_id, dish_name, dish_price) 
    values (14, 11, 'Soup', 6.99);


create table reviews (
  rev_id number,
  cust_id number,
  rest_id number,
  rev_date date,
  rev_score number,
  comments varchar2(1000),
  primary key (rev_id),
  foreign key (cust_id) references customer(cust_id),
  foreign key (rest_id) references restaurant(rest_id)
);

insert into reviews (rev_id, cust_id, rest_id, rev_date, rev_score, comments) 
    values (15, 0, 9, date '2022-10-05', 4, 'the food was delicious, but the service was slow.');

insert into reviews (rev_id, cust_id, rest_id, rev_date, rev_score, comments) 
    values (16, 1, 10, date '2022-11-04', 3, 'place was nice and food was delicious.');

insert into reviews (rev_id, cust_id, rest_id, rev_date, rev_score, comments) 
    values (17, 2, 11, date '2022-10-02', 1, 'this place has nice food and service.');


create table cart (
  cart_id number,
  cust_id number,
  rest_id number,
  primary key (cart_id),
  foreign key (cust_id) references customer(cust_id),
  foreign key (rest_id) references restaurant(rest_id)
);

insert into cart(cart_id, cust_id, rest_id) 
    values (18, 0, 9);
    
insert into cart(cart_id, cust_id, rest_id)  
    values (19, 1, 10);
    
insert into cart(cart_id, cust_id, rest_id)  
    values (20, 2, 11);


create table cart_list (
    cart_id number,
    dish_id number, --need to implement a check condition
    list_quantity number,
    primary key (cart_id, dish_id),
    foreign key (cart_id) references cart(cart_id),
    foreign key (dish_id) references restaurant_dishes(dish_id)
--    check (dish_id in (select dish_id from restaurant_dishes d, restaurant r where d.rest_id = r.rest_id))
);

insert into cart_list(cart_id, dish_id, list_quantity) 
    values (18, 12, 1);

insert into cart_list(cart_id, dish_id, list_quantity) 
    values (19, 13, 2);

insert into cart_list(cart_id, dish_id, list_quantity) 
    values (20, 14, 3);
    
create table customer_order(
    co_id number,
	cust_id number,
	rest_id number,
    s_id number,
	co_time_placed timestamp,
	co_time_delivered timestamp,
	co_estimated_time timestamp,
	co_status varchar2(20) check(co_status in('in progress', 'delivered', 'canceled')),
	co_payment_status number check(co_payment_status between 0 and 1),
	co_total_cost decimal(5,2), -- if 1 then price + delivery fee + tip + sales tax else price + sales tax
	co_delivery_method number check(co_delivery_method between 1 and 2),
    primary key (co_id),
    foreign key (s_id) references sales_tax(s_id),
    foreign key (cust_id) references customer(cust_id),
    foreign key (rest_id) references restaurant(rest_id)
);

insert into customer_order(co_id, cust_id, rest_id, s_id , co_time_placed, co_time_delivered, 
    co_estimated_time, co_status, co_payment_status, co_total_cost, co_delivery_method)
    values(21, 0, 11, 12, timestamp '2023-03-15 17:30:00.00', null, timestamp '2023-03-15 18:00:00.00', 'in progress', 0, 50.46, 2);
    
insert into customer_order(co_id, cust_id, rest_id, s_id, co_time_placed, co_time_delivered, 
    co_estimated_time, co_status, co_payment_status, co_total_cost, co_delivery_method)
    values(22, 1, 10, 13, timestamp '2023-03-15 13:30:00.00', timestamp '2023-03-15 13:50:00.00', timestamp '2023-03-15 13:55:00.00', 'canceled', 0, 33.54,1);
    
insert into customer_order(co_id, cust_id, rest_id, s_id, co_time_placed, co_time_delivered, 
    co_estimated_time, co_status, co_payment_status, co_total_cost, co_delivery_method)
    values(23, 2, 9, 14, timestamp '2023-03-15 10:30:00.00', timestamp '2023-03-15 11:30:00.00', timestamp '2023-03-15 11:00:00.00', 'delivered', 1, 24.68, 1);

create table order_list (
    co_id number,
    dish_id number,
    quantity number,
    primary key (co_id, dish_id),
    foreign key (co_id) references customer_order(co_id),
    foreign key (dish_id) references restaurant_dishes(dish_id)
);

insert into order_list(co_id, dish_id, quantity)
    values(21, 12, 1);
    
insert into order_list(co_id, dish_id, quantity)
    values(22, 13, 2);
    
insert into order_list(co_id, dish_id, quantity)
    values(23, 14, 1);

create table payment (
    p_id number,
    cust_id number,
    co_id number,
    p_time timestamp,
    p_amount decimal(5,2),
    p_method varchar(20) check (p_method in ('credit card', 'debit card', 'apple pay', 'paypal')),
    foreign key (cust_id) references customer(cust_id),
    foreign key (co_id) references customer_order(co_id),
    primary key (p_id)
);

insert into payment(p_id, cust_id, co_id, p_time, p_amount, p_method)
    values(24, 0, 21, timestamp '2023-03-15 17:55:00.00', 50.46, 'credit card');

insert into payment(p_id, cust_id, co_id, p_time, p_amount, p_method)
    values(25, 1, 22, timestamp '2023-03-15 13:55:00.00', 33.54, 'apple pay');
    
insert into payment(p_id, cust_id, co_id, p_time, p_amount, p_method)
    values(26, 2, 23, timestamp '2023-03-15 10:55:00.00', 24.68, 'paypal');
    
create table message(
    m_id number,
    cust_id number,
    m_time timestamp,
    m_body varchar2(4000),
    primary key (m_id),
    foreign key (cust_id) references customer(cust_id)
);

insert into message(m_id, cust_id, m_time, m_body)
    values(27, 0, timestamp '2023-03-15 17:30:00.00', 'Your order is being prepared');
    
insert into message(m_id, cust_id, m_time, m_body)
    values(28, 1, timestamp '2023-03-15 13:55:00.00', 'Your order has been canceled, if you did not wish to cancel please contact the restaurant at which you placed the order');
    
insert into message(m_id, cust_id, m_time, m_body)
    values(29, 2, timestamp '2023-03-15 11:15:00.00', 'Your order is out for delivery');
    
