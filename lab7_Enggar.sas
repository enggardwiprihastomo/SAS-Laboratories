libname lab7 "/folders/myfolders/sasuser.v94/lab7";

/* Exercise 7.1 */
data ex_7_1_data;
array z(10);
	count=0;
	do i=1 to 20;
		do j=1 to 10;
			count+1;
			z(j)=count;
		end;
		output;
	end;
	keep z:;
run;

data ex_7_1;
	set ex_7_1_data end=last;
	array tmp(10,20) _temporary_;
	array trans_z(20);
	array z(*) z:;
	do i=1 to 10;
		tmp(i,_n_)=z(i);
	end;
	if last then do;
		do i=1 to 10;
			do j=1 to 20;
				trans_z(j)=tmp(i,j);
			end;
			output;
		end;
	end;
	keep trans_z:;
run;

/* Exercise 7.2 */
proc transpose data=lab7.z1 out=z2(drop=_name_);
	where dat ^= .;
	by art;
	id dat;
run;

/* Exercise 7.4c */
proc sql;
	title "Exercise 7.4C";
	SELECT * FROM (
		SELECT * FROM (
			SELECT *, COUNT(*) AS occurences FROM lab7.a GROUP BY x,y
		)
		GROUP BY x HAVING y=MIN(y)
	)
	WHERE occurences=1;
quit;

/* Exercise 7.4d */
proc sql;
	title "Exercise 7.4D";
	SELECT x FROM (
		SELECT DISTINCT x, occurences FROM (
			SELECT *, COUNT(*) AS occurences FROM lab7.a GROUP BY x,y
		)
		GROUP BY x HAVING occurences=MAX(occurences)
	)
	WHERE occurences=1;
quit;

/* Exercise 7.4e */
proc sql;
	title "Exercise 7.4E";
	SELECT x FROM (
	SELECT x, COUNT(*) as occurences FROM (
		SELECT DISTINCT * FROM lab7.a
		)
	GROUP BY x
	)
	HAVING occurences=MAX(occurences);
quit;

/* Exercise 7.4f */
proc sql;
	SELECT x FROM(
		SELECT x, min, max, count(*) AS count FROM(
			SELECT x, count(*), min, max FROM (
				SELECT *, MIN(y) AS min, MAX(y) AS max FROM lab7.a GROUP BY x
			) GROUP BY x, y, min, max
		) GROUP BY x, min, max
	) WHERE min=1 AND max=count;
quit;

/* Exercise 7.4g */
proc sql;
	title "Exercise 7.4G";
	SELECT x FROM (
		SELECT x, MIN(y) AS min, MAX(y) AS max, COUNT(DISTINCT y) AS count FROM lab7.a GROUP BY x
	) WHERE min=1 AND max=count;
quit;

/* Exercise 7.4h */
proc sql;
	title "Exercise 7.4H";
	SELECT y FROM(
		SELECT DISTINCT *, COUNT(DISTINCT x)/2 as halfx FROM lab7.a
	)
	GROUP BY y HAVING COUNT(*)>halfx;
quit;

/* Exercise 7.5a */
proc sql;
	title "Exercise 7.5A";
	SELECT DISTINCT id FROM lab7.z3 WHERE id NOT IN (
		SELECT DISTINCT id FROM lab7.z3 WHERE year<1993
	);
quit;

/* Exercise 7.5b */
/* Solution 1 */
proc sql;
	title "Exercise 7.5B";
	SELECT DISTINCT id FROM lab7.z3 WHERE id IN (
		SELECT DISTINCT id FROM lab7.z3 WHERE year IN (
			SELECT MIN(year) FROM lab7.z3
		)
	)
	AND year IN (
		SELECT MAX(year) FROM lab7.z3
	);
quit;
/* Solution 2 */
proc sql;
	title "Exercise 7.5B";
	SELECT DISTINCT id FROM lab7.z3 HAVING year=MIN(year)
	INTERSECT
	SELECT DISTINCT id FROM lab7.z3 HAVING year=MAX(year);
quit;

/* Exercise 7.5c */
proc sql;
	title "Exercise 7.5C";
	SELECT DISTINCT id FROM z3 primary WHERE NOT EXISTS(
		SELECT DISTINCT year FROM z3
		EXCEPT
		SELECT DISTINCT year FROM z3 WHERE id=primary.id);
quit;

/* Exercise 7.6a */
proc sql;
	title "Exercise 7.6A";
	SELECT a1, x1 FROM lab7.b primary WHERE x1 BETWEEN (
		SELECT MIN(x2) FROM lab7.b WHERE a2=primary.a1 GROUP BY a2
	) AND (
		SELECT MAX(x2) FROM lab7.b WHERE a2=primary.a1 GROUP BY a2
	);
quit;

/* Exercise 7.6b */
proc sql;
	title "Exercise 7.6B";
	SELECT letter, SUM(count1,count2) AS sum FROM (
		SELECT a1 AS letter, COUNT(a1) AS count1, (
				SELECT COUNT(a2) FROM lab7.b WHERE a2=primary.a1
		) AS count2 FROM lab7.b primary GROUP BY a1
	)
	HAVING MAX(SUM(count1,count2))=SUM(count1,count2);
quit;

/* Exercise 7.7a */
proc sql;
	title "Exercise 7.7A";
	SELECT * FROM (
		SELECT DISTINCT MONTH(day) AS month, COUNT(*) AS occurences FROM lab7.c WHERE r2=. GROUP BY MONTH(day)
	)
	HAVING occurences=MAX(occurences);
quit;

/* Exercise 7.7b */
proc sql;
	title "Exercise 7.7B";
	SELECT * FROM (
		SELECT DISTINCT MONTH(day) AS month, STD(r1) AS stddev FROM lab7.c GROUP BY MONTH(day)
	)
	HAVING stddev=MAX(stddev);
quit;
