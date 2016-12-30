pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- heliopause
-- by anthonydigirolamo
function split_number_string(a)local b={}local c=split_number_string_start_index or 0
local d=1
for e=1,#a do if sub(a,e,e)==" "then b[c]=sub(a,d,e-1)+0
c+=1
d=e+1 end end
return b end
local f={split_number_string"-1 1 0 ",split_number_string"1 -1 0 ",split_number_string"-1 -1 0 ",split_number_string"1 0 1 ",split_number_string"-1 0 1 ",split_number_string"1 0 -1 ",split_number_string"-1 0 -1 ",split_number_string"0 1 1 ",split_number_string"0 -1 1 ",split_number_string"0 1 -1 ",split_number_string"0 -1 -1 "}f[0]=split_number_string"1 1 0 "split_number_string_start_index=1
star_color_index=0
star_color_monochrome=0
star_colors={split_number_string"10 14 12 13 7 6 ",split_number_string"9 8 13 1 6 5 ",split_number_string"4 2 1 0 5 1 ",split_number_string"7 6 7 6 7 6 ",split_number_string"6 5 6 5 6 5 ",split_number_string"5 1 5 1 5 1 "}darkshipcolors=split_number_string"0 1 2 2 1 5 6 2 4 9 3 13 1 8 9 "dark_planet_colors=split_number_string"0 0 1 1 0 5 5 5 4 5 5 3 1 1 2 1 "function round(e)return flr(e+.5)end
function ceil(g)return-flr(-g)end
function random_plus_to_minus_one()return random_int(3)-1 end
function random_int(h,i)local j=i or 0
return flr(rnd(32767))%(h-j)+j end
function format_float(k)local h=flr(k*10+0.5)/10
return flr(h).."."..flr(h%1*10)end
Vector={}Vector.__index=Vector
function Vector.new(g,l)return setmetatable({x=g or 0,y=l or 0},Vector)end
function Vector:draw_point(m)pset(round(self.x),round(self.y),m)end
function Vector:draw_line(n,m)line(round(self.x),round(self.y),round(n.x),round(n.y),m)end
function Vector:draw_circle(o,m,p)local q=circ
if p then q=circfill end
q(round(self.x),round(self.y),round(o),m)end
function Vector:round()self.x=round(self.x)self.y=round(self.y)return self end
function Vector:normalize()local r=self:length()
self.x/=r
self.y/=r
return self end
function random_angle(s)return rotated_vector(rnd(),s)end
function rotated_vector(t,g,l)return Vector(g or 1,l):rotate(t)end
function Vector:rotate(u)local v=cos(u)local a=sin(u)local g=self.x
local l=self.y
self.x=v*g-a*l
self.y=a*g+v*l
return self end
function Vector:add(n)
self.x+=n.x
self.y+=n.y
return self end
function Vector.__add(w,x)return Vector.new(w.x+x.x,w.y+x.y)end
function Vector.__sub(w,x)return Vector.new(w.x-x.x,w.y-x.y)end
function Vector.__mul(w,x)return Vector.new(w.x*x,w.y*x)end
function Vector.__div(w,x)return Vector.new(w.x/x,w.y/x)end
function Vector:about_equals(n)return round(n.x)==self.x and round(n.y)==self.y end
function Vector:angle()return atan2(self.x,self.y)end
function Vector:length()return sqrt(self.x^2+self.y^2)end
function Vector:scaled_length()return sqrt((self.x/182)^2+(self.y/182)^2)*182 end
function vector_long_distance(w,x)return(x-w):scaled_length()end
function Vector:tostring()return format_float(self.x)..", "..format_float(self.y)end
function Vector:clone()return Vector.new(self.x,self.y)end
function Vector:perpendicular()return Vector.new(-self.y,self.x)end
setmetatable(Vector,{__call=function(y,...)return Vector.new(...)end})screen_center=Vector(63,63)Ship={}Ship.__index=Ship
function Ship.new()local z={npc=false,screen_position=screen_center,sector_position=Vector(),current_deltav=0,current_gees=0,angle=0,angle_radians=0,heading=90,velocity_angle=0,velocity_angle_opposite=180,velocity=0,velocity_vector=Vector(),orders={},last_fire_time=0}setmetatable(z,Ship)return z end
ship_types={{name="cruiser",shape=split_number_string"3.5 .5 0 -1 .583333 .8125 18 24 "},{name="freighter",shape=split_number_string"3 2 0 -3 .2125 .8125 16 22 "},{name="super freighter",shape=split_number_string"6 -.25 0 .25 .2125 .8125 32 45 "},{name="fighter",shape=split_number_string"1.5 .25 .75 -2 .7 .8 14 18 "}}function Ship:generate_random_ship(A)local B=A or random_int(32767)srand(B)self.seed_value=B
self.ship_type=ship_types[random_int(#ship_types)+1]local C=self.ship_type.shape
local D=split_number_string"6 7 8 9 10 11 12 13 14 15 "for e=1,6 do del(D,D[random_int(#D)+1])end
local E=0
local F={}local G=random_int(C[8]+1,C[7])local H=flr(G/2)local I=Vector(1,C[1])local J=Vector(1,C[2])local K=Vector(1,C[3])local L=Vector(1,C[4])local M=flr(C[5]*G)local N=flr(C[6]*G)for l=1,G do add(F,{})for g=1,H do add(F[l],D[4])end end
local O=I
local P=J
local Q=round(G/3)local R=round(H/4)for l=2,G-1 do for g=1,H do local m=D[1]if l>=Q+random_plus_to_minus_one()and l<=2*Q+random_plus_to_minus_one()then m=D[3]end
if g>=R+random_plus_to_minus_one()and l>=2*Q+random_plus_to_minus_one()then m=D[2]end
if H-g<max(0,flr(O.y))then if rnd()<.6 then F[l][g]=m
E=E+1
if F[l-1][g]==D[4]then F[l][g]=darkshipcolors[m]end end end end
if l>=N then P=L elseif l>=M then P=K end
O=O+P
if O.y>0 and l>3 and l<G-1 then for e=1,random_int(round(O.y/4)+1)do F[l][H-e]=5
E=E+2 end end end
local S=random_int(2)for l=G,1,-1 do for g=H-S,1,-1 do add(F[l],F[l][g])end end
self.hp=E
self.max_hp=E
self.hp_percent=1
self.deltav=max(E*-0.0188235294118+4.56470588235,1)*0.03268667
self.turn_rate=round(max(E*-0.0470588235294+11.4117647059,2))self.sprite_rows=G
self.sprite_columns=#F[1]self.transparent_color=D[4]self.sprite=F
return self end
function nearest_planet()local T
local U=32767
for V in all(thissector.planets)do if V.planet_type then local W=vector_long_distance(playership.sector_position,V.sector_position)if W<U then U=W
T=V end end end
return T,U end
function land_at_nearest_planet()local T,U=nearest_planet()if U<T.radius*1.4 then if playership.velocity<.5 then thissector:reset_planet_visibility()landed_front_rendered=false
landed_back_rendered=false
landed_planet=T
landed=true
landed_menu()draw_rect(128,128,0) else notification_add("moving too fast to land")end else notification_add("too far to land")end
return false end
function takeoff()thissector:reset_planet_visibility()playership:set_position_near_object(landed_planet)landed=false
return false end
function Ship:set_position_near_object(X)local o=X.radius or X.sprite_rows
self.sector_position=random_angle(1.2*o)+X.sector_position
self:reset_velocity()end
function Ship:clear_target()self.target_index=nil
self.target=nil end
function clear_targeted_ship_flags()for Y in all(npcships)do Y.targeted=false end end
function next_hostile_target(Y)local Z=Y or playership
local _
for e=1,#npcships do next_ship_target(Y)if Z.target.hostile then break end end
return true end
function next_ship_target(Y,a0)local Z=Y or playership
if a0 then Z.target_index=random_int(#npcships)+1 else Z.target_index=(Z.target_index or#npcships)%#npcships+1 end
Z.target=npcships[Z.target_index]if Z==Z.target then Z.target=playership end
if not Y then clear_targeted_ship_flags()Z.target.targeted=true end
return true end
function Ship:targeted_color()if self.hostile then return 8,2 else return 11,3 end end
function Ship:draw_sprite_rotated(a1,t)local a2=a1 or self.screen_position
local w=t or self.angle_radians
local G=self.sprite_rows
local H=self.sprite_columns
local a3=self.transparent_color
if self.targeted then local a4=round(G/2)+4
local a5,a6=self:targeted_color()if a1 then(a2+Vector(1,1)):draw_circle(a4,a6,true)a2:draw_circle(a4,0,true)end
a2:draw_circle(a4,a5)end
local a7={}for a8 in all(projectiles)do if a8.firing_ship~=self then if a8.sector_position and a1 and(self.sector_position-a8.sector_position):scaled_length()<=G or vector_long_distance(a8.screen_position,a2)<G then add(a7,a8)end end end
local a9
for l=1,H do for g=1,G do local m=self.sprite[g][l]if m~=a3 and m~=nil then local aa=Vector(G-g-flr(G/2),l-flr(H/2)-1)local ab=Vector(aa.x+1,aa.y)aa:rotate(w):add(a2):round()ab:rotate(w):add(a2):round()if self.hp<1 then make_explosion(aa,G/2,18,self.velocity_vector)if not a1 then add(particles,Spark.new(aa,random_angle(rnd(.25)+.25)+self.velocity_vector,m,128+random_int(32)))end else for a8 in all(a7)do local ac=false
if not a1 and(aa:about_equals(a8.screen_position)or a8.position2 and aa:about_equals(a8.position2))then ac=true elseif a1 and a8.last_offscreen_pos and aa:about_equals(a8.last_offscreen_pos)then ac=true end
if ac then a9=a8.firing_ship
local ad=a8.damage or 1
self.hp-=ad
if ad>10 then make_explosion(aa,4,18,self.velocity_vector)end
local ae=self.hp_percent
self.hp_percent=self.hp/self.max_hp
if not self.npc and ae>.1 and self.hp_percent<=.1 then notification_add("thruster malfunction")end
make_explosion(aa,2,6,self.velocity_vector)if rnd()<.5 then add(particles,Spark.new(aa,random_angle(2*rnd()+1)+self.velocity_vector,m,128))end
del(projectiles,a8)self.sprite[g][l]=-5
m=-5
break end end
if m<0 then m=5 end
rectfill(aa.x,aa.y,ab.x,ab.y,m)end end end end
if a9 then self.last_hit_time=secondcount
self.last_hit_attacking_ship=a9 end end
function Ship:turn_left()self:rotate(self.turn_rate)end
function Ship:turn_right()self:rotate(-self.turn_rate)end
function Ship:rotate(af)self.angle=(self.angle+af)%360
self.angle_radians=self.angle/360
self.heading=(450-self.angle)%360 end
function Ship:draw()print_shadowed("‡"..self:hp_string(),0,0,self:hp_color())print_shadowed("pixels/sec "..format_float(10*self.velocity),0,7)if self.accelerating then print_shadowed(format_float(self.current_gees).." gS",0,14)end
self:draw_sprite_rotated()end
local ag=split_number_string"8 8 9 9 10 10 10 11 11 11 "function Ship:hp_color()return ag[ceil(10*self.hp_percent)]end
function Ship:hp_string()return round(100*self.hp_percent).."% "..self.hp.."/"..self.max_hp end
function Ship:is_visible(ah)local ai=round(self.sprite_rows/2)local a2=(self.sector_position-ah+screen_center):round()self.screen_position=a2
return a2.x<128+ai and a2.x>0-ai and a2.y<128+ai and a2.y>0-ai end
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
function approach_nearest_planet()local T,U=nearest_planet()playership:approach_object(T)return false end
function Ship:approach_object(av)local X=av or thissector.planets[random_int(#thissector.planets)+1]self:set_destination(X)self:reset_orders(self.fly_towards_destination)if self.velocity>0 then add(self.orders,self.full_stop)end end
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
if self.hp_percent<=rnd(.1)then aC=0 end
self.current_gees=aC*30.593514175
local w=self.angle_radians
local aD=Vector(cos(w)*aC,sin(w)*aC)local aE=self.velocity_vector
local aF
local aG=rotated_vector(w,self.sprite_rows*-.5)+self.screen_position
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
function HomingWeapon.new(aK,aL)return setmetatable({sector_position=aK.sector_position:clone(),screen_position=aK.screen_position:clone(),velocity_vector=rotated_vector((aK.angle_radians+.25)%1,.5)+aK.velocity_vector,velocity=aK.velocity,target=aL,sprite_rows=1,firing_ship=aK,current_deltav=.1,deltav=.1,hp_percent=1,duration=512,damage=20},HomingWeapon)end
function HomingWeapon:update()self.destination=self.target:predict_sector_position()self:update_steering_velocity()self.angle_radians=self.steering_velocity:angle()if self.duration<500 then self:apply_thrust(abs(self.steering_velocity:length()))end
self.duration-=1
self:update_location()end
function HomingWeapon:draw(aM,a1)local a2=a1 or self.screen_position
self.last_offscreen_pos=a1
if self:is_visible(playership.sector_position)or a1 then a2:draw_line(a2+rotated_vector(self.angle_radians,4),6)end end
setmetatable(HomingWeapon,{__index=Ship})Star={}Star.__index=Star
function Star.new()return setmetatable({position=Vector(),color=7,speed=1},Star)end
function Star:reset(g,l)self.position=Vector(g or random_int(128),l or random_int(128))self.color=random_int(#star_colors[star_color_monochrome+star_color_index+1])+1
self.speed=rnd(0.75)+0.25
return self end
sun_colors=split_number_string"6 14 10 9 13 7 8 9 10 12 "Sun={}Sun.__index=Sun
function Sun.new(o,g,l)local aJ=o or 64+random_int(128)local v=random_int(6,1)return setmetatable({screen_position=Vector(),radius=aJ,sun_color_index=v,color=sun_colors[v+5],sector_position=Vector(g or 0,l or 0)},Sun)end
function Sun:draw(aN)if stellar_object_is_visible(self,aN)then for e=0,1 do self.screen_position:draw_circle(self.radius-e*3,sun_colors[e*5+self.sun_color_index],true)end end end
function stellar_object_is_visible(X,aN)X.screen_position=X.sector_position-aN+screen_center
return X.screen_position.x<128+X.radius and X.screen_position.x>0-X.radius and X.screen_position.y<128+X.radius and X.screen_position.y>0-X.radius end
starfield_count=40
Sector={}Sector.__index=Sector
function Sector.new()local aO={seed=random_int(32767),planets={},starfield={}}srand(aO.seed)for e=1,starfield_count do add(aO.starfield,Star.new():reset())end
setmetatable(aO,Sector)return aO end
function Sector:reset_planet_visibility()for V in all(self.planets)do V.rendered_circle=false
V.rendered_terrain=false end end
function Sector:new_planet_along_elipse()local g
local l
local aP
local aQ=true
while aQ do g=rnd(150)l=sqrt((rnd(35)+40)^2*(1-g^2/(rnd(50)+100)^2))if rnd()<.5 then
g*=-1
 end
if rnd()<.75 then
l*=-1
 end
if#self.planets==0 then break end
aP=32767
for V in all(self.planets)do aP=min(aP,vector_long_distance(Vector(g,l),V.sector_position/33))end
aQ=aP<15 end
return Planet.new(g*33,l*33,(1-Vector(g,l):angle()-.25)%1)end
function Sector:draw_starfield(aM)local aR
local aS
for aT in all(self.starfield)do aR=aT.position+aM*aT.speed*-.5
aS=aT.position+aM*aT.speed*.5
local e=star_color_monochrome+star_color_index+1
local aU=#star_colors[e]local aV=1+(aT.color-1)%aU
aT.position:draw_line(aS,star_colors[e+1][aV])aR:draw_line(aT.position,star_colors[e][aV])end end
function Sector:scroll_starfield(aM)local aW=starfield_count-#self.starfield
for e=1,aW do add(self.starfield,Star.new():reset())end
for aT in all(self.starfield)do aT.position:add(aM*aT.speed*-1)if aW<0 then del(self.starfield,aT)aW=aW+1 elseif aT.position.x>134 then aT:reset(-6) elseif aT.position.x<-6 then aT:reset(134) elseif aT.position.y>134 then aT:reset(false,-6) elseif aT.position.y<-6 then aT:reset(false,134)end end end
function is_offscreen(V,j)local aX=j or 0
local aY=0-aX
local aZ=128+aX
local g=V.screen_position.x
local l=V.screen_position.y
local a_=V.duration<0
if V.deltav then return a_ else return a_ or g>aZ or g<aY or l>aZ or l<aY end end
Spark={}Spark.__index=Spark
function Spark.new(V,b0,v,W)return setmetatable({screen_position=V,particle_velocity=b0,color=v,duration=W or random_int(7,2)},Spark)end
function Spark:update(aM)self.screen_position:add(self.particle_velocity-aM)
self.duration-=1
 end
function Spark:draw(aM)pset(self.screen_position.x,self.screen_position.y,self.color)self:update(aM)end
damage_colors=split_number_string"7 10 9 8 5 0 7 10 9 8 5 0 7 10 9 8 5 0 "function make_explosion(aa,ai,b1,b2)add(particles,Explosion.new(aa,ai,b1,b2))end
Explosion={}Explosion.__index=Explosion
function Explosion.new(b3,ai,b1,aM)local b4=rnd()return setmetatable({screen_position=b3:clone(),particle_velocity=aM:clone(),radius=b4*ai,radius_delta=b4*rnd(.5),len=b1-3,duration=b1},Explosion)end
function Explosion:draw(aM)local aJ=round(self.radius)for e=aJ+3,aJ,-1 do local v=damage_colors[self.len-self.duration+e]if v then self.screen_position:draw_circle(e,v,true)end end
self:update(aM)
self.radius-=self.radius_delta
 end
setmetatable(Explosion,{__index=Spark})MultiCannon={}MultiCannon.__index=MultiCannon
function MultiCannon.new(V,b0,v,Y)return setmetatable({screen_position=V,position2=V:clone(),particle_velocity=b0+b0:perpendicular():normalize()*(rnd(2)-1),color=v,firing_ship=Y,duration=16},MultiCannon)end
function MultiCannon:draw(aM)self.position2:draw_line(self.screen_position,self.color)self.position2=self.screen_position:clone()end
setmetatable(MultiCannon,{__index=Spark})ThrustExhaust={}ThrustExhaust.__index=ThrustExhaust
function ThrustExhaust.new(V,b0)return setmetatable({screen_position=V,particle_velocity=b0,duration=0},ThrustExhaust)end
function ThrustExhaust:draw(aM)local v=random_int(11,9)local b0=self.particle_velocity
local b5=b0:perpendicular()*0.7
local b6=b0*(rnd(2)+2)+b5*(rnd()-.5)local b7=self.screen_position+b6
local b8=self.screen_position+b0+b5
local b9=self.screen_position+b0+b5*-1
local ba=self.screen_position
b8:draw_line(b7,v)b9:draw_line(b7,v)b9:draw_line(ba,v)b8:draw_line(ba,v)if rnd()>.4 then add(particles,Spark.new(b7,aM+b6*.25,v))end
self.screen_position:add(b0-aM)
self.duration-=1
 end
function draw_circle(bb,bc,o,p,m)local bd={}local be=not p
local bf=0
local bg=0
local g=-o
local l=0
local bh=2-2*o
while g<0 do bd[1+g*-1]=l
if be then bf=g
bg=l end
for e=g,bf do sset(bb-e,bc+l,m)sset(bb+e,bc-l,m)end
for e=bg,l do sset(bb-e,bc-g,m)sset(bb+e,bc+g,m)end
o=bh
if o<=l then
l+=1
bh+=l*2+1
 end
if o>g or bh>l then
g+=1
bh+=g*2+1
 end end
bd[1]=bd[2]return bd end
function draw_moon_at_ycoord(bi,bj,bk,o,bl,bd,bm)local g
local l=o-bi
local bn
local bo
local bp
local e
local bq
local br
local bs=abs(l)+1
if bs<=#bd then g=flr(sqrt(o*o-l*l))bn=2*g
if bl<.5 then bo=-bd[bs]bp=flr(bn-2*bl*bn-g) else bo=flr(g-2*bl*bn+bn)bp=bd[bs]end
for e=bo,bp do if not bm or bl<.5 and e>bp-2 or bl>=.5 and e<bo+2 then bq=dark_planet_colors[sget(bj+e,bk-l)+1] else bq=0 end
sset(bj+e,bk-l,bq)end end end
perms={}for e=0,255 do perms[e]=e end
for e=0,255 do local aJ=random_int(32767)%256
perms[e],perms[aJ]=perms[aJ],perms[e]end
local bt={}for e=0,255 do local g=perms[e]%12
perms[e+256],bt[e],bt[e+256]=perms[e],g,g end
function GetN_3d(bu,bv,bw,g,l,bx)local b=.6-g*g-l*l-bx*bx
local by=bt[bu+perms[bv+perms[bw]]]return max(0,b*b*b*b)*(f[by][0]*g+f[by][1]*l+f[by][2]*bx)end
function Simplex3D(g,l,bx)local a=(g+l+bx)*0.333333333
local bu,bv,bw=flr(g+a),flr(l+a),flr(bx+a)local b=(bu+bv+bw)*0.166666667
local bz=g+b-bu
local bA=l+b-bv
local bB=bx+b-bw
bu,bv,bw=band(bu,255),band(bv,255),band(bw,255)local bC=GetN_3d(bu,bv,bw,bz,bA,bB)local bD=GetN_3d(bu+1,bv+1,bw+1,bz-0.5,bA-0.5,bB-0.5)local bE,bF,bG,bH,bI,bJ
if bz>=bA then if bA>=bB then bE,bF,bG,bH,bI,bJ=1,0,0,1,1,0 elseif bz>=bB then bE,bF,bG,bH,bI,bJ=1,0,0,1,0,1 else bE,bF,bG,bH,bI,bJ=0,0,1,1,0,1 end else if bA<bB then bE,bF,bG,bH,bI,bJ=0,0,1,0,1,1 elseif bz<bB then bE,bF,bG,bH,bI,bJ=0,1,0,0,1,1 else bE,bF,bG,bH,bI,bJ=0,1,0,1,1,0 end end
local bK=GetN_3d(bu+bE,bv+bF,bw+bG,bz+0.166666667-bE,bA+0.166666667-bF,bB+0.166666667-bG)local bL=GetN_3d(bu+bH,bv+bI,bw+bJ,bz+0.333333333-bH,bA+0.333333333-bI,bB+0.333333333-bJ)return 32*(bC+bK+bL+bD)end
function create_planet_type(bM,bN,bO,bP,bQ)local bR=split_number_string(bN)return{class_name=bM,noise_octaves=bR[1],noise_zoom=bR[2],noise_persistance=bR[3],minimap_color=bR[4],transparent_color=bQ or 14,full_shadow=bP or"yes",color_map=split_number_string(bO)}end
planet_types={create_planet_type("tundra","5 .5 .6 6 ","7 6 5 4 5 6 7 6 5 4 3 "),create_planet_type("desert","5 .35 .3 9 ","4 4 9 9 4 4 9 9 4 4 9 9 11 1 9 4 9 9 4 9 9 4 9 9 4 9 9 4 9 "),create_planet_type("barren","5 .55 .35 5 ","5 6 5 0 5 6 7 6 5 0 5 6 "),create_planet_type("lava","5 .55 .65 4 ","0 4 0 5 0 4 0 4 9 8 4 0 4 0 5 0 4 0 "),create_planet_type("gas giant","1 .4 .75 2 ","7 6 13 1 2 1 12 "),create_planet_type("gas giant","1 .4 .75 8 ","7 15 14 2 1 2 8 8 ",nil,12),create_planet_type("gas giant","1 .7 .75 10 ","15 10 9 4 9 10 "),create_planet_type("terran","5 .3 .65 11 ","1 1 1 1 1 1 1 13 12 15 11 11 3 3 3 4 5 6 7 ","partial shadow"),create_planet_type("island","5 .55 .65 12 ","1 1 1 1 1 1 1 1 13 12 15 11 3 ","partial shadow")}Planet={}Planet.__index=Planet
function Planet.new(g,l,bl,aJ)local bS=planet_types[random_int(#planet_types)+1]local bT=bS.noise_factor_vert or 1
if bS.class_name=="gas giant"then bS.min_size=50
bT=4
if rnd()<.5 then bT=20 end end
local bU=bS.min_size or 10
local o=aJ or random_int(65,bU)return setmetatable({screen_position=Vector(),radius=o,sector_position=Vector(g,l),bottom_right_coord=2*o-1,phase=bl,planet_type=bS,noise_factor_vert=bT,noisedx=rnd(1024),noisedy=rnd(1024),noisedz=rnd(1024),rendered_circle=false,rendered_terrain=false,color=bS.minimap_color},Planet)end
function Planet:draw(aN)if stellar_object_is_visible(self,aN)then self:render_a_bit_to_sprite_sheet()sspr(0,0,self.bottom_right_coord,self.bottom_right_coord,self.screen_position.x-self.radius,self.screen_position.y-self.radius)end end
function draw_rect(bV,bW,v)for g=0,bV-1 do for l=0,bW-1 do sset(g,l,v)end end end
function Planet:render_a_bit_to_sprite_sheet(bX,bY)local o=self.radius-1
if bX then o=47 end
if not self.rendered_circle then self.width=self.radius*2
self.height=self.radius*2
self.x=0
self.yfromzero=0
self.y=o-self.yfromzero
self.phi=0
thissector:reset_planet_visibility()pal()palt(0,false)palt(self.planet_type.transparent_color,true)if bX then self.width=114
self.height=96
draw_rect(self.width,self.height,0) else draw_rect(self.width,self.height,self.planet_type.transparent_color)self.bxs=draw_circle(o,o,o,true,0)draw_circle(o,o,o,false,self.planet_type.minimap_color)end
self.rendered_circle=true end
if not self.rendered_terrain and self.rendered_circle then local bZ=0
local b_=.5
local c0=b_/self.width
if bX and bY then bZ=.5
b_=1 end
if self.phi<=.25 then for c1=bZ,b_-c0,c0 do if sget(self.x,self.y)~=self.planet_type.transparent_color then local c2=self.planet_type.noise_zoom
local c3=0
local c4=1
local c5=0
for h=1,self.planet_type.noise_octaves do c5=c5+Simplex3D(self.noisedx+c2*cos(self.phi)*cos(c1),self.noisedy+c2*cos(self.phi)*sin(c1),self.noisedz+c2*sin(self.phi)*self.noise_factor_vert)c3=c3+c4
c4=c4*self.planet_type.noise_persistance
c2=c2*2 end
c5=c5/c3
if c5>1 then c5=1 end
if c5<-1 then c5=-1 end
c5=c5+1
c5=c5*(#self.planet_type.color_map-1)/2
c5=round(c5)sset(self.x,self.y,self.planet_type.color_map[c5+1])end
self.x+=1
 end
if not bX then draw_moon_at_ycoord(self.y,o,o,o,self.phase,self.bxs,self.planet_type.full_shadow=="yes")end
self.x=0
if self.phi>=0 then
self.yfromzero+=1
self.y=o+self.yfromzero
self.phi+=.5/(self.height-1) else
 self.y=o-self.yfromzero end
self.phi*=-1
 else self.rendered_terrain=true end end
return self.rendered_terrain end
function add_npc(V)local b3=V or playership
local c6=Ship.new():generate_random_ship()c6:set_position_near_object(b3)c6.npc=true
add(npcships,c6)c6.index=#npcships
if c6.ship_type.name~="freighter"and c6.ship_type.name~="super freighter"and rnd()<.2 then c6.hostile=true end end
function load_sector()thissector=Sector.new()notification_add("arriving in system ngc "..thissector.seed)add(thissector.planets,Sun.new())for e=0,random_int(12)do add(thissector.planets,thissector:new_planet_along_elipse())end
playership:set_position_near_object(thissector.planets[2])playership:clear_target()npcships={}for V in all(thissector.planets)do for e=1,random_int(4)do add_npc(V)end end
return true end
function _init()paused=false
landed=false
particles={}projectiles={}playership=Ship.new()playership:generate_random_ship()load_sector()setup_minimap()show_title_screen=true
local c7=Vector(0,-3)while not btnp(4)do cls()thissector:scroll_starfield(c7)thissector:draw_starfield(c7)circfill(64,135,90,2)circfill(64,172,122,0)map(0,0,6,-15)print_shadowed("\n\n    ”  thrust      —  fire\n  ‹  ‘  rotate  Ž  menu\n    ƒ  reverse",0,70,6,true)flip()end end
minimap_sizes={16,32,48,128,false}function setup_minimap(ai)minimap_size_index=ai or 0
minimap_size=minimap_sizes[minimap_size_index+1]if minimap_size then minimap_size_halved=minimap_size/2
minimap_offset=Vector(126-minimap_size_halved,minimap_size_halved+1)end end
function draw_minimap_planet(X)local b3=X.sector_position+screen_center
if X.planet_type then b3:add(Vector(-X.radius,-X.radius))end
b3=b3/minimap_denominator+minimap_offset
if minimap_size>100 then local aJ=ceil(X.radius/32)b3:draw_circle(aJ+1,X.color) else b3:draw_point(X.color)end end
function draw_minimap_ship(X)local c8=(X.sector_position/minimap_denominator):add(minimap_offset):round()local m=X:targeted_color()if X.npc then c8:draw_point(m)if X.targeted then c8:draw_circle(2,m)end else rect(c8.x-1,c8.y-1,c8.x+1,c8.y+1,15)end end
function draw_minimap()local c9=minimap_size or 0
if minimap_size then if minimap_size>0 and minimap_size<100 then c9=c9+4
rectfill(126-minimap_size,1,126,minimap_size+1,0)rect(125-minimap_size,0,127,minimap_size+2,6,11) else c9=0 end
local g=abs(playership.sector_position.x)local l=abs(playership.sector_position.y)if l>g then g=l end
local ca=min(6,flr(g/5000)+1)minimap_denominator=ca*5000/minimap_size_halved
for V in all(thissector.planets)do draw_minimap_planet(V)end
if framecount%3~=0 then for cb in all(projectiles)do if cb.deltav then draw_minimap_ship(cb)end end
for Y in all(npcships)do draw_minimap_ship(Y)end
draw_minimap_ship(playership)end end
print_shadowed("•"..#npcships,112,c9)end
outlined_text_draw_points=split_number_string"2 2 1 2 0 2 2 0 2 1 1 1 -1 -1 1 -1 -1 1 -1 0 1 0 0 -1 0 1 "function print_shadowed(cc,g,l,cd,ce)local v=cd or 6
local a=darkshipcolors[v]if ce then for e=1,#outlined_text_draw_points,2 do if e>10 then a=v end
print(cc,g+outlined_text_draw_points[e],l+outlined_text_draw_points[e+1],a)end
v=0 else print(cc,g+1,l+1,a)end
print(cc,g,l,v)end
local cf=nil
local cg=4
function notification_add(cc)cf=cc
cg=4 end
function notification_draw()if cg>0 then print_shadowed(cf,0,121)if framecount>=29 then
cg-=1
 end end end
function call_option(e)if current_option_callbacks[e]then local ch=current_option_callbacks[e]()paused=false
if ch==nil then paused=true elseif ch then if type(ch)=="string"then notification_add(ch)end
paused=true end end end
function display_menu(ci,cj,ck)if cj then current_options=cj
current_menu_colors=split_number_string(ci)current_option_callbacks=ck end
for w=.25,1,.25 do local e=w*4
local cl=current_menu_colors[e]if e==pressed then cl=darkshipcolors[cl]end
if current_options[e]then local V=rotated_vector(w,15)+Vector(64,90)if w==.5 then V.x=V.x-4*#current_options[e] elseif w~=1 then V.x=V.x-round(4*#current_options[e]/2)end
print_shadowed(current_options[e],V.x,V.y,cl,true)end end
print_shadowed("  ”  \n‹  ‘\n  ƒ",52,84,6,true)end
function main_menu()display_menu("12 8 11 7 ",{"autopilot","fire missile","options","systems"},{function()display_menu("12 12 6 12 ",{"full stop","near planet","back","follow"},{function()playership:reset_orders(playership.full_stop)return false end,approach_nearest_planet,main_menu,function()if playership.target then playership:reset_orders(playership.seek)playership.seektime=0 end
return false end})end,function()playership:fire_missile()return false end,function()display_menu("6 15 11 10 ",{"back","starfield","minimap size","debug"},{main_menu,function()display_menu("7 15 6 10 ",{"more stars","~dimming","less stars","~colors"},{function()
starfield_count+=5
return"star count: "..starfield_count end,function()star_color_index=(star_color_index+1)%2
return true end,function()starfield_count=max(0,starfield_count-5)return"star count: "..starfield_count end,function()star_color_monochrome=(star_color_monochrome+1)%2*3
return true end})end,function()setup_minimap((minimap_size_index+1)%#minimap_sizes)return true end,function()display_menu("12 6 9 8 ",{"new ship","back","new sector","spawn enemy"},{function()playership:generate_random_ship()return playership.ship_type.name.." "..playership.sprite_rows end,main_menu,load_sector,function()add_npc()npcships[#npcships].hostile=true
npcships[#npcships].target=playership
return"npc created"end})end})end,function()display_menu("8 6 12 11 ",{"target next hostile","back","land","target next"},{next_hostile_target,main_menu,land_at_nearest_planet,next_ship_target})end})end
function landed_menu()display_menu("12 11 6 6 ",{"takeoff","repair"},{takeoff,function()playership:generate_random_ship(playership.seed_value)notification_add("hull damage repaired")return"hull damage repaired"end})end
local cm=0
local cn={}for e=1,96 do cn[e]={flr(-sqrt(-sin(e/193))*48+64)}cn[e][2]=(64-cn[e][1])*2 end
for e=0,95 do poke(64*e+56,peek(64*e+0x1800))end
local co={}for e=0,15 do co[e]={(cos(0.5+0.5/16*e)+1)/2}co[e][2]=(cos(0.5+0.5/16*(e+1))+1)/2-co[e][1]end
function shift_sprite_sheet()for e=0,95 do poke(64*e+0x1838,peek(64*e))memcpy(64*e,64*e+1,56)memcpy(64*e+0x1800,64*e+0x1801,56)poke(64*e+56,peek(64*e+0x1800))end end
function landed_update()local V=landed_planet
if not landed_front_rendered then landed_front_rendered=V:render_a_bit_to_sprite_sheet(true)if landed_front_rendered then V.rendered_circle=false
V.rendered_terrain=false
for cp=1,56 do shift_sprite_sheet()end end else if not landed_back_rendered then landed_back_rendered=V:render_a_bit_to_sprite_sheet(true,true) else cm=1-cm
if cm==0 then shift_sprite_sheet()end end end end
function render_landed_screen()cls()if landed_front_rendered and landed_back_rendered then for e=1,96 do local w,x=cn[e][1],cn[e][2]pal()local cq=ceil(x*co[15][2])for cp=15,0,-1 do if cp==4 then for cr=0,#dark_planet_colors-1 do pal(cr,dark_planet_colors[cr+1])end end
if cp<15 then cq=flr(w+x*co[cp+1][1])-flr(w+x*co[cp][1])end
sspr(cm+cp*7,e-1,7,1,flr(w+x*co[cp][1]),e+16,cq,1)end end
pal()print_shadowed("planet class: "..landed_planet.planet_type.class_name,1,1) else sspr(0,0,127,127,0,0)print_shadowed("mapping surface...",1,1,6,true)end end
framecount=0
secondcount=0
local cs=split_number_string"2 0 3 1 "function _update()framecount=(framecount+1)%30
if framecount==0 then
secondcount+=1
 end
if not landed and btnp(4,0)then paused=not paused
if paused then main_menu()end
pressed=nil end
if landed then landed_update()end
if paused or landed then for e=1,4 do if btn(cs[e])then pressed=e end
if pressed then if pressed==e and not btn(cs[e])then pressed=nil
call_option(e)end end end else if btn(0,0)then playership:turn_left()end
if btn(1,0)then playership:turn_right()end
if btn(3,0)then playership:reverse_direction()end
if btn(5,0)then playership:fire_weapon()end
if btn(2,0)then playership:apply_thrust() else if playership.accelerating and not playership.orders[1]then playership:cut_thrust()end end
for a8 in all(projectiles)do a8:update(playership.velocity_vector)end
for Y in all(npcships)do if Y.last_hit_time and Y.last_hit_time+30>secondcount then Y:reset_orders()Y:flee()if Y.hostile then Y.target=Y.last_hit_attacking_ship
Y.target_index=Y.target.index end else if#Y.orders==0 then if Y.hostile then Y.seektime=0
if not Y.target then next_ship_target(Y,true)end
add(Y.orders,Y.seek) else Y:approach_object()Y.wait_duration=random_int(46,10)Y.wait_time=secondcount
add(Y.orders,Y.wait)end end
Y:follow_current_order()end
Y:update_location()if Y.hp<1 then del(npcships,Y)playership:clear_target()end end
playership:follow_current_order()playership:update_location()thissector:scroll_starfield(playership.velocity_vector)end end
function render_game_screen()cls()thissector:draw_starfield(playership.velocity_vector)for ct in all(thissector.planets)do ct:draw(playership.sector_position)end
for Y in all(npcships)do if Y:is_visible(playership.sector_position)then Y:draw_sprite_rotated()end end
if playership.target then last_offscreen_pos=nil
local cu=playership.screen_position
local cv=playership.target
if cv then if not cv:is_visible(playership.sector_position)then local ar=""..flr((cv.screen_position-cu):scaled_length())local m,cw=cv:targeted_color()local cx=flr(cv.sprite_rows*.5)local W=rotated_vector((cv.screen_position-cu):angle())last_offscreen_pos=W*(60-cx)+screen_center
local b9=last_offscreen_pos:clone():add(Vector(-4*#ar/2))cv:draw_sprite_rotated(last_offscreen_pos)if b9.y>63 then b9:add(Vector(1,-12-cx)) else b9:add(Vector(1,7+cx))end
print_shadowed(ar,round(b9.x),round(b9.y),m)end
print_shadowed("target‡"..cv:hp_string(),0,114,cv:hp_color())end end
if playership.hp<1 then playership:generate_random_ship()end
playership:draw()for cy in all(particles)do if is_offscreen(cy,32)then del(particles,cy) else if paused then cy:draw(Vector()) else cy:draw(playership.velocity_vector)end end end
for a8 in all(projectiles)do if is_offscreen(a8,63)then del(projectiles,a8) else if last_offscreen_pos and a8.sector_position and playership.target and(playership.target.sector_position-a8.sector_position):scaled_length()<=playership.target.sprite_rows then a8:draw(nil,a8.sector_position-playership.target.sector_position+last_offscreen_pos) else a8:draw(playership.velocity_vector)end end end
draw_minimap()end
function _draw()if landed then render_landed_screen() else render_game_screen()end
if paused or landed then display_menu()end
notification_draw()end
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
