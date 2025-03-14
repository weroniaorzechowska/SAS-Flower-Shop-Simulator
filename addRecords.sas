libname macroP base "/home/u63791625/projekt/makra";

/* add new customer*/
%macro newCustomer(Name, Surname, Phone, mail, PostCode, City, BuildingStreet);

	%if %length(&Name) = 0 or %length(&Surname) = 0 or %length(&Phone) = 0 or
		%length(&mail) = 0 or %length(&PostCode) = 0 or %length(&City) = 0 or
		%length(&BuildingStreet) = 0 %then %do;
		%put ERROR: Some of the required arguments are missing;
		%return;
	%end;
	
	data _null_;
		set customers nobs=n;
		call symputx('n_customers', n);
		stop;		
	run;
	data _null_;
		set adresses nobs=n;
		call symputx('n_adresses', n);
		stop;		
	run;
	
	data nc;
		Customer_id = &n_customers + 1;
		Name = &Name;
		Surname = &Surname;
		status = 0;
		mail = &mail;
		phone = &Phone;
		AdressId = &n_adresses + 1;
	run;
	
	data customersN;
		set Customers nc;
	run;
	
	proc sort data = customersN out = customersN nodupkey;
		by name surname mail phone;
	run;
	
	data _null_;
		set customersN nobs=n;
		call symputx('n_customersN', n);
		stop;		
	run;
	
	%if &n_customersN = &n_customers %then 
		%put "Client with this data already exists in database";
		
	%else %do;
	%put "New client succesfully added to the database";
	data customers;
		set customersN;
	run;
	
	data na;
		AdressId = &n_adresses + 1;
		PostCode = &PostCode;
		City = &City;
		BuildingStreet = &BuildingStreet;
	run;
	data adressesN;
		set Adresses na;
	run;
	data Adresses;
		set Adressesn;
	run;
	%end;
	
%mend newCustomer;

/* 
TEST 
%newCustomer("Martha", "Stewart", "+44 721-686-460", "martha.stwerat@gmail.com", 
			 "L2K 0PD", 'Foxborough', '851 Long Place');*/


/* add arrangement */

%macro addArrangement(Name, flowers, count);
	data _null_;
		set arrangements nobs=n;
		call symputx('n_arrangements', n);
		stop;
	run;
	
	data check;
		set arrangements(where = (Product = &Name and archive = 0));
	run;
	data _null_;
		set check nobs=n;
		call symputx("n_names", n);
	run;
	%if &n_names = 1 %then %do;
		%put ERROR: Arrangement with this name exists in the database;
		%return;
	%end;
	
	data _null_;
		set flowers end = end;
		retain flower_price;
		length flower_price $32000;
		if _N_ = 1 then do;
			flower_price = put(stock_price, best12.);
		end;	
		else do;
			flower_price = catx(',', flower_price, put(stock_price, best12.));
		end;
		if end then do;
			call symputx('flower_price', flower_price);
		end;
	run;
	data ad;
		ProductId = &n_arrangements + 1 + 51;
		x = countw(&flowers, ",");
		do i = 1 to x;
			flower = input(scan(&flowers, i, ","), best12.);
			quant = input(scan(&count, i, ","), best12.);
			price_f = input(scan("&&flower_price", flower, ','), best12.);
			pq = price_f*quant;
			output;
		end;
		drop x i price_f;
	run;
	proc sql;
		create table ad as
		select *, sum(pq) as total_price, sum(quant) as flower_count
		from ad
		group by ProductId;
	quit;
	
	data _null_;
		set arrangements_details(where=(size = 0)) end = end;
		if _N_ = 1 then max = flower_count;
		else do;
			if flower_count > max then max = flower_count;
		end;
		if end then call symputx('max0', max);
	run;
	data _null_;
		set arrangements_details(where=(size = 1)) end = end;
		if _N_ = 1 then max = flower_count;
		else do;
			if flower_count > max then max = flower_count;
		end;
		if end then call symputx('max1', max);
	run;
	data _null_;
		set arrangements_details(where=(size = 2)) end = end;
		if _N_ = 1 then max = flower_count;
		else do;
			if flower_count > max then max = flower_count;
		end;
		if end then call symputx('max2', max);
	run;
	
	data ad;
		set ad;
		if flower_count < &max0 then do;
			total_price = round(total_price*1.25, 0.01);
			size = 0;
		end;
		else if flower_count < &max1 then do;
			total_price = round(total_price*1.5, 0.01);
			size = 1;
		end;
		else do;
			total_price = round(total_price*1.75, 0.01);
			size = 2;
		end;
		drop pq;
	run;
	data arrangements_details;
		set arrangements_details ad;
	run;
	
	data _null_;
		set ad;
		call symputx('fc', flower_count);
		call symputx('s', size);
		call symputx('p', total_price);
	run;
	data a;
		Product = &Name;
		ProductId = &n_arrangements + 1;
		Archive = 0;
		category = 2;
		flower_count = &fc;
		size = &s;
		Price = &p;
	run;
	data arrangements;
		set arrangements a;
	run;
%mend addArrangement;

/*%addArrangement('Lovely Afternoon', "3,35,6,1", "5,10,2,3");*/


/* add Order */

%macro newOrder(customerId, deliveryDate, arrangement);

	data _null_;
		set Orders nobs=n;
		call symputx('n_orders', n);
		stop;
	run;
	
	data _null_;
		set Customers end = end;
		retain check;
		if _N_ = 1 then check = 0;
		if customer_id = &CustomerId then check = 1;
		if end then call symputx("check", check);
	run;
	
	%if &check = 0 %then %do;
		%put Customer doesnt exist in database. Create new customer first;
		%return;
	%end;
	
	%local t;
	%let t = %sysevalf(%sysfunc(today())+3);
	data _null_;
		format temp_date date9.;
		temp_date = input("&deliveryDate", date9.);
		call symputx('DeliveryDate', temp_date, 'G');
	run;
	
	%if &DeliveryDate < &t %then %do;
		%put ERROR: Invalid DeliveryDate;
		%return;
	%end;
	
	data no;
		CustomerId = &customerId;
		OrderDate = today();
		ShippmentDate = intnx('day', input("&deliveryDate", date9.), -1, 'same');
		DeliveryDate = input("&deliveryDate", date9.);
		OrderId = &n_orders + 1;
		Status = 0;
	run;
	
	data Orders;
		set Orders no;
	run;
	
	data _null_;
		set arrangements(where = (ProductId = &arrangement));
		call symputx('price', Price);
		stop;
	run;
	
	data nod;
		OrderId = &n_orders + 1;
		ProductId = &arrangement;
		Quant = 1;
		Price = &price;
	run;
	
	data OrderDetails;
		set OrderDetails nod;
	run;
%mend newOrder;

/*%newOrder(1000, 04FEB2024, 67);*/

