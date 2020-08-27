libname exam '/folders/myfolders/sasuser.v94/E1';
/* Enggar Dwi Prihastomo */
/* enggardprihastomo@gmail.com */


* ********************************** ;
/* TASK 1 */
%macro a(lib, extset);
	data _null_;
		set &lib..&extset nobs=numobs;
		call symput(cat('set',_n_), set);
		call symput(cat('var',_n_), var);
		call symput(cat('val',_n_), val);
		call symput('numobs', numobs);
	run;
	%do i=1 %to &numobs;
		data &&set&i;
			&&var&i=&&val&i;
		run;
	%end;
%mend;
%a(exam,a);

* ********************************** ;
/* TASK 2 */
data _null_;
	set exam.b1-exam.b3 end=last;
	retain count 0;
	if x=lag(x) and abs(date-lag(date))=1 then count+1;
	if last then do;
		put count=;
	end;
run;

* ********************************** ;
/* TASK 3 */
data task3;
	set exam.c end=last;
	array years(2012:2020) _TEMPORARY_ (9*0);
	array ids(9) _TEMPORARY_ (9*0);
	array maxim(9) _TEMPORARY_ (9*0);
	array sales(*) s:;
	if years(year)=0 then do;
		ids(year-lbound(years)+1)=id;
		years(year) = sum(of sales(*));
		maxim(year-lbound(years)+1)=max(of sales(*));
	end;
	else do;
		if years(year)<sum(of sales(*)) then do;
			ids(year-lbound(years)+1)=id;
			years(year) = sum(of sales(*));
			maxim(year-lbound(years)+1)=max(of sales(*));
		end;
	end;
	if last then do;
		do i=lbound(years) to hbound(years);
			year=i;
			id=ids(i-lbound(years)+1);
			sum_transaction = years(i);
			max_transaction = maxim(i-lbound(years)+1);
			output;
		end;
	end;
	keep year id sum_transaction max_transaction;
run;