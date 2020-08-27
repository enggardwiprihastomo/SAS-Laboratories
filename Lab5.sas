libname lab5 "/folders/myfolders/sasuser.v94/lab5";

/* Exercise 5.1 */
data ex_5_1;
	set lab5.a;
	by x;
	retain max;
	if first.x then do;
		max = 0;
	end;
	diff = abs(u-lag(u));
	if max<diff then max=diff;
	if last.x then do;
		output;
	end;
	keep x max;
run;

/*data ex_5_2;
	set lab5.b;
	by x;
	array maxval(10)(10*0);
	array valys(*) y1-y10;
	if first.x then do i=1 to dim(maxval);
		maxval(i) = valys(i);
	end;
	do i=1 to dim(maxval);
		if maxval(i) < valys(i) then maxval(i) = valys(i);
	end;
	if last.x then output;
	keep x maxval:;
run;
*/

/* Exercise 5.2 */
data ex_5_2;
	set lab5.b;
	by x;
	array maxval(10)(10*0);
	array valy(*) y:;
	if first.x then do;
		do i=1 to dim(maxval);
			maxval(i)=0;
		end;
	end;
	do i=1 to dim(maxval);
		idx=0;
		do j=1 to dim(maxval);
			if maxval(i)<valy(j) then do;
				idx=j;
				maxval(i)=valy(j);
			end;
		end;
		if idx^=0 then valy(idx)=0;
	end;
	if last.x then output;
	keep x maxval:;
run;

/* Exercise 5.3 */
data ex_5_3;
	set lab5.c;
	by x;
	array ys(*) y1-y10;
	array fillys(10);
	array countval(10);
	array sumval(10);
	array meanval(10);
	array y_tmp(5,10) _temporary_;
	if first.x then do;
		do i=1 to dim(ys);
			countval(i) = 0;
			sumval(i) = 0;
			meanval(i) = 0;
		end;
		k=0;
	end;
	k+1;
	do i=1 to dim(ys);
		if ys(i)^=. then do;
			countval(i)+1;
			sumval(i)+ys(i);
		end;
		y_tmp(k,i) = ys(i);
	end;
	if last.x then do;
		do i=1 to dim(ys);
			meanval(i) = sumval(i)/countval(i);
		end;
		do i=1 to 5;
			do j=1 to dim(ys);
				if y_tmp(i,j)=. then fillys(j)=meanval(j);
				else fillys(j)=y_tmp(i,j);
			end;
			output;
		end;
	end;
	keep x fillys:;
run;

/* Exercise 5.4 */
data ex_5_4;
	set lab5.values;
	count = 1;
	val=0;
	do while(val^=_nil_);
		val = scan(x,count,", ");
		count+1;
		if val^=_nil_ then output;
	end;
	keep val;
run;

/* Exercise 5.5 */
proc sort data=lab5.alert_client out=alert_clients;
	by client_id descending alert_date;
run;

data ex_5_5a;
	set alert_clients;
	by client_id;
	retain alert__id alert__date;
	format alert__date date9.;
	diff = abs(lag(alert_date)-alert_date);
	if first.client_id then do;
		alert__date=0;
		alert__id=0;
	end;
	else do;
		if diff<2*365 then do;
			alert__date=alert_date;
			alert__id=alert_id;
		end;
	end;
	if last.client_id and alert__id^=0 then output;
	keep alert__id client_id alert__date;
run;

data ex_5_5b;
	set lab5.alert_client;
	array lastdate(500) _temporary_;
	array outputed(500) _temporary_;
	if lastdate(client_id-1000)=. then lastdate(client_id-1000)=alert_date;
	else 
		if lastdate(client_id-1000)-alert_date<2*365 and outputed(client_id-1000)=. then do;
			output;
			outputed(client_id-1000)=1;
		end;
		else lastdate(client_id-1000)=alert_date;
run;

/* Exercise 5.6 */
data ex_5_6;
	set lab5.d;
	format date date9.;
	array values(*) y1-y12;
	do i=1 to 12;
		date=mdy(i,1,year);
		y=values(i);
		output;
	end;
	keep date y;
run;

/* Exercise 5.7 */
data ex_5_7;
	set ex_5_6;
	year=year(date);
	array z(12) y1-y12 (12*0);
	z(month(date))=	y;
	if month(date)=12 then output;
	drop y date;
run;