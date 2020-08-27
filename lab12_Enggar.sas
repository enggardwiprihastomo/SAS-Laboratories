libname lab12 '/folders/myfolders/sasuser.v94/lab12';

/* Data generation */
data mainset;
	do i=1 to 100;
		x=100*rannor(0);
		output;
	end;
	keep x;
run;

data secondaryset;
	n=ceil(20*ranuni(0));
	do i=1 to n;
		pt=ceil(100*ranuni(0));
		set mainset point=pt;
		output;
	end;
	keep x;
	stop;
run;
proc sort data=secondaryset out=secondaryset;
	by x;
run;

data gen_set;
	do i=1 to 100;
		j=ceil(10*ranuni(0));
		if j=5 then j=.;
		k=ceil(25*ranuni(0));
		if k=10 then k=.;
		l=ceil(50*ranuni(0));
		if l=10 then l=.;
		output;
	end;
run;

data gen_set2;
	do i=65 to 70;
		x=byte(i);
		output;
	end;
	keep x;
run;

data gen_set3;
	do var1set3=1 to 30;
		var2set3 = 100*ranuni(0);
		output;
	end;
run;

data gen_set4;
	do var1set4="A", "B", "C", "E";
		var2set4=ranuni(0);
		output;
	end;
run;

data gen_set5;
	do var1set5=1 to 25;
		var2set5=ceil(50*rannor(0));
		var3set5=byte(65+(ceil(25*ranuni(0))));
		output;
	end;
run;

data gen_set6;
	length set $20. var $20.;
	infile datalines dsd dlm=',';
	input set$ var$;
	datalines ;
	gen_set3,var1set3 var2set3
	gen_set4,var1set4
	gen_set5,var1set5 var3set5
	;
run;

data gen_set7;
	do i=1 to 50;
		x=round(100*ranuni(0),0.1);
		output;
	end;
	keep x;
run;

/* Exercise 12.2 */
%macro ex_12_2(sets, id);
	%let countsets=%sysfunc(countw(&sets, ' '));
	data _null_;
		retain count 0;
		retain latest_x latest_date;
		format latest_date date9.;
		%do i=1 %to &countsets;
			set %sysfunc(scan(&sets, &i, ' ')) end=last;
			if id=&id then do;
				if count=0 then do;
					latest_date=date;
					latest_x=x;
				end;
				else do;
					if (today()-latest_date)>(today()-date) then do;
						latest_date=date;
						latest_x=x;
					end;
				end;
				count+1;
			end;
			if last and &i=&countsets then do;
				if count=0 then put "The given ID cannot be found in the sets given";
				else do;
					put "Given ID= &id";
					put 'Date=' latest_date;
					put 'X=' latest_x;
				end;
			end;
		%end;
	run;
%mend;
%ex_12_2(lab12.A0346 lab12.A0594 lab12.A0447, 0001);

/* Exercise 12.3 */
%macro ex_12_3(mainset, secondaryset);
	data formatset;
		fmtname="toroman";
		array roman(20)$('I' 'II' 'III' 'IV' 'V' 'VI' 'VII' 'VIII' 'IX' 'X' 'XI' 'XII' 'XIII' 'XIV' 'XV' 'XVI' 'XVII' 'XVIII' 'XIX' 'XX');
		set &secondaryset end=last;
		end=input(x, $20.);
		start=put(lag(end), $20.);
		if _n_=1 then start='low';
		label=roman(_n_);
		output;
		if last then do;
			start=end;
			end='high';
			label=roman(_n_+1);
			output;
		end;
		drop x roman:;
	run;
	
	proc format cntlin=formatset;
	run;
	
	data formated_mainset;
		format formated_x toroman.;
		set &mainset;
		formated_x=x;
	run;
	
	proc sort data=formated_mainset out=formated_mainset;
		by x;
	run;
%mend;
%ex_12_3(mainset, secondaryset);

/* Exercise 12.4 */
%macro ex_12_4(set);
	proc transpose data=&set out=tp_set(keep=_name_);
	run;
	
	data _null_;
		set tp_set nobs=numobs;
		call symput(cat('var',_n_), _name_);
		call symput('numobstp', numobs);
	run;
	
	data _null_;
		set &set nobs=numobs;
		call symput('numobs', numobs);
	run;
	
	data _null_;
		%do i=1 %to &numobs;
			pt=&i;
			set &set point=pt;
			%do j=1 %to &numobstp;
				if &&var&j=. then do;
					tmp&j="&&var&j";
				end;
			%end;
		%end;
		%do i=1 %to &numobstp;
			call symput("m&i", tmp&i);
		%end;
		stop;
	run;
	
	data set_12_4;
		set &set;
		%do i=1 %to &numobstp;
			drop &&m&i;
		%end;
	run;
%mend;
%ex_12_4(gen_set);

/* Exercise 12.5 */
%macro division(set, var);
	%let countvar=%sysfunc(countw(&var));
	%do i=1 %to &countvar;
		%let distinctvar=%sysfunc(scan(&var, &i));
		data z&i;
			pt=&distinctvar;
			set &set point=pt;
			output;
			stop;
		run;
	%end;
%mend;
%division(gen_set,1 2 3 4 5 6 7 20);

/* Exercise 12.6 */
%macro ex_12_6(set, var, n);
	data _null_;
		retain max min;
		set &set end=last;
		if _n_=1 then do;
			max=&var;
			min=&var;
		end;
		if max<&var then max=&var;
		if min>&var then min=&var;
		if last then do;
			call symput("min", min);
			call symput("max", max);
		end;
	run;
	%let interval = %sysfunc(round(%sysevalf(%sysevalf(&max-&min)/&n), 0.1));
	%put Dataset= &set;
	%put Variable= &var;
	%put Minimum value in dataset= %sysfunc(trim(&min));
	%put Maximum value in dataset= %sysfunc(trim(&max));
	%put Class interval (EDF) is &interval;
	%do i=1 %to &n;
		%if &i=1 %then %do;
			%put Class &i has range %sysfunc(trim(&min)).-%sysevalf(&min+&interval);
			%let range = %sysevalf(&min+&interval+0.1);
		%end;
		%else %do;
			%put Class &i has range %sysevalf(&range)-%sysevalf(&range+&interval);
			%let range = %sysevalf(&range+&interval+0.1);
		%end;
	%end;
%mend;
%ex_12_6(gen_set7, x, 5);

/* Exercise 12.7 */
%macro ex_12_7(set);
	data _null_;
		set &set nobs=numobs;
		call symput("numobs", numobs);
	run;
	
	data _null_;
		%do i=1 %to &numobs;
			pt=&i;
			set &set point=pt;
			call symput("set&i", set);
			call symput("var&i", var);
		%end;
		stop;
	run;
	
	data set_12_7;
		%do i=1 %to &numobs;
			set &&set&i;
			keep &&var&i;
		%end;
	run;
	
	%do i=1 %to &numobs;
		data &&set&i;
			set &&set&i;
			drop &&var&i;
		run;
	%end;
%mend;
%ex_12_7(gen_set6);

/* Exercise 12.8 */
%macro ex_12_8(set, k);
	data _null_;
		set &set nobs=numobs;
		call symput("numobs", numobs);
	run;
	%let start=1;
	%let stop=%eval(&numobs-&k);
	data set_12_8;
		%do i=1 %to &k;
			%let stop=%eval(&stop+1);
			do k&i=&start to &stop;
			set &set point=k&i;
			c&i=x;
			%let start=%str(%(k&i+1%));
		%end;
		output;
		%do i=1 %to &k;
			end;
		%end;
		stop;
		keep c:;
	run;
%mend;
%ex_12_8(gen_set2, 3);