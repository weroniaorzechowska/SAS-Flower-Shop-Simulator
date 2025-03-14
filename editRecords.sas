/* edit customer */

%macro editCustomer(CustomerId, Var, NewVal);
	
	data _null_;
		set Customers end = end;
		retain check;
		if _N_ = 1 then check = 0;
		if customer_id = &CustomerId then check = 1;
		if end then call symputx("check", check);
	run;
	
	%if &check = 0 %then %do;
		%put Customer doesnt exist in database
		%return;
	%end;
	
	data customers;
		set customers;
		if Customer_id = &CustomerId then &Var = "&NewVal";
	run;
%mend editCustomer;

/*%editCustomer(903, status, 1)*/;


/* edit arrangement */
%macro editArrangement(ArrangementId, Type, Var1, Var2 = .);

	%if &Type = 0 %then %do;
		data arrangements;
			set arrangements;
			if ProductId = &ArrangementId then do;
				Name = &Var1;
			end;
		run;
	%end;

	%else %do;
	
		data ao;
			set OrderDetails(where = (ProductId = &ArrangementId));
		run;
		data _null_;
			set ao nobs = n;
			call symputx('n_orders', n);
		run;
		
		%if n_orders = 0 %then %do;
		data nad;
			ProductId = &ArrangementId;
			do i = 1 to countw(&Var1, ",");
				flower = input(scan(&Var1, i, ","), 8.);
				quant = input(scan(&Var2, i, ","), 8.);
				output;
			end;
			drop i;
		run;
		proc sql noprint;
			create table nad as
			select * from nad
			left join flowers on flowers.ProductId = nad.flower;
		quit;
		data nad;
			set nad;
			pq = quant * stock_price;
			drop Product stock_price;
		run;
		proc sql;
			create table nad as
			select *, sum(pq) as total_price, sum(quant) as flower_count
			from nad;
		run;
		
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
		
		data nad;
			set nad;
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
			set arrangements_details;
			if not(ProductId = &ArrangementId) then output;
		run;
		data arrangements_details;
			set arrangements_details nad;
		run;
		%end;
		
		%else %do;
		%put Nie możemy edytować bukiety - były już złożone na niego zamówienia.; 
		%put Bukiet zostaje zarchiwizowany i dodany nowy;
		data _null_;
			set Arrangements (where = (ProductId = &ArrangementId));
			call symputx('Name', Product);
			stop;
		run;
		%addArrangement("&Name", &Var1, &Var2);
		%end;
	%end;
%mend editArrangement;

/*%editArrangement(67, 1, "37,42,13,12", Var2 = "3,4,5,5")*/;

/* edit OrderDetails */
%macro editOrderDetails(OrderId, NewP);
	data _null_;
		set Orders(where=(OrderId = &OrderId));
		call symputx('ShippmentDate', ShippmentDate);
	run;
	%if %sysfunc(inputn(&ShippmentDate,best.)) <= 
		%sysfunc(intnx('day', %sysfunc(inputn(&ShippmentDate,best.)), -2, 'same')) %then %do;
		%put ERROR: Too late, changes cannot be made.;
		%return;
	%end;
	%else %do;
		data _null_;
			set arrangements(where = (ProductId = &NewP));
			call symputx('price', Price);
			stop;
		run;
		data OrderDetails;
			set OrderDetails;
			if OrderId = &OrderId then do;
				ProductId = &NewP;
				Price = &Price;
			end;
		run;
	%end;
%mend editOrderDetails;

/*%editOrderDetails(261, 70);*/

/* edit Order */
%macro editOrder(OrderId, NewDate);
	data _null_;
		set Orders(where=(OrderId = &OrderId));
		call symputx('DeliveryDate', DeliveryDate, 'G');
	run;
	data _null_;
		format temp_date date9.;
		temp_date = input(&NewDate, date9.);
		call symputx('NewDate2', temp_date, 'G');
	run;
	
	%local t nt2;
	%let t = %sysfunc(today());
	%let nt2 = %sysevalf(&NewDate2 -2);

	
	%if &NewDate2 > &DeliveryDate or &nt2 > &t %then %do;
		data Orders;
			set Orders;
			if OrderId = &OrderId then do;
				DeliveryDate = input(&NewDate, date9.);
				ShippmentDate = intnx('day', DeliveryDate, -1, 'same');
				format ShippmentDate DeliveryDate date9.;
			end;
		run;
	%end;
	%else %do;
		%put ERROR: We are unable to deliver flowers for this date;
		%return;
	%end;
%mend editOrder;

/*%editOrder(294, "30JAN2025");*/
























