libname lab1 "/folders/myfolders/sasuser.v94/lab1";

/* Exercise 1.1 */
data ex_1_1;
	do i=1 to 100;
		x=(2*ranuni(0))-1;
		y=(2*ranuni(0))-1;
		max=max(x,y);
		avg=(x+y)/2;
		output;
	end;
	drop i;
run;

/* Exercise 1.2 */
data ex_1_2;
	set lab1.a;
	do i=1 to x;
		output;
	end;
	drop i;
run;

/* Exercise 1.3 */
data ex_1_3;
	set lab1.rank;
	if x<lag(x) then y+1;
run;

/* Exercise 1.4 */
data ex_1_4;
	set lab1.cb end=last;
	if cb<lag(cb) and _n_>1 then dcs+1;
	if cb>lag(cb) and _n_>1 then ics+1;
	if last then output;
	keep dcs ics;
run;

/* Exercise 1.5 */
data ex_1_5;
	set lab1.cb end=last;
	if _n_=2 and cb<lag(cb) then locmax+1;
	if _n_>2 and cb<lag(cb) and lag2(cb)<lag(cb) then locmax+1;
	if last and cb>lag(cb) then locmax+1;
	if last then output;
	keep locmax;
run;


/* Exercise 1.6 */
data ex_1_6;
	set lab1.miss end=last;
	retain prevx 0;
	prev=lag(x);
	if _n_>1 then do;
		if prev=. then do;
			y=(x+prevx)/2;
		end;
		else y=prev;
	prevx=prev;
	output;
	end;
	if last then do;
		y=x;
		output;
	end;
	keep y;
run;

/* Exercise 1.7 */
data ex_1_7a;
	set lab1.nodots;
	missvals=floor(5*ranuni(0));
	output;
	if missvals>0 then do i=1 to missvals;
		x=.;
		output;
	end;
	keep x;
run;

data ex_1_7b;
	set lab1.nodots end=last;
	missvals=floor(5*ranuni(0));
	output;
	if missvals>0 then do i=1 to missvals;
		y=.;
		output;
	end;
	keep y;
run;

data ex_1_7c;
	merge ex_1_7a ex_1_7b;
run;