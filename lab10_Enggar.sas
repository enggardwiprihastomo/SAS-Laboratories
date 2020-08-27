libname lab10 "/folders/myfolders/sasuser.v94/lab10";

/* Exercise 10.3 */
/* This part is enough to answer exercise 10.3 */
proc means data=stat noprint;
	output out=ex_10_3(drop=_type_ _freq_) median=q1=q3=qrange=/autoname;
run;

/* But, to display the result in a neater form, here I applied this code */
proc transpose data=ex_10_3 out=ex_10_3;
run;

data ex_10_3;
	format varname $ 2.;
	set ex_10_3 end=last;
	array amedian(5)_temporary_;
	array aq1(5)_temporary_;
	array aq3(5)_temporary_;
	array ainquartile_range(5)_temporary_;
	if substr(_name_,1,1) = 'z' then count+1;
	if substr(_name_,4) = 'Median' then amedian(count)=col1;
	if substr(_name_,4) = 'Q1' then aq1(count)=col1;
	if substr(_name_,4) = 'Q3' then aq3(count)=col1;
	if substr(_name_,4) = 'QRange' then ainquartile_range(count)=col1;
	if count=5 then count=0;
	if last then do;
		do i=1 to dim(amedian);
			varname=catt('z', i);
			median=amedian(i);
			q1=aq1(i);
			q3=aq3(i);
			inquartile_range=ainquartile_range(i);
			output;
		end;
	end;
	drop _name_ i count col1;
run;
	
/* Exercise 10.4 */
/* Generation of informat */
data ex_10_4;
	fmtname="@longdatetosasdate";
	do label = 0 to today();
		start = trim(left(put(label,worddate.)));
		output;
	end;
	format label date9.;
run;

proc format cntlin=ex_10_4;
run;

/* Result */
data ex_10_4;
input in_date longdatetosasdate.;
format in_date ddmmyy10.;
datalines;
May 15, 2020
;
run;

/* Exercise 10.5 */
proc means data=lab10.grades mean maxdec=2 nway noprint;
	class student code;
	var grade;
	output out=ex_10_5(drop=_type_ _freq_) mean=mean;
run;

proc transpose data=ex_10_5 out=ex_10_5(drop=_name_);
	by student;
	id code;
run;

/* Exercise 10.6 */
proc means data=lab10.data mean noprint;
	class group;
	output out=ex_10_6(drop=_type_ _freq_) mean=/autoname;
run;

data ex_10_6;
	retain closest_group global_x global_y local_x local_y mindistance;
	set ex_10_6 end=last;
	if _n_=1 then do;
		global_x=x_mean;
		global_y=y_mean;
	end;
	else if _n_=2 then do;
		mindistance = abs(global_x-x_mean) + abs(global_y-y_mean);
		closest_group = group;
	end;
	else do;
		distance=abs(global_x-x_mean) + abs(global_y-y_mean);
		if mindistance>distance then do;
			mindistance=distance;
			local_x=x_mean;
			local_y=y_mean;
			closest_group=group;
		end;
	end;
	if last then output;
	keep closest_group global_x global_y local_x local_y mindistance;
run;

/* Exercise 10.7 */
/* Generation of function */
proc fcmp outlib=work.functions.ex_10_7;
	function numtoword(num) $;
		length result $ 20;
 		array words[10]$ ('Zero' 'One' 'Two' 'Three' 'Four' 'Five' 'Six' 'Seven' 'Eight' 'Nine');
		if substr(put(num, 3.1),3,1) = 0 then do;
			result = words[substr(put(num, 3.1),1,1)+1];
		end;
		else do;	
			result=catx(' point ', words[substr(put(num, 3.1),1,1)+1], words[substr(put(num, 3.1),3,1)+1]);
		end;
		return (result);
	endsub;
run;

/* Result */
options cmplib=(work.functions);
data ex_10_7;
	do i=0 to 9.9 by 0.1;
		result=numtoword(i);
		output;
	end;
run;

/* Exercise 10.8 */
/* Generation of data */
data ex_10_8;
	do i=1 to 100;
		x=ceil(50*ranuni(0));
		output;
	end;
	keep x;
run;

proc means data=ex_10_8 noprint;
	output out=ex_10_8a(drop=_type_ _freq_) median=qrange=/autoname;
run;

/* Generation of function */
proc fcmp outlib=work.functions.ex_10_8;
	function outliers(x, med,range, alpha) $;
		length result $ 15;
		if (med-alpha*range)<=x and (med+alpha*range)>=x then result=cat('Within Range');
		else result='Outside Range';
		return (result);
	endsub;
run;

/* Result */
options cmplib=(work.functions);
data ex_10_8b;
	pt=1;
	set ex_10_8;
	set ex_10_8a point=pt;
	status=outliers(x, x_median,x_qrange, 1);
	keep x status;
run;