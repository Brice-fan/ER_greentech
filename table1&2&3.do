/*==================================================
              table 1 & 2: Summary, CDtest and Moran's I
==================================================*/
cd "/Users/fanbing/OneDrive - mail.nankai.edu.cn/working paper/SpatialEcon/Working_data"
use Final_panel,clear
*----------1.1: Summary
eststo clear
eststo: estpost sum lngp_all lngup lngip lnER1 lnper_gdp lnRDi fiscal fdi
esttab using summary.tex,replace cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") ///
label nonumber nomtitles noobs

*----------1.2: CD test

xtset _ID year
xtreg lngp_all ER1,fe
predict res,residual
xtcd res
xtcd2 res,histogram


*----------1.3: Moran test for green patents
spatwmat using W1.dta,name(W1) standardize
spatwmat using W2.dta,name(W2) standardize
spatwmat using W3.dta,name(W3) standardize

use Final_panel.dta,clear
//W1
forvalues i = 2005/2016{
	preserve
	keep if year == `i'
	qui spatgsa lngp_all,weights(W1) moran twotail
	mat moran_`i' = r(Moran)
	restore
}
mat moran_gp = (moran_2005\moran_2006\moran_2007\moran_2008\moran_2009\moran_2010\moran_2011\moran_2012\moran_2013\moran_2014\moran_2015\moran_2016)
mat rownames moran_gp = 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016
mat colnames moran_gp = Green_patents_W1 mean sd z p-value
mat list moran_gp
mat moran_gp = moran_gp[1..12,1]

//W2
forvalues i = 2005/2016{
	preserve
	keep if year == `i'
	qui spatgsa lngp_all,weights(W2) moran twotail
	mat moran_`i' = r(Moran)
	restore
}
mat temp = (moran_2005\moran_2006\moran_2007\moran_2008\moran_2009\moran_2010\moran_2011\moran_2012\moran_2013\moran_2014\moran_2015\moran_2016)
mat moran_gp = (moran_gp,temp)
mat rownames moran_gp = 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016
mat colnames moran_gp = Green_patents_W1 Green_patents_W2 mean sd z p-value
mat list moran_gp
mat moran_gp = moran_gp[1..12,1..2]

//W3
forvalues i = 2005/2016{
	preserve
	keep if year == `i'
	qui spatgsa lngp_all,weights(W3) moran twotail
	mat moran_`i' = r(Moran)
	restore
}
mat temp = (moran_2005\moran_2006\moran_2007\moran_2008\moran_2009\moran_2010\moran_2011\moran_2012\moran_2013\moran_2014\moran_2015\moran_2016)
mat moran_gp = (moran_gp,temp)
mat rownames moran_gp = 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016
mat colnames moran_gp = Green_patents_W1 Green_patents_W2 Green_patents_W3 mean sd z p-value
mat list moran_gp
mat moran_gp = moran_gp[1..12,1..3]

mat list moran_gp
*----------1.4: Moran test for ER
//W1
use Final_panel.dta,clear
forvalues i = 2005/2016{
	preserve
	keep if year == `i'
	qui spatgsa ER1,weights(W1) moran twotail
	mat moran_`i' = r(Moran)
	restore
}
mat moran_er = (moran_2005\moran_2006\moran_2007\moran_2008\moran_2009\moran_2010\moran_2011\moran_2012\moran_2013\moran_2014\moran_2015\moran_2016)
mat rownames moran_er = 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016
mat colnames moran_er = ER_W1 mean sd z p-value
mat list moran_er
//you may need to record the significant level manually
mat moran_er = moran_er[1..12,1]

//W2
forvalues i = 2005/2016{
	preserve
	keep if year == `i'
	qui spatgsa ER1,weights(W2) moran twotail
	mat moran_`i' = r(Moran)
	restore
}
mat temp = (moran_2005\moran_2006\moran_2007\moran_2008\moran_2009\moran_2010\moran_2011\moran_2012\moran_2013\moran_2014\moran_2015\moran_2016)
mat moran_er = (moran_er,temp)
mat rownames moran_er = 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016
mat colnames moran_er = ER_W1 ER_W2 mean sd z p-value
mat list moran_er
//you may need to record the significant level manually
mat moran_er = moran_er[1..12,1..2]

//W3
forvalues i = 2005/2016{
	preserve
	keep if year == `i'
	qui spatgsa ER1,weights(W3) moran twotail
	mat moran_`i' = r(Moran)
	restore
}
mat temp = (moran_2005\moran_2006\moran_2007\moran_2008\moran_2009\moran_2010\moran_2011\moran_2012\moran_2013\moran_2014\moran_2015\moran_2016)
mat moran_er = (moran_er,temp)
mat rownames moran_er = 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016
mat colnames moran_er = ER_W1 ER_W2 ER_W3 mean sd z p-value
mat list moran_er
//you may need to record the significant level manually
mat moran_er = moran_er[1..12,1..3]

*----------1.5: Export Moran test to txt
mat moran_final = (moran_gp,moran_er)
matlist moran_final
mat2txt, matrix(moran_final) saving(moran_test) replace
