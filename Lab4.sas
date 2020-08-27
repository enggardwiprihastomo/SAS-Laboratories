libname lab4 "/folders/myfolders/sasuser.v94/lab4";

/* Exercise 4.1 */
data ex_4_1a;
	set lab4.survey;
	array data(*) question:;
	array answer(*) A B C;
	do i=1 to dim(answer);
		answer(i)=0;
	end;
	do i=1 to dim(data);
		answer(rank(data(i))-64)+1;
	end;
	keep A B C;
run;

data ex_4_1b;
	set lab4.survey end=last;
	array data(*) question:;
	array answer(*) A B C (3*0);
	do i=1 to dim(data);
		answer(rank(data(i))-64)+1;
	end;
	if last then output;
	keep A B C;
run;

data ex_4_1c;
	set lab4.survey end=last;
	array data(*) question:;
	array tmp(10,3) _temporary_;
	array answer(3) A B C;
	do i=1 to dim(data);
		tmp(i,rank(data(i))-64)+1;
	end;
	if last then do;
		do i=1 to dim(data);
			do j=1 to 3;
				answer(j)=tmp(i,j);
			end;
			output;
		end;
	end;
	keep A B C;
run;

/* Exercise 4.2 */
data ex_4_2a;
	set lab4.a;
	array ys(10) y1-y10;
	array xs(*) x:;
	do i=1 to l;
		ys(i)=xs(ceil(10*ranuni(0)));
	end;
	keep y:;
run;

data ex_4_2b;
	set lab4.a;
	array ys(10);
	array xs(*) x:;
	do i=1 to l;
		u = .;
		do while(u=.);
			v=ceil(10*ranuni(0));
			u=xs(v);
			xs(v)=.;
		end;
		ys(i)=u;
	end;
	keep l y:;
run;

/* Exercise 4.3 */
data ex_4_3;
	array triangle(10)(10*0);
	array tmp(10)_temporary_(10*0);
	do i=1 to dim(triangle);
		do j=1 to dim(triangle);
			tmp(j)=triangle(j);
		end;
		triangle(1)=1;
		do j=2 to i;
			triangle(j)=tmp(j)+tmp(j-1);
		end;
		output;
	end;
	keep triangle:;
run;

/* Exercise 4.4 */
data ex_4_4a;
	array z(100);
	do i=1 to dim(z);
		z(i)=2*ranuni(0) - 1;
	end;
	keep z:;
run;

data ex_4_4b;
	set ex_4_4a;
	array pz(10)p1-p10(10*0);
	array zs(*) z:;
	do i=1 to dim(zs);
		count+1;
		pz(count)=zs(i);
		if count=10 then do;
			count=0;
			output;
		end;
	end;
	keep p:;
run;

data ex_4_4c;
	set ex_4_4b end=last;
	array pz(*) p1-p10;
	array tmp(100) _temporary_;
	count=0;
	do i=(10*(_n_-1))+1 to 10*_n_;
		count+1;
		tmp(i)=pz(count);
	end;
	if last then do;
		i=0;
		do while(i<25);
			random=ceil(100*ranuni(0));
			if tmp(random)^=. then do;
				tmp(random)=.;
				i+1;
			end;
		end;
		do i=1 to 10;
			do j=1 to 10;
				pz(j)=tmp(10*(i-1)+j);
			end;
		output;
		end;
	end;
	keep p:;
run;

/* Exercise 4.5 */
data ex_4_5;
	set lab4.a;
	array cols(*) x: l;
	array sort(11)(11*0);
	do i=1 to dim(cols);
		do j=1 to dim(cols)-1;
			if(cols(j)>cols(j+1)) then do;
				tmp=cols(j);
				cols(j)=cols(j+1);
				cols(j+1)=tmp;
			end;
		end;
	end;
	do i=1 to dim(sort);
		sort(i)=cols(i);
	end;
	keep sort:;
run;

/* Exercise 4.6 */
data ex_4_6;
	set lab4.conversion;
	dates=mdy(input(scan(date,1,"."),2.), input(scan(date,3,"."),2.), input(scan(date,2,"."),4.));
	x=char(code, index(code,"x")+2);
	substr(number, index(number,"x"),1)=x;
	z=char(code, index(code,"z")+2);
	substr(number, index(number,"z"),1)=z;
	number=input(number,8.0);
	format dates ddmmyy8.;
	keep number dates;
run;

/* Exercise 4.7 */
data ex_4_7;
	set lab4.binsys;
	array binary(*) b1-b9;
	dec = 0;
	k=0;
	do i=9 to 1 by -1;
		if binary(i) ^= . then do;
			if binary(i) then dec + (2**k);
			k+1;
		end;
	end;
	keep dec;
run;

data ex_4_8a;
	set lab4.xa;
	array taba(*) $ a1-a5;
	array tabx(*) x1-x5;
	array u(5);
	do i=1 to 5;
		if taba(i)^=lag(taba(i)) then u(i)=1;
		else u(i)=0;
	end;
	drop i;
run;

data ex_4_8b;
	set ex_4_8a end=last;
	array v(5);
	array u(5) u:;
	do i=1 to 5;
		v(i)=u(i);
	end;
	if _n_>1 then output;
	
	if last then do i=1 to 5;
		v(i)=1;	
		if i=5 then output;
	end;
	keep v:;
run;

data ex_4_8c;
	set ex_4_8a end=last;
	set ex_4_8b;
	length a $ 2;
	array avgx_tmp(5) _temporary_ (5*0);
	array v(5) v:;
	array xx(5) x:;
	array avgxp(5,5) _temporary_;
	array k(5) _temporary_ (5*0);
	array whichgroup(5) _temporary_ (5*0);
	array means_group(5) avgx_1-avgx_5 (5*0);
	do i=1 to 5;
		avgx_tmp(i)=avgx_tmp(i)+xx(i);
		k(i)=k(i)+1;
		if v(i)=1 then do;
			avgx_tmp(i)= avgx_tmp(i)/k(i);
			whichgroup(i)+1;
			avgxp(i, whichgroup(i))=avgx_tmp(i);
			k(i)=0;
			avgx_tmp(i)=0;
		end;
	end;
	if last then do i=1 to 5;
		a=catt("A", i);
		do j=1 to 5;
			means_group(j)=avgxp(j,i);
		end;
		output;
	end;
	keep a avgx_1-avgx_5;
run;

data ex_4_9a;
	set lab4.a;
	array tab(*) x1-x10;
	array sort(10);
	do i=10 to 1 by -1;
		do j=1 to 9;
			if tab(j)>tab(j+1) then do;
				temp = tab(j);
				tab(j)=tab(j+1);
				tab(j+1)=temp;
			end;
		end;
	end;
	do i=1 to 10;
		sort(i)=tab(i);
	end;
	keep sort:;
run;

data ex_4_9b;
	set ex_4_9a;
	sr=mean(sort8,sort9,sort10);
	keep sr;
run;

/* Exercise 4.10 */
data ex_4_10;
	set lab4.a1;
	length coordinate $ 8;
	array tab(*) r1-r4;
	do i=1 to 4;
		if tab(i)=. then do;
			coordinate = catt("r",_n_,".c",i);
			output;
		end;
	end;
	keep coordinate;
run;