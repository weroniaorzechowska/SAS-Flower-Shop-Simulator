/*data Orders;
	set Orders(where=(OrderDate > 23750));
run;*/

%macro simulation;
	
	data _null_;
		x = intnx('day', today(), -2, 'same');
		if _N_ = 1 then call symputx("max", x);
	run;
	proc sort data=Orders out = O; by ShippmentDate; run;
	data _null_;
		set O;
		x = intnx('day', ShippmentDate, -2, 'same');
		if _N_ = 1 then call symputx("min", x);
	run;

	
	%do i = &min %to &max;
	
	data O_today;
		set Orders(where = (ShippmentDate = &i + 2));
	run;
	data O_today;
		set O_today nobs = n;
		call symputx("no_today", n);
	run;
	
	%if &no_today = 0 %then continue;
	
	%do j = 1 %to &no_today;
		data _null_;
			set O_today(firstobs=&j obs=&j);
			call symputx("id", OrderId);
		run;
		data _null_;
			set OrderDetails(where = (OrderId = &id));
			call symputx("arrangement", ProductId);
		run;
		
		%if &j = 1 %then %do;
		data usedFlowers;
			set arrangements_details(where = (ProductId = &arrangement));
			keep flower quant;
		run;
		%end;
		%else %do;
			data usedFlowers;
			set arrangements_details(where = (ProductId = &arrangement)) usedFlowers;
			keep flower quant;
		run;
		%end;
		proc print data = usedFlowers; run;
	%end;
		
	proc sql noprint;
		create table usedFlowers as
		select flower, sum(quant) as quant from usedFlowers
		group by flower;
	quit;
		
	proc sql noprint;
		create table usedFlowers as
		select flower, quant, stock from usedFlowers
		left join flowers_p on flowers_p.productId = usedFlowers.flower;
	quit;
		
	data usedFlowers;
		set usedFlowers;
		new_stock = Stock - quant;
	run;
		
	proc print data = usedFlowers; run;
		
	proc sql noprint;
		create table nf as
		select *, new_stock from flowers_p
		left join usedFlowers on usedFlowers.flower = flowers_p.productId;
	quit;
		
	data nf;
		set nf;
		if not missing(new_stock) then do;
			stock = new_stock;
		end;
		drop new_stock flower quant;
	run;
		
	data of;
		set nf(where = (stock <= 0));
		quant = 20 - stock;
		total_price = quant*Price;
		OrderDate = &i;
		format OrderDate date9.;
		drop stock;
	run;
	
	proc print data = of; run;
	
	data flowerOrders;
		set flowerOrders of;
	run;
	
	data flowers_p;
		set nf;
		if stock <= 0 then stock = 20;
	run;
	%end;
	
%mend;

%simulation;



%macro OrderFlowers;

	data O_today;
		set Orders(where = (ShippmentDate = intnx('day', today(), 2, 'same')));
	run;
	data O_today;
		set O_today nobs = n;
		call symputx("no_today", n);
	run;
	
	%do j = 1 %to &no_today;
		data _null_;
			set O_today(firstobs=&j obs=&j);
			call symputx("id", OrderId);
		run;
		data _null_;
			set OrderDetails(where = (OrderId = &id));
			call symputx("arrangement", ProductId);
		run;
		
		%if &j = 1 %then %do;
		data usedFlowers;
			set arrangements_details(where = (ProductId = &arrangement));
			keep flower quant;
		run;
		%end;
		%else %do;
			data usedFlowers;
			set arrangements_details(where = (ProductId = &arrangement)) usedFlowers;
			keep flower quant;
		run;
		%end;
		proc print data = usedFlowers; run;
	%end;
		
	proc sql noprint;
		create table usedFlowers as
		select flower, sum(quant) as quant from usedFlowers
		group by flower;
	quit;
		
	proc sql noprint;
		create table usedFlowers as
		select flower, quant, stock from usedFlowers
		left join flowers_p on flowers_p.productId = usedFlowers.flower;
	quit;
		
	data usedFlowers;
		set usedFlowers;
		new_stock = Stock - quant;
	run;
		
	proc print data = usedFlowers; run;
		
	proc sql noprint;
		create table nf as
		select *, new_stock from flowers_p
		left join usedFlowers on usedFlowers.flower = flowers_p.productId;
	quit;
		
	data nf;
		set nf;
		if not missing(new_stock) then do;
			stock = new_stock;
		end;
		drop new_stock flower quant;
	run;
		
	data of;
		set nf(where = (stock <= 0));
		quant = 20 - stock;
		total_price = quant*Price;
		OrderDate = today();
		format OrderDate date9.;
		drop stock;
	run;
	
	data flowerOrders;
		set flowerOrders of;
	run;
	
	data flowers_p;
		set nf;
		if stock <= 0 then stock = 20;
	run;
%mend;