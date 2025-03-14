/* Kod do wizualizacji i podsumowań w SAS dla kwiaciarni */

/* Krok 1: Filtrowanie danych dla wybranego miesiąca */
%let month_start = '01JAN2025'd;
%let month_end = '31JAN2025'd;

/* Filtrowanie zamówień w wybranym miesiącu */
data Orders_month;
    set Orders;
    where OrderDate between &month_start and &month_end;
run;

/* Krok 2: Liczba zamówień w poszczególnych dniach */
proc sql;
    create table Daily_Orders as
    select OrderDate, count(*) as Order_Count
    from Orders_month
    group by OrderDate;
quit;

/* Wykres liczby zamówień w dniach */
proc sgplot data=Daily_Orders;
    title "Liczba zamówień w poszczególnych dniach miesiąca";
    vbar OrderDate / response=Order_Count datalabel;
    xaxis label="Data";
    yaxis label="Liczba zamówień";
run;

/* Krok 3: Całkowite przychody w podziale na tygodnie */
data Orders_weekly;
    set Orders_month;
    Week = intnx('week', OrderDate, 0, 'b');
    format Week date9.;
run;

proc sql;
    create table Weekly_Revenue as
    select Week, sum(Price) as Total_Revenue
    from Orders_weekly O
    inner join OrderDetails D
    on O.OrderId = D.OrderId
    group by Week;
quit;

/* Wykres przychodów tygodniowych */
proc sgplot data=Weekly_Revenue;
    title "Całkowite przychody w podziale na tygodnie";
    series x=Week y=Total_Revenue / markers;
    xaxis label="Tydzień";
    yaxis label="Całkowite przychody";
run;

/* Krok 4: Najbardziej popularne produkty */
proc sql;
    create table Top_Products as
    select P.Product, count(*) as Order_Count
    from OrderDetails D
    inner join arrangements P
    on D.ProductId = P.ProductId
    inner join Orders_month O
    on D.OrderId = O.OrderId
    group by P.Product
    order by Order_Count desc;
quit;

/* Wykres najpopularniejszych produktów */
proc sgplot data=Top_Products(obs=10);
    title "Top 10 najpopularniejszych produktów";
    hbar Product / response=Order_Count datalabel;
    xaxis label="Liczba zamówień";
    yaxis label="Produkt";
run;

/* Krok 5: Podsumowanie */
proc sql;
    create table Orders_summary as
    select O.OrderId, sum(D.Price) as total_price
    from Orders_month O
    inner join OrderDetails D
    on O.OrderId = D.OrderId
    group by O.OrderId;
quit;

proc means data=Orders_summary mean sum maxdec=2;
    var total_price;
    title "Podsumowanie sprzedaży dla wybranego miesiąca";
run;

/* Krok 6: Analiza kosztów zamówień kwiatów */
data FlowerOrders_month;
    set flowerOrders;
    where OrderDate between &month_start and &month_end;
run;

proc sql;
    create table Flower_Costs as
    select OrderDate, sum(total_price) as Total_Cost
    from FlowerOrders_month
    group by OrderDate;
quit;

/* Wykres kosztów zamówień kwiatów */
proc sgplot data=Flower_Costs;
    title "Koszty zamówień kwiatów w poszczególnych dniach";
    series x=OrderDate y=Total_Cost / markers;
    xaxis label="Data";
    yaxis label="Całkowite koszty";
run;

/* Krok 7: Analiza zysku (przychód - koszty) dla każdego dnia */
proc sql;
    create table Daily_Profit as
    select R.OrderDate, 
           coalesce(R.Total_Revenue, 0) - coalesce(C.Total_Cost, 0) as Profit
    from (select OrderDate, sum(Price) as Total_Revenue
          from Orders_month O
          inner join OrderDetails D
          on O.OrderId = D.OrderId
          group by OrderDate) R
    full join Flower_Costs C
    on R.OrderDate = C.OrderDate;
quit;

/* Wykres dziennego zysku */
proc sgplot data=Daily_Profit;
    title "Zysk dzienny (przychód - koszty)";
    series x=OrderDate y=Profit / markers;
    xaxis label="Data";
    yaxis label="Zysk";
run;
