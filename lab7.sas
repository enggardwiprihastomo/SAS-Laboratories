libname lab7 "/folders/myfolders/sasuser.v94/lab7";

data a;
	input x y z;
	cards;
	1 2 3
	4 5 6
	7 8 9
	;
run;

proc transpose data=a out=b name=Variable_Names;
run;

data a;
	input x y z;
	label x='label "X"'y='label "Y"' z='label "Z"';
	cards;
	1 2 3
	4 5 6
	7 8 9
	;
run;

proc transpose data=a out=b name=names label=labels;
run;

proc transpose data=a out=b(drop = names labels) name=names label=labels;
run;

proc transpose data=a out=b name=names label=labels;
	
run;

data a;
	input x $ y z $;
	label x='label "X"'y='label "Y"' z='label "Z"';
	cards;
	a 1 c
	d 2 f
	g 3 i
	;
run;

proc transpose data=a out=b name=names label=labels;
	format x $1. y best32. z $1.;
	var _all_;
run;

data a;
	infile datalines delimiter='|';
	input merk $ : 10. model $ : 20. engine power color $;
	datalines;
	BMW|BMW X6 M|4.6|230|Black
	Toyota|BMW X6 Mantap|4.6|230|Black
	Volvo|BMW X6 M|4.6|230|Black
	Ferrari|BMW X6 M|4.6|230|Black
	Audi|BMW X6 M|4.6|230|Black
	Honda|BMW X6 M|4.6|230|Black
	;
run;

proc transpose data=a out=b name=specs label=labels prefix=merk_ suffix=_car;
	id merk;
	idlabel model;
	var _all_;
run;

proc transpose data=a out=b name=specs label=labels prefix=merk_ suffix=_car let; *let is to omit error when there are more than one variable with the same name in the dataset;
	id merk;
	idlabel model;
	var _all_;
run;

data a;
	infile datalines;
	input year brand $ price;
	datalines;
	2011 BMW 250000
	2011 Toyota 130000
	2011 Audi 460000
	2012 Ford 280000
	2012 Renault 210000
	2012 Honda 180000
	2013 Nisan 195000
	2013 Fiat 620000
	;
run;

proc transpose data=a out=b name=specs;
	by year;
	var brand price;
run;

proc sort data=a out=a;
	by year brand;
run;

proc transpose data=a out=b name=specs;
	by year brand;
	var price;
run;

proc transpose data=a out=b name=specs;
	by year;
	id brand;
	var price;
run;


data a;
	set lab7.a end=last;
	output;
	if last then do;
		x='F';
		y=1;
		output;
	end;
run;


data a;
	set lab7.a end=last;
	output;
	if last then do;
		x='F';
		y=1;
		output;
		x='E';
		y=3;
		output;
	end;
run;

data z3;
	set lab7.z3 end=last;
	output;
	if last then do;
		do year='1996','1997','2001','2002';
			id=001;
			output;
		end;
	end;
run;