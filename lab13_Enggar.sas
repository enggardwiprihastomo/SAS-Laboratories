libname lab13 "/folders/myfolders/sasuser.v94/lab13";
libname lib13 "/folders/myfolders/sasuser.v94";
/* Data generation */
%let globvar = this is global variable;

data gen_set;
	do i=1 to 100;
		j=ceil(50*ranuni(0));
		k=byte(65+ceil(25*ranuni(0)));
		output;
	end;
run;

data set1;
	do i=1 to 100;
		j=ceil(50*ranuni(0));
		k=byte(65+ceil(25*ranuni(0)));
		output;
	end;
run;

data set2;
	do i=1 to 100;
		var1=ceil(300*ranuni(0));
		var2=ceil(100*ranuni(0));
		output;
	end;
	drop i;
run;

data set3;
	do group=1 to 5;
		do i=1 to ceil(10*ranuni(0));
			val=ceil(100*ranuni(0));
			output;
		end;
	end;
	drop i;
run;

data set4;
	low =ceil(5*ranuni(0));
	high=low + ceil(5*ranuni(0));
	do group=low to high;
		do i=1 to ceil(5*ranuni(0));
			val=ceil(20*ranuni(0));
			output;
		end;
	end;
run;

data lib13.set1;
	do i=1 to 20;
		x=ceil(50*ranuni(0));
		output;
	end;
run;

data lib13.set2;
	do i=20 to 50;
		x=byte(65+ceil(25*ranuni(0)));
		output;
	end;
	drop i;
run;

data lib13.set3;
	do i=1 to 10;
		x=ceil(100*rannor(0));
		y=ranuni(0);
		output;
	end;
run;

/* Exercise 13.1 */
%macro ex_13_1(dataset, n);
	%let lib=%sysfunc(scan(&dataset, 1, '.'));
	%let set=%sysfunc(scan(&dataset, 2, '.'));
	proc sql noprint;
		SELECT name, nlobs
		INTO :names separated by ' ', :numobs FROM
		(SELECT name
		FROM dictionary.columns
		WHERE libname="%upcase(&lib)" AND memname="%upcase(&set)" AND type="num"), dictionary.tables 
		WHERE libname="%upcase(&lib)" AND memname="%upcase(&set)";
	run;
	data &set._new;
		%let numvar=%sysfunc(countw(&names));
		%let arr= %eval(&numobs*&numvar);
		array tmp(&arr) _temporary_;
		%do incobs=1 %to &numobs;
			pt=&incobs;
			set &set point=pt;
			%let count=1;
			%do incvar=(&numvar*(&incobs-1))+1 %to &numvar*&incobs;
				%let varname=%sysfunc(scan(&names, &count));
				%let count=%eval(&count+1);
				tmp(&incvar) = &varname;
			%end;
		%end;
		count=0;
		do while(count<&n);
			random=ceil(%eval(&numobs*&numvar)*ranuni(0));
			if tmp(random)^=. then do;
				tmp(random)=.;
				count+1;
			end;
		end;
		%do inci=1 %to &numobs;
			%do incj=1 %to &numvar;
				%let varname=%sysfunc(scan(&names, &incj));
				&varname = tmp(&numvar*(&inci-1)+&incj);
			%end;
			output;
		%end;
		keep &names;
		stop;
	run;
%mend;
%ex_13_1(work.gen_set, 5);

/* Exercise 13.2 */
%macro ex_13_2(numofvars, numofgrps);
	data ex_13_2;
		%let rand = %eval(&numofgrps*%sysfunc(ceil(10*%sysfunc(ranuni(0)))));
		%do i=1 %to &numofvars;
			length var&i $ 8;
			array tmp&i(&rand)$ _temporary_;
			%do j=1 %to &rand;
				tmp&i(&j)=cat("A",ceil(&numofgrps*ranuni(0)));
			%end;
			call sortn(of tmp&i[*]);
		%end;
		%do i=1 %to &rand;
			%do j=1 %to &numofvars;
				var&j=tmp&j(&i);
			%end;
			output;
		%end;
	run;
%mend;
%ex_13_2(5, 9);

/* Exercise 13.3 */
%macro ex_13_3(scope, name);
	proc sql noprint;
		SELECT count(*)
		INTO :status
		FROM dictionary.macros
		WHERE scope="%upcase(&scope)" AND name="%upcase(&name)";
	run;
	%if &status %then
		%put "%upcase(&scope) variable %upcase(&name) exists";
	%else 
		%put "%upcase(&scope) variable %upcase(&name) does not exist";
%mend;
%ex_13_3(global, globvar);

/* Exercise 13.4 */
%macro ex_13_4(lib);
	proc sql noprint;
		SELECT memname
		INTO :sets separated by ' '
		FROM dictionary.tables
		WHERE libname="%upcase(&lib)";
	run;
	%let numset = %sysfunc(countw(&sets));
	%do i=1 %to &numset;
		%let set = %sysfunc(scan(&sets, &i));
		proc sql noprint;
			SELECT name
			INTO :vars&i separated by ' '
			FROM dictionary.columns
			WHERE libname="%upcase(&lib)" AND memname="%upcase(&set)" AND type="num";
		run;
		
		data _null_;
			retain max 0;
			set %sysfunc(scan(&sets, &i)) end=last;
			%let numvars = %sysfunc(countw(&&vars&i));
			%do j=1 %to &numvars;
				%let tmp = %sysfunc(scan(&&vars&i, &j));
				if max<&tmp then max=&tmp;
			%end;
			if last then call symput("max&i", max);
		run;
	%end;
	%let max=0;
	%do i=1 %to &numset;
		%if &max<&&max&i %then %let max=&&max&i;
	%end;
	%put Maximum value found in library %upcase(&lib) is &max;
run;
%mend;
%ex_13_4(work);

/* Exercise 13.6 */
%macro ex_13_6(lib, dir);
	proc sql noprint;
		SELECT memname
		INTO :sets separated by ' '
		FROM dictionary.tables
		WHERE libname="%upcase(&lib)";
	run;
	%let numset = %sysfunc(countw(&sets));
	%do i=1 %to &numset;
		%let set = %sysfunc(scan(&sets, &i));
		proc export data=&lib..&set
			outfile="&dir&set..txt";
			delimiter='|';
		run;
	%end;
%mend;
%ex_13_6(work,/folders/myfolders/sasuser.v94/);

/* Exercise 13.7 */
%macro howmany(lib,group,val);
	proc sql noprint;
		SELECT memname
		INTO :sets separated by ' '
		FROM (SELECT memname
			FROM dictionary.columns
			WHERE libname="%upcase(&lib)" AND type="num" AND name="%lowcase(&group)" OR name="%lowcase(&val)")
		GROUP BY memname HAVING count(*)=2;
	run;
	%if %symexist(sets) %then %do;
		%let numsets = %sysfunc(countw(&sets));
		proc sql noprint;
			%do i=1 %to &numsets;
				%let set = %sysfunc(scan(&sets, &i));
				SELECT DISTINCT &group, &val
				into :groupset&i separated by ' ', :valset&i separated by ' '
				FROM &set;
			%end;
		run;
		%do i=1 %to &numsets;
			%let groupset = %sysfunc(countw(&&groupset&i));
			%do j=1 %to &groupset;
				%let el = %sysfunc(scan(&&groupset&i,&j));
				%let group&el = 0;
			%end;
		%end;
		
		%let numgroups = 0;
		%do i=1 %to &numsets;
			%let groupset = %sysfunc(countw(&&groupset&i));
			%do j=1 %to &groupset;
				%let el = %sysfunc(scan(&&groupset&i,&j));
				%let group&el = %eval(&&group&el+1);
				%if &numgroups<&el %then %let numgroups=&el;
			%end;
		%end;
		%let maxgroup = 0;
		%do i=1 %to &numgroups;
			%if &maxgroup<&&group&i %then %let maxgroup=&&group&i;
			%if &i=&numgroups %then %do;
				%do j=1 %to &numgroups;
					%if &&group&j=&maxgroup %then
					%put %upcase(&group) &j has the maximum distinct occurences of variable %upcase(&val) = &maxgroup;
				%end;
			%end;
		%end;
	%end;
	%else %put There is no pair of variables %upcase(&group) and %upcase(&val) found in library %upcase(&lib);
%mend;
%howmany(work,group,val);

/* Exercise 13.8 */
%macro ex_13_8(lib);
	proc sql noprint;
		SELECT memname
		INTO :sets separated by ' '
		FROM dictionary.tables
		WHERE libname="%upcase(&lib)";
	run;
	%let numsets = %sysfunc(countw(&sets));
	%do i=1 %to &numsets;
		%let set = %sysfunc(scan(&sets, &i));
		proc sql noprint;
			SELECT name
			INTO :varset&i separated by ' '
			FROM dictionary.columns
			WHERE libname="%upcase(&lib)" AND memname="%upcase(&set)";
		run;
	%end;
	%let commonvar=;
	%do i=1 %to &numsets;
		%let var = %sysfunc(countw(&&varset&i));
		%do j=1 %to &var;
			%let el = %sysfunc(scan(&&varset&i,&j));
			%let var&el = 0;
		%end;
	%end;
	%do i=1 %to &numsets;
		%let var = %sysfunc(countw(&&varset&i));
		%do j=1 %to &var;
			%let el = %sysfunc(scan(&&varset&i,&j));
			%let var&el = %eval(&&var&el+1);
		%end;
	%end;
	%let var = %sysfunc(countw(&&varset1));
	%do j=1 %to &var;
		%let el = %sysfunc(scan(&&varset1,&j));
		%if &&var&el=&numsets %then %let commonvar=&commonvar. &el;
	%end;
	%do i=1 %to &numsets;
		%let set = %sysfunc(scan(&sets, &i));
		proc sort data=&lib..&set out=&lib..&set;
			by &commonvar;
		run;
	%end;
	%put Common variable in library %upcase(&lib) is %upcase(&commonvar);
%mend;
%ex_13_8(lib13);

/* Exercise 13.9 */
%macro ex_13_9(lib);
	proc sql noprint;
		SELECT memname
		INTO :sets separated by ' '
		FROM dictionary.tables
		WHERE libname="%upcase(&lib)";
	run;
	%let numset = %sysfunc(countw(&sets));
	%do i=1 %to &numset;
		%let set = %sysfunc(scan(&sets, &i));
		proc sql noprint;
			SELECT name
			INTO :vars&i separated by ' '
			FROM dictionary.columns
			WHERE libname="%upcase(&lib)" AND memname="%upcase(&set)";
		run;
	%end;
	data set_13_9;
		%do i=1 %to &numset;
			%let numvar = %sysfunc(countw(&&vars&i));
			%do j=1 %to &numvar;
				%let varval = %sysfunc(scan(&&vars&i, &j));
				%let setval = %sysfunc(scan(&sets, &i));
				&varval="&setval";
			%end;
		%end;
		output;
	run;
%mend;
%ex_13_9(work);