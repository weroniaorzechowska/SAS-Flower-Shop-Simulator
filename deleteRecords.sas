/* delete arrangement */
%macro deleteArrangement(ProductId);
	
	data a;
		set arrangements(where=(Product = &ProductId));
	run;
	data _null_;
		set a nobs=n;
		call symputx('n_p', n);
		stop;
	run;
	%if not(&n_p = 1) %then %do;
		%put ERROR: This arrangement doesnt exist.
	%end;
	
	data o;
		set OrderDetails(where=(ProductId = &ProductId));
	run;
	
	data _null_;
		set o nobs=n;
		call symputx('n_orders', n);
		stop;
	run;
	
	%if &n_orders >= 1 %then %do;
		data arrangements;
			set arrangements;
			if ProductId = &ProductId then archive = 1;
		run;
	%end;
	%else %do;
		data arrangements;
			set arrangements;
			if ProductId != &ProductId then output;
		run;
		data arrangements_details;
			set arrangements_details;
			if ProductId != &ProductId then output;
		run;
	%end;
%mend deleteArrangement(ProductId);

/*%deleteArrangement(46);*/

/* delete Order */
%macro deleteOrder(OrderId);
	data _null_;
		set Orders(where = (OrderId = &OrderId));
		call symputx('sDate', ShippmentDate, 'G');
	run;
	%local t;
	%let t = %sysevalf(%sysfunc(today())-2);
	%if &sDate > &t %then %do;
		data Orders;
			set Orders;
			if not(OrderId = &OrderId) then output;
		run;
		data OrderDetails;
			set OrderDetails;
			if not(OrderId = &OrderId) then output;
		run;
	%end;
	%else %do;
		%put Order is in the preparation. Cannot cancell now.;
	%end;
%mend deleteOrder;

/*%deleteOrder(297);*/