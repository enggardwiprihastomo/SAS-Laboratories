libname lab3 "/folders/myfolders/sasuser.v94/lab3";

/* Exercise 3.1 */
data ex_3_1set;
	do i=65 to 90;
		do j=1 to ceil(10*ranuni(0));
			x=byte(i);
			y=ceil(100*ranuni(0));
			output;
		end;
	end;
	keep x y;
run;

data ex_3_1aa;
	set ex_3_1set end=last;
	if x^=lag(x) then do;
		avg=sum/count;
		output;
		sum=y;
		count=1;
	end;
	else do;
		sum+y;
		count+1;
	end;
	if last then do;
		avg=sum/count;
		output;
	end;
run;

data ex_3_1ab;
	set ex_3_1aa;
	x=lag(x);
	if _n_>1 then do;
		output;
	end;
	keep x avg;
run;

data ex_3_1b;
	set ex_3_1set;
	by x;
	if first.x then do;
		sum=0;
		count=0;
	end;
	sum+y;
	count+1;
	if last.x then do;
		avg=sum/count;	
		output;
	end;
	keep x avg;
run;

/* Exercise 3.2 */
data ex_3_2a;
	idx=0;
	do x='A','B','C','D','E';
		do i=1 to ceil(20*ranuni(0));
			y=idx*20+ceil(20*ranuni(0));
			output;
		end;
		idx+1;
	end;
	keep x y;
run;

data ex_3_2b;
	set ex_3_2a;
	by x;
	retain max;
	if first.x then do;
		max=0;
	end;
	if max<y then max=y;
	if last.x then output;
	drop y;
run;

/* Exercise 3.3 */
data ex_3_3a;
	set lab3.b;
	by x;
	if first.x then count+1;
	y=ceil(count/10);
	drop count;
run;

data ex_3_3b;
	set ex_3_3a;
	by x;
	if first.x then do;
		count=0;
	end;
	count+1;
	if last.x then do;
		output;
	end;
run;

data ex_3_3c;
	set ex_3_3b;
	by y;
	retain max val;
	if first.y then do;
		max=0;
		val=0;
	end;
	if max<count then do;
		max=count;
		val=x;
	end;
	if last.y then do;
		output;
	end;
	drop x count;
run;

/* Exercise 3.4 */
proc sort data=lab3.a out=ex_3_4a;
	by u;
run;

data ex_3_4b;
	set ex_3_4a;
	by u;
	retain groups;
	length groups $ 16;
	if first.u then do;
		groups='';
		count=0;
	end;
	if lag(x)^=x then do;
		if groups='' then groups=x;
		else groups=cats(groups,', ',x);
		count+1;
	end;
	if last.u and count>1 then do;
		output;
	end;
	keep u groups;
run;

/* Exercise 3.5 */
data ex_3_5;
	set ex_3_4a end=lastrow;
	by u;
	retain max_u 0 max_count 0;
	if first.u then do;
		count=0;
	end;
	if lag(x)^=x then do;
		count+1;
	end;
	if last.u and count>1 then do;
		if max_count<count then do;
			max_count=count;
			max_u=u;
		end;
	end;
	if lastrow then do;
		output;
	end;
	keep max_u max_count;
run;

/* Exercise 3.6 */
data ex_3_6;
	set lab3.a;
	by x;
	retain avg;
	if first.x then do;
		count=0;
		sum=0;
		avg=0;
	end;
	count+1;
	sum+u;
	if count=5 then do;
		avg=sum/count;
	end;
	if last.x then output;
	keep x avg;
run;

/* Exercise 3.7 */
data ex_3_7a;
	set lab3.a end=last;
	by x;
	if last.x then start=1;
	output;
	if last then do;
		do i=1 to 4;
			x=.;
			u=.;
			start=.;
			output;
		end;
	end;
	drop i;
run;

data ex_3_7b;
	set ex_3_7a;
	shiftedx=lag4(x);
	shiftedu=lag4(u);
run;

data ex_3_7c;
	set ex_3_7b;
	if start then do;
		sum=0;
		count=0;
	end;
	count+1;
	sum+shiftedu;
	if count=5 then do;
		x=shiftedx;
		avg=sum/count;
		output;
	end;
	keep x avg;
run;

/* Exercise 3.8 */
data ex_3_8;
	set lab3.a;
	by x;
	retain exist0 exist9;
	if first.x then do;
		exist0=0;
		exist9=0;
	end;
	if u=0 then exist0=1;
	if u=9 then exist9=1;
	if last.x and ^(exist0 and exist9) then output;
	keep x;
run;

/* Exercise 3.9 */
proc sort data=lab3.function out=ex_3_9;
	by x;
run;

data _null_;
	set ex_3_9 end=last;
	by x;
	retain max;
	retain fnc 1;
	if first.x then max=fx;
	else if max<fx then do;
		max=fx;
		fnc=0;
	end;
	if fx<max then fnc=0;
	if last then do;
		if fnc then put "It is a function.";
		else put "It is not a function.";
	end;
run;