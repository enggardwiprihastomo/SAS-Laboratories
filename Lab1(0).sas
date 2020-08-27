libname bilb "/folders/myfolders/sasuser.v94/lab1(0)";

/* Exercise 1(0).1 */
data bilb.results;
	input code $ test1 test2 grade;
	cards;
	AD11423 19 23 3.5
	AG19020 16 21 3
	Aw93048 35 12 4
	RG04729 4 15 2
	DR03827 8 11 2
;
run;

data ex_1_0_1a;
	set bilb.results end=last;
	if code='AG19020' then do;
		test1=20;
		grade=3.5;
	end;
	output;
	if last then do;
		code='AC45632';
		test1=13;
		test2=29;
		grade=4;
		output;
	end;
run;

data ex_1_0_1b;
	set ex_1_0_1a;
	sum = test1 + test2;
run;

/* Exercise 1(0).2 */
data _null_;
	current=today();
	birth=mdy(1,21,1994);
	daysofliving = intck('day', birth, current, 'c');
	monthsofliving = intck('month', birth, current, 'c');
	yearssofliving = intck('year', birth, current, 'c');
	lastday=intnx('month', today(), -5);
	lastday=lastday-1;
   	put "The last day of the month of 6 months before today is " lastday date9.;
	put "You've been living for " daysofliving "days";
	put "You've been living for " monthsofliving "months";
	put "You've been living for " yearssofliving "years";
run;

/* Exercise 1(0).3 */
data a;
	do x=1 to 10;
		output;
	end;
run;

data ex_1_0_3;
	set a end=last;
	retain sum 0 factor 1;
	sum = sum+x;
	factor = factor*x;
	if last then output;
	keep sum factor;
run;

/* Exercise 1(0).4 */
proc means data=bilb.results mean;
	title 'Means of test1 and test2';
	var test1 test2;
run;