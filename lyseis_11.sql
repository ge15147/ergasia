use test;

#3.1  Μέσος Όρος Αξιολογήσεων (σκορ) ανά μάγειρα και Εθνική κουζίνα

select g.con_id , avg(g.grade) from grades g group by con_id ; 	-- mageira	

select r.cuis_id, c.country , avg(g.grade)
from grades g
join ep_rec_cons erc on g.rec_id = erc.rec_id 
join recipes r on erc.rec_id = r.rec_id 
join cuisines c on c.cuis_id = r.cuis_id 
group by c.cuis_id ;                           -- cuisine

# 3.2. Για δεδομένη Εθνική κουζίνα και έτος, ποιοι μάγειρες ανήκουν σε αυτήν και ποιοι μάγειρες συμμετείχαν σε επεισόδια;
delimiter //
create procedure ans_32 (in p_year varchar(5),in p_cui int) 
begin
		select e.ep_id , concat(c.first_name,' ',c.last_name) `name`, year(e.date_of) `year`, cc.cuis_id ,cui.country
	from episode e 
	join ep_rec_cons erc on e.ep_id = erc.ep_id 
	join ep_cons_jdgs ecj on erc.cook_id =ecj.cook_id 
	join cooks c on ecj.cook_id =c.cook_id
	join cook_cuisines cc on cc.cook_id =c.cook_id 
	join cuisines cui on cui.cuis_id=cc.cuis_id
	where year(e.date_of)=p_year and cc.cuis_id =p_cui
	group by `name`;
end //

delimiter ;

-- call ans_32('2022',1);

	

#3.3. Βρείτε τους νέους μάγειρες (ηλικία < 30 ετών) που έχουν τις περισσότερες συνταγές

select * from cook_vw cv where age<30;
select c.cook_id, concat(c.first_name,' ',c.last_name), year(current_date)- year(c.birth_date) age , count(rc.rec_id) num
from cooks c join rec_cook rc on c.cook_id=rc.cook_id 
group by c.cook_id 
having  age <30 
order by num desc;

#3.4. Βρείτε τους μάγειρες που δεν έχουν συμμετάσχει ποτέ σε ως κριτές σε κάποιο επεισόδιο.

select ecj.cook_id ,concat(c.first_name,' ',c.last_name) ,sum(ecj.is_jdg) num 
from ep_cons_jdgs ecj 
join cooks c on ecj.cook_id =c.cook_id 
group by cook_id 
having num=0;

#3.5. Ποιοι κριτές έχουν συμμετάσχει στον ίδιο αριθμό επεισοδίων σε διάστημα ενός έτους με περισσότερες από 3 εμφανίσεις;

select  ep_id ecjid, cook_id , sum(is_jdg) num 
from ep_cons_jdgs ecj 
group by cook_id 
having num >3;

select * from ep_cons_jdgs ecj 
where cook_id =111 and is_jdg =1;

select * from ep_cons_jdgs ecj 
where cook_id =125 and is_jdg =1;

-- Δυο κριτες υπαρχουν με πανω απο 3 εμφανισεις και αυτες σε διαφορετικεσ σεζον :(
-- Δες να υπηρχαν πως θα το εβγαζες 

#3.6. Πολλές συνταγές καλύπτουν περισσότερες από μια ετικέτες. Ανάμεσα σε ζεύγη πεδίων (π.χ.  brunch και κρύο πιάτο)
# που είναι κοινά στις συνταγές, βρείτε τα 3 κορυφαία (top-3) ζεύγη που εμφανίστηκαν σε επεισόδια. Για το ερώτημα αυτό 
# η απάντηση σας θα πρέπει να περιλαμβάνει εκτός από το ερώτημα (query), εναλλακτικό Query Plan (πχ με force index), τα αντίστοιχα traces
# και τα συμπεράσματα σας από την μελέτη αυτών




#3.7. Βρείτε όλους τους μάγειρες που συμμετείχαν τουλάχιστον 5 λιγότερες φορές από τον μάγειρα με τις περισσότερες συμμετοχές σε επεισόδια.

select ecj2.cook_id 
from 
(select ep_id, cook_id , sum(ep_id) num1 from ep_cons_jdgs group by cook_id order by num1 desc limit 1 ) ecj1 
join 
(select ep_id, cook_id , sum(ep_id) num2 from ep_cons_jdgs group by cook_id ) ecj2
where ecj1.num1-ecj2.num2>5;

# 3.8. Σε ποιο επεισόδιο χρησιμοποιήθηκαν τα περισσότερα εξαρτήματα (εξοπλισμός); Ομοίως με ερώτημα 3.6,
# η απάντηση σας θα πρέπει να περιλαμβάνει εκτός από το ερώτημα (query), εναλλακτικό Query Plan (πχ με force index), 
# τα αντίστοιχα traces και τα συμπεράσματα σας απότην μελέτη αυτών

select erc.ep_id ,count(erc.ep_id) num
from ep_rec_cons erc 
join recipes r on erc.rec_id = r.rec_id 
join rec_equip re on r.rec_id =re.rec_id 
join equipment e on re.eq_id =e.eq_id 
group by erc.ep_id 
order by num desc; -- σε ολα ιδιο αριθμο , λογω του οτι η συνδεση συνταγης-εξοπλισμου γινεται με query και δεν εχουν γινει εισαγωγη για καθε συνταγη αυτα πχ



#3.9. Λίστα με μέσο όρο αριθμού γραμμάριων υδατανθράκων στο διαγωνισμό ανά έτος;


select aa1.f1,aa2.f2,aa3.f3,aa4.f4,aa5.f5
from 
(select avg(a.f) f1 from (
select erc.ep_id, avg(fat_100gr) f , rank() over(order by erc.ep_id+10) as num
from complete_recipes cr 
join ep_rec_cons erc on cr.rec_id=erc.rec_id 
group by ep_id 
having ep_id<=10) a)aa1 -- season 1
join
(select avg(a2.f) f2 from (
select erc.ep_id, avg(fat_100gr) f , rank() over(order by erc.ep_id+10) as num
from complete_recipes cr 
join ep_rec_cons erc on cr.rec_id=erc.rec_id 
group by ep_id 
having ep_id>10 and ep_id<=20) a2)aa2 -- season 2
join
(select avg(a3.f) f3 from (
select erc.ep_id, avg(fat_100gr) f , rank() over(order by erc.ep_id+10) as num
from complete_recipes cr 
join ep_rec_cons erc on cr.rec_id=erc.rec_id 
group by ep_id 
having ep_id>20 and ep_id<=30) a3)aa3 -- season 3
join
(select avg(a4.f) f4 from (
select erc.ep_id, avg(fat_100gr) f , rank() over(order by erc.ep_id+10) as num
from complete_recipes cr 
join ep_rec_cons erc on cr.rec_id=erc.rec_id 
group by ep_id 
having ep_id>30 and ep_id<=40) a4)aa4 -- season 4
join
(select avg(a5.f) f5 from (
select erc.ep_id, avg(fat_100gr) f , rank() over(order by erc.ep_id+10) as num
from complete_recipes cr 
join ep_rec_cons erc on cr.rec_id=erc.rec_id 
group by ep_id 
having ep_id>40 and ep_id<=50) a5)aa5; -- season 5


#3.10. Ποιες Εθνικές κουζίνες έχουν τον ίδιο αριθμό συμμετοχών σε διαγωνισμούς, σε διάστημα δύο συνεχόμενων ετών, με τουλάχιστον 3 συμμετοχές ετησίως



#3.11. Βρείτε τους top-5 κριτές που έχουν δώσει συνολικά την υψηλότερη βαθμολόγηση σε ένα μάγειρα. (όνομα κριτή, όνομα μάγειρα και συνολικό σκορ βαθμολόγησης)
	 
delimiter // 

create or replace procedure biggest_fan(in p_conid int)
begin 
	select concat(c1.first_name,' ',c1.last_name) jdg_name ,con11.con , con11.contestant , sum(con11.grade) num
	from
		(select g.jdg_id jdg ,g.con_id con ,g.grade , concat(c.first_name,' ',c.last_name) contestant 
 		from grades g
 		join 
 		(select con_id , grade from grades where con_id=p_conid order by grade desc) con on con.con_id =g.con_id
 		join cooks c on c.cook_id = g.con_id 
 		where g.grade=con.grade) con11        -- 
	join cooks c1 on c1.cook_id=con11.jdg
	group by jdg_name
	order by num desc
	limit 5;
end //

delimiter ;


-- call biggest_fan();


 
#3.12. Ποιο ήταν το πιο τεχνικά δύσκολο, από πλευράς συνταγών, επεισόδιο του διαγωνισμού ανά έτος;

select erc.ep_id , avg(r.difficulty) a, year(e.date_of)
from ep_rec_cons erc 
join episode e on e.ep_id = erc.ep_id 
join recipes r on r.rec_id =erc.rec_id 
group by erc.ep_id 
having erc.ep_id <=10
order by a desc
limit 1; -- season 1

select erc.ep_id , avg(r.difficulty) a, year(e.date_of)
from ep_rec_cons erc 
join episode e on e.ep_id = erc.ep_id 
join recipes r on r.rec_id =erc.rec_id 
group by erc.ep_id 
having erc.ep_id>10 and erc.ep_id<=20
order by a desc
limit 1; -- season 2

select erc.ep_id , avg(r.difficulty) a, year(e.date_of)
from ep_rec_cons erc 
join episode e on e.ep_id = erc.ep_id 
join recipes r on r.rec_id =erc.rec_id 
group by erc.ep_id 
having erc.ep_id>20 and erc.ep_id<=30
order by a desc
limit 1; -- season 3

select erc.ep_id , avg(r.difficulty) a, year(e.date_of)
from ep_rec_cons erc 
join episode e on e.ep_id = erc.ep_id 
join recipes r on r.rec_id =erc.rec_id 
group by erc.ep_id 
having erc.ep_id>30 and erc.ep_id<=40
order by a desc
limit 1; -- season 4

select erc.ep_id , avg(r.difficulty) a, year(e.date_of)
from ep_rec_cons erc 
join episode e on e.ep_id = erc.ep_id 
join recipes r on r.rec_id =erc.rec_id 
group by erc.ep_id 
having erc.ep_id>40 and erc.ep_id<=50
order by a desc
limit 1; -- season 5

#3.13. Ποιο επεισόδιο συγκέντρωσε τον χαμηλότερο βαθμό επαγγελματικής κατάρτισης (κριτές και μάγειρες);

select b.ep_id , b.`rank` r from
(select a.ep_id, avg(a.c_rank) `rank` from
	(select ecj.ep_id , c.cook_id , c.c_rank 
	from ep_cons_jdgs ecj 
	join cooks c on c.cook_id =ecj.cook_id 
	group by c.cook_id) a
	group by a.ep_id)b
	order by r asc
	limit 1;


#3.14. Ποια θεματική ενότητα έχει εμφανιστεί τις περισσότερες φορές στο διαγωνισμό;

select  t.name , count(rt.theme_id ) c
from ep_rec_cons erc 
join recipes r on r.rec_id = erc.rec_id 
join rec_theme rt on rt.rec_id =r.rec_id 
join themes t on rt.theme_id = t.theme_id
group by rt.theme_id 
order by c desc
limit 1;

#3.15. Ποιες ομάδες τροφίμων δεν έχουν εμφανιστεί ποτέ στον διαγωνισμό;
	
select a.name, a.c from 
(select i.name , count(f.f_id) c
from ep_rec_cons erc 
join recipes r on r.rec_id = erc.rec_id 
join rec_ingr ri on r.rec_id =ri.rec_id 
join ingredients i on ri.ingr_id = i.ingr_id 
join foods f on i.food_id = f.f_id 
group by f.f_id )a;
-- where a.c=0 ; -- εμφανιζει το ποτε , αλλα εδω εμφανιζονται ολα 





















