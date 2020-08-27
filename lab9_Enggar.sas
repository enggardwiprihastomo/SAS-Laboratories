libname lab9 "/folders/myfolders/sasuser.v94/lab9";

/* Exercise 9.1c */
proc sql;
	TITLE "Exercise 9.1C";
	SELECT nr_rent_office, nr_car, (input(date_return, yymmdd10.)-input(date_rent, yymmdd10.)) AS days_rent FROM lab9.rental
	WHERE input(date_rent, yymmdd10.)
	BETWEEN input("1998/10/01", yymmdd10.) AND input("1998/12/31", yymmdd10.)
	ORDER BY nr_rent_office, days_rent;
quit;

/* Exercise 9.1d */
proc sql;
	TITLE "Exercise 9.1D";
	SELECT surname FROM (
		SELECT surname, brand, COUNT(*) AS count FROM (
			SELECT surname, brand FROM lab9.customers Cust
			INNER JOIN lab9.rental Rental ON Cust.nr_customer=Rental.nr_customer
			INNER JOIN lab9.cars Cars ON Rental.nr_car=Cars.nr_car GROUP BY name, surname
			HAVING COUNT(*)>1
		)GROUP BY surname, brand
	) GROUP BY surname HAVING MAX(count)=1;
quit;

/* Exercise 9.1e */
/* Between 1 October 1999 and 1 February 2020 (Not neccesaryly as menitoned in the question 9.1E) */
proc sql;
	TITLE "Exercise 9.1E";
	SELECT * FROM lab9.employees
	EXCEPT
	SELECT DISTINCT nr_employee, name, surname, date_employment, department, position, salary, bonus, nr_seat, nr_phone FROM lab9.employees Employees
	INNER JOIN lab9.rental Rental ON Employees.nr_employee=Rental.nr_employee_rent
	WHERE input(date_rent, yymmdd10.) BETWEEN input("1999/10/01", yymmdd10.) AND input("2000/02/01", yymmdd10.);
quit;

/* Between October 1999 and February 2020 (As menitoned in the question 9.1E) */
proc sql;
	TITLE "Exercise 9.1E";
	SELECT * FROM lab9.employees
	EXCEPT
	SELECT DISTINCT nr_employee, name, surname, date_employment, department, position, salary, bonus, nr_seat, nr_phone FROM lab9.employees Employees
	INNER JOIN lab9.rental Rental ON Employees.nr_employee=Rental.nr_employee_rent
	WHERE MONTH(input(date_rent, yymmdd10.)) BETWEEN 02 AND 10
	AND YEAR(input(date_rent, yymmdd10.)) BETWEEN 1999 AND 2000;
quit;

/* Exercise 9.1f */
proc sql;
	TITLE "Exercise 9.1F";
	SELECT DISTINCT nr_rental,
	(SELECT DISTINCT surname FROM lab9.employees WHERE nr_employee=Rentals.nr_employee_rent) AS renting,
	(SELECT DISTINCT surname FROM lab9.employees WHERE nr_employee=Rentals.nr_employee_return) AS receiving
	FROM lab9.rental Rentals
	INNER JOIN lab9.employees Employees ON Rentals.nr_employee_rent=Employees.nr_employee OR Rentals.nr_employee_return=Employees.nr_employee
	WHERE nr_rent_office<>"" AND nr_office_return<>"" AND nr_rent_office <> nr_office_return;
quit;

/* Exercise 9.1g */
proc sql;
	TITLE "Exercise 9.1G";
	SELECT * FROM (
	SELECT DISTINCT Employees_Filter.nr_employee, surname, SUM((input(date_return, yymmdd10.)-input(date_rent, yymmdd10.))*day_price) AS profit FROM (
		SELECT nr_employee FROM lab9.employees WHERE YEAR(input(date_employment, yymmdd10.))<1998) Employees_Filter
	INNER JOIN lab9.employees Employees ON Employees.nr_employee=Employees_Filter.nr_employee
	INNER JOIN lab9.rental Rentals ON Employees_Filter.nr_employee=Rentals.nr_employee_rent
	WHERE YEAR(input(date_return, yymmdd10.)) = 1999
	GROUP BY nr_employee_rent)
	HAVING profit=MAX(profit);
quit;

/* Exercise 9.1h */
proc sql;
	TITLE "Exercise 9.1H";
	SELECT date_rent, date_return, surname, ((input(date_return, yymmdd10.)-input(date_rent, yymmdd10.))*day_price) AS cost FROM lab9.cars Cars
	INNER JOIN lab9.rental Rentals ON Cars.nr_car=Rentals.nr_car
	INNER JOIN lab9.employees Employees ON Rental.nr_employee_rent=Employees.nr_employee
	WHERE Cars.nr_car='000003';
quit;

/* Exercise 9.2 */
proc sql;
	TITLE "Exercise 9.2";
	SELECT Dates.instrument, Dates.date, measurement FROM lab9.dates Dates
	INNER JOIN lab9.measurements measurements ON measurements.instrument=Dates.instrument AND measurements.date IN
	(SELECT date FROM (
		SELECT date, abs(Dates.date-date) AS diff
		FROM lab9.measurements WHERE instrument=Dates.instrument)
	HAVING diff=MIN(diff));
quit;

/* Exercise 9.3 (From Problem 8.2) */
proc sql;
	TITLE "Exercise 9.3";
	SELECT AVG(sales) AS mean_sales FROM lab8.large Large
	INNER JOIN lab8.small Small ON Large.id=Small.id;
quit;

/* Exercise 9.4 */
proc sql;
	TITLE "Exercise 9.4";
	SELECT * FROM (SELECT *, "." AS indyk FROM (
		SELECT * FROM lab9.b INTERSECT SELECT * FROM lab9.a))
	UNION
	SELECT * FROM (SELECT *, "1" AS indyk FROM (
		SELECT * FROM lab9.b EXCEPT SELECT * FROM lab9.a))
	ORDER BY a,b,c;
quit;

/* Exercise 9.5 */
proc sql;
	TITLE "Exercise 9.5";
	SELECT DISTINCT Students1.id_student AS student1, Students2.id_student AS student2, Students1.id_class FROM lab9.students Students1
	INNER JOIN lab9.students Students2 ON Students1.id_student<>Students2.id_student AND Students1.id_class IN 
	(SELECT id_class FROM lab9.students WHERE id_class=Students1.id_class AND id_student=Students2.id_student)
	ORDER BY Students1.id_student, Students1.id_class;
quit;

/* Below is just the code to prove/compare the correctness of the query 9.5 above  */
proc sql;
	CREATE TABLE compare AS
	SELECT id_class, id_student FROM lab9.students ORDER BY id_class,id_student;
quit;