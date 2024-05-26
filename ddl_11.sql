drop schema test_1;
create schema test_1;
use test_1;


 #βαλε indexes σε στειλες για αναζητηση πχ ονοματα,  στην ουσια τι αναπαρηστα καθε γραμμη φτιαχνεις



	# εξπλισμος
create or replace table equipment (
	eq_id int unsigned not null auto_increment,
	name varchar(45) not null,
	how_to text,
	primary key (eq_id)
);


# βηματα
create or replace table steps (
	step_id int unsigned not null auto_increment,
	description text not null ,
	primary key (step_id)
);


# εθνικες κουζινες
create or replace table cuisines	(	
	cuis_id int unsigned not null auto_increment,
	country varchar(45) not null,
	primary key (cuis_id)
);



#βαθμος μαγειρα 
create or replace table `rank` (
	rank_id int unsigned not null auto_increment ,
	name varchar(45) not null,
	rank_hier int not null ,
		primary key (rank_id) 
	);




#γευματα  πρωινο,μεσημεριανο,βραδινο,κτλ
create or replace table geymata (
 geyma_id int unsigned not null auto_increment ,
 name varchar(20) not null,
 primary key (geyma_id)
 );

# tags brunch,κυριο πιατο , κτλ 
create or replace table tags (
	tag_id int unsigned not null auto_increment,
	name varchar(45)not null,
	primary key (tag_id)
	);



# θεματικες ενοτητες
create or replace table themes (
	theme_id int unsigned not null auto_increment,
	name varchar(45) not null ,
	description text default null ,
	primary key (theme_id)
);

# ομαδα τροφιμων
create or replace table foods (
	f_id int unsigned not null auto_increment,
	name varchar(45) not null,
	`desc` text,
	primary key (f_id)
);

#υλικα 
create or replace table ingredients (
	ingr_id int unsigned not null auto_increment,
	name varchar(45) not null,
	calories_per_100gr decimal(6,2) not null,
	fat_100 decimal(5,2) ,
	crabs_100 decimal(5,2) ,
	protein_100 decimal(5,2),
	food_id int unsigned not null,
	primary key (ingr_id),
	unique (ingr_id,food_id),
	foreign key (food_id) references foods (f_id) on delete restrict on update cascade
);




# συνταγες
create or replace table recipes (
	rec_id int unsigned not null auto_increment,
	name varchar(45) not null,
	rec_is varchar(45) check (rec_is in ('cooked','sweet')),
	description text default 'fato mwre' ,
	difficulty int check (difficulty in (1,2,3,4,5)) ,
	tips text default 'megalwnei',
	cuis_id int unsigned , -- εθνικη κουζινα
	num_cooks int , -- αλλωστε στο διαγωνισμο ενας μαγειρας ανα συνταγη
	t_prep int default 10,
	t_cook int default 10,
	primary key (rec_id),
	foreign key (cuis_id) references cuisines (cuis_id) on delete restrict on update cascade
);

-- -----------------------------------------------------------------------

# μαγειρες
create or replace table cooks (
	cook_id int unsigned not null auto_increment , 
	first_name varchar(45) not null,
	last_name varchar(45) not null,
	phone varchar(20) , -- ενα τηλεφωνο
	birth_date date not null default current_date , 
    xp int,
    c_rank int unsigned default 5 ,
    primary key (cook_id),
    foreign key (c_rank) references `rank` (rank_id) on delete restrict on update cascade
   ) ;


-- -----------------------------------------------------------------------------------------------------------------
--  ---------------------------------- ΣΧΕΧΕΙΣ ---------------------------------------------------------------------

#geyma_recipe
create or replace table rec_geymata (
	rec_id int unsigned not null ,
	geyma_id int unsigned ,
	primary key (rec_id,geyma_id),
	foreign key (rec_id) references recipes (rec_id) on delete restrict on update cascade,
	foreign key (geyma_id) references geymata (geyma_id) on delete restrict on update cascade
	);

#tag_recipe
create or replace table rec_tags (
	rec_id int unsigned not null,
	tag_id int unsigned ,
	primary key (rec_id,tag_id),
	foreign key (rec_id) references recipes (rec_id) on delete restrict on update cascade,
	foreign key (tag_id) references tags (tag_id) on delete restrict on update cascade
	); 



# συνταγες-εξοπλισμος 
create or replace table rec_equip (
	rec_id int unsigned not null,
	eq_id int unsigned ,
	num_of_equip int default 1 ,
	primary key(rec_id,eq_id),
	foreign key (rec_id) references recipes (rec_id) on delete restrict on update cascade,
	foreign key (eq_id) references equipment (eq_id) on delete restrict on update cascade
	);

 # συνταγες-υλικα (ποσοτητες, βασικο υλικο)
 create or replace table rec_ingr (
	rec_id int unsigned not null ,
	ingr_id int unsigned,
	num_of_ingr int(11) default 100,
	is_base boolean  default 0,
	primary key (rec_id,ingr_id),
	unique (rec_id,ingr_id,is_base),
	foreign key (rec_id) references recipes (rec_id) on delete restrict on update cascade,
	foreign key (ingr_id) references ingredients (ingr_id) on delete restrict on update cascade
);

# συνταγες-βηματα 
create or replace table rec_step (
	rec_id int unsigned not null ,
	step_id int unsigned,
	primary key (rec_id,step_id),
	foreign key (rec_id) references recipes (rec_id) on delete restrict on update cascade,
	foreign key (step_id) references steps (step_id) on delete restrict on update cascade
	);

# συνταγες-θεμ_ενοτητα
create or replace table rec_theme (
	rec_id int unsigned not null ,
	theme_id int unsigned  , 
	primary key(rec_id,theme_id),
	foreign key (rec_id) references recipes (rec_id) on delete restrict on update cascade,
	foreign key (theme_id) references themes (theme_id) on delete restrict on update cascade
	);

#μαγειρες-εθνικη_κουζινα
create or replace table  cook_cuisines (
  cook_id int(11) unsigned NOT NULL,
  cuis_id int(11) unsigned ,
  PRIMARY KEY (cook_id,cuis_id),
  foreign key (cook_id) references cooks (cook_id) on delete restrict on update cascade,
  foreign key (cuis_id) references cuisines (cuis_id) on delete restrict on update cascade
 );

#mageires-recs
create or replace table rec_cook (
 	rec_id int unsigned,
	cook_id int unsigned,
 	primary key (rec_id,cook_id),
 	foreign key (cook_id) references cooks (cook_id) on delete restrict on update cascade,
 	foreign key (rec_id) references recipes (rec_id) on delete restrict on update cascade
);
-- ----------------------------------------------------------------------------------------------------------------
-- ----------------------------- Episode -------------------------------------------------------------------------

# episodes
create or replace table episode (
	ep_id int unsigned not null auto_increment,
	date_of date not null default current_date ,
	primary key (ep_id)
	);



-- --------------------------------- sxeseis -----------------------------------------------------------------------------


#mageires ana episodio , diagonizomenoi kai krites
create or replace table ep_cons_jdgs (
	ep_id int unsigned not null, 
	cook_id int unsigned ,
	is_jdg boolean default 0,
	primary key (ep_id,cook_id,is_jdg),
	foreign key (ep_id) references episode (ep_id) on update cascade ,
	foreign key (cook_id) references cooks (cook_id) on update cascade
	);

/*
#ep-rec syntages
create or replace table ep_recipes (
	ep_id int unsigned not null ,
	rec_id int unsigned ,
	cuis_id int unsigned , -- δεν χρειαζεται εφυγε το not null απο πανω και αρκει το unique ??? κληρωση για 10 διαφορετικες κουζινες;
	primary key (ep_id,rec_id),
	unique (ep_id,cuis_id),
	foreign key (ep_id) references episode (ep_id) on delete restrict on update cascade ,
	foreign key (rec_id) references recipes (rec_id) on delete restrict on update cascade,
	foreign key (cuis_id) references recipes (cuis_id) on delete restrict on update cascade
);
*/

#ep_rec_cook
create or replace table ep_rec_cons (
	ep_id int unsigned not null ,
	cook_id int unsigned , 
	rec_id int unsigned ,
	cuis_id int unsigned, 
	primary key (ep_id,rec_id,cook_id),
	foreign key (ep_id) references ep_cons_jdgs (ep_id) on delete restrict on update cascade ,
	foreign key (rec_id) references recipes (rec_id) on delete restrict on update cascade,
	foreign key (cook_id) references ep_cons_jdgs (cook_id) on delete restrict on update cascade,
	foreign key (cuis_id) references recipes (cuis_id) on delete restrict on update cascade
);


	
-- βαθμοι ----------------------------------------------------------------------------------------------------------

# βαθμοι
	create or replace table grades (
		ep_id int unsigned not null ,
		con_id int unsigned,
		jdg_id int unsigned ,
		rec_id int unsigned ,
		grade int default 0,
		primary key (ep_id,con_id,jdg_id,rec_id),
		foreign key (ep_id) references episode (ep_id) on delete restrict on update cascade,
		foreign key (con_id) references ep_rec_cons (cook_id) on delete restrict on update cascade ,
		foreign key (jdg_id) references ep_cons_jdgs (cook_id) on delete restrict on update cascade ,
		foreign key (rec_id) references ep_rec_cons (rec_id) on delete restrict on update cascade
		);

-- ----------------------------------------------------------------------------------------------------


	
	
		
-- -----------------------------------------------------------------------------------------------------------
-- ----------------------------------------   Views ----------------------------------------------------------


#view αναλογα το βασικο υλικο 
create or replace view basic_ingr_tag (rec_name,basic_ingr,`desc`) as 
	select r.name, i.name , f.`desc`	
	from rec_ingr ri 
	join recipes r on r.rec_id=ri.rec_id
	join ingredients i on i.ingr_id=ri.ingr_id
	join foods f
	where ri.is_base=1 ;



#view μαγειρα με ηλικια
create or replace view cook_vw (name, age, `rank`) as 
	select concat(c.first_name,' ',c.last_name) , year(current_date)- year(c.birth_date),c_rank
	from cooks c;


# ep_vw year
create or replace view ep_year (ep_id,`year`) as 
	select e.ep_id, year(e.date_of)
	from episode e ;

#olokliromenes syntages
create or replace view complete_recipes (rec_id,name,calories_100gr,fat_100gr,crabs_100gr,protein_100gr,time_prep_min,time_cook_min,dishes_250gr) as
	select r.rec_id, r.name, sum((i.calories_per_100gr*ri.num_of_ingr)/100 )/100, sum((i.fat_100*ri.num_of_ingr)/100)/100, 
									sum((i.crabs_100 *ri.num_of_ingr)/100)/100, sum((i.protein_100 *ri.num_of_ingr)/100)/100,
									r.t_prep, r.t_cook, ceil(sum((i.calories_per_100gr*ri.num_of_ingr)/100 )/250)
from recipes r 
join rec_ingr ri on r.rec_id = ri.rec_id 
join ingredients i on i.ingr_id =ri.ingr_id 
group by r.rec_id;

-- ----------------------------------------------------------------------------------------------------------------
-- ------------------------------------------Procedures/Functions--------------------------------------------------


delimiter //


delimiter //

create procedure ins_ep_jdgs11 ()
begin 
	declare `max` int ;
	declare i int ;
	set i=1;
	select count(*) from episode e into `max`;

	while (i <= `max`) do
		begin
			insert into ep_cons_jdgs  select distinct e.ep_id, c1.cook_id, 1
									 	 from cooks c1 
										 join episode e
										 where e.ep_id = i
						 				 order by rand()
										 limit 3;
			set i=i+1;
		end;
		end while ;
			
end//

create procedure ins_ep_cons11 ()
begin 
	declare `max` int ;
	declare i int ;
	set i=1;
	select count(*) from episode e into `max`;

	while (i <= `max`) do
		begin
			insert into ep_cons_jdgs  select distinct e.ep_id, c1.cook_id , 0
												 from cooks c1 
												 join episode e 
												 where e.ep_id = i
												 order by rand()
												 limit 10;	
			set i=i+1;
		end;
		end while ;
			
end//


delimiter ;

delimiter //


#con_rec_set
create procedure ins_ep_rec_cons11 ()
begin 
	declare `max` int ;
	declare i int ;
	set i=1;
	select count(*) from episode e into `max`;

	while (i <= `max`) do
		begin
			insert into ep_rec_cons 
				select ecj.ep_id, ecj.cook_id, er.rec_id ,er.cuis_id
				from (select ep_id, cook_id,( rank () over (order by rand())) rc
		  		from ep_cons_jdgs
		 		where (is_jdg=0) and (ep_id=i)) ecj 
				join (select  rec_id,cuis_id, rank () over (order by rand())  rr
		  		from recipes) er 
				where (ecj.ep_id =i) and (rc=rr); 
			
			set i=i+1;
		end;
		end while ;
			
end//

#populate grades 
create or replace procedure ins_grades_cjr ()
begin 
	declare `max` int ;
	declare i int ;
	set i=1;
	select count(*) from episode e into `max`;

	while (i <= `max`) do
		begin
			insert into grades (ep_id,con_id,jdg_id,rec_id)
		select ecj.ep_id, erc.cook_id, ecj.cook_id, erc.rec_id
		from ep_cons_jdgs ecj 
		join ep_rec_cons erc on erc.ep_id = ecj.ep_id 
		where (ecj.is_jdg=1)and(ecj.ep_id=i);
			
			set i=i+1;
		end;
		end while ;
			
end//
 
#assing grade 
create or replace procedure set_grade (in p_epid int,p_conid int,p_jdgid int,in p_grd int)
begin 
	update grades
	set grade=p_grd
	where (ep_id=p_epid) and (con_id=p_conid) and (jdg_id=p_jdgid);
end//

#assing grades randomly
create or replace procedure set_grade_random ()
begin 
	update grades 
	set grade=ceil((rand()*10)%5);
end //




delimiter ;


