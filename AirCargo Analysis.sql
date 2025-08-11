## A query to create a route_details table using suitable data types for the fields, such as route_id, flight_num, origin_airport, destination_airport, 
##aircraft_id, and distance_miles. Implement the check constraint for the flight number and unique constraint for the route_id fields. Also, make sure that the distance
 ###miles field is greater than 0. 
create database if not exists airline;
use  airline;

##a query to create a route_details table using suitable data types for the fields, such as route_id, flight_num, origin_airport, destination_airport, aircraft_id, and distance_miles. Implement the check constraint
## for the flight number and unique constraint for the route_id fields. Also, make sure that the distance miles field is greater than 0. 
#creating route_details table
create table if not exists
airline.route_details(
route_id varchar(500) not null,
flight_number varchar(500) not null,
origin_airport varchar(500) not null,
destination_airport varchar(500) not null,
aircraft_id varchar(500) not null,
distance_miles varchar(500) not null
);

 create table if not exists
airline.route_details(
route_id varchar(500) not null,
flight_number varchar(500) not null,
origin_airport varchar(500) not null,
destination_airport varchar(500) not null,
aircraft_id varchar(500) not null,
distance_miles varchar(500) not null,
constraint flight_num_check check( flight_number LIKE '[0=9][0-9][0-9][0-9][0-9]'),
constraint route_id_unique unique(route_id),
constraint distance_miles_check check(distance_miles > 0)
);


##a query to display all the passengers (customers) who have travelled in routes 01 to 25. Take data from the passengers_on_flights table.
select * from airline.passengers_on_flights
 where route_id >= 01 and route_id<= 25;
 
 ## a query to identify the number of passengers and total revenue in business class from the ticket_details table.
 select sum(Price_per_ticket) as total_revenue from ticket_details
 where class_id = 'bussiness';
 
 ## to display the full name of the customer by extracting the first name and last name from the customer table.
  select concat( first_name,' ',last_name) as full_name from airline.customer;

 ##a query to extract the customers who have registered and booked a ticket. Use data from the customer and ticket_details tables.
select distinct c.customer_id, c.first_name, c.last_name, c.date_of_birth, c.gender
from customer as c
inner join ticket_details t on c.customer_id = t.customer_id
order by customer_id;

##a query to identify the customer’s first name and last name based on their customer ID and brand (Emirates) from the ticket_details table.
select distinct c.first_name, c.last_name, c.customer_id
from customer as c
inner join ticket_details t on c.customer_id = t.customer_id
where t.brand= 'emirates'
order by customer_id;

##Write a query to identify the customers who have travelled by Economy Plus class using Group By and
## Having clause on the passengers_on_flights table. 
select customer_id from passengers_on_flights
where class_id = 'economy plus'
group by customer_id
having count(*) > 0;

## a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table.
select if(SUM(no_of_tickets * price_per_ticket) > 10000, 'Yes', 'No') AS revenue_crossed_10000
FROM ticket_details;

##	Write a query to create and grant access to a new user to perform operations on a database
create user 'new_user'@'localhost' identified by 'password';
grant select, update ,insert, delete on airline_database.* TO 'new_user'@'localhost';

##Write a query to find the maximum ticket price for each class using window functions
 ##on the ticket_details table. 
 select distinct class_id, max(price_per_ticket) over (partition by class_id) as maximum_ticket_price
 from ticket_details;
 
 ##a query to extract the passengers whose route ID is 4 by improving the speed and performance of the 
 ##passengers_on_flights table.
CREATE INDEX route_id ON passengers_on_flights (route_id);
SELECT aircraft_id, route_id, customer_id, depart, arrival, seat_num, class_id, travel_date, flight_num
FROM passengers_on_flights
WHERE route_id = 4;
 
 ##For the route ID 4, write a query to view the 
 ##execution plan of the passengers_on_flights table.
 
 explain select * from  passengers_on_flights where route_id ='4';
 
 ##Write a query to calculate the total price of all tickets booked by a 
 ##customer across different aircraft IDs using rollup function
 
select customer_id, aircraft_id, sum(price_per_ticket) as total_price from ticket_details
group by customer_id, aircraft_id 
with rollup;

##a query to create a view with only business class customers along with 
##the brand of airlines. 
create view BusinessClassCustomers as 
select customer_id,brand from ticket_details
where class_id = 'business';

##Write a query to create a stored procedure to get the details of all passengers flying between a range of routes defined in 
##run time. Also, return an error message if the table doesn't exist.

delimiter //
create procedure PassengersByRouteRange (
    IN start_route_id INT,
    IN end_route_id INT
)
begin
    declare table_exists INT ;
    select COUNT(*)
    into table_exists
    from information_schema.tables
    where table_name = 'passengers_on_flights';

    ##If the table doesn't exist, return an error message
    if table_exists = 0 THEN
        select 'The table passengers_on_flights does not exist.' AS message;
    else
        ##If the table exists, retrieve passenger details
        select *
        from  passengers_on_flights
        where route_id between start_route_id and end_route_id;
    end if;
end //

delimiter  ;
 
 
 ##Write a query to create a stored procedure that extracts all the details from the routes
 ##table where the travelled distance is more than 2000 miles.
 
 DELIMITER //

create procedure Routes ()
begin
    select *
    from route_details
    where Distance_miles > 2000;
end //

DELIMITER ;


##a query to create a stored procedure that groups the distance travelled by each flight into three categories. The categories are, 
##short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500, and long-distance travel (LDT) for >6500.

delimiter //
CREATE PROCEDURE DistanceCategories ()
BEGIN
    SELECT 
        flight_number,
        CASE
            WHEN Distance_miles >= 0 AND Distance_miles <= 2000 THEN 'SDT'
            WHEN Distance_miles > 2000 AND Distance_miles <= 6500 THEN 'IDT'
            WHEN Distance_miles > 6500 THEN 'LDT'
        END AS Distance_category
    FROM route_details;
END //

delimiter ;


#Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services are 
#provided for the specific class using a stored function in stored procedure on the ticket_details table. 
#Condition: 
##If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No


delimiter //
create function ComplimentaryServiceProvided(class_id VARCHAR(20))
returns varchar(3)
deterministic
begin
    declare complimentary varchar(3);
    
    if class_id in ('Business', 'Economy Plus') then
        set complimentary = 'Yes';
    else
        set complimentary = 'No';
    end if;
    
    return complimentary;
end //

DELIMITER ;

delimiter //
create procedure ExtractTicketDetailsWithComplimentaryService()
begin
    select p_date, customer_id, class_id, ComplimentaryServiceProvided(class_id) AS complimentary_service
    from ticket_details;
end //

delimiter ;

##Write a query to extract the first record of the customer whose last name ends 
##with Scott using a cursor from the customer table.

 SELECT customer_id, first_name, last_name, date_of_birth, gender
    FROM Customer
    WHERE last_name LIKE '%Scott'
    ORDER BY customer_id
    LIMIT 1;

