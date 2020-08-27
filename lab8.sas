libname lab8 "/folders/myfolders/sasuser.v94/lab8";
/* Exercise 8.1 */
data _null_;
	set lab8.z1 end=last;
	set lab8.z2(rename=(x=x2));
	if x^=x2 then count+1;
	if last then put count "different rows found";
run;

/* Exercise 8.2 */
data ex_8_2;
	set lab8.large end=last;
	do i=1 to num;
		set lab8.small(rename=(id=id1)) point=i nobs=num;
		if id=id1 then do;
			k+1;
			mean+sales;
		end;
	end;
	if last then do;
		mean=mean/k;
		output;
	end;
	keep mean;
run;

/* Exercise 8.3 */
data ex_8_3;
	set lab8.numbers end=last;
	set lab8.large point=nr;
	mean+sales;
	count+1;
	if last then do;
		mean=mean/count;
		output;
	end;
	keep mean;
run;

/* Exercise 8.4 */
/* Solution 1 (Without need to know number of observations)*/
data ex_8_4;
	set lab8.dots;
	array zval(3)(3*.);
	array temp(3) _temporary_;
	array z(*) z1-z3;
	do i=1 to dim(z);
		if z(i)^=. and zval(i)=. then zval(i)=z(i);
		else if z(i)^=. and zval(i)^=. then temp(i)=z(i);
	end;
	if zval(1)^=. and zval(2)^=. and zval(3)^=. then do;
		output;
		do i=1 to dim(z);
			zval(i)=.;
			if temp(i)^=. then do;
				zval(i)=temp(i);
				temp(i)=.;
			end;
		end;
	end;
	format zval: 1.;
	keep zval:;
run;

/* Solution 2 (Have to know number of observations)*/
data ex_8_4;
	set lab8.dots end=last;
	array zval(100,3) _temporary_ ;
	array count(3)(3*0);
	array z(*) z1-z3;
	do i=1 to dim(z);
		if z(i)^=. then do;
			count(i)+1;
			zval(count(i),i)=z(i);
		end;
	end;
	if last then do;
		do i=1 to dim1(zval);
			do j=1 to dim2(zval);
				z(j)=zval(i,j);
			end;
			if z(1)^=. and z(2)^=. and z(3)^=. then output;
		end;
	end;
	keep z:;
run;

/* Exercise 8.5 */
data numbers;
	do i=1 to 50;
		u=floor(5*ranuni(0));
		output;
	end;
	keep u;
run;

data ex_8_5a;
	set numbers;
	array tmp(5) _temporary_;
	if _n_<=dim(tmp) then tmp(_n_)=u;
	else do;
		do i=1 to dim(tmp)-1;
			tmp(i)=tmp(i+1);
		end;
		tmp(dim(tmp))=u;
	end;
	
	if _n_>=dim(tmp) then do;
		sum=sum(of tmp(*));
		output;
	end;
	
	keep sum;
run;

data ex_8_5b;
	array xx(5) x1-x5;
	do i=1 to 50;
		set numbers point=i;
		if i<=5 then do;
			xx(i)=u;
			sum=sum(of x1-x5);
		end;
		else do;
			sum=sum-xx(1);
			do j=1 to 4;
				xx(j)=xx(j+1);
			end;
			xx(dim(xx))=u;
			sum+u;
		end;
		if i>=dim(xx) then output;
	end;
	keep sum;
	stop;
run;

/* Exercise 8.6 */
data ex_8_6;
	set lab8.a;
	retain firstrow lastrow;
	by x;
	if first.x then do;
		firstrow=_n_;
		count=0;
	end;
	count+1;
	if last.x then do;
		lastrow=_n_;
		if count>5 then do;
			do i=firstrow to lastrow;
				set lab8.a point=i;
				output;
			end;
		end;
	end;
	drop firstrow lastrow;
run;

/* Exercise 8.7 */
data ex_8_7;
	set lab8.zb1-lab8.zb5;
run;

proc sort data=ex_8_7 out=result;
	by date;
run;

/* Exercise 8.8 */
data ex8_8_1;
set lab8.jan (in=wj) lab8.feb (in=wf) lab8.mar (in=wm);
if wj=1 then d=1;
if wf=1 then d=2;
if wm=1 then d=3;
run;

proc sort data=ex8_8_1 out=ex8_8_2;
by person d;
run;

data ex8_8;
set ex8_8_2;
by person;
if last.person then output;
keep person result;
run;

/* Exercise 8.9 */
data ex_8_9;
	set lab8.zxy;
	do i=1 to numobsx;
		set lab8.zx(rename=(x=xc)) point=i nobs=numobsx;
		if x=xc then do;
			checkx=1;
			leave;
		end;
	end;
	do i=1 to numobsy;
		set lab8.zy(rename=(y=yc)) point=i nobs=numobsy;
		if y=yc then do;
			checky=1;
			leave;
		end;
	end;
	if checkx and checky then output;
	keep x y;
run;