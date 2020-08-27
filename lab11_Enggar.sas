libname lab11 '/folders/myfolders/sasuser.v94/lab11';

/* Exercise 11.3 */
%macro ex_11_3;
	data _null_;
		set lab11.dots end=last;
		array countvar(54) _temporary_;
		%do i=1 %to 54;
			if z&i^=. then do;
				countvar(&i)+1;
				call symput(cat('mz',&i,'_',countvar(&i)), z&i);
			end;
		%end;
		if last then do;
			call symput('maxcount', max(of countvar[*]));
		end;
	run;
	
	data no_dots;
		%put _all_;
		%let underscore=_;
		%do i=1 %to &maxcount;
			%do j=1 %to 54;
				z&j=.;
				%if %symexist(mz&j&underscore&i) %then %do;
					z&j=&&mz&j&underscore&i;
				%end;
			%end;
			output;
		%end;
	run;
%mend;
%ex_11_3

/* Exercise 11.4 */
/* Data Generation */
data a;
	do i=1 to 50;
		x=ceil(50*ranuni(0));
		output;
	end;
	keep x;
run;

/* Exercise 11.4A */
/* Generation of sets for each mean of observation */
%macro copies_means_a;
	data _null_;
		set a end=last;
		call symput(cat('obs',_n_), x);
		if last then call symput('numobs', _n_);
	run;
	
	%do i=1 %to &numobs;
		data a&i;
			mean=0;
			%do j=&i %to &numobs;
				mean+%sysevalf(&&obs&j);
			%end;
			denominator = %sysevalf(%sysevalf(&numobs+1)-&i);
			mean=mean/denominator;
			keep mean;
		run;
	%end;
%mend;
%copies_means_a

/* Merging copies of means of datset A to dataset AVERAGES_A */
%macro ex_11_4a(sets);
	data averages_a;
		%let low=%sysfunc(substr(%sysfunc(scan(&sets,1)), 2));
		%let high=%sysfunc(substr(%sysfunc(scan(&sets,2)), 2));
		%do i=&low %to &high;
			set a&i;
			output;
		%end;
	run;
%mend;
%ex_11_4a(a1-a50)

/* Exercise 11.4B */
/* Transposing and calculating means of dataset A and store to dataset AVERAGES_B */
%macro ex_11_4b(set);
	data _null_;
		set &set end=last;
		call symput(cat('obs', _n_), x);
		if last then call symput('numobs', _n_);
	run;
	
	data averages_b;
		%do i=1 %to &numobs;
			%do j=&i %to &numobs;
				mean_obs&i+%sysevalf(&&obs&j);
			%end;
			denominator = %sysevalf(%sysevalf(&numobs+1)-&i);
			mean_obs&i=mean_obs&i/denominator;
		%end;
		drop denominator;
	run;
%mend;
%ex_11_4b(a)

/* Exercise 11.5 */
%macro ex_11_5(words);
	data ex_11_5_set;
		%let len_words=%sysfunc(countw(&words));
		len_words=&len_words;
		%do i=1 %to &len_words;
			%let varwords=%sysfunc(scan(&words, &i));
			&&varwords=cat('Word ', &i, '-th');
		%end;
		output;
	run;
%mend;
%ex_11_5(This is SAS lab number eleven)

/* Exercise 11.6 */
%macro ex_11_6(n);
	%let result=1;
	%if &n=0 %then
	%put Factorial of &n is 1;
	%else %do;
		%do i=1 %to &n;
			%let result=%eval(&result*&i);
		%end;
		%put Factorial of &n is &result;
	%end;
%mend;
%ex_11_6(5)

/* Exercise 11.7 */
%macro ex_11_7(names, chars);
	%let result = &names;
	%do i=1 %to %sysfunc(countw(&chars));
		%let result = %sysfunc(tranwrd(&result., %scan(&chars.,&i), %str( )));
	%end;
	%let result = %sysfunc(compbl(&result));
	%put Names which are not excluded;
	%do i=1 %to %sysfunc(countw(&result));
		%put %sysfunc(scan(&result, &i));
	%end;
%mend;
%ex_11_7(Andy John Christian Zoe Jackson Jasmin Anna, John Anna)

/* Exercise 11.9 */
%macro comb(n,k);
	%let start=1;
	%let stop=%eval(&n-&k);
	data combinations;
	 	%do i=1 %to &k;
			%let stop=%eval(&stop+1);
			do c&i=&start to &stop;
			%let start=%str(%(c&i+1%));
		%end;
		output;
		%do i=1 %to &k;
			end;
		%end;
	run;
%mend;
%comb(5,3)