sets
i /1*500/
sc /1*1000/
scs(sc)
;

sets
np /1*1000/
m /1*2/
;

parameters
sm(m)
fm(m)
ls
fs
;

alias(i,ip);

parameters
j /197/
ij(i)
cap(i)
mtp /0.2/
d(i)
dsc(sc,i)
cogs(i)
mm(i)
p(sc)
;

$onecho > inputs.txt
par=ij  rng=ij!    rdim=1 cdim=0
par=sm  rng=sm!    rdim=1 cdim=0
par=fm  rng=fm!    rdim=1 cdim=0
par=cap  rng=cap!    rdim=1 cdim=0
par=d  rng=d!    rdim=1 cdim=0
par=dsc  rng=dsc!    rdim=1 cdim=1
par=cogs  rng=cogs!    rdim=1 cdim=0
par=mm  rng=mm!    rdim=1 cdim=0
par=p  rng=p!    rdim=1 cdim=0
$offecho

$call GDXXRW.EXE inputs.xlsx  @inputs.txt
$GDXIN inputs.gdx
$load ij,cap,d,dsc,cogs,mm,p,sm,fm
$GDXIN

positive variables
s(i)
a(sc,i)
u(sc,i)
l(sc,i)
o(sc,i,ip)
;

variables
z
zn
;

equations
c1
c1n
c2
c3
c4_1
c4_2
c5
c6
c7
c8
c4_1m
c4_2m
c5m
c6m
c7m
c8m
;

c1..
z =e= sum((i,sc), p(sc)*mm(i)*a(sc,i)) - sum(i, (s(i) + d(i)) * cogs(i))
;
c1n..
zn =e= sum((i,scs), p(scs)*mm(i)*a(scs,i)) - sum(i, (s(i) + d(i)) * cogs(i))
;

c2(i)..
s(i) + d(i) =l= cap(i)
;

c3..
sum(i,s(i)) =l= mtp * sum(i, d(i))
;

c4_1(i,sc)..
a(sc,i) =l= s(i) + d(i)
;
c4_1m(i,scs)..
a(scs,i) =l= s(i) + d(i)
;

c4_2(i,sc)..
a(sc,i) =l= dsc(sc,i)
;
c4_2m(i,scs)..
a(scs,i) =l= dsc(scs,i)
;

c5(sc,i)..
l(sc,i) =g= s(i) - dsc(sc,i)
;
c5m(scs,i)..
l(scs,i) =g= s(i) - dsc(scs,i)
;

c6(sc,i)..
u(sc,i) =g= dsc(sc,i) - s(i)
;
c6m(scs,i)..
u(scs,i) =g= dsc(scs,i) - s(i)
;

c7(sc,i)..
l(sc,i) =e= sum(ip$(ij(ip) = ij(i)), o(sc,ip,i))
;
c7m(scs,i)..
l(scs,i) =e= sum(ip$(ij(ip) = ij(i)), o(scs,ip,i))
;

c8(sc,i)..
u(sc,i) =e= sum(ip$(ij(ip) = ij(i)), o(sc,i,ip))
;
c8m(scs,i)..
u(scs,i) =e= sum(ip$(ij(ip) = ij(i)), o(scs,i,ip))
;

model sales
/
c1
c2
c3
c4_1
c4_2
c5
c6
c7
c8
/
;

model sample
/
c1n
*c2
*c3
*c4_1m
*c4_2m
*c5m
*c6m
*c7m
*c8m
/
;

parameters
obj(m)
;

loop(m,

scs(sc) = no;

ls = sm(m);
fs = fm(m);

scs(sc)$(ord(sc)>ls - 1 and ord(sc) < fs +1) = yes;

solve sample using mip max zn;
obj(m) = zn.l

display
scs
ls
fs
zn.l
s.l
a.l
;

);

display
obj
;


