libname lab6 "/folders/myfolders/sasuser.v94/lab6";

/* Exercise 6.2 */
data ex_6_2;
	length selected_side $ 8;
	pt=1;
	node=1; selected_side='Root';
	output;
	do while(pt^=.);
		set lab6.tree point=pt;
		side = round(ranuni(0));
		if side then do;
			pt=right;
			node=right;
			selected_side='Right';
		end;
		else do;
			pt=left;
			node=left;
			selected_side='Left';
		end;
		if pt^=. then output;
	end;
	stop;
	keep node selected_side;
run;

/* Exercise 6.4 */
data ex_6_4;
	retain startdate dif;
	infile "/folders/myfolders/sasuser.v94/lab6/experiment.txt" truncover;
	format date ddmmyy8. startdate ddmmyy8.;
	input date yymmdd8. result status $;
	if status='START' then do;
		startdate=date;
		dif=result;
	end;
	if status='STOP' then do;
		result=abs(result-dif);
		duration_days=date-startdate;
		output;
	end;
	keep duration_days result;
run;

/* Exercise 6.6 */
data ex_6_6;
	retain tmpdate;
	length tmpperson $ 9;
	format id 8. date mmddyy10. person $4.;
	array amounts(2) _temporary_;
	infile "/folders/myfolders/sasuser.v94/lab6/fileC.txt" missover;
	input id tmpperson $ amounts(1) :comma. amounts(2) :comma. date mmddyy10.;
	if date then tmpdate=date;
	else date=tmpdate;
	do i=1 to 2;
		person=scan(tmpperson, i, '/');
		amount=amounts(i);
		output;
	end;
	keep id date person amount; 
run;

/* Exercise 6.7 */
data ex_6_7;
	length id $ 5;
	infile "/folders/myfolders/sasuser.v94/lab6/fileD.txt";
	input @;
	tmp=_infile_;
	count = countw(tmp, ' ');
	id=scan(tmp, 1, ' ');
	x=input(scan(tmp, count-1, ' '), 2.);
	keep id x;
run;

/* Exercise 6.8 */
data ex_6_8;
	format k1-k10 2.;
	u=1;
	infile "/folders/myfolders/sasuser.v94/lab6/p.txt" truncover;
	input #1 k1-k10;
	put _all_;
	if _n_=1 then do;
		array ks(*) k:;
		array temp(10) _temporary_;
		do i=1 to 10;
			temp(i)=ks(i);
		end;
	end;
	do i=1 to dim(temp);
		u=temp(i);
		if u^=. then do;	
			input #u k1-k10;
			output;
		end;
		else leave;
	end;
	input #10 k1-k10;
	drop u i;
run;

/* Exercise 6.9 */
data ex_6_9;
	format val1-val3 1.;
	infile "/folders/myfolders/sasuser.v94/lab6/gaps.txt" dlm='. ' truncover;
	input val1-val3;
run;

/* Exercise 6.10 */
data ex_6_10;
	infile "/folders/myfolders/sasuser.v94/lab6/blocks.txt" truncover;
	input year (val1-val12)(2.);
	retain r2004-r2007;
	array vals(*) val:;
	array temp(4,12) _temporary_;
	if year=2004 then do;
		r2004=1;
		do i=1 to 12;
			temp(1,i)=vals(i);
		end;
	end;
	else if year=2005 then do;
		r2005=1;
		do i=1 to 12;
			temp(2,i)=vals(i);
		end;
	end;
	else if year=2006 then do;
		r2006=1;
		do i=1 to 12;
			temp(3,i)=vals(i);
		end;
	end;
	else do;
		r2007=1;
		do i=1 to 12;
			temp(4,i)=vals(i);
		end;
	end;
	if r2004 and r2005 and r2006 and r2007 then do;
		do i=1 to 12;
			r2004=temp(1,i);r2005=temp(2,i);r2006=temp(3,i);r2007=temp(4,i);
			output;
		end;
		r2004=0;r2005=0;r2006=0;r2007=0;
	end;
	keep r200:;
run;