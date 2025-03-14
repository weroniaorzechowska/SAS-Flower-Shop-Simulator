%newOrder(96, 4FEB2025, 40);

%newCustomer("Weronika", "Orzechowska", "+44 728-646-560", "weronia.orzechowska@gmail.com",
			 "S9 8AY", "Lake Beth", "6 Gemma tunnel");
%getCustomerId("Weronika", "Orzechowska", "phone","+44 728-646-560");
%getArrangementId("Radiance Within");
%newOrder(156, 15FEB2025, 47);
%getOrderId(15FEB2025, 156, 47);
%editOrder(288, "11FEB2025");

%newOrder(84, 30JAN2025, 35);

/****************************/
/* Podsumowanie dnia */
proc sort data = Customers out = Customers; by Customer_Id; run;

proc sort data = Orders out = Orders; by descending OrderDate; run;

proc sort data = OrderDetails out = OrderDetails; by descending OrderId; run;

title "New Orders";
proc print data = Orders(where = (OrderDate = today())); run;
title "Shipped Today";
proc print data = Orders(where = (ShippmentDate = today())); run;
title "Delivered Today";
proc print data = Orders(where = (DeliveryDate = today())); run;

/* aktualizacja statusów zamówień */
data Orders;
	set Orders;
	if ShippmentDate = today() then status = 1;
	else if DeliveryDate = today() then status = 3;
run;

/* stworzenie nowego zamówienia na kwiaty*/
%OrderFlowers;