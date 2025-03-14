%macro getCustomerId(Name, Surname, t, val);
	data _null_;
		set customers(where = (Name = &Name and Surname = &Surname));
		if &t = "phone" and phone = &val then call symputx("id", customer_id);
		else if &t = "mail" and mail = &val then call symputx("id", customer_id);
	run;
	%put Customers Id: &id;
%mend getCustomerId;

/*%getCustomerId("Eva", "Howe", "phone", "+44 881-374-356");
%getCustomerId("Eva", "Howe", "phone", "+44 881-364-356");*/

%macro getArrangementId(Name);
	data _null_;
		set arrangements(where = (Product = &Name));
		call symputx("id", ProductId);
	run;
	%put Arrangement Id: &id;
%mend getArrangementId;

/*%getArrangementId("Luminous Glow");*/

%macro getOrderId(DeliveryDate, CustomerId, Product);
	data o;
		set Orders(where=(DeliveryDate = input("&DeliveryDate", date9.) and CustomerId = &CustomerId));
	run;
	proc sql noprint;
		create table od as
		select * from o
		left join OrderDetails on OrderDetails.OrderId = o.OrderId;
	quit;
	data _null_;
		set od;
		call symputx("id", OrderId);
	run;
	%put Order Id: &id;
%mend getOrderId;

/*%getOrderId(30JAN2025, 63, 1);*/