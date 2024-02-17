create database Tenant;
Use Tenant;


create table Profiles (
profile_id int not null identity (1,1),
first_name varchar(255) null,
last_name varchar(255) null,
email varchar(255) not null,
phone varchar(255) not null,
city_hometown varchar(255) null,
pan_card varchar(255) null,
created_at date not null,
gender varchar(255) not null,
referral_code varchar(255) null,
marital_status varchar(255) null,

constraint pk_pi primary key (profile_id)
)

create table Houses (
house_id int not null identity (1,1),
house_type varchar(255) null,
bhk_details varchar(255) null,
bed_count int not null,
furnishing_type varchar(255) null,
Beds_vacant int not null,

constraint pk_hi primary key (house_id) 
)

create table Tenancy_histories (
id int not null identity(1,1),
profile_id int not null,
house_id int not null,
move_in_date date not null,  
move_out_date date null,
rent int not null,
Bed_Type varchar(255) null,
move_out_reason varchar(255) null,

constraint pk_id primary key (id),
constraint fk_pi foreign key (profile_id) references Profiles(profile_id),
constraint fk_hi foreign key (house_id) references Houses(house_id)
)


create table Addresses (
ad_id int not null identity(1,1),
name varchar(255) null,
description text null,
pincode int null,
city varchar(255) null,
house_id int not null,

constraint pk_ai primary key (ad_id),
constraint fk_houid foreign key (house_id) references Houses(house_id) 
)

create table Referrals (
ref_id int not null identity(1,1),
referrer_id int not null,
referrer_bounus_amount float null,
referral_valid tinyint null,
valid_from date null,
valid_till date null,

constraint pk_ri primary key (ref_id),
constraint fk_refi foreign key (referrer_id) references Profiles(profile_id)
);


create table Emplotyment_details (
id int not null identity(1,1),
profile_id int not null,
latest_employer varchar(255) null,
official_mail_id varchar(255) null,
yrs_experience int null,
occupational_catagory varchar(255) null,

constraint pk_eid primary key (id),
constraint fk_proid foreign key (profile_id) references Profiles(profile_id)
);
