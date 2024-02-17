use tenant

 --1>  Write a query to get Profile ID, Full Name and Contact Number of the tenant who has stayed with us for the longest time period in the past

select profile_id, (first_name+ ' '+ last_name) as full_name, email_id,phone as contact_Number from Profiles$
where profile_id in 
(select b.profile_id from (select a.profile_id,datediff(MONTH,a.Move_in_date1,a.move_out_date2) as date_diff from (
select profile_id,cast(Move_In_Date as date) as Move_in_date1,
cast(Move_Out_Date as date) as move_out_date2
 from Tenancy_History) as a)as b where b.date_diff = (select max(datediff(MONTH,a.Move_in_date1,a.move_out_date2)) from (
select cast(Move_In_Date as date) as Move_in_date1,
cast(Move_Out_Date as date) as move_out_date2
 from Tenancy_History) as a))


--2> Write a query to get the Full name, email id, phone of tenants who are married and paying rent > 9000 using subqueries

select (first_name + ' '+last_name) as Full_Name, email_id, phone from Profiles$
where marital_status = 'Y'
 and profile_id in (select profile_id from Tenancy_history where rent> 9000) 



 --3>  Write a query to display profile id, full name, phone, email id, city, house id, move_in_date ,
--move_out date, rent, total number of referrals made, latest employer and the occupational--
--category of all the tenants living in Bangalore or Pune in the time period of jan 2015 to jan
--2016 sorted by their rent in descending order

---(need apply the clause for date)


select p.profile_id,(p.first_name + ' '+p.last_name) as Full_Name, p.phone, p.email_id, p.city, 
t.house_id,cast(t.Move_In_Date as date) as Move_in_date, t.rent, 
e.latest_employer, e.occupational_category, COUNT(r.profile_id) as number_of_refer 
from Profiles$ p 
join Tenancy_History t on p.profile_id = t.profile_id
join Employment_Details$ e on p.profile_id = e.profile_id
join Referral$ r on r.profile_id=p.profile_id 
where p.city in ('Bangalore', 'Pune') and t.Move_In_Date > '2015/01/01' and move_out_date < '2016-01-01'
group by 
	p.profile_id,
    p.first_name,
    p.last_name,
    p.phone,
    p.email_id,
	p.city, 
	t.house_id,
	t.Move_In_Date,
	t.Move_Out_Date,
	t.rent,
	e.latest_employer,
	e.occupational_category
order by rent desc

--4>  Write a sql snippet to find the full_name, email_id, phone number and referral code of all
--the tenants who have referred more than once.
--Also find the total bonus amount they should receive given that the bonus gets calculated
--only for valid referrals

select (p.first_name+' '+p.last_name) as full_name, p.email_id, p.phone, p.referral_code,
A.bonus_amount_received
from Profiles$ p
join 
(select distinct profile_id,sum(referrer_bonus_amount) over(partition by profile_id) as bonus_amount_received from Referral$
where referral_valid = 1 and 
profile_id in (select profile_id from Referral$ 
group by profile_id
having count(profile_id)>1)) as A 
on p.profile_id = A.profile_id


 --5> Write a query to find the rent generated from each city and also the total of all cities.
---- done----

select coalesce(p.city,'Total of all cities') as city, sum(t.rent) as rent_from_cities  from 
Tenancy_History t 
join 
Profiles$ p on t.profile_id = p.profile_id
group by p.city with rollup 



 -- 6>Create a view 'vw_tenant' find profile_id,rent,move_in_date,house_type,beds_vacant,description and city of tenants who shifted on/after 30th april 2015 and are living in houses having vacant beds and its address.


create view vw_tenant as 
select T.profile_id,T.rent,T.Move_In_Date,H.house_type,H.beds_vacant,A.description as address ,A.pincode, P.city
from Houses$ H 
join 
Tenancy_History T on H.house_id = T.house_id
join
Profiles$ P on T.profile_id = P.profile_id
join 
Addresses$ A on H.house_id = A.house_id
where H.beds_vacant>0 and 
H.house_id in (select house_id from Tenancy_History where Move_In_Date > '2015/04/29' and Move_Out_Date is null)

select * from vw_tenant

--- 7>  Write a code to extend the valid_till date for a month of tenants who have referred more than one time


select  profile_id,cast(valid_till as date) as Old_Valid_Till_Date ,cast(dateadd(month, 1, valid_till) as date) as new_valid_till_date
from Referral$ where profile_id in 
(select profile_id
from Referral$ 
group by profile_id
having count(profile_id)>1)


---8>  Write a query to get Profile ID, Full Name, Contact Number of the tenants along with a new
----column 'Customer Segment' wherein if the tenant pays rent greater than 10000, tenant falls
---in Grade A segment, if rent is between 7500 to 10000, tenant falls in Grade B else in Grade C


select P.profile_id, (p.first_name + ' '+p.last_name) as Full_Name, P.phone, P.email_id,
T.rent,
case 
when rent > 10000 then 'A'
when rent >=7500 then'B'
else 'c'
end as Customer_Segment
from Tenancy_History T 
inner join 
Profiles$ P on T.profile_id = P.profile_id

--9>  Write a query to get Fullname, Contact, City and House Details of the tenants who have not referred even once


select p.profile_id,(p.first_name + ' '+p.last_name) as Full_Name,p.phone,p.city,
h.house_id, h.house_type,h.bed_count, h.beds_vacant,h.bhk_type,h.furnishing_type
from Profiles$ p
join 
Tenancy_History t on p.profile_id = t.profile_id
join
Houses$ h on t.house_id = h.house_id
where t.profile_id in (select T.profile_id from Tenancy_History T
left join 
Referral$ R
on T.profile_id = R.profile_id
where R.profile_id is null)


-------10> Write a query to get the house details of the house having highest occupancy 

select top (1) with ties h.house_id,h.house_type,h.bhk_type,h.furnishing_type,h.bed_count, h.beds_vacant,
(h.bed_count - h.beds_vacant) as total_occupancy, 
a.name,a.description, a.city,a.pincode  
from Houses$ h 
join 
Addresses$ a
on h.house_id = a.house_id
order by total_occupancy desc 

