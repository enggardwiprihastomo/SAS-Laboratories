libname lab8 "/folders/myfolders/sasuser.v94/lab8";

/* Exercise 8.1 */
data _null_;
	set lab8.z1 end=last;
	set lab8.z2(rename=(x=x2));
	if x^=x2 then count+1;
	if last then put count "different rows found";
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
/* Solution 1 (Dynamic code)*/
data ex_8_4;
	set lab8.dots(rename=(z1-z3=sz1-sz3));
	array z(3)(3*.);
	array tmpz(*) sz1-sz3;
	array temp(3) _temporary_;
	do i=1 to dim(tmpz);
		if tmpz(i)^=. and z(i)=. then z(i)=tmpz(i);
		else if tmpz(i)^=. and z(i)^=. then temp(i)=tmpz(i);
	end;
	if nmiss(of z(*))=0 then do;
		output;
		do i=1 to dim(z);
			z(i)=.;
			if temp(i)^=. then do;
				z(i)=temp(i);
				temp(i)=.;
			end;
		end;
	end;
	format z: 1.;
	keep z:;
run;

/* Solution 2 (Static code)*/
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
			if nmiss(of z(*))=0 then do;
				output;
			end;
		end;
	end;
	keep z:;
run;

/* Exercise 8.6 */
data ex_8_6;
	set lab8.a;
	retain firstrow;
	by x;
	if first.x then firstrow=_n_;
	count+1;
	if last.x then do;
		if count>5 then do;
			do i=firstrow to _n_;
				set lab8.a point=i;
				output;
			end;
		end;
		count=0;
	end;
	drop firstrow;
run;

/* Exercise 8.7 */
/* Solution 1 (Without merge) */
data ex_8_7;
	set lab8.zb1(rename=(x=xx1)) lab8.zb2(rename=(x=xx2)) lab8.zb3(rename=(x=xx3)) lab8.zb4(rename=(x=xx4)) lab8.zb5(rename=(x=xx5));
	by date;
	array x(5)(5*.);
	if xx1^=. then x(1)=xx1;if xx2^=. then x(2)=xx2;if xx3^=. then x(3)=xx3;if xx4^=. then x(4)=xx4;if xx5^=. then x(5)=xx5;
	if last.date then do;
		output;
		do i=1 to dim(x);
			x(i)=.;
		end;
	end;
	keep date x1-x5;
run;

/* Solution 2 (With merge) */
data ex_8_7;
	merge lab8.zb1(rename=(x=x1)) lab8.zb2(rename=(x=x2)) lab8.zb3(rename=(x=x3)) lab8.zb4(rename=(x=x4)) lab8.zb5(rename=(x=x5));
	by date;
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