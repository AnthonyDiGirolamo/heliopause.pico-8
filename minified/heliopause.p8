pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- heliopause
-- by anthonydigirolamo
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
function format_float(g)return flr(g).."."..flr(g%1*10)end
Vector={}Vector.__index=Vector
function Vector.new(f,j)return setmetatable({x=f or 0,y=j or 0},Vector)end
function Vector:draw_point(color)pset(round(self.x),round(self.y),color)end
function Vector:draw_line(k,color)line(round(self.x),round(self.y),round(k.x),round(k.y),color)end
function Vector:draw_circle(l,color,m)local n=circ
if m then n=circfill end
n(round(self.x),round(self.y),round(l),color)end
function Vector:round()self.x=round(self.x)self.y=round(self.y)return self end
function Vector:normalize()local o=self:length()
self.x/=o
self.y/=o
return self end
function random_angle(p)return rotated_vector(rnd(),p)end
function rotated_vector(q,f,j)return Vector(f or 1,j):rotate(q)end
function Vector:rotate(r)local t=cos(r)local s=sin(r)local f=self.x
local j=self.y
self.x=t*f-s*j
self.y=s*f+t*j
return self end
function Vector:add(k)
self.x+=k.x
self.y+=k.y
return self end
function Vector.__add(u,v)return Vector.new(u.x+v.x,u.y+v.y)end
function Vector.__sub(u,v)return Vector.new(u.x-v.x,u.y-v.y)end
function Vector.__mul(u,v)return Vector.new(u.x*v,u.y*v)end
function Vector.__div(u,v)return Vector.new(u.x/v,u.y/v)end
function Vector:about_equals(k)return round(k.x)==self.x and round(k.y)==self.y end
function Vector:angle()return atan2(self.x,self.y)end
function Vector:length()return sqrt(self.x^2+self.y^2)end
function Vector:scaled_length()return sqrt((self.x/182)^2+(self.y/182)^2)*182 end
function Vector.distance(u,v)return(v-u):length()end
function Vector:tostring()return format_float(self.x)..", "..format_float(self.y)end
function Vector:clone()return Vector.new(self.x,self.y)end
function Vector:perpendicular()return Vector.new(-self.y,self.x)end
setmetatable(Vector,{__call=function(w,...)return Vector.new(...)end})screen_center=Vector(63,63)Ship={}Ship.__index=Ship
function Ship.new(x,y)local z={npc=false,screen_position=screen_center,sector_position=Vector(),gees=x or 4,turn_rate=y or 8,current_deltav=0,current_gees=0,angle=0,angle_radians=0,heading=90,velocity_angle=0,velocity_angle_opposite=180,velocity=0,velocity_vector=Vector(),orders={},last_fire_time=0}z.deltav=9.806*z.gees/300
setmetatable(z,Ship)return z end
ship_types={{name="cruiser",shape=split_number_string"3.5 .5 0 -1 .583333 .8125 18 24 "},{name="freighter",shape=split_number_string"3 2 0 -3 .2125 .8125 16 22 "},{name="fighter",shape=split_number_string"1.5 .25 .75 -2 .7 .8 14 18 "}}function Ship:generate_random_ship(A,B,C)self.ship_type=C or ship_types[random_int(#ship_types)+1]local D=self.ship_type.shape
local E=B or rnd()srand(E)local F={}for d=6,15 do add(F,d)end
for d=1,6 do del(F,random_int(16,6))end
local G=0
local H={}local I=A or random_int(D[8]+1,D[7])local J=flr(I/2)local K=Vector(1,D[1])local L=Vector(1,D[2])local M=Vector(1,D[3])local N=Vector(1,D[4])local O=flr(D[5]*I)local P=flr(D[6]*I)for j=1,I do add(H,{})for f=1,J do add(H[j],F[4])end end
local Q=K
local R=L
local S=round(I/3)local T=round(J/4)for j=2,I-1 do for f=1,J do local color=F[1]if j>=S+random_plus_to_minus_one()and j<=2*S+random_plus_to_minus_one()then color=F[3]end
if f>=T+random_plus_to_minus_one()and j>=2*S+random_plus_to_minus_one()then color=F[2]end
if J-f<max(0,flr(Q.y))then if rnd()<.6 then H[j][f]=color
G=G+1
if H[j-1][f]==F[4]then H[j][f]=darkshipcolors[color]end end end end
if j>=P then R=N elseif j>=O then R=M end
Q=Q+R
if Q.y>0 and j>3 and j<I-1 then for d=1,random_int(round(Q.y/4)+1)do H[j][J-d]=5
G=G+2 end end end
local U=random_int(2)for j=I,1,-1 do for f=J-U,1,-1 do add(H[j],H[j][f])end end
self.hp=G
self.max_hp=G
self.hp_percent=1
self.sprite_rows=I
self.sprite_columns=#H[1]self.transparent_color=F[4]self.sprite=H
return self end
function nearest_planet()local V
local W=32767
for X in all(thissector.planets)do if X.planet_type then local Y=Vector.distance(playership.sector_position/182,X.sector_position/182)if Y<W then W=Y
V=X end end end
return V,W*182 end
function land_at_nearest_planet()local V,W=nearest_planet()if W<V.radius*1.4 then if playership.velocity<.5 then thissector:reset_planet_visibility()landed_front_rendered=false
landed_back_rendered=false
landed_planet=V
landed=true
landed_menu()draw_rect(128,128,0) else notifications:add("moving too fast to land")end else notifications:add("too far to land")end
return false end
function takeoff()thissector:reset_planet_visibility()playership:set_position_near_object(landed_planet)landed=false
return false end
function Ship:set_position_near_object(Z)local l=Z.radius or Z.sprite_rows
self.sector_position=random_angle(1.2*l)+Z.sector_position
self:reset_velocity()end
function Ship:clear_target()self.target_index=nil
self.target=nil end
function clear_targeted_ship_flags()for _ in all(npcships)do _.targeted=false end end
function next_hostile_target(_)local a0=_ or playership
local a1
for d=1,#npcships do next_ship_target(_)if a0.target.hostile then break end end
return true end
function next_ship_target(_,a2)local a0=_ or playership
if a2 then a0.target_index=random_int(#npcships)+1 else a0.target_index=(a0.target_index or#npcships)%#npcships+1 end
a0.target=npcships[a0.target_index]if a0==a0.target then a0.target=playership end
if not _ then clear_targeted_ship_flags()a0.target.targeted=true end
return true end
function Ship:targeted_color()if self.hostile then return 8,2 else return 11,3 end end
function Ship:draw_sprite_rotated(a3)local a4=a3 or self.screen_position
local u=self.angle_radians
local I=self.sprite_rows
local J=self.sprite_columns
local a5=self.transparent_color
if self.targeted then local a6=round(I/2)+4
local a7,a8=self:targeted_color()if a3 then(a4+Vector(1,1)):draw_circle(a6,a8,true)a4:draw_circle(a6,0,true)end
a4:draw_circle(a6,a7)end
local a9={}for aa in all(projectiles)do if aa.firing_ship~=self then if aa.sector_position and a3 and(self.sector_position-aa.sector_position):scaled_length()<=I or Vector.distance(aa.screen_position,a4)<I then add(a9,aa)end end end
local ab
for j=1,J do for f=1,I do local color=self.sprite[f][j]if color~=a5 and color~=nil then local ac=Vector(I-f-flr(I/2),j-flr(J/2)-1)local ad=Vector(ac.x+1,ac.y)ac:rotate(u):add(a4):round()ad:rotate(u):add(a4):round()if self.hp<1 then make_explosion(ac,I/2)if not a3 then add(particles,Spark.new(ac,random_angle(rnd(.25)+.25)+self.velocity_vector,color,128+random_int(32)))end else for aa in all(a9)do local ae=false
if not a3 and(ac:about_equals(aa.screen_position)or aa.position2 and ac:about_equals(aa.position2))then ae=true elseif a3 and aa.last_offscreen_pos and ac:about_equals(aa.last_offscreen_pos)then ae=true end
if ae then ab=aa.firing_ship
local af=aa.damage or 1
self.hp-=af
if af>10 then make_explosion(ac)end
self.hp_percent=self.hp/self.max_hp
add(particles,Circle.new(ac,random_angle(),color,#damage_colors-3))if rnd()<.5 then add(particles,Spark.new(ac,random_angle(2*rnd()+1)+self.velocity_vector,color,128))end
del(projectiles,aa)color=-random_int(#damage_colors)break end end
if color<=0 then if-color<#damage_colors then color=-color+1
self.sprite[f][j]=-color
color=damage_colors[color] else color=5 end end
rectfill(ac.x,ac.y,ad.x,ad.y,color)end end end end
if ab then self.last_hit_time=secondcount
self.last_hit_attacking_ship=ab end end
function Ship:turn_left()self:rotate(self.turn_rate)end
function Ship:turn_right()self:rotate(-self.turn_rate)end
function Ship:rotate(ag)self.angle=(self.angle+ag)%360
self.angle_radians=self.angle/360
self.heading=(450-self.angle)%360 end
function Ship:draw()print_shadowed("prj:"..#projectiles,100,100)print_shadowed("cpu:"..stat(1),100,107)print_shadowed("ram:"..stat(0),100,114)local ah=11
if self.hp_percent<=.3 then ah=9 end
if self.hp_percent<=.1 then ah=8 end
print_shadowed(self:hp_string(),0,0,ah,darkshipcolors[ah])print_shadowed(10*self.velocity.." pixels/sec",0,7)if self.accelerating then print_shadowed(self.current_gees.."gS",0,14)end
self:draw_sprite_rotated()end
function Ship:hp_string()return"hp: "..self.hp.."/"..self.max_hp.." "..round(100*self.hp_percent).."%"end
function Ship:is_visible(ai)local A=round(self.sprite_rows/2)local a4=(self.sector_position-ai+screen_center):round()self.screen_position=a4
return a4.x<128+A and a4.x>0-A and a4.y<128+A and a4.y>0-A end
function Ship:update_location()if self.velocity>0.0 then self.sector_position:add(self.velocity_vector)end end
function Ship:reset_velocity()self.velocity_vector=Vector()self.velocity=0 end
function Ship:predict_sector_position()local aj=self.sector_position:clone()if self.velocity>0 then aj:add(self.velocity_vector*4)end
return aj end
function Ship:set_destination(ak)self.destination=ak.sector_position
self:update_steering_velocity()self.max_distance_to_destination=self.distance_to_destination end
function Ship:flee()self:set_destination(self.last_hit_attacking_ship)self:update_steering_velocity(1)local al=self.steering_velocity:angle()local am=(al+.5)%1
if self.distance_to_destination<55 then self:rotate_towards_heading(al)self:apply_thrust() else self:full_stop(true)if self.hostile and self.angle_radians<am+.1 and self.angle_radians>am-.1 then self:fire_weapon()end end end
function Ship:update_steering_velocity(an)local ao=an or-1
local ap=self.sector_position-self.destination
self.distance_to_destination=ap:scaled_length()self.steering_velocity=(ap-self.velocity_vector)*ao end
function Ship:seek()if self.seektime%20==0 then self:set_destination(self.target or playership)end
self.seektime+=1
local aq=self.destination-self.sector_position
local ar=aq:scaled_length()self.distance_to_destination=ar
local as=ar/50
local at=ar/(self.max_distance_to_destination*.7)*as
local au=min(at,as)local ap=aq*at/ar
self.steering_velocity=ap-self.velocity_vector
if self:rotate_towards_heading(self.steering_velocity:angle())then self:apply_thrust(abs(self.steering_velocity:length()))end
if self.hostile then if ar<128 then self:fire_weapon()self:fire_missile()end end end
function Ship:fly_towards_destination()self:update_steering_velocity()if self.distance_to_destination>self.max_distance_to_destination*.9 then if self:rotate_towards_heading(self.steering_velocity:angle())then self:apply_thrust()end else self.accelerating=false
self:reverse_direction()if self.distance_to_destination<=self.max_distance_to_destination*.11 then self:order_done(self.full_stop)end end end
function approach_nearest_planet()local V,W=nearest_planet()playership:approach_object(V)return false end
function Ship:approach_object(av)local Z=av or thissector.planets[random_int(#thissector.planets)+1]self:set_destination(Z)self:reset_orders(self.fly_towards_destination)if self.velocity>0 then add(self.orders,self.full_stop)end end
function Ship:follow_current_order()local aw=self.orders[#self.orders]if aw then aw(self)end end
function Ship:order_done(ax)self.orders[#self.orders]=ax end
function Ship:reset_orders(ax)self.orders={}if ax then add(self.orders,ax)end end
function Ship:cut_thrust()self.accelerating=false
self.current_deltav=self.deltav/3 end
function Ship:wait()if secondcount>self.wait_duration+self.wait_time then self:order_done()end end
function Ship:full_stop()if self.velocity>0 and self:reverse_direction()then self:apply_thrust()if self.velocity<1.2*self.deltav then self:reset_velocity()self:order_done()end end end
function Ship:fire_missile(ay)if self.target and secondcount>3+self.last_fire_time then self.last_fire_time=secondcount
add(projectiles,HomingWeapon.new(self,self.target))end end
function Ship:fire_weapon(ay)local az=rotated_vector(self.angle_radians)local aA=az*self.sprite_rows/2+self.screen_position
if framecount%3==0 then add(projectiles,MultiCannon.new(aA,az*6+self.velocity_vector,12,self))end end
function Ship:apply_thrust(aB)self.accelerating=true
if self.current_deltav<self.deltav then
self.current_deltav+=self.deltav/30
 else self.current_deltav=self.deltav end
local aC=self.current_deltav
if aB and aC>aB then aC=aB end
if self.hp_percent<.15+rnd(.1)-.05 then aC=0 end
self.current_gees=aC*300/9.806
local u=self.angle_radians
local aD=Vector(cos(u)*aC,sin(u)*aC)local aE=self.velocity_vector
local aF
local aG=rotated_vector(u,self.sprite_rows*-.5)+self.screen_position
add(particles,ThrustExhaust.new(aG,aD*-1.3*self.sprite_rows))aE:add(aD)aF=aE:length()self.velocity_angle=aE:angle()self.velocity_angle_opposite=(self.velocity_angle+0.5)%1
if aF<.05 then aF=0.0
aE=Vector()end
self.velocity=aF
self.velocity_vector=aE end
function Ship:reverse_direction()if self.velocity>0.0 then return self:rotate_towards_heading(self.velocity_angle_opposite)end end
function Ship:rotate_towards_heading(aH)local aI=(aH*360-self.angle+180)%360-180
if aI~=0 then local aJ=self.turn_rate*aI/abs(aI)if abs(aI)>abs(aJ)then aI=aJ end
self:rotate(aI)end
return aI<0.1 and aI>-.1 end
HomingWeapon={}HomingWeapon.__index=HomingWeapon
function HomingWeapon.new(aK,aL)local aM=(aK.angle_radians+.25)%1
return setmetatable({sector_position=aK.sector_position:clone(),screen_position=aK.screen_position:clone(),velocity_vector=rotated_vector(aM,.5)+aK.velocity_vector,velocity=aK.velocity,target=aL,sprite_rows=1,firing_ship=aK,current_deltav=.1,deltav=.1,hp_percent=1,duration=512,damage=20},HomingWeapon)end
function HomingWeapon:draw(aN,a3)local a4=a3 or self.screen_position
self.last_offscreen_pos=a3
self.destination=self.target:predict_sector_position()self:update_steering_velocity()self.angle_radians=self.steering_velocity:angle()if self.duration<500 then self:apply_thrust(abs(self.steering_velocity:length()))end
self.duration-=1
self:update_location()if self:is_visible(playership.sector_position)or a3 then a4:draw_line(a4+rotated_vector(self.angle_radians,4),6)end end
setmetatable(HomingWeapon,{__index=Ship})Star={}Star.__index=Star
function Star.new()return setmetatable({position=Vector(),color=7,speed=1},Star)end
function Star:reset(f,j)self.position=Vector(f or random_int(128),j or random_int(128))self.color=random_int(#star_colors[star_color_monochrome+star_color_index+1])+1
self.speed=rnd(0.75)+0.25
return self end
sun_colors={split_number_string"6 14 10 9 13 ",split_number_string"7 8 9 10 12 "}Sun={}Sun.__index=Sun
function Sun.new(l,f,j)local aJ=l or 64+random_int(128)local t=random_int(6,1)return setmetatable({screen_position=Vector(),radius=aJ,sun_color_index=t,color=sun_colors[2][t],sector_position=Vector(f or 0,j or 0)},Sun)end
function stellar_object_is_visible(Z,aO)Z.screen_position=Z.sector_position-aO+screen_center
return Z.screen_position.x<128+Z.radius and Z.screen_position.x>0-Z.radius and Z.screen_position.y<128+Z.radius and Z.screen_position.y>0-Z.radius end
function Sun:draw(aO)if stellar_object_is_visible(self,aO)then for d=0,1 do self.screen_position:draw_circle(self.radius-d*3,sun_colors[d+1][self.sun_color_index],true)end end end
starfield_count=50
Sector={}Sector.__index=Sector
function Sector.new()local aP={seed=random_int(32767),planets={},starfield={}}srand(aP.seed)for d=1,starfield_count do add(aP.starfield,Star.new():reset())end
setmetatable(aP,Sector)return aP end
function Sector:reset_planet_visibility()for X in all(self.planets)do X.rendered_circle=false
X.rendered_terrain=false end end
function Sector:new_planet_along_elipse()local f
local j
local aQ
local aR=true
while aR do f=rnd(150)j=sqrt((rnd(35)+40)^2*(1-f^2/(rnd(50)+100)^2))if rnd()<.5 then
f*=-1
 end
if rnd()<.75 then
j*=-1
 end
if#self.planets==0 then break end
aQ=32767
for X in all(self.planets)do aQ=min(aQ,Vector.distance(Vector(f,j),X.sector_position/33))end
aR=aQ<15 end
return Planet.new(f*33,j*33,(1-Vector(f,j):angle()-.25)%1)end
function Sector:draw_starfield(aN)local aS
local aT
for aU in all(self.starfield)do aS=aU.position+aN*aU.speed*-.5
aT=aU.position+aN*aU.speed*.5
local d=star_color_monochrome+star_color_index+1
local aV=#star_colors[d]local aW=1+(aU.color-1)%aV
aU.position:draw_line(aT,star_colors[d+1][aW])aS:draw_line(aU.position,star_colors[d][aW])end end
function Sector:scroll_starfield(aN)local aX=starfield_count-#self.starfield
for d=1,aX do add(self.starfield,Star.new():reset())end
for aU in all(self.starfield)do aU.position:add(aN*aU.speed*-1)if aX<0 then del(self.starfield,aU)aX=aX+1 elseif aU.position.x>134 then aU:reset(-6) elseif aU.position.x<-6 then aU:reset(134) elseif aU.position.y>134 then aU:reset(false,-6) elseif aU.position.y<-6 then aU:reset(false,134)end end end
function is_offscreen(X,i)local aY=i or 0
local aZ=0-aY
local a_=128+aY
local f=X.screen_position.x
local j=X.screen_position.y
if X.deltav then return X.duration<0 else return X.duration<0 or f>a_ or f<aZ or j>a_ or j<aZ end end
Spark={}Spark.__index=Spark
function Spark.new(X,b0,t,Y)return setmetatable({screen_position=X,particle_velocity=b0,color=t,duration=Y or random_int(7,2)},Spark)end
function Spark:update(aN)self.screen_position:add(self.particle_velocity-aN)
self.duration-=1
 end
function Spark:draw(aN)pset(self.screen_position.x,self.screen_position.y,self.color)self:update(aN)end
Circle={}Circle.__index=Circle
function Circle.new(X,b0,t,Y,b1)return setmetatable({screen_position=X:clone(),particle_velocity=b0,color=t,center_position=b1 or X:clone(),duration=Y},Circle)end
function Circle:draw(aN)local b2=flr(Vector.distance(self.screen_position,self.center_position))for d=b2+3,b2,-1 do local t=damage_colors2[#damage_colors2-3-self.duration+d]if t then self.center_position:draw_circle(d,t,true)end end
self:update(aN)end
setmetatable(Circle,{__index=Spark})function make_explosion(ac,A)local b3=random_angle()add(particles,Circle.new(ac,b3*rnd(.5),color,#damage_colors2-3,b3*(A or 4)+ac))end
MultiCannon={}MultiCannon.__index=MultiCannon
function MultiCannon.new(X,b0,t,_)local b4=b0:perpendicular():normalize()*(rnd(2)-1)return setmetatable({screen_position=X,position2=X:clone(),particle_velocity=b0+b4,color=t,firing_ship=_,duration=16},MultiCannon)end
function MultiCannon:draw(aN)self:update(aN)self.position2:draw_line(self.screen_position,self.color)self.position2=self.screen_position:clone()end
setmetatable(MultiCannon,{__index=Spark})ThrustExhaust={}ThrustExhaust.__index=ThrustExhaust
function ThrustExhaust.new(X,b0)return setmetatable({screen_position=X,particle_velocity=b0,duration=0},ThrustExhaust)end
function ThrustExhaust:draw(aN)local t=random_int(11,9)local b0=self.particle_velocity
local b4=b0:perpendicular()*0.7
local b5=b0*(rnd(2)+2)+b4*(rnd()-.5)local b6=self.screen_position+b5
local b7=self.screen_position+b0+b4
local b8=self.screen_position+b0+b4*-1
local b9=self.screen_position
b7:draw_line(b6,t)b8:draw_line(b6,t)b8:draw_line(b9,t)b7:draw_line(b9,t)if rnd()>.4 then add(particles,Spark.new(b6,aN+b5*.25,t))end
self.screen_position:add(b0-aN)
self.duration-=1
 end
function draw_circle(ba,bb,l,m,color)local bc={}local bd=not m
local be=0
local bf=0
local f=-l
local j=0
local bg=2-2*l
while f<0 do bc[1+f*-1]=j
if bd then be=f
bf=j end
for d=f,be do sset(ba-d,bb+j,color)sset(ba+d,bb-j,color)end
for d=bf,j do sset(ba-d,bb-f,color)sset(ba+d,bb+f,color)end
l=bg
if l<=j then
j+=1
bg+=j*2+1
 end
if l>f or bg>j then
f+=1
bg+=f*2+1
 end end
bc[1]=bc[2]return bc end
function draw_moon_at_ycoord(bh,bi,bj,l,bk,bc,bl)local f
local j
local bm
local bn
local bo
local d
local bp
local bq
j=l-bh
local br=abs(j)+1
if br<=#bc then f=flr(sqrt(l*l-j*j))bm=2*f
if bk<.5 then bn=-bc[br]bo=flr(bm-2*bk*bm-f) else bn=flr(f-2*bk*bm+bm)bo=bc[br]end
for d=bn,bo do if not bl or bk<.5 and d>bo-2 or bk>=.5 and d<bn+2 then bp=dark_planet_colors[sget(bi+d,bj-j)+1] else bp=0 end
sset(bi+d,bj-j,bp)end end end
perms={}for d=0,255 do perms[d]=d end
for d=0,255 do local aJ=random_int(32767)%256
perms[d],perms[aJ]=perms[aJ],perms[d]end
local bs={}for d=0,255 do local f=perms[d]%12
perms[d+256],bs[d],bs[d+256]=perms[d],f,f end
function GetN_3d(bt,bu,bv,f,j,bw)local a=.6-f*f-j*j-bw*bw
local bx=bs[bt+perms[bu+perms[bv]]]return max(0,a*a*a*a)*(e[bx][0]*f+e[bx][1]*j+e[bx][2]*bw)end
function Simplex3D(f,j,bw)local s=(f+j+bw)*0.333333333
local bt,bu,bv=flr(f+s),flr(j+s),flr(bw+s)local a=(bt+bu+bv)*0.166666667
local by=f+a-bt
local bz=j+a-bu
local bA=bw+a-bv
bt,bu,bv=band(bt,255),band(bu,255),band(bv,255)local bB=GetN_3d(bt,bu,bv,by,bz,bA)local bC=GetN_3d(bt+1,bu+1,bv+1,by-0.5,bz-0.5,bA-0.5)local bD,bE,bF,bG,bH,bI
if by>=bz then if bz>=bA then bD,bE,bF,bG,bH,bI=1,0,0,1,1,0 elseif by>=bA then bD,bE,bF,bG,bH,bI=1,0,0,1,0,1 else bD,bE,bF,bG,bH,bI=0,0,1,1,0,1 end else if bz<bA then bD,bE,bF,bG,bH,bI=0,0,1,0,1,1 elseif by<bA then bD,bE,bF,bG,bH,bI=0,1,0,0,1,1 else bD,bE,bF,bG,bH,bI=0,1,0,1,1,0 end end
local bJ=GetN_3d(bt+bD,bu+bE,bv+bF,by+0.166666667-bD,bz+0.166666667-bE,bA+0.166666667-bF)local bK=GetN_3d(bt+bG,bu+bH,bv+bI,by+0.333333333-bG,bz+0.333333333-bH,bA+0.333333333-bI)return 32*(bB+bJ+bK+bC)end
function create_planet_type(bL,bM,bN,bO,bP,bQ,bR,bS)return{class_name=bL,noise_octaves=bM,noise_zoom=bN,noise_persistance=bO,transparent_color=bS or 14,minimap_color=bP,full_shadow=bR or"yes",color_map=bQ}end
planet_types={create_planet_type("tundra",5,.5,.6,6,split_number_string"7 6 5 4 5 6 7 6 5 4 3 "),create_planet_type("desert",5,.35,.3,9,split_number_string"4 4 9 9 4 4 9 9 4 4 9 9 11 1 9 4 9 9 4 9 9 4 9 9 4 9 9 4 9 "),create_planet_type("barren",5,.55,.35,5,split_number_string"5 6 5 0 5 6 7 6 5 0 5 6 "),create_planet_type("lava",5,.55,.65,4,split_number_string"0 4 0 5 0 4 0 4 9 8 4 0 4 0 5 0 4 0 "),create_planet_type("gas giant",1,.4,.75,2,split_number_string"7 6 13 1 2 1 12 "),create_planet_type("gas giant",1,.4,.75,8,split_number_string"7 15 14 2 1 2 8 8 ",nil,12),create_planet_type("gas giant",1,.7,.75,10,split_number_string"15 10 9 4 9 10 "),create_planet_type("terran",5,.3,.65,11,split_number_string"1 1 1 1 1 1 1 13 12 15 11 11 3 3 3 4 5 6 7 ","partial shadow"),create_planet_type("island",5,.55,.65,12,split_number_string"1 1 1 1 1 1 1 1 13 12 15 11 3 ","partial shadow")}Planet={}Planet.__index=Planet
function Planet.new(f,j,bk,aJ)local bT=planet_types[random_int(#planet_types)+1]local bU=bT.noise_factor_vert or 1
if bT.class_name=="gas giant"then bT.min_size=50
bU=4
if rnd()<.5 then bU=20 end end
local bV=bT.min_size or 10
local l=aJ or random_int(65,bV)return setmetatable({screen_position=Vector(),radius=l,sector_position=Vector(f,j),bottom_right_coord=2*l-1,phase=bk,planet_type=bT,noise_factor_vert=bU,noisedx=rnd(1024),noisedy=rnd(1024),noisedz=rnd(1024),rendered_circle=false,rendered_terrain=false,color=bT.minimap_color},Planet)end
function Planet:draw(aO)if stellar_object_is_visible(self,aO)then self:render_a_bit_to_sprite_sheet()sspr(0,0,self.bottom_right_coord,self.bottom_right_coord,self.screen_position.x-self.radius,self.screen_position.y-self.radius)end end
function draw_rect(bW,bX,t)for f=0,bW-1 do for j=0,bX-1 do sset(f,j,t)end end end
function Planet:render_a_bit_to_sprite_sheet(bY,bZ)local l=self.radius-1
if bY then l=47 end
if not self.rendered_circle then self.width=self.radius*2
self.height=self.radius*2
self.x=0
self.yfromzero=0
self.y=l-self.yfromzero
self.phi=0
thissector:reset_planet_visibility()pal()palt(0,false)palt(self.planet_type.transparent_color,true)if bY then self.width=114
self.height=96
draw_rect(self.width,self.height,0) else draw_rect(self.width,self.height,self.planet_type.transparent_color)self.bxs=draw_circle(l,l,l,true,0)draw_circle(l,l,l,false,self.planet_type.minimap_color)end
self.rendered_circle=true end
if not self.rendered_terrain and self.rendered_circle then local b_=0
local c0=.5
local c1=c0/self.width
if bY and bZ then b_=.5
c0=1 end
if self.phi<=.25 then for c2=b_,c0-c1,c1 do if sget(self.x,self.y)~=self.planet_type.transparent_color then local c3=self.planet_type.noise_zoom
local c4=0
local c5=1
local c6=0
for g=1,self.planet_type.noise_octaves do c6=c6+Simplex3D(self.noisedx+c3*cos(self.phi)*cos(c2),self.noisedy+c3*cos(self.phi)*sin(c2),self.noisedz+c3*sin(self.phi)*self.noise_factor_vert)c4=c4+c5
c5=c5*self.planet_type.noise_persistance
c3=c3*2 end
c6=c6/c4
if c6>1 then c6=1 end
if c6<-1 then c6=-1 end
c6=c6+1
c6=c6*(#self.planet_type.color_map-1)/2
c6=round(c6)sset(self.x,self.y,self.planet_type.color_map[c6+1])end
self.x+=1
 end
if not bY then draw_moon_at_ycoord(self.y,l,l,l,self.phase,self.bxs,self.planet_type.full_shadow=="yes")end
self.x=0
if self.phi>=0 then
self.yfromzero+=1
self.y=l+self.yfromzero
self.phi+=.5/(self.height-1) else
 self.y=l-self.yfromzero end
self.phi*=-1
 else self.rendered_terrain=true end end
return self.rendered_terrain end
function add_npc(X)local c7=X or playership
local c8=Ship.new(2,4):generate_random_ship()c8:set_position_near_object(c7)c8.npc=true
add(npcships,c8)c8.index=#npcships
if c8.ship_type.name~="freighter"and rnd()<.2 then c8.hostile=true end end
function load_sector()thissector=Sector.new()notifications:cancel_all()notifications:add("arriving in system ngc "..thissector.seed)add(thissector.planets,Sun.new())for d=0,random_int(12)do add(thissector.planets,thissector:new_planet_along_elipse())end
playership:set_position_near_object(thissector.planets[2])playership:clear_target()npcships={}for X in all(thissector.planets)do for d=1,random_int(4)do add_npc(X)end end
return true end
function _init()paused=false
landed=false
particles={}projectiles={}notifications=Notification.new()playership=Ship.new()playership:generate_random_ship()load_sector()setup_minimap()show_title_screen=true
local c9=Vector(0,-3)while not btnp(4)do cls()thissector:scroll_starfield(c9)thissector:draw_starfield(c9)circfill(64,135,90,2)circfill(64,172,122,0)map(0,0,6,-15)
print("\n\n    ”  thrust      —  fire\n  ‹  ‘  rotate  Ž  menu\n    ƒ  reverse",0,70,7)
flip()end end
minimap_sizes={16,32,48,128,false}function setup_minimap(A)minimap_size_index=A or 0
minimap_size=minimap_sizes[minimap_size_index+1]if minimap_size then minimap_size_halved=minimap_size/2
minimap_offset=Vector(126-minimap_size_halved,minimap_size_halved+1)end end
function draw_minimap_planet(Z)local c7=Z.sector_position+screen_center
if Z.planet_type then c7:add(Vector(-Z.radius,-Z.radius))end
c7=c7/minimap_denominator+minimap_offset
if minimap_size>100 then local aJ=ceil(Z.radius/32)c7:draw_circle(aJ+1,Z.color) else c7:draw_point(Z.color)end end
function draw_minimap_ship(Z)local ca=(Z.sector_position/minimap_denominator):add(minimap_offset):round()local color=Z:targeted_color()if Z.npc then ca:draw_point(color)if Z.targeted then ca:draw_circle(2,color)end else rect(ca.x-1,ca.y-1,ca.x+1,ca.y+1,15)end end
function draw_minimap()if minimap_size then if minimap_size<100 then rectfill(126-minimap_size,1,126,minimap_size+1,0)rect(125-minimap_size,0,127,minimap_size+2,6,11)end
local f=abs(playership.sector_position.x)local j=abs(playership.sector_position.y)if j>f then f=j end
local cb=min(6,flr(f/5000)+1)minimap_denominator=cb*5000/minimap_size_halved
for X in all(thissector.planets)do draw_minimap_planet(X)end
if framecount%3~=0 then for cc in all(projectiles)do if cc.deltav then draw_minimap_ship(cc)end end
for _ in all(npcships)do draw_minimap_ship(_)end
draw_minimap_ship(playership)end end end
outlined_text_draw_points=split_number_string"-1 -1 1 -1 -1 1 -1 0 1 0 0 -1 0 1 "function print_shadowed(cd,f,j,color,ce,cf)local t=color or 6
local s=ce or 5
if cf then for d=1,#outlined_text_draw_points,2 do print(cd,f+outlined_text_draw_points[d],j+outlined_text_draw_points[d+1],s)end end
print(cd,f+1,j+1,s)print(cd,f,j,t)end
Notification={}Notification.__index=Notification
function Notification.new()return setmetatable({messages={},display_time=4},Notification)end
function Notification:add(cd)add(self.messages,cd)end
function Notification:cancel_current()del(self.messages,self.messages[1])self.display_time=4 end
function Notification:cancel_all(cd)if cd then del(self.messages,cd) else self.messages={}end
self.display_time=4 end
function Notification:draw()if#self.messages>0 then print_shadowed(self.messages[1],0,121)if framecount==29 then
self.display_time-=1
 end
if self.display_time<1 then self:cancel_current()end end end
function call_option(d)if current_option_callbacks[d]then local cg=current_option_callbacks[d]()paused=false
if cg==nil then paused=true elseif cg then display_menu(nil,nil,d)if type(cg)=="string"then print_shadowed(cg,64-round(4*#cg/2),40,11,0,true)end
paused=true end end end
function display_menu(ch,ci,cj)if ch then current_options=ch
current_option_callbacks=ci end
if not landed then render_game_screen()end
local b1=Vector(64,90)local ck=b1+Vector(-1,2)for u=.25,1,.25 do local d=u*4
local cl=6
local cm=0
if cj==d then cl=11 end
local X=rotated_vector(u,8)+ck
X:draw_line(rotated_vector(u,3)+ck,cl)X:draw_line(rotated_vector(u,5,2)+ck,cl)X:draw_line(rotated_vector(u,5,-2)+ck,cl)if current_options[d]then X=rotated_vector(u,14)+b1
if u==.5 then X:add(Vector(-4*#current_options[d])) elseif u~=1 then X:add(Vector(round(-4*#current_options[d]/2)))end
print_shadowed(current_options[d],X.x,X.y,cl,cm,true)end end end
function main_menu()display_menu({"autopilot","fire missile","options","systems"},{function()display_menu({"full stop","planet","back","follow"},{function()playership:reset_orders(playership.full_stop)return false end,approach_nearest_planet,main_menu,function()playership:reset_orders(playership.seek)playership.seektime=0
return false end})end,function()playership:fire_missile()return false end,function()display_menu({"back","starfield","minimap size","debug"},{main_menu,function()display_menu({"more stars","~dimming","less stars","~colors"},{function()
starfield_count+=5
return"star count: "..starfield_count end,function()star_color_index=(star_color_index+1)%2
return true end,function()starfield_count=max(0,starfield_count-5)return"star count: "..starfield_count end,function()star_color_monochrome=(star_color_monochrome+1)%2*3
return true end})end,function()setup_minimap((minimap_size_index+1)%#minimap_sizes)return true end,function()display_menu({"new ship","back","new sector","spawn enemy"},{function()s=max((s+1)%48,8)playership:generate_random_ship(s)return playership.ship_type.name.." "..s end,main_menu,load_sector,function()add_npc()npcships[#npcships].hostile=true
return"npc created"end})end})end,function()display_menu({"target next hostile","back","land","target next"},{next_hostile_target,main_menu,land_at_nearest_planet,next_ship_target})end})end
function landed_menu()display_menu({"takeoff"},{takeoff})end
local cn=0
local co={}for d=1,96 do co[d]={flr(-sqrt(-sin(d/193))*48+64)}co[d][2]=(64-co[d][1])*2 end
for d=0,95 do poke(64*d+56,peek(64*d+0x1800))end
local cp={}for d=0,15 do cp[d]={(cos(0.5+0.5/16*d)+1)/2}cp[d][2]=(cos(0.5+0.5/16*(d+1))+1)/2-cp[d][1]end
function shift_sprite_sheet()for d=0,95 do poke(64*d+0x1838,peek(64*d))memcpy(64*d,64*d+1,56)memcpy(64*d+0x1800,64*d+0x1801,56)poke(64*d+56,peek(64*d+0x1800))end end
function landed_update()local X=landed_planet
if not landed_front_rendered then landed_front_rendered=X:render_a_bit_to_sprite_sheet(true)if landed_front_rendered then X.rendered_circle=false
X.rendered_terrain=false
for cq=1,56 do shift_sprite_sheet()end end else if not landed_back_rendered then landed_back_rendered=X:render_a_bit_to_sprite_sheet(true,true) else cn=1-cn
if cn==0 then shift_sprite_sheet()end end end end
function render_landed_screen()cls()if landed_front_rendered and landed_back_rendered then for d=1,96 do local u,v=co[d][1],co[d][2]pal()local cr=ceil(v*cp[15][2])for cq=15,0,-1 do if cq==4 then for cs=0,#dark_planet_colors-1 do pal(cs,dark_planet_colors[cs+1])end end
if cq<15 then cr=flr(u+v*cp[cq+1][1])-flr(u+v*cp[cq][1])end
sspr(cn+cq*7,d-1,7,1,flr(u+v*cp[cq][1]),d+16,cr,1)end end
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
for _ in all(npcships)do if _.last_hit_time and _.last_hit_time+30>secondcount then _:reset_orders()_:flee()if _.hostile then _.target=_.last_hit_attacking_ship
_.target_index=_.target.index end else if#_.orders==0 then if _.hostile then _.seektime=0
if not _.target then next_ship_target(_,true)end
add(_.orders,_.seek) else _:approach_object()_.wait_duration=random_int(46,10)_.wait_time=secondcount
add(_.orders,_.wait)end end
_:follow_current_order()end
_:update_location()if _.hp<1 then del(npcships,_)playership:clear_target()end end
playership:follow_current_order()playership:update_location()thissector:scroll_starfield(playership.velocity_vector)end end
function render_game_screen()cls()thissector:draw_starfield(playership.velocity_vector)for ct in all(thissector.planets)do ct:draw(playership.sector_position)end
for _ in all(npcships)do if _:is_visible(playership.sector_position)then _:draw_sprite_rotated()end end
if playership.target then last_offscreen_pos=nil
local cu=playership.screen_position
local cv=playership.target
if cv then if not cv:is_visible(playership.sector_position)then local ar=format_float((cv.screen_position-cu):scaled_length())local color,cw=cv:targeted_color()local cx=flr(cv.sprite_rows*.5)local Y=rotated_vector((cv.screen_position-cu):angle())last_offscreen_pos=Y*(60-cx)+screen_center
local b8=last_offscreen_pos:clone():add(Vector(-4*#ar/2))cv:draw_sprite_rotated(last_offscreen_pos)if b8.y>63 then b8:add(Vector(1,-12-cx)) else b8:add(Vector(1,7+cx))end
print_shadowed(ar,round(b8.x),round(b8.y),color,cw)end
print_shadowed("target "..cv:hp_string(),0,114)end end
if playership.hp<1 then playership:generate_random_ship()end
playership:draw()for cy in all(particles)do if is_offscreen(cy,32)then del(particles,cy) else cy:draw(playership.velocity_vector)end end
for aa in all(projectiles)do if is_offscreen(aa,63)then del(projectiles,aa) else if last_offscreen_pos and aa.sector_position and playership.target and(playership.target.sector_position-aa.sector_position):scaled_length()<=playership.target.sprite_rows then aa:draw(nil,aa.sector_position-playership.target.sector_position+last_offscreen_pos) else aa:draw(playership.velocity_vector)end end end
draw_minimap()notifications:draw()end
function _draw()if landed then render_landed_screen()display_menu() elseif not paused then render_game_screen()end end
__gfx__
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
0000000000000000000000008880888099900000aaa0aaa00bbbbb00333330000ddddd00ccc0ccc0011111002220000000000000000000000000000000000000
0000000000000000000000008880888099900000aaa0aaa0bbbbbbb033333300ddddddd0ccc0ccc0111111102220000000000000000000000000000000000000
0000000000000000000000008880888077700000aaa0aaa0bbbbbbb033333330ddddddd0ccc0ccc0111111107770000000000000000000000000000000000000
0000000000000000000000008880888099999990aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102222222000000000000000000000000000000000
0000000000000000000000008880888099999990aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102222222000000000000000000000000000000000
0000000000000000000000008880888099999990aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102222222000000000000000000000000000000000
0000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000000000
0000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000000000
0000000000000000000000008880888099999990aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111000002222222000000000000000000000000000000000
0000000000000000000000008880888099999990aaa0a000bbb0bbb033303330ddd0ddd0ccc0ccc0111000002222222000000000000000000000000000000000
0000000000000000000000007770777099999990aaa00000bbb0bbb0333033307770777077707770777000002222222000000000000000000000000000000000
0000000000000000000000008888888099900000aaa00aaabbb0bbb033303330ddddddd0ccc0ccc0111111002220000000000000000000000000000000000000
0000000000000000000000008888888099900000aaaa9a9abbb0bbb033303330ddddddd0ccc0ccc0011111102220000000000000000000000000000000000000
0000000000000000000000008888888099900000a9a9a900bbb0bbb033303330ddddddd0ccc0ccc0000011102220000000000000000000000000000000000000
00000000000000000000000088808880999000009a9a0000bbb0bbb033303330ddd0ddd0ccc0ccc0000011102220000000000000000000000000000000000000
0000000000000000000000008880888099900000a9000000bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000000000
0000000000000000000000008880888099900000aaa0aaa0bbbb3b3033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000000000
0000000000000000000000008880888099900000aaa0aaa0b3b3b30033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000000000
0000000000000000000000008880888099900000777077703b3b000077707770ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000000000
0000000000000000000000008880888099900000aaa0aaa00000000033333330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000000000
0000000000000000000000008880888099900000aaa0aaa00000000033333300ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000000000
0000000000000000000000008880828099900000aaa0aaa00000000033333000ddd0ddd0dcdcccc0111011102220000000000000000000000000000000000000
0000000000000000000000008820282099900000aaa0aaa00000000033300000ddd0ddd00dcdcdc0111011102220000000000000000000000000000000000000
0000000000000000000000008280800099900000aaa0aaa00000000033300000ddd0ddd0000cdc00111011102220000000000000000000000000000000000000
000000000000000000000000000000009990009000000000bbb0bbb033300000d1d0ddd000000000111011102220000000000000000000000000000000000000
000000000000000000000000000000009990949400000000bbb0bbb0333000001d10ddd000000000515111102220000000000000000000000000000000000000
000000000000000000000000000000009999494000000000777077703330000000d0d1d000000000051515102220000000000000000000000000000000000000
000000000000000000000000000000009494900000000000bbb0bbb03330000000001d1000000000000151002220000000000000000000000000000000000000
000000000000000000000000000000004940000000000000bbb0bbb033300000000000d000000000000000005220000000000000000000000000000000000000
000000000000000000000000000000009000000000000000bbb0bbb0335000000000000000000000000000002522222200000000000000000000000000000000
000000000000000000000000000000000000000000000000bbb0bbb0353000000000000000000000000000000252525200000000000000000000000000000000
000000000000000000000000000000000000000000000000bbb0bbb0530000000000000000000000000000000005252500000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000700000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000700000000
00000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000007000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000
0000000000000000000000000000008880888099999990aaa0aaa00bbbbb00333330000ddddd00ccc0ccc0011111002222222000000000000000000000000000
0000000000000000000000000000008880888099999990aaa0aaa0bbbbbbb033333300ddddddd0ccc0ccc0111111102222222000000000000000000000000000
0000000000070000000000000000008880888099999990aaa0aaa0bbbbbbb033333330ddddddd0ccc0ccc0111111102222222000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000700000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000700000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111000002220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111000002220000000000000000000000000000000
00000000000000000000000000000077707770777000007770777077707770777077707770777777707770777000007770000000000000000000000000000000
0000000000000000000000070000008888888099999990aaa0aaa0bbb0bbb033333330ddddddd0ccc0ccc0111111002222222000000000000000000000000000
0000000000000000000000000000008888888099999990aaa0aaa0bbb0bbb033333300ddddddd0ccc0ccc0011111102222222000000000000000000000000700
0000000000000000000000000000008888888099999990aaa0aaa0bbb0bbb033333000ddddddd0ccc0ccc0000011102222222000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033300700ddd0ddd0ccc0ccc0000011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033300000ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000700000000000000000000000008880888099900000aaa0aaa0bbb0bbb033300000ddd0ddd0ccc0ccc0111011172220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033300000ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033300000ddd0ddd0ccc0ccc0111011102220000000000000000000000000000070
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033300000ddd0ddd0ccc0ccc7111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb2bbb233322222ddd2ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa2aaa2bbb2bbb233522222ddd2ddd2ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900222aaa2aaa2bbb2bbb235322222ddd2ddd2ccc2ccc2111011102220000000000000000000000000000000
0000000000000000000000000000078880888099922222aaa2aaa2bbb2bbb253222222ddd2ddd2ccc2ccc2111011102220000000000000000000000000000000
0000000000000000000000000000008880888299922222aaa2aaa2bbbb3b3222222222d1d2ddd2ccc2ccc2111211102220000000000000000000007000000000
0070000000000000000000000000008880888299922222aaa2a220b3b3b300000000001d10ddd2ccc2ccc2111211122220000000000000000000070000000000
0000000000000000000000000000008882888299922220aaa000003b3b00000000000000d0d1d0ccc0ccc2111211122222000000000000000007000000000000
0000000000000000000000000000028882888299900000aaa00aaa000000000000000000001d10ccc0ccc0111211122222227000000000000000000000000000
0000000000000000000000000022228882888099900000aaaa9a9a0000000000000000000000d0ccc0ccc0111011102222222220000000000000000000000000
0000000000000070000000002222228880888099900000a9a9a900000000000000000000000000dcdcccc0111011102222222222200000000000000000000000
00000000000000000000002222220088808880999000009a9a00000000000000000000000000000dcdcdc0111011102220000222222000000000000000000000
0000000000000000000022222000008880888099900000a9000000000000000000000000000000000cdc00111011102220000000222220000000000000000000
00000000000000000002220000000088808880999000900000000000000000000000000000000000000000111011102220000000000222000000000000000000
00000000000000000222000000000088808880999094940000000000000000000000000000000000000000515111102220000000000002220000000000000000
00000000000000002000000000000088808880999949400000000000000000000000000000000000000000051515102220000000000000002000000000700000
00000000000000200000000000000088808880949490000000000000000000000000000000000000000000000151002220000000000000000020000000000000
00000000000000000000000000000088808880494000000000000000000000000000000000000000000000000000005220000000000000000000000000000000
00000000000000000000000000000088808280900000000000000000000000000000000000000000000000000000002522222200000000000000000000000000
00000000000000000000000000000088202820000000000000000000000000000000000000000000000000000000000252525200000000000000000000000000
00000000000000000000000000000082808000000000000000000000000000000000000000000000000000000000000005252500000000000000000000000000
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
00000000000000000000c0c20000c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c2c2c2000000000000000000c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c2c20000000000000000c2c2c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c20000000000000000c2c2c2c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c2c3d4c5c6c7c8c9cadbc2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c2c3e4c5d6d7e8c9eaebc2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c2d3c4e5f6e7d8d9dacbc2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c3e4c5d6f7e8c9eaebc2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c3e4d5e600f8e9eaebc2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000e3f4c000000000fafbc200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
