pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- heliopause
-- by anthony digirolamo
function split_number_string(s)local a={}local b=split_number_string_start_index
local c=1
for d=1,#s do if sub(s,d,d)==" "then a[b]=sub(s,c,d-1)+0
b+=1
c=d+1 end end
return a end
split_number_string_start_index=0
local e={split_number_string"-1 1 0 ",split_number_string"1 -1 0 ",split_number_string"-1 -1 0 ",split_number_string"1 0 1 ",split_number_string"-1 0 1 ",split_number_string"1 0 -1 ",split_number_string"-1 0 -1 ",split_number_string"0 1 1 ",split_number_string"0 -1 1 ",split_number_string"0 1 -1 ",split_number_string"0 -1 -1 "}e[0]=split_number_string"1 1 0 "split_number_string_start_index=1
damage_colors=split_number_string"7 10 9 8 5 0 "damage_colors2=split_number_string"7 10 9 8 5 0 7 10 9 8 5 0 7 10 9 8 5 0 "star_color_index=0
star_color_monochrome=0
star_colors={split_number_string"10 14 12 13 7 6 ",split_number_string"9 8 13 1 6 5 ",split_number_string"4 2 1 0 5 1 ",split_number_string"7 6 ",split_number_string"6 5 ",split_number_string"5 1 "}darkshipcolors=split_number_string"0 1 2 2 1 5 6 2 4 9 3 13 1 8 9 "dark_planet_colors=split_number_string"0 0 1 1 0 5 5 5 4 5 5 3 1 1 2 1 "function round(d)return flr(d+.5)end
function ceil(f)return-flr(-f)end
function random_plus_to_minus_one()return random_int(3)-1 end
function random_int(g,h)local i=h or 0
return flr(rnd(32767))%(g-i)+i end
function random_angle()return Vector(1):rotate(rnd())end
function format_float(g)return flr(g).."."..flr(g%1*10)end
Vector={}Vector.__index=Vector
function Vector.new(f,j)return setmetatable({x=f or 0,y=j or 0},Vector)end
function Vector:draw_point(k)pset(round(self.x),round(self.y),k)end
function Vector:draw_line(l,k)line(round(self.x),round(self.y),round(l.x),round(l.y),k)end
function Vector:round()self.x=round(self.x)self.y=round(self.y)return self end
function Vector:normalize()local m=self:length()
self.x/=m
self.y/=m
return self end
function Vector:rotate(n)local o=cos(n)local s=sin(n)local f=self.x
local j=self.y
self.x=o*f-s*j
self.y=s*f+o*j
return self end
function Vector:add(l)
self.x+=l.x
self.y+=l.y
return self end
function Vector.__add(p,q)return Vector.new(p.x+q.x,p.y+q.y)end
function Vector.__sub(p,q)return Vector.new(p.x-q.x,p.y-q.y)end
function Vector.__mul(p,q)return Vector.new(p.x*q,p.y*q)end
function Vector.__div(p,q)return Vector.new(p.x/q,p.y/q)end
function Vector:about_equals(l)return round(l.x)==self.x and round(l.y)==self.y end
function Vector:angle()return atan2(self.x,self.y)end
function Vector:length()return sqrt(self.x^2+self.y^2)end
function Vector:scaled_length()return sqrt((self.x/182)^2+(self.y/182)^2)*182 end
function Vector.distance(p,q)return(q-p):length()end
function Vector:clone()return Vector.new(self.x,self.y)end
function Vector:perpendicular()return Vector.new(-self.y,self.x)end
setmetatable(Vector,{__call=function(r,...)return Vector.new(...)end})screen_center=Vector(63,63)Ship={}Ship.__index=Ship
function Ship.new(t,u)local v={npc=false,screen_position=screen_center,sector_position=Vector(),gees=t or 4,turn_rate=u or 8,current_deltav=0,current_gees=0,angle=0,angle_radians=0,heading=90,velocity_angle=0,velocity_angle_opposite=180,velocity=0,velocity_vector=Vector(),orders={}}v.deltav=9.806*v.gees/300
setmetatable(v,Ship)return v end
ship_types={{name="cruiser",shape=split_number_string"3.5 .5 0 -1 .583333 .8125 18 24 "},{name="freighter",shape=split_number_string"3 2 0 -3 .2125 .8125 16 22 "},{name="fighter",shape=split_number_string"1.5 .25 .75 -2 .7 .8 14 18 "}}function Ship:generate_random_ship(w,x,y)self.ship_type=y or ship_types[random_int(#ship_types)+1]local z=self.ship_type.shape
local A=x or rnd()srand(A)local B={}for d=6,15 do add(B,d)end
for d=1,6 do del(B,random_int(16,6))end
local C=0
local D={}local E=w or random_int(z[8]+1,z[7])local F=flr(E/2)local G=Vector(1,z[1])local H=Vector(1,z[2])local I=Vector(1,z[3])local J=Vector(1,z[4])local K=flr(z[5]*E)local L=flr(z[6]*E)for j=1,E do add(D,{})for f=1,F do add(D[j],B[4])end end
local M=G
local N=H
local O=round(E/3)local P=round(F/4)for j=2,E-1 do for f=1,F do local k=B[1]if j>=O+random_plus_to_minus_one()and j<=2*O+random_plus_to_minus_one()then k=B[3]end
if f>=P+random_plus_to_minus_one()and j>=2*O+random_plus_to_minus_one()then k=B[2]end
if F-f<max(0,flr(M.y))then if rnd()<.6 then D[j][f]=k
C=C+1
if D[j-1][f]==B[4]then D[j][f]=darkshipcolors[k]end end end end
if j>=L then N=J elseif j>=K then N=I end
M=M+N
if M.y>0 and j>3 and j<E-1 then for d=1,random_int(round(M.y/4)+1)do D[j][F-d]=5
C=C+2 end end end
local Q=random_int(2)for j=E,1,-1 do for f=F-Q,1,-1 do add(D[j],D[j][f])end end
self.hp=C
self.max_hp=C
self.hp_percent=1
self.sprite_rows=E
self.sprite_columns=#D[1]self.transparent_color=B[4]self.sprite=D
return self end
function nearest_planet()local R
local S=32767
for T in all(thissector.planets)do if T.planet_type then local U=Vector.distance(playership.sector_position/182,T.sector_position/182)if U<S then S=U
R=T end end end
return R,S*182 end
function land_at_nearest_planet()local R,S=nearest_planet()if S<R.radius*1.4 then if playership.velocity<.5 then thissector:reset_planet_visibility()landed_front_rendered=false
landed_back_rendered=false
landed_planet=R
landed=true
landed_menu()draw_rect(128,128,0) else notifications:add("moving too fast to land")end else notifications:add("too far to land")end
return false end
function takeoff()thissector:reset_planet_visibility()playership:set_position_near_object(landed_planet)landed=false
return false end
function Ship:set_position_near_object(V)local W=V.radius or V.sprite_rows
self.sector_position=random_angle()*1.2*W+V.sector_position
self:reset_velocity()end
function Ship:clear_target()self.target_index=nil
self.target=nil end
function clear_targeted_ship_flags()for X in all(npcships)do X.targeted=false end end
function next_hostile_target()local Y
for d=1,#npcships do next_ship_target()if playership.target.hostile then break end end
return true end
function next_ship_target()clear_targeted_ship_flags()playership.target_index=(playership.target_index or#npcships)%#npcships+1
playership.target=npcships[playership.target_index]playership.target.targeted=true
return true end
function next_object_target()clear_targeted_ship_flags()return true end
function Ship:targeted_color()if self.hostile then return 8,2 else return 11,3 end end
function Ship:draw_sprite_rotated()local Z=self.screen_position
local p=self.angle_radians
local E=self.sprite_rows
local F=self.sprite_columns
local _=self.transparent_color
if self.targeted then circ(Z.x,Z.y,E,self:targeted_color())end
local a0={}for a1 in all(projectiles)do if Vector.distance(a1.position,Z)<E then add(a0,a1)end end
local a2
for j=1,F do for f=1,E do local k=self.sprite[f][j]if k~=_ and k~=nil then local a3=Vector(E-f-flr(E/2),j-flr(F/2)-1)local a4=Vector(a3.x+1,a3.y)a3:rotate(p):add(Z):round()a4:rotate(p):add(Z):round()if self.hp<1 then local a5=random_angle()add(particles,Circle.new(a3,a5*rnd(.5),k,#damage_colors2-3,a5*E*.5+a3))add(particles,Spark.new(a3,random_angle()*(rnd(.25)+.25),k,128)) else for a1 in all(a0)do if a1.ship~=self and(a3:about_equals(a1.position)or a3:about_equals(a1.position2))then a2=a1.ship
add(particles,Circle.new(a3,random_angle(),k,#damage_colors-3))if rnd()<.5 then add(particles,Spark.new(a3,random_angle()*(2*rnd()+1),k,128))end
self.hp-=1
self.hp_percent=self.hp/self.max_hp
del(projectiles,a1)k=-random_int(#damage_colors)break end end
if k<=0 then if-k<#damage_colors then k=-k+1
self.sprite[f][j]=-k
k=damage_colors[k] else k=5 end end
rectfill(a3.x,a3.y,a4.x,a4.y,k)end end end end
if a2 then self.last_hit_time=secondcount
self.last_hit_attacking_ship=a2 end end
function Ship:turn_left()self:rotate(self.turn_rate)end
function Ship:turn_right()self:rotate(-self.turn_rate)end
function Ship:rotate(a6)self.angle=(self.angle+a6)%360
self.angle_radians=self.angle/360
self.heading=(450-self.angle)%360 end
function Ship:draw()local a7=11
if self.hp_percent<=.3 then a7=9 end
if self.hp_percent<=.1 then a7=8 end
print_shadowed(self:hp_string(),0,0,a7,darkshipcolors[a7])print_shadowed(10*self.velocity.." pixels/s",0,7)if self.accelerating then print_shadowed(self.current_gees.."gS",0,14)end
local a8=self.screen_position
local a9=self.target
if a9 then if not a9:is_visible(self.sector_position)then local U=(a9.screen_position/182-a8/182):normalize()local aa=U*(self.sprite_rows/2+4)+a8
local ab=U*(self.sprite_rows/2+14)+a8
local k,ac=a9:targeted_color()aa:draw_line(ab,k)local ad=format_float((a9.screen_position-a8):scaled_length())if ab.x>63 then ab:add(Vector(3,-2)) else ab:add(Vector(-4*#ad-1,-2))end
print_shadowed(ad,round(ab.x),round(ab.y),k,ac)end
print_shadowed("target "..a9:hp_string(),0,114)end
self:draw_sprite_rotated()end
function Ship:hp_string()return"hp: "..self.hp.."/"..self.max_hp.." "..round(100*self.hp_percent).."%"end
function Ship:is_visible(ae)local w=self.sprite_rows
local Z=(self.sector_position-ae+screen_center):round()self.screen_position=Z
return Z.x<128+w and Z.x>0-w and Z.y<128+w and Z.y>0-w end
function Ship:update_location()if self.velocity>0.0 then self.sector_position:add(self.velocity_vector)end end
function Ship:reset_velocity()self.velocity_vector=Vector()self.velocity=0 end
function Ship:set_destination(af)self.destination=af.sector_position
self:update_steering_velocity()self.max_distance_to_destination=self.distance_to_destination end
function Ship:flee()self:set_destination(self.last_hit_attacking_ship)self:update_steering_velocity(1)local ag=self.steering_velocity:angle()local ah=(ag+.5)%1
if self.distance_to_destination<55 then self:rotate_towards_heading(ag)self:apply_thrust() else self:full_stop(true)if self.hostile and self.angle_radians<ah+.1 and self.angle_radians>ah-.1 then self:fire_weapon()end end end
function Ship:update_steering_velocity(ai)local aj=ai or-1
local ak=self.sector_position-self.destination
self.distance_to_destination=ak:scaled_length()self.steering_velocity=(ak-self.velocity_vector)*aj end
function Ship:seek()if self.seektime%20==0 then self:set_destination(self.target or playership)end
self.seektime+=1
local al=self.destination-self.sector_position
local ad=al:scaled_length()self.distance_to_destination=ad
local am=ad/50
local an=ad/(self.max_distance_to_destination*.7)*am
local ao=min(an,am)local ak=al*an/ad
self.steering_velocity=ak-self.velocity_vector
if self:rotate_towards_heading(self.steering_velocity:angle())then self:apply_thrust(abs(self.steering_velocity:length()))end
if self.hostile then self:fire_weapon()end end
function Ship:fly_towards_destination()self:update_steering_velocity()if self.distance_to_destination>self.max_distance_to_destination*.9 then if self:rotate_towards_heading(self.steering_velocity:angle())then self:apply_thrust()end else self.accelerating=false
self:reverse_direction()if self.distance_to_destination<=self.max_distance_to_destination*.11 then self:order_done(self.full_stop)end end end
function approach_nearest_planet()local R,S=nearest_planet()playership:approach_object(R)return false end
function Ship:approach_object(ap)local V=ap or thissector.planets[random_int(#thissector.planets)+1]self:set_destination(V)self:reset_orders(self.fly_towards_destination)if self.velocity>0 then add(self.orders,self.full_stop)end end
function Ship:follow_current_order()local aq=self.orders[#self.orders]if aq then aq(self)end end
function Ship:order_done(ar)self.orders[#self.orders]=ar end
function Ship:reset_orders(ar)self.orders={}if ar then add(self.orders,ar)end end
function Ship:cut_thrust()self.accelerating=false
self.current_deltav=self.deltav/3 end
function Ship:wait()if secondcount>self.wait_duration+self.wait_time then self:order_done()end end
function Ship:full_stop()if self.velocity>0 and self:reverse_direction()then self:apply_thrust()if self.velocity<1.2*self.deltav then self:reset_velocity()self:order_done()end end end
function Ship:fire_weapon(as)local at=Vector(1):rotate(self.angle_radians)local au=at*self.sprite_rows/2+self.screen_position
if framecount%3==0 then add(projectiles,MultiCannon.new(au,at*6+self.velocity_vector,12,self))end end
function Ship:apply_thrust(av)self.accelerating=true
if self.current_deltav<self.deltav then 
self.current_deltav+=self.deltav/30
 else self.current_deltav=self.deltav end
local aw=self.current_deltav
if av and aw>av then aw=av end
if self.hp_percent<.15+rnd(.1)-.05 then aw=0 end
self.current_gees=aw*300/9.806
local p=self.angle_radians
local ax=Vector(cos(p)*aw,sin(p)*aw)local ay=self.velocity_vector
local az
ay:add(ax)if ay.x>180 or ay.y>180 then az=ay:scaled_length() else az=ay:length()end
self.velocity_angle=ay:angle()self.velocity_angle_opposite=(self.velocity_angle+0.5)%1
local aA=Vector(1):rotate(p)*-(self.sprite_rows/2)+self.screen_position
if az<.05 then az=0.0
ay=Vector() else add(particles,ThrustExhaust.new(aA,ax*-1.3*self.sprite_rows))end
self.velocity=az
self.velocity_vector=ay end
function Ship:reverse_direction()if self.velocity>0.0 then return self:rotate_towards_heading(self.velocity_angle_opposite)end end
function Ship:rotate_towards_heading(aB)local aC=(aB*360-self.angle+180)%360-180
if aC~=0 then local aD=self.turn_rate*aC/abs(aC)if abs(aC)>abs(aD)then aC=aD end
self:rotate(aC)end
return aC<0.1 and aC>-.1 end
Star={}Star.__index=Star
function Star.new()return setmetatable({position=Vector(),color=7,speed=1},Star)end
function Star:reset(f,j)self.position=Vector(f or random_int(128),j or random_int(128))self.color=random_int(#star_colors[star_color_monochrome+star_color_index+1])+1
self.speed=rnd(0.75)+0.25
return self end
sun_colors={split_number_string"6 14 10 9 13 ",split_number_string"7 8 9 10 12 "}Sun={}Sun.__index=Sun
function Sun.new(W,f,j)local aD=W or 64+random_int(128)local o=random_int(6,1)return setmetatable({screen_position=Vector(),radius=aD,sun_color_index=o,color=sun_colors[2][o],sector_position=Vector(f or 0,j or 0)},Sun)end
function stellar_object_is_visible(V,aE)V.screen_position=V.sector_position-aE+screen_center
return V.screen_position.x<128+V.radius and V.screen_position.x>0-V.radius and V.screen_position.y<128+V.radius and V.screen_position.y>0-V.radius end
function Sun:draw(aE)if stellar_object_is_visible(self,aE)then for d=0,1 do circfill(self.screen_position.x,self.screen_position.y,self.radius-d*3,sun_colors[d+1][self.sun_color_index])end end end
starfield_count=50
Sector={}Sector.__index=Sector
function Sector.new()local aF={seed=random_int(32767),planets={},starfield={}}srand(aF.seed)for d=1,starfield_count do add(aF.starfield,Star.new():reset())end
setmetatable(aF,Sector)return aF end
function Sector:reset_planet_visibility()for T in all(self.planets)do T.rendered_circle=false
T.rendered_terrain=false end end
function Sector:new_planet_along_elipse()local f
local j
local aG
local aH=true
while aH do f=rnd(150)j=sqrt((rnd(35)+40)^2*(1-f^2/(rnd(50)+100)^2))if rnd()<.5 then 
f*=-1
 end
if rnd()<.75 then 
j*=-1
 end
if#self.planets==0 then break end
aG=32767
for T in all(self.planets)do aG=min(aG,Vector.distance(Vector(f,j),T.sector_position/33))end
aH=aG<15 end
return Planet.new(f*33,j*33,(1-Vector(f,j):angle()-.25)%1)end
function Sector:draw_starfield(aI)local aJ
local aK
for aL in all(self.starfield)do aJ=aL.position+aI*aL.speed*-.5
aK=aL.position+aI*aL.speed*.5
local d=star_color_monochrome+star_color_index+1
local aM=#star_colors[d]local aN=1+(aL.color-1)%aM
aL.position:draw_line(aK,star_colors[d+1][aN])aJ:draw_line(aL.position,star_colors[d][aN])end end
function Sector:scroll_starfield(aI)local aO=starfield_count-#self.starfield
for d=1,aO do add(self.starfield,Star.new():reset())end
for aL in all(self.starfield)do aL.position:add(aI*aL.speed*-1)if aO<0 then del(self.starfield,aL)aO=aO+1 elseif aL.position.x>134 then aL:reset(-6) elseif aL.position.x<-6 then aL:reset(134) elseif aL.position.y>134 then aL:reset(false,-6) elseif aL.position.y<-6 then aL:reset(false,134)end end end
function is_offscreen(T,i)local aP=i or 0
local aQ=0-aP
local aR=128+aP
local f=T.position.x
local j=T.position.y
return T.duration<0 or f>aR or f<aQ or j>aR or j<aQ end
MultiCannon={}MultiCannon.__index=MultiCannon
function MultiCannon.new(T,aS,o,aT)local aU=aS:perpendicular():normalize()*(rnd(2)-1)return setmetatable({position=T,position2=T:clone(),particle_velocity=aS+aU,color=o,ship=aT,duration=256},MultiCannon)end
function MultiCannon:draw(aI)self.position:add(self.particle_velocity-aI)self.position2:draw_line(self.position,self.color)self.position2=self.position:clone()
self.duration-=1
 end
Spark={}Spark.__index=Spark
function Spark.new(T,aS,o,U)return setmetatable({position=T,particle_velocity=aS,color=o,duration=U or random_int(7,2)},Spark)end
function Spark:update(aI)self.position:add(self.particle_velocity-aI)
self.duration-=1
 end
function Spark:draw(aI)pset(self.position.x,self.position.y,self.color)self:update(aI)end
Circle={}Circle.__index=Circle
function Circle.new(T,aS,o,U,aV)return setmetatable({position=T:clone(),particle_velocity=aS,color=o,center_position=aV or T:clone(),duration=U},Circle)end
function Circle:draw(aI)local aW=flr(Vector.distance(self.position,self.center_position))for d=aW+3,aW,-1 do local o=damage_colors2[#damage_colors2-3-self.duration+d]if o then circfill(self.center_position.x,self.center_position.y,d,o)end end
self:update(aI)end
setmetatable(Circle,{__index=Spark})ThrustExhaust={}ThrustExhaust.__index=ThrustExhaust
function ThrustExhaust.new(T,aS)return setmetatable({position=T,particle_velocity=aS,duration=0},ThrustExhaust)end
function ThrustExhaust:draw(aI)local o=random_int(11,9)local aS=self.particle_velocity
local aU=aS:perpendicular()*0.7
local aX=aS*(rnd(2)+2)+aU*(rnd()-.5)local aY=self.position+aX
local aa=self.position+aS+aU
local ab=self.position+aS+aU*-1
local aZ=self.position
aa:draw_line(aY,o)ab:draw_line(aY,o)ab:draw_line(aZ,o)aa:draw_line(aZ,o)if rnd()>.4 then add(particles,Spark.new(aY,aI+aX*.25,o))end
self.position:add(aS-aI)
self.duration-=1
 end
function draw_circle(a_,b0,W,b1,k)local b2={}local b3=not b1
local b4=0
local b5=0
local f=-W
local j=0
local b6=2-2*W
while f<0 do b2[1+f*-1]=j
if b3 then b4=f
b5=j end
for d=f,b4 do sset(a_-d,b0+j,k)sset(a_+d,b0-j,k)end
for d=b5,j do sset(a_-d,b0-f,k)sset(a_+d,b0+f,k)end
W=b6
if W<=j then 
j+=1
b6=b6+j*2+1 end
if W>f or b6>j then 
f+=1
b6=b6+f*2+1 end end
b2[1]=b2[2]return b2 end
function draw_moon_at_ycoord(b7,b8,b9,W,ba,b2,bb)local f
local j
local bc
local bd
local be
local d
local bf
local bg
j=W-b7
local bh=abs(j)+1
if bh<=#b2 then f=flr(sqrt(W*W-j*j))bc=2*f
if ba<.5 then bd=-b2[bh]be=flr(bc-2*ba*bc-f) else bd=flr(f-2*ba*bc+bc)be=b2[bh]end
for d=bd,be do if not bb or ba<.5 and d>be-2 or ba>=.5 and d<bd+2 then bf=dark_planet_colors[sget(b8+d,b9-j)+1] else bf=0 end
sset(b8+d,b9-j,bf)end end end
perms={}for d=0,255 do perms[d]=d end
for d=0,255 do local aD=random_int(32767)%256
perms[d],perms[aD]=perms[aD],perms[d]end
local bi={}for d=0,255 do local f=perms[d]%12
perms[d+256],bi[d],bi[d+256]=perms[d],f,f end
function GetN_3d(bj,bk,bl,f,j,bm)local a=.6-f*f-j*j-bm*bm
local bn=bi[bj+perms[bk+perms[bl]]]return max(0,a*a*a*a)*(e[bn][0]*f+e[bn][1]*j+e[bn][2]*bm)end
function Simplex3D(f,j,bm)local s=(f+j+bm)*0.333333333
local bj,bk,bl=flr(f+s),flr(j+s),flr(bm+s)local a=(bj+bk+bl)*0.166666667
local bo=f+a-bj
local bp=j+a-bk
local bq=bm+a-bl
bj,bk,bl=band(bj,255),band(bk,255),band(bl,255)local br=GetN_3d(bj,bk,bl,bo,bp,bq)local bs=GetN_3d(bj+1,bk+1,bl+1,bo-0.5,bp-0.5,bq-0.5)local bt,bu,bv,bw,bx,by
if bo>=bp then if bp>=bq then bt,bu,bv,bw,bx,by=1,0,0,1,1,0 elseif bo>=bq then bt,bu,bv,bw,bx,by=1,0,0,1,0,1 else bt,bu,bv,bw,bx,by=0,0,1,1,0,1 end else if bp<bq then bt,bu,bv,bw,bx,by=0,0,1,0,1,1 elseif bo<bq then bt,bu,bv,bw,bx,by=0,1,0,0,1,1 else bt,bu,bv,bw,bx,by=0,1,0,1,1,0 end end
local bz=GetN_3d(bj+bt,bk+bu,bl+bv,bo+0.166666667-bt,bp+0.166666667-bu,bq+0.166666667-bv)local bA=GetN_3d(bj+bw,bk+bx,bl+by,bo+0.333333333-bw,bp+0.333333333-bx,bq+0.333333333-by)return 32*(br+bz+bA+bs)end
function create_planet_type(bB,bC,bD,bE,bF,bG,bH,bI)return{class_name=bB,noise_octaves=bC,noise_zoom=bD,noise_persistance=bE,transparent_color=bI or 14,minimap_color=bF,full_shadow=bH or"yes",color_map=bG}end
planet_types={create_planet_type("tundra",5,.5,.6,6,split_number_string"7 6 5 4 5 6 7 6 5 4 3 "),create_planet_type("desert",5,.35,.3,9,split_number_string"4 4 9 9 4 4 9 9 4 4 9 9 11 1 9 4 9 9 4 9 9 4 9 9 4 9 9 4 9 "),create_planet_type("barren",5,.55,.35,5,split_number_string"5 6 5 0 5 6 7 6 5 0 5 6 "),create_planet_type("lava",5,.55,.65,4,split_number_string"0 4 0 5 0 4 0 4 9 8 4 0 4 0 5 0 4 0 "),create_planet_type("gas giant",1,.4,.75,2,split_number_string"7 6 13 1 2 1 12 "),create_planet_type("gas giant",1,.4,.75,8,split_number_string"7 15 14 2 1 2 8 8 ",nil,12),create_planet_type("gas giant",1,.7,.75,10,split_number_string"15 10 9 4 9 10 "),create_planet_type("terran",5,.3,.65,11,split_number_string"1 1 1 1 1 1 1 13 12 15 11 11 3 3 3 4 5 6 7 ","partial shadow"),create_planet_type("island",5,.55,.65,12,split_number_string"1 1 1 1 1 1 1 1 13 12 15 11 3 ","partial shadow")}Planet={}Planet.__index=Planet
function Planet.new(f,j,ba,aD)local bJ=planet_types[random_int(#planet_types)+1]local bK=bJ.noise_factor_vert or 1
if bJ.class_name=="gas giant"then bJ.min_size=50
bK=4
if rnd()<.5 then bK=20 end end
local bL=bJ.min_size or 10
local W=aD or random_int(65,bL)return setmetatable({screen_position=Vector(),radius=W,sector_position=Vector(f,j),bottom_right_coord=2*W-1,phase=ba,planet_type=bJ,noise_factor_vert=bK,noisedx=rnd(1024),noisedy=rnd(1024),noisedz=rnd(1024),rendered_circle=false,rendered_terrain=false,color=bJ.minimap_color},Planet)end
function Planet:draw(aE)if stellar_object_is_visible(self,aE)then self:render_a_bit_to_sprite_sheet()sspr(0,0,self.bottom_right_coord,self.bottom_right_coord,self.screen_position.x-self.radius,self.screen_position.y-self.radius)end end
function draw_rect(bM,bN,o)for f=0,bM-1 do for j=0,bN-1 do sset(f,j,o)end end end
function Planet:render_a_bit_to_sprite_sheet(bO,bP)local W=self.radius-1
if bO then W=47 end
if not self.rendered_circle then self.width=self.radius*2
self.height=self.radius*2
self.x=0
self.yfromzero=0
self.y=W-self.yfromzero
self.phi=0
thissector:reset_planet_visibility()pal()palt(0,false)palt(self.planet_type.transparent_color,true)if bO then self.width=114
self.height=96
draw_rect(self.width,self.height,0) else draw_rect(self.width,self.height,self.planet_type.transparent_color)self.bxs=draw_circle(W,W,W,true,0)draw_circle(W,W,W,false,self.planet_type.minimap_color)end
self.rendered_circle=true end
if not self.rendered_terrain and self.rendered_circle then local bQ=0
local bR=.5
local bS=bR/self.width
if bO and bP then bQ=.5
bR=1 end
if self.phi<=.25 then for bT=bQ,bR-bS,bS do if sget(self.x,self.y)~=self.planet_type.transparent_color then local bU=self.planet_type.noise_zoom
local bV=0
local bW=1
local bX=0
for g=1,self.planet_type.noise_octaves do bX=bX+Simplex3D(self.noisedx+bU*cos(self.phi)*cos(bT),self.noisedy+bU*cos(self.phi)*sin(bT),self.noisedz+bU*sin(self.phi)*self.noise_factor_vert)bV=bV+bW
bW=bW*self.planet_type.noise_persistance
bU=bU*2 end
bX=bX/bV
if bX>1 then bX=1 end
if bX<-1 then bX=-1 end
bX=bX+1
bX=bX*(#self.planet_type.color_map-1)/2
bX=round(bX)sset(self.x,self.y,self.planet_type.color_map[bX+1])end
self.x+=1
 end
if not bO then draw_moon_at_ycoord(self.y,W,W,W,self.phase,self.bxs,self.planet_type.full_shadow=="yes")end
self.x=0
if self.phi>=0 then 
self.yfromzero+=1
self.y=W+self.yfromzero
self.phi+=.5/(self.height-1) else
 self.y=W-self.yfromzero end
self.phi*=-1
 else self.rendered_terrain=true end end
return self.rendered_terrain end
function add_npc(T)local bY=T or playership
local bZ=Ship.new(2,4):generate_random_ship()bZ:set_position_near_object(bY)bZ.npc=true
if bZ.ship_type.name~="freighter"and rnd()<.2 then bZ.hostile=true end
add(npcships,bZ)end
function load_sector()thissector=Sector.new()notifications:cancel_all()notifications:add("arriving in system ngc "..thissector.seed)add(thissector.planets,Sun.new())for d=0,random_int(12)do add(thissector.planets,thissector:new_planet_along_elipse())end
playership:set_position_near_object(thissector.planets[2])playership:clear_target()npcships={}for T in all(thissector.planets)do for d=1,random_int(4)do add_npc(T)end end
return true end
function _init()paused=false
landed=false
particles={}projectiles={}notifications=Notification.new()playership=Ship.new()playership:generate_random_ship()load_sector()setup_minimap()end
minimap_sizes={16,32,48,128,false}function setup_minimap(w)minimap_size_index=w or 0
minimap_size=minimap_sizes[minimap_size_index+1]if minimap_size then minimap_size_halved=minimap_size/2
minimap_offset=Vector(126-minimap_size_halved,minimap_size_halved+1)end end
function draw_minimap_planet(V)local bY=V.sector_position+screen_center
if V.planet_type then bY:add(Vector(-V.radius,-V.radius))end
bY=bY/minimap_denominator+minimap_offset
if minimap_size>100 then local aD=ceil(V.radius/32)circ(bY.x,bY.y,aD+1,V.color) else bY:draw_point(V.color)end end
function draw_minimap_ship(V)local b_=(V.sector_position/minimap_denominator):add(minimap_offset):round()if V.npc then b_:draw_point(V:targeted_color())if V.targeted then circ(b_.x,b_.y,2,V:targeted_color())end else rect(b_.x-1,b_.y-1,b_.x+1,b_.y+1,15)end end
function draw_minimap()if minimap_size then if minimap_size<100 then rectfill(126-minimap_size,1,126,minimap_size+1,0)rect(125-minimap_size,0,127,minimap_size+2,6,11)end
local f=abs(playership.sector_position.x)local j=abs(playership.sector_position.y)if j>f then f=j end
local c0=min(6,flr(f/5000)+1)minimap_denominator=c0*5000/minimap_size_halved
for T in all(thissector.planets)do draw_minimap_planet(T)end
if framecount%2==1 then for X in all(npcships)do draw_minimap_ship(X)end
draw_minimap_ship(playership)end end end
outlined_text_draw_points=split_number_string"-1 -1 1 -1 -1 1 -1 0 1 0 0 -1 0 1 "function print_shadowed(c1,f,j,k,c2,c3)local o=k or 6
local s=c2 or 5
if c3 then for d=1,#outlined_text_draw_points,2 do print(c1,f+outlined_text_draw_points[d],j+outlined_text_draw_points[d+1],s)end end
print(c1,f+1,j+1,s)print(c1,f,j,o)end
Notification={}Notification.__index=Notification
function Notification.new()return setmetatable({messages={},display_time=4},Notification)end
function Notification:add(c1)add(self.messages,c1)end
function Notification:cancel_current()del(self.messages,self.messages[1])self.display_time=4 end
function Notification:cancel_all(c1)if c1 then del(self.messages,c1) else self.messages={}end
self.display_time=4 end
function Notification:draw()if#self.messages>0 then print_shadowed(self.messages[1],0,121)if framecount==29 then 
self.display_time-=1
 end
if self.display_time<1 then self:cancel_current()end end end
function call_option(d)if current_option_callbacks[d]then local c4=current_option_callbacks[d]()paused=false
if c4==nil then paused=true elseif c4 then display_menu(nil,nil,d)if type(c4)=="string"then print_shadowed(c4,64-round(4*#c4/2),40,11,0,true)end
paused=true end end end
function display_menu(c5,c6,c7)if c5 then current_options=c5
current_option_callbacks=c6 end
if not landed then render_game_screen()end
local aV=Vector(64,90)local c8=aV+Vector(-1,2)for p=.25,1,.25 do local d=p*4
local c9=6
local ca=0
if c7==d then c9=11 end
local T=Vector(8):rotate(p)+c8
T:draw_line(Vector(3):rotate(p)+c8,c9)T:draw_line(Vector(5,2):rotate(p)+c8,c9)T:draw_line(Vector(5,-2):rotate(p)+c8,c9)if current_options[d]then T=Vector(14):rotate(p)+aV
if p==.5 then T:add(Vector(-4*#current_options[d])) elseif p~=1 then T:add(Vector(round(-4*#current_options[d]/2)))end
print_shadowed(current_options[d],T.x,T.y,c9,ca,true)end end end
function main_menu()display_menu({"autopilot","debug","display options","systems"},{function()display_menu({"nearest planet","full stop","back","follow"},{approach_nearest_planet,function()playership:reset_orders(playership.full_stop)return false end,main_menu,function()playership:reset_orders(playership.seek)playership.seektime=0
return false end})end,function()display_menu({"new ship","spawn enemy","new sector","back"},{function()s=max((s+1)%48,8)playership:generate_random_ship(s)return playership.ship_type.name.." "..s end,function()add_npc()npcships[#npcships].hostile=true
return"npc created"end,load_sector,main_menu})end,function()display_menu({"back","starfield","minimap size"},{main_menu,function()display_menu({"more stars","~dimming","less stars","~colors"},{function()
starfield_count+=5
return"star count: "..starfield_count end,function()star_color_index=(star_color_index+1)%2
return true end,function()starfield_count=max(0,starfield_count-5)return"star count: "..starfield_count end,function()star_color_monochrome=(star_color_monochrome+1)%2*3
return true end})end,function()setup_minimap((minimap_size_index+1)%#minimap_sizes)return true end})end,function()display_menu({"target next hostile","back","land","target next"},{next_hostile_target,main_menu,land_at_nearest_planet,next_ship_target})end})end
function landed_menu()display_menu({"takeoff"},{takeoff})end
local cb=0
local cc={}for d=1,96 do cc[d]={flr(-sqrt(-sin(d/193))*48+64)}cc[d][2]=(64-cc[d][1])*2 end
for d=0,95 do poke(64*d+56,peek(64*d+0x1800))end
local cd={}for d=0,15 do cd[d]={(cos(0.5+0.5/16*d)+1)/2}cd[d][2]=(cos(0.5+0.5/16*(d+1))+1)/2-cd[d][1]end
function shift_sprite_sheet()for d=0,95 do poke(64*d+0x1838,peek(64*d))memcpy(64*d,64*d+1,56)memcpy(64*d+0x1800,64*d+0x1801,56)poke(64*d+56,peek(64*d+0x1800))end end
function landed_update()local T=landed_planet
if not landed_front_rendered then landed_front_rendered=T:render_a_bit_to_sprite_sheet(true)if landed_front_rendered then T.rendered_circle=false
T.rendered_terrain=false
for ce=1,56 do shift_sprite_sheet()end end else if not landed_back_rendered then landed_back_rendered=T:render_a_bit_to_sprite_sheet(true,true) else cb=1-cb
if cb==0 then shift_sprite_sheet()end end end end
function render_landed_screen()cls()if landed_front_rendered and landed_back_rendered then for d=1,96 do local p,q=cc[d][1],cc[d][2]pal()local cf=ceil(q*cd[15][2])for ce=15,0,-1 do if ce==4 then for cg=0,#dark_planet_colors-1 do pal(cg,dark_planet_colors[cg+1])end end
if ce<15 then cf=flr(p+q*cd[ce+1][1])-flr(p+q*cd[ce][1])end
sspr(cb+ce*7,d-1,7,1,flr(p+q*cd[ce][1]),d+16,cf,1)end end
pal()print_shadowed("planet class: "..landed_planet.planet_type.class_name,1,1,7,5,true) else sspr(0,0,127,127,0,0)print_shadowed("mapping surface...",1,1,7,5,true)end end
s=8
framecount=0
secondcount=0
function _update()framecount=(framecount+1)%30
if framecount==0 then 
secondcount+=1
 end
if not landed and btnp(4,0)then paused=not paused
if paused then main_menu()end end
if landed then landed_update()end
if paused or landed then if btnp(2)then call_option(1)end
if btnp(0)then call_option(2)end
if btnp(3)then call_option(3)end
if btnp(1)then call_option(4)end else if btn(0,0)then playership:turn_left()end
if btn(1,0)then playership:turn_right()end
if btn(3,0)then playership:reverse_direction()end
if btn(5,0)then playership:fire_weapon()end
if btn(2,0)then playership:apply_thrust()if playership.current_deltav<playership.deltav then camera(random_int(2)-1,random_int(2)-1) else camera()end else if playership.accelerating and not playership.orders[1]then camera()playership:cut_thrust()end end
for X in all(npcships)do if X.last_hit_time and X.last_hit_time+30>secondcount then X:reset_orders()X:flee() else if#X.orders==0 then if X.hostile then X.seektime=0
add(X.orders,X.seek) else X:approach_object()X.wait_duration=random_int(46,10)X.wait_time=secondcount
add(X.orders,X.wait)end end
X:follow_current_order()end
X:update_location()if X.hp<1 then del(npcships,X)playership:clear_target()end end
playership:follow_current_order()playership:update_location()thissector:scroll_starfield(playership.velocity_vector)end end
function render_game_screen()cls()thissector:draw_starfield(playership.velocity_vector)for ch in all(thissector.planets)do ch:draw(playership.sector_position)end
for X in all(npcships)do if X:is_visible(playership.sector_position)then X:draw_sprite_rotated()end end
if playership.hp<1 then playership:generate_random_ship()end
playership:draw()for ci in all(particles)do if is_offscreen(ci)then del(particles,ci) else ci:draw(playership.velocity_vector)end end
for a1 in all(projectiles)do if is_offscreen(a1,63)then del(projectiles,a1) else a1:draw(playership.velocity_vector)end end
draw_minimap()notifications:draw()end
function _draw()if landed then render_landed_screen()display_menu() elseif not paused then render_game_screen()end end
__gfx__
77d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777777777760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
