pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- heliopause
-- by anthony digirolamo
function split_number_string(s)local a={}local b=1
for c=1,#s do if sub(s,c,c)==" "then add(a,sub(s,b,c-1)+0)b=c+1 end end
return a end
damage_colors=split_number_string"7 10 9 8 5 0 "damage_colors2=split_number_string"7 10 9 8 5 0 7 10 9 8 5 0 7 10 9 8 5 0 "star_color_index=0
star_color_monochrome=0
star_colors={split_number_string"10 14 12 13 7 6 ",split_number_string"9 8 13 1 6 5 ",split_number_string"4 2 1 0 5 1 ",split_number_string"7 6 ",split_number_string"6 5 ",split_number_string"5 1 "}darkshipcolors=split_number_string"0 1 2 2 1 5 6 2 4 9 3 13 1 8 9 "dark_planet_colors=split_number_string"0 0 1 1 0 5 5 5 4 5 5 3 1 1 2 1 "function round(c)return flr(c+.5)end
function ceil(d)return-flr(-d)end
function random_plus_to_minus_one()return random_int(3)-1 end
function random_int(e)return flr(rnd(32767))%e end
function random_angle()return Vector(1):rotate(rnd())end
function format_float(e)return flr(e).."."..flr(e%1*10)end
Vector={}Vector.__index=Vector
function Vector.new(d,f)return setmetatable({x=d or 0,y=f or 0},Vector)end
function Vector:draw_point(g)pset(round(self.x),round(self.y),g)end
function Vector:draw_line(h,g)line(round(self.x),round(self.y),round(h.x),round(h.y),g)end
function Vector:round()self.x=round(self.x)self.y=round(self.y)return self end
function Vector:normalize()local i=self:length()
self.x/=i
self.y/=i
return self end
function Vector:rotate(j)local k=cos(j)local s=sin(j)local d=self.x
local f=self.y
self.x=k*d-s*f
self.y=s*d+k*f
return self end
function Vector:add(h)
self.x+=h.x
self.y+=h.y
return self end
function Vector.__add(l,m)return Vector.new(l.x+m.x,l.y+m.y)end
function Vector.__sub(l,m)return Vector.new(l.x-m.x,l.y-m.y)end
function Vector.__mul(l,m)return Vector.new(l.x*m,l.y*m)end
function Vector.__div(l,m)return Vector.new(l.x/m,l.y/m)end
function Vector:about_equals(h)return round(h.x)==self.x and round(h.y)==self.y end
function Vector:angle()return atan2(self.x,self.y)end
function Vector:length()return sqrt(self.x^2+self.y^2)end
function Vector:scaled_length()return sqrt((self.x/182)^2+(self.y/182)^2)*182 end
function Vector.distance(l,m)return(m-l):length()end
function Vector:clone()return Vector.new(self.x,self.y)end
function Vector:perpendicular()return Vector.new(-self.y,self.x)end
setmetatable(Vector,{__call=function(n,...)return Vector.new(...)end})screen_center=Vector(63,63)Ship={}Ship.__index=Ship
function Ship.new(o,p)local q={npc=false,screen_position=screen_center,sector_position=Vector(),gees=o or 4,turn_rate=p or 8,current_deltav=0,current_gees=0,angle=0,angle_radians=0,heading=90,velocity_angle=0,velocity_angle_opposite=180,velocity=0,velocity_vector=Vector(),orders={}}q.deltav=9.806*q.gees/300
setmetatable(q,Ship)return q end
ship_types={{name="cruiser",shape=split_number_string"3.5 .5 0 -1 .583333 .8125 "},{name="freighter",shape=split_number_string"3 2 0 -3 .2125 .8125 "},{name="fighter",shape=split_number_string"1.5 .25 .75 -2 .7 .8 "}}function Ship:generate_random_ship(r,t,u)self.ship_type=u or ship_types[random_int(#ship_types)+1]local v=t or rnd()srand(v)local w={}for c=6,15 do add(w,c)end
for c=1,6 do del(w,random_int(10)+6)end
self.hp=0
self.sprite=nil
local x={}local y=r or 16
self.length=y
local z=flr(y/2)local A=Vector(1,self.ship_type.shape[1])local B=Vector(1,self.ship_type.shape[2])local C=Vector(1,self.ship_type.shape[3])local D=Vector(1,self.ship_type.shape[4])local E=flr(self.ship_type.shape[5]*y)local F=flr(self.ship_type.shape[6]*y)for f=1,y do add(x,{})for d=1,z do add(x[f],w[4])end end
local G=A
local H=B
local I=round(y/3)local J=round(z/4)for f=2,y-1 do for d=1,z do local g=w[1]if f>=I+random_plus_to_minus_one()and f<=2*I+random_plus_to_minus_one()then g=w[3]end
if d>=J+random_plus_to_minus_one()and f>=2*I+random_plus_to_minus_one()then g=w[2]end
if z-d<max(0,flr(G.y))then if rnd()<.6 then x[f][d]=g
self.hp+=1
if x[f-1][d]==w[4]then x[f][d]=darkshipcolors[g]end end end end
if f>=F then H=D elseif f>=E then H=C end
G=G+H
if G.y>0 and f>3 and f<y-1 then for c=1,random_int(round(G.y/4)+1)do x[f][z-c]=5
self.hp+=2
 end end end
self.sprite_has_odd_columns=random_int(2)for f=y,1,-1 do for d=z-self.sprite_has_odd_columns,1,-1 do add(x[f],x[f][d])end end
self.max_hp=self.hp
self.hp_percent=1
self.sprite_rows=#x
self.sprite_columns=#x[1]self.transparent_color=w[4]self.sprite=x
return self end
function nearest_planet()local K
local L=32767
for M in all(thissector.planets)do if M.planet_type then local N=Vector.distance(playership.sector_position/182,M.sector_position/182)if N<L then L=N
K=M end end end
return K,L*182 end
function land_at_nearest_planet()local K,L=nearest_planet()if L<K.radius*1.4 then if playership.velocity<.5 then thissector:reset_planet_visibility()landed_front_rendered=false
landed_back_rendered=false
landed_planet=K
landed=true
landed_menu()draw_rect(128,128,0) else notifications:add("moving too fast to land")end else notifications:add("too far to land")end
return false end
function takeoff()thissector:reset_planet_visibility()playership:set_position_near_object(landed_planet)landed=false
return false end
function Ship:set_position_near_object(O)local P=O.radius or O.length
self.sector_position=random_angle()*1.2*P+O.sector_position
self:reset_velocity()end
function clear_targeted_ship()for Q in all(npcships)do Q.targeted=false end end
function next_hostile_target()local R
while not R do next_ship_target()R=npcships[playership.target_index].hostile end
return true end
function next_ship_target()clear_targeted_ship()playership.target_index=(playership.target_index or#npcships)%#npcships+1
npcships[playership.target_index].targeted=true
return true end
function next_object_target()clear_targeted_ship()return true end
function Ship:targeted_color()if self.hostile then return 8,2 else return 11,3 end end
function Ship:draw_sprite_rotated()local S=self.screen_position
local l=self.angle_radians
local y=self.sprite_rows
local z=self.sprite_columns
local T=self.transparent_color
if self.targeted then circ(S.x,S.y,y,self:targeted_color())end
local U={}for V in all(projectiles)do if Vector.distance(V.position,S)<y then add(U,V)end end
local W
for f=1,z do for d=1,y do local g=self.sprite[d][f]if g~=T and g~=nil then local X=Vector(y-d-flr(y/2),f-flr(z/2)-1)local Y=Vector(X.x+1,X.y)X:rotate(l):add(S):round()Y:rotate(l):add(S):round()if self.hp<1 then local Z=random_angle()add(particles,Circle.new(X,Z*rnd(.5),g,#damage_colors2-3,Z*y*.5+X))add(particles,Spark.new(X,random_angle()*(rnd(.25)+.25),g,128)) else for V in all(U)do if V.ship~=self and(X:about_equals(V.position)or X:about_equals(V.position2))then W=V.ship
add(particles,Circle.new(X,random_angle(),g,#damage_colors-3))if rnd()<.5 then add(particles,Spark.new(X,random_angle()*(2*rnd()+1),g,128))end
self.hp-=1
self.hp_percent=self.hp/self.max_hp
del(projectiles,V)g=-random_int(#damage_colors)break end end
if g<=0 then if-g<#damage_colors then g=-g+1
self.sprite[d][f]=-g
g=damage_colors[g] else g=5 end end
rectfill(X.x,X.y,Y.x,Y.y,g)end end end end
if W then self.last_hit_time=secondcount
self.last_hit_attacking_ship=W end end
function Ship:turn_left()self:rotate(self.turn_rate)end
function Ship:turn_right()self:rotate(-self.turn_rate)end
function Ship:rotate(_)self.angle=(self.angle+_)%360
self.angle_radians=self.angle/360
self.heading=(450-self.angle)%360 end
function Ship:draw()print_shadowed("cpu:"..stat(1),100,107)print_shadowed("ram:"..stat(0),100,114)local a0=11
if self.hp_percent<=.3 then a0=9 end
if self.hp_percent<=.1 then a0=8 end
print_shadowed(self:hp_string(),0,0,a0,darkshipcolors[a0])print_shadowed(10*self.velocity.." pixels/s",0,7)if self.accelerating then print_shadowed(self.current_gees.."gS",0,14)end
local a1=self.screen_position
local a2=npcships[self.target_index]if a2 then if not a2:is_visible(self.sector_position)then local N=(a2.screen_position/182-a1/182):normalize()local a3=N*(self.length/2+4)+a1
local a4=N*(self.length/2+14)+a1
local g,a5=a2:targeted_color()a3:draw_line(a4,g)local a6=format_float((a2.screen_position-a1):scaled_length())if a4.x>63 then a4:add(Vector(3,-2)) else a4:add(Vector(-4*#a6-1,-2))end
print_shadowed(a6,round(a4.x),round(a4.y),g,a5)end
print_shadowed("target "..a2:hp_string(),0,114)end
self:draw_sprite_rotated()end
function Ship:hp_string()return"hp: "..self.hp.."/"..self.max_hp.." "..100*self.hp_percent.."%"end
function Ship:is_visible(a7)local r=self.length
local S=(self.sector_position-a7+screen_center):round()self.screen_position=S
return S.x<128+r and S.x>0-r and S.y<128+r and S.y>0-r end
function Ship:update_location()if self.velocity>0.0 then self.sector_position:add(self.velocity_vector)end end
function Ship:reset_velocity()self.velocity_vector=Vector()self.velocity=0 end
function Ship:set_destination(a8)self.destination=a8.sector_position
self:update_steering_velocity()self.max_distance_to_destination=self.distance_to_destination end
function Ship:flee()self:set_destination(self.last_hit_attacking_ship)self:update_steering_velocity(1)local a9=self.steering_velocity:angle()local aa=(a9+.5)%1
if self.distance_to_destination<55 then self:rotate_towards_heading(a9)self:apply_thrust() else self:full_stop(true)if self.hostile and self.angle_radians<aa+.1 and self.angle_radians>aa-.1 then self:fire_weapon()end end end
function Ship:update_steering_velocity(ab)local ac=ab or-1
local ad=self.sector_position-self.destination
self.distance_to_destination=ad:scaled_length()self.steering_velocity=(ad-self.velocity_vector)*ac end
function Ship:seek()if self.seektime%20==0 then self:set_destination(npcships[self.target_index]or playership)end
self.seektime+=1
local ae=self.destination-self.sector_position
local a6=ae:scaled_length()self.distance_to_destination=a6
local af=a6/50
local ag=a6/(self.max_distance_to_destination*.7)*af
local ah=min(ag,af)local ad=ae*ag/a6
self.steering_velocity=ad-self.velocity_vector
if self:rotate_towards_heading(self.steering_velocity:angle())then self:apply_thrust(abs(self.steering_velocity:length()))end
if self.hostile then self:fire_weapon()end end
function Ship:fly_towards_destination()self:update_steering_velocity()if self.distance_to_destination>self.max_distance_to_destination*.9 then if self:rotate_towards_heading(self.steering_velocity:angle())then self:apply_thrust()end else self.accelerating=false
self:reverse_direction()if self.distance_to_destination<=self.max_distance_to_destination*.11 then self:order_done(self.full_stop)end end end
function approach_nearest_planet()local K,L=nearest_planet()playership:approach_object(K)return false end
function Ship:approach_object(ai)local O=ai or thissector.planets[random_int(#thissector.planets)+1]self:set_destination(O)self:reset_orders(self.fly_towards_destination)if self.velocity>0 then add(self.orders,self.full_stop)end end
function Ship:follow_current_order()local aj=self.orders[#self.orders]if aj then aj(self)end end
function Ship:order_done(ak)self.orders[#self.orders]=ak end
function Ship:reset_orders(ak)self.orders={}if ak then add(self.orders,ak)end end
function Ship:cut_thrust()self.accelerating=false
self.current_deltav=self.deltav/3 end
function Ship:wait()if secondcount>self.wait_duration+self.wait_time then self:order_done()end end
function Ship:full_stop()if self.velocity>0 and self:reverse_direction()then self:apply_thrust()if self.velocity<1.2*self.deltav then self:reset_velocity()self:order_done()end end end
function Ship:fire_weapon(al)local am=Vector(1):rotate(self.angle_radians)local an=am*self.length/2+self.screen_position
if framecount%3==0 then add(projectiles,MultiCannon.new(an,am*6+self.velocity_vector,12,self))sfx(0)end end
function Ship:apply_thrust(ao)self.accelerating=true
if self.current_deltav<self.deltav then 
self.current_deltav+=self.deltav/30
 else self.current_deltav=self.deltav end
local ap=self.current_deltav
if ao and ap>ao then ap=ao end
if self.hp_percent<.15+rnd(.1)-.05 then ap=0 end
self.current_gees=ap*300/9.806
local l=self.angle_radians
local aq=Vector(cos(l)*ap,sin(l)*ap)local ar=self.velocity_vector
local as
ar:add(aq)if ar.x>180 or ar.y>180 then as=ar:scaled_length() else as=ar:length()end
self.velocity_angle=ar:angle()self.velocity_angle_opposite=(self.velocity_angle+0.5)%1
local at=Vector(1):rotate(l)*-(self.length/2)+self.screen_position
if as<.05 then as=0.0
ar=Vector() else add(particles,ThrustExhaust.new(at,aq*-1.3*self.length))end
self.velocity=as
self.velocity_vector=ar end
function Ship:reverse_direction()if self.velocity>0.0 then return self:rotate_towards_heading(self.velocity_angle_opposite)end end
function Ship:rotate_towards_heading(au)local av=(au*360-self.angle+180)%360-180
if av~=0 then local aw=self.turn_rate*av/abs(av)if abs(av)>abs(aw)then av=aw end
self:rotate(av)end
return av<0.1 and av>-.1 end
Star={}Star.__index=Star
function Star.new()return setmetatable({position=Vector(),color=7,speed=1},Star)end
function Star:reset(d,f)self.position=Vector(d or random_int(128),f or random_int(128))self.color=random_int(#star_colors[star_color_monochrome+star_color_index+1])+1
self.speed=rnd(0.75)+0.25
return self end
sun_colors={split_number_string"6 14 10 9 13 ",split_number_string"7 8 9 10 12 "}Sun={}Sun.__index=Sun
function Sun.new(P,d,f)local aw=P or 64+random_int(128)local k=random_int(5)+1
return setmetatable({screen_position=Vector(),radius=aw,sun_color_index=k,color=sun_colors[2][k],sector_position=Vector(d or 0,f or 0)},Sun)end
function stellar_object_is_visible(O,ax)O.screen_position=O.sector_position-ax+screen_center
return O.screen_position.x<128+O.radius and O.screen_position.x>0-O.radius and O.screen_position.y<128+O.radius and O.screen_position.y>0-O.radius end
function Sun:draw(ax)if stellar_object_is_visible(self,ax)then for c=0,1 do circfill(self.screen_position.x,self.screen_position.y,self.radius-c*3,sun_colors[c+1][self.sun_color_index])end end end
starfield_count=50
Sector={}Sector.__index=Sector
function Sector.new()local ay={seed=random_int(32767),planets={},starfield={}}srand(ay.seed)for c=1,starfield_count do add(ay.starfield,Star.new():reset())end
setmetatable(ay,Sector)return ay end
function Sector:reset_planet_visibility()for M in all(self.planets)do M.rendered_circle=false
M.rendered_terrain=false end end
function Sector:new_planet_along_elipse()local d
local f
local az
local aA=true
while aA do d=rnd(150)f=sqrt((rnd(35)+40)^2*(1-d^2/(rnd(50)+100)^2))if rnd()<.5 then 
d*=-1
 end
if rnd()<.75 then 
f*=-1
 end
if#self.planets==0 then break end
az=32767
for M in all(self.planets)do az=min(az,Vector.distance(Vector(d,f),M.sector_position/33))end
aA=az<15 end
return Planet.new(d*33,f*33,(1-Vector(d,f):angle()-.25)%1)end
function Sector:draw_starfield(aB)local aC
local aD
for aE in all(self.starfield)do aC=aE.position+aB*aE.speed*-.5
aD=aE.position+aB*aE.speed*.5
local c=star_color_monochrome+star_color_index+1
local aF=#star_colors[c]local aG=1+(aE.color-1)%aF
aE.position:draw_line(aD,star_colors[c+1][aG])aC:draw_line(aE.position,star_colors[c][aG])end end
function Sector:scroll_starfield(aB)local aH=starfield_count-#self.starfield
for c=1,aH do add(self.starfield,Star.new():reset())end
for aE in all(self.starfield)do aE.position:add(aB*aE.speed*-1)if aH<0 then del(self.starfield,aE)aH=aH+1 elseif aE.position.x>134 then aE:reset(-6) elseif aE.position.x<-6 then aE:reset(134) elseif aE.position.y>134 then aE:reset(false,-6) elseif aE.position.y<-6 then aE:reset(false,134)end end end
function is_offscreen(M,aI)local aJ=aI or 0
local aK=0-aJ
local aL=128+aJ
local d=M.position.x
local f=M.position.y
return M.duration<0 or d>aL or d<aK or f>aL or f<aK end
MultiCannon={}MultiCannon.__index=MultiCannon
function MultiCannon.new(M,aM,k,aN)local aO=aM:perpendicular():normalize()*(rnd(2)-1)return setmetatable({position=M,position2=M:clone(),particle_velocity=aM+aO,color=k,ship=aN,duration=256},MultiCannon)end
function MultiCannon:draw(aB)self.position:add(self.particle_velocity-aB)self.position2:draw_line(self.position,self.color)self.position2=self.position:clone()
self.duration-=1
 end
Spark={}Spark.__index=Spark
function Spark.new(M,aM,k,N)return setmetatable({position=M,particle_velocity=aM,color=k,duration=N or random_int(5)+2},Spark)end
function Spark:update(aB)self.position:add(self.particle_velocity-aB)
self.duration-=1
 end
function Spark:draw(aB)pset(self.position.x,self.position.y,self.color)self:update(aB)end
Circle={}Circle.__index=Circle
function Circle.new(M,aM,k,N,aP)return setmetatable({position=M:clone(),particle_velocity=aM,color=k,center_position=aP or M:clone(),duration=N},Circle)end
function Circle:draw(aB)local aQ=flr(Vector.distance(self.position,self.center_position))for c=aQ+3,aQ,-1 do local k=damage_colors2[#damage_colors2-3-self.duration+c]if k then circfill(self.center_position.x,self.center_position.y,c,k)end end
self:update(aB)end
setmetatable(Circle,{__index=Spark})ThrustExhaust={}ThrustExhaust.__index=ThrustExhaust
function ThrustExhaust.new(M,aM)return setmetatable({position=M,particle_velocity=aM,duration=0},ThrustExhaust)end
function ThrustExhaust:draw(aB)local k=9+random_int(2)local aO=self.particle_velocity:perpendicular()*0.7
local aR=self.particle_velocity*(rnd(2)+2)+aO*(rnd()-.5)local aS=self.position+aR
local a3=self.position+self.particle_velocity+aO
local a4=self.position+self.particle_velocity+aO*-1
local aT=self.position
a3:draw_line(aS,k)a4:draw_line(aS,k)a4:draw_line(aT,k)a3:draw_line(aT,k)if rnd()>.4 then add(particles,Spark.new(aS,aB+aR*.25,k))end
self.position:add(self.particle_velocity-aB)
self.duration-=1
 end
function draw_circle(aU,aV,P,aW,g)local aX={}local aY=not aW
local aZ=0
local a_=0
local d=-P
local f=0
local b0=2-2*P
while d<0 do aX[1+d*-1]=f
if aY then aZ=d
a_=f end
for c=d,aZ do sset(aU-c,aV+f,g)sset(aU+c,aV-f,g)end
for c=a_,f do sset(aU-c,aV-d,g)sset(aU+c,aV+d,g)end
P=b0
if P<=f then 
f+=1
b0=b0+f*2+1 end
if P>d or b0>f then 
d+=1
b0=b0+d*2+1 end end
aX[1]=aX[2]return aX end
function draw_moon_at_ycoord(b1,b2,b3,P,b4,aX,b5)local d
local f
local b6
local b7
local b8
local c
local b9
local ba
f=P-b1
local bb=abs(f)+1
if bb<=#aX then d=flr(sqrt(P*P-f*f))b6=2*d
if b4<.5 then b7=-aX[bb]b8=flr(b6-2*b4*b6-d) else b7=flr(d-2*b4*b6+b6)b8=aX[bb]end
for c=b7,b8 do if not b5 or b4<.5 and c>b8-2 or b4>=.5 and c<b7+2 then b9=dark_planet_colors[sget(b2+c,b3-f)+1] else b9=0 end
sset(b2+c,b3-f,b9)end end end
perms={}for c=0,255 do perms[c]=c end
for c=0,255 do local aw=random_int(32767)%256
perms[c],perms[aw]=perms[aw],perms[c]end
local bc={}for c=0,255 do local d=perms[c]%12
perms[c+256],bc[c],bc[c+256]=perms[c],d,d end
local bd={{1,1,0},{-1,1,0},{1,-1,0},{-1,-1,0},{1,0,1},{-1,0,1},{1,0,-1},{-1,0,-1},{0,1,1},{0,-1,1},{0,1,-1},{0,-1,-1}}for be in all(bd)do for c=0,2 do be[c]=be[c+1]end end
for c=0,11 do bd[c]=bd[c+1]end
function GetN_3d(bf,bg,bh,d,f,bi)local a=.6-d*d-f*f-bi*bi
local bj=bc[bf+perms[bg+perms[bh]]]return max(0,a*a*a*a)*(bd[bj][0]*d+bd[bj][1]*f+bd[bj][2]*bi)end
function Simplex3D(d,f,bi)local s=(d+f+bi)*0.333333333
local bf,bg,bh=flr(d+s),flr(f+s),flr(bi+s)local a=(bf+bg+bh)*0.166666667
local bk=d+a-bf
local bl=f+a-bg
local bm=bi+a-bh
bf,bg,bh=band(bf,255),band(bg,255),band(bh,255)local bn=GetN_3d(bf,bg,bh,bk,bl,bm)local bo=GetN_3d(bf+1,bg+1,bh+1,bk-0.5,bl-0.5,bm-0.5)local bp,bq,br,bs,bt,bu
if bk>=bl then if bl>=bm then bp,bq,br,bs,bt,bu=1,0,0,1,1,0 elseif bk>=bm then bp,bq,br,bs,bt,bu=1,0,0,1,0,1 else bp,bq,br,bs,bt,bu=0,0,1,1,0,1 end else if bl<bm then bp,bq,br,bs,bt,bu=0,0,1,0,1,1 elseif bk<bm then bp,bq,br,bs,bt,bu=0,1,0,0,1,1 else bp,bq,br,bs,bt,bu=0,1,0,1,1,0 end end
local bv=GetN_3d(bf+bp,bg+bq,bh+br,bk+0.166666667-bp,bl+0.166666667-bq,bm+0.166666667-br)local bw=GetN_3d(bf+bs,bg+bt,bh+bu,bk+0.333333333-bs,bl+0.333333333-bt,bm+0.333333333-bu)return 32*(bn+bv+bw+bo)end
function create_planet_type(bx,by,bz,bA,bB,bC,bD,bE)return{class_name=bx,noise_octaves=by,noise_zoom=bz,noise_persistance=bA,transparent_color=bE or 14,minimap_color=bB,full_shadow=bD or"yes",color_map=bC}end
planet_types={create_planet_type("tundra",5,.5,.6,6,split_number_string"7 6 5 4 5 6 7 6 5 4 3 "),create_planet_type("desert",5,.35,.3,9,split_number_string"4 4 9 9 4 4 9 9 4 4 9 9 11 1 9 4 9 9 4 9 9 4 9 9 4 9 9 4 9 "),create_planet_type("barren",5,.55,.35,5,split_number_string"5 6 5 0 5 6 7 6 5 0 5 6 "),create_planet_type("lava",5,.55,.65,4,split_number_string"0 4 0 5 0 4 0 4 9 8 4 0 4 0 5 0 4 0 "),create_planet_type("gas giant",1,.4,.75,2,split_number_string"7 6 13 1 2 1 12 "),create_planet_type("gas giant",1,.4,.75,8,split_number_string"7 15 14 2 1 2 8 8 ",nil,12),create_planet_type("gas giant",1,.7,.75,10,split_number_string"15 10 9 4 9 10 "),create_planet_type("terran",5,.3,.65,11,split_number_string"1 1 1 1 1 1 1 13 12 15 11 11 3 3 3 4 5 6 7 ","partial shadow"),create_planet_type("island",5,.55,.65,12,split_number_string"1 1 1 1 1 1 1 1 13 12 15 11 3 ","partial shadow")}Planet={}Planet.__index=Planet
function Planet.new(d,f,b4,aw)local bF=planet_types[random_int(#planet_types)+1]local bG=bF.noise_factor_vert or 1
if bF.class_name=="gas giant"then bF.min_size=50
bG=4
if rnd()<.5 then bG=20 end end
local bH=bF.min_size or 10
local P=aw or bH+random_int(64-bH)+1
return setmetatable({screen_position=Vector(),radius=P,sector_position=Vector(d,f),bottom_right_coord=2*P-1,phase=b4,planet_type=bF,noise_factor_vert=bG,noisedx=rnd(1024),noisedy=rnd(1024),noisedz=rnd(1024),rendered_circle=false,rendered_terrain=false,color=bF.minimap_color},Planet)end
function Planet:draw(ax)if stellar_object_is_visible(self,ax)then self:render_a_bit_to_sprite_sheet()sspr(0,0,self.bottom_right_coord,self.bottom_right_coord,self.screen_position.x-self.radius,self.screen_position.y-self.radius)end end
function draw_rect(bI,bJ,k)for d=0,bI-1 do for f=0,bJ-1 do sset(d,f,k)end end end
function Planet:render_a_bit_to_sprite_sheet(bK,bL)local P=self.radius-1
if bK then P=47 end
if not self.rendered_circle then self.width=self.radius*2
self.height=self.radius*2
self.x=0
self.yfromzero=0
self.y=P-self.yfromzero
self.phi=0
thissector:reset_planet_visibility()pal()palt(0,false)palt(self.planet_type.transparent_color,true)if bK then self.width=114
self.height=96
draw_rect(self.width,self.height,0) else draw_rect(self.width,self.height,self.planet_type.transparent_color)self.bxs=draw_circle(P,P,P,true,0)draw_circle(P,P,P,false,self.planet_type.minimap_color)end
self.rendered_circle=true end
if not self.rendered_terrain and self.rendered_circle then local bM=0
local bN=.5
local bO=bN/self.width
if bK and bL then bM=.5
bN=1 end
if self.phi<=.25 then for bP=bM,bN-bO,bO do if sget(self.x,self.y)~=self.planet_type.transparent_color then local bQ=self.planet_type.noise_zoom
local bR=0
local bS=1
local bT=0
for e=1,self.planet_type.noise_octaves do bT=bT+Simplex3D(self.noisedx+bQ*cos(self.phi)*cos(bP),self.noisedy+bQ*cos(self.phi)*sin(bP),self.noisedz+bQ*sin(self.phi)*self.noise_factor_vert)bR=bR+bS
bS=bS*self.planet_type.noise_persistance
bQ=bQ*2 end
bT=bT/bR
if bT>1 then bT=1 end
if bT<-1 then bT=-1 end
bT=bT+1
bT=bT*(#self.planet_type.color_map-1)/2
bT=round(bT)sset(self.x,self.y,self.planet_type.color_map[bT+1])end
self.x+=1
 end
if not bK then draw_moon_at_ycoord(self.y,P,P,P,self.phase,self.bxs,self.planet_type.full_shadow=="yes")end
self.x=0
if self.phi>=0 then 
self.yfromzero+=1
self.y=P+self.yfromzero
self.phi+=.5/(self.height-1) else
 self.y=P-self.yfromzero end
self.phi*=-1
 else self.rendered_terrain=true end end
return self.rendered_terrain end
function add_npc(M)local bU=M or playership
local bV=Ship.new(2,4):generate_random_ship(12+random_int(8))bV:set_position_near_object(bU)bV.npc=true
add(npcships,bV)end
function load_sector()thissector=Sector.new()notifications:cancel_all()notifications:add("arriving in system ngc "..thissector.seed)add(thissector.planets,Sun.new())for c=0,1+random_int(12)do add(thissector.planets,thissector:new_planet_along_elipse())end
playership:set_position_near_object(thissector.planets[2])playership.target_index=nil
npcships={}for M in all(thissector.planets)do for c=1,random_int(4)do add_npc(M)end end
npcships[1].hostile=true
return true end
function _init()paused=false
landed=false
particles={}projectiles={}notifications=Notification.new()playership=Ship.new()playership:generate_random_ship()load_sector()setup_minimap()end
minimap_sizes={16,32,48,128,false}function setup_minimap(r)minimap_size_index=r or 0
minimap_size=minimap_sizes[minimap_size_index+1]if minimap_size then minimap_size_halved=minimap_size/2
minimap_offset=Vector(126-minimap_size_halved,minimap_size_halved+1)end end
function draw_minimap_planet(O)local bU=O.sector_position+screen_center
if O.planet_type then bU:add(Vector(-O.radius,-O.radius))end
bU=bU/minimap_denominator+minimap_offset
if minimap_size>100 then local aw=ceil(O.radius/32)circ(bU.x,bU.y,aw+1,O.color) else bU:draw_point(O.color)end end
function draw_minimap_ship(O)local bW=(O.sector_position/minimap_denominator):add(minimap_offset)if O.npc then bW:draw_point(O:targeted_color()) else bW:round()rect(bW.x-1,bW.y-1,bW.x+1,bW.y+1,15)end end
function draw_minimap()if minimap_size then if minimap_size<100 then rectfill(126-minimap_size,1,126,minimap_size+1,0)rect(125-minimap_size,0,127,minimap_size+2,6,11)end
local d=abs(playership.sector_position.x)local f=abs(playership.sector_position.y)if f>d then d=f end
local bX=min(6,flr(d/5000)+1)minimap_denominator=bX*5000/minimap_size_halved
for M in all(thissector.planets)do draw_minimap_planet(M)end
if framecount%2==1 then for Q in all(npcships)do draw_minimap_ship(Q)end
draw_minimap_ship(playership)end end end
outlined_text_draw_points=split_number_string"-1 -1 1 -1 -1 1 -1 0 1 0 0 -1 0 1 "function print_shadowed(bY,d,f,g,bZ,b_)local k=g or 6
local s=bZ or 5
if b_ then for c=1,#outlined_text_draw_points,2 do print(bY,d+outlined_text_draw_points[c],f+outlined_text_draw_points[c+1],s)end end
print(bY,d+1,f+1,s)print(bY,d,f,k)end
Notification={}Notification.__index=Notification
function Notification.new()return setmetatable({messages={},display_time=4},Notification)end
function Notification:add(bY)add(self.messages,bY)end
function Notification:cancel_current()del(self.messages,self.messages[1])self.display_time=4 end
function Notification:cancel_all(bY)if bY then del(self.messages,bY) else self.messages={}end
self.display_time=4 end
function Notification:draw()if#self.messages>0 then print_shadowed(self.messages[1],0,121)if framecount==29 then 
self.display_time-=1
 end
if self.display_time<1 then self:cancel_current()end end end
function call_option(c)if current_option_callbacks[c]then local c0=current_option_callbacks[c]()paused=false
if c0==nil then paused=true elseif c0 then display_menu(nil,nil,c)if type(c0)=="string"then print_shadowed(c0,64-round(4*#c0/2),40,11,0,true)end
paused=true end end end
function display_menu(c1,c2,c3)if c1 then current_options=c1
current_option_callbacks=c2 end
if not landed then render_game_screen()end
local aP=Vector(64,90)local c4=aP+Vector(-1,2)for l=.25,1,.25 do local c=l*4
local c5=6
local c6=0
if c3==c then c5=11 end
local M=Vector(8):rotate(l)+c4
M:draw_line(Vector(3):rotate(l)+c4,c5)M:draw_line(Vector(5,2):rotate(l)+c4,c5)M:draw_line(Vector(5,-2):rotate(l)+c4,c5)if current_options[c]then M=Vector(14):rotate(l)+aP
if l==.5 then M:add(Vector(-4*#current_options[c])) elseif l~=1 then M:add(Vector(round(-4*#current_options[c]/2)))end
print_shadowed(current_options[c],M.x,M.y,c5,c6,true)end end end
function main_menu()display_menu({"autopilot","debug","display options","systems"},{function()display_menu({"nearest planet","full stop","back","follow"},{approach_nearest_planet,function()playership:reset_orders(playership.full_stop)return false end,main_menu,function()playership:reset_orders(playership.seek)playership.seektime=0
return false end})end,function()display_menu({"new ship","spawn enemy","new sector","back"},{function()s=max((s+1)%48,8)playership:generate_random_ship(s)return playership.ship_type.name.." "..s end,function()add_npc()npcships[#npcships].hostile=true
return"npc created"end,load_sector,main_menu})end,function()display_menu({"back","starfield","minimap size"},{main_menu,function()display_menu({"more stars","~dimming","less stars","~colors"},{function()
starfield_count+=5
return"star count: "..starfield_count end,function()star_color_index=(star_color_index+1)%2
return true end,function()starfield_count=max(0,starfield_count-5)return"star count: "..starfield_count end,function()star_color_monochrome=(star_color_monochrome+1)%2*3
return true end})end,function()setup_minimap((minimap_size_index+1)%#minimap_sizes)return true end})end,function()display_menu({"target next hostile","back","land","target next"},{next_hostile_target,main_menu,land_at_nearest_planet,next_ship_target})end})end
function landed_menu()display_menu({"takeoff"},{takeoff})end
local c7=0
local c8={}for c=1,96 do c8[c]={flr(-sqrt(-sin(c/193))*48+64)}c8[c][2]=(64-c8[c][1])*2 end
for c=0,95 do poke(64*c+56,peek(64*c+0x1800))end
local c9={}for c=0,15 do c9[c]={(cos(0.5+0.5/16*c)+1)/2}c9[c][2]=(cos(0.5+0.5/16*(c+1))+1)/2-c9[c][1]end
function shift_sprite_sheet()for c=0,95 do poke(64*c+0x1838,peek(64*c))memcpy(64*c,64*c+1,56)memcpy(64*c+0x1800,64*c+0x1801,56)poke(64*c+56,peek(64*c+0x1800))end end
function landed_update()local M=landed_planet
if not landed_front_rendered then landed_front_rendered=M:render_a_bit_to_sprite_sheet(true)if landed_front_rendered then M.rendered_circle=false
M.rendered_terrain=false
for ca=1,56 do shift_sprite_sheet()end end else if not landed_back_rendered then landed_back_rendered=M:render_a_bit_to_sprite_sheet(true,true) else c7=1-c7
if c7==0 then shift_sprite_sheet()end end end end
function render_landed_screen()cls()if landed_front_rendered and landed_back_rendered then for c=1,96 do local l,m=c8[c][1],c8[c][2]pal()local cb=ceil(m*c9[15][2])for ca=15,0,-1 do if ca==4 then for cc=0,#dark_planet_colors-1 do pal(cc,dark_planet_colors[cc+1])end end
if ca<15 then cb=flr(l+m*c9[ca+1][1])-flr(l+m*c9[ca][1])end
sspr(c7+ca*7,c-1,7,1,flr(l+m*c9[ca][1]),c+16,cb,1)end end
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
for Q in all(npcships)do if Q.last_hit_time and Q.last_hit_time+30>secondcount then Q:reset_orders()Q:flee() else if#Q.orders==0 then if Q.hostile then Q.seektime=0
add(Q.orders,Q.seek) else Q:approach_object()Q.wait_duration=11+random_int(50)Q.wait_time=secondcount
add(Q.orders,Q.wait)end end
Q:follow_current_order()end
Q:update_location()if Q.hp<1 then del(npcships,Q)playership.target_index=false end end
playership:follow_current_order()playership:update_location()thissector:scroll_starfield(playership.velocity_vector)end end
function render_game_screen()cls()thissector:draw_starfield(playership.velocity_vector)for cd in all(thissector.planets)do cd:draw(playership.sector_position)end
for Q in all(npcships)do if Q:is_visible(playership.sector_position)then Q:draw_sprite_rotated()end end
if playership.hp<1 then playership:generate_random_ship()end
playership:draw()for ce in all(particles)do if is_offscreen(ce)then del(particles,ce) else ce:draw(playership.velocity_vector)end end
for V in all(projectiles)do if is_offscreen(V,63)then del(projectiles,V) else V:draw(playership.velocity_vector)end end
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
