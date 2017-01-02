pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- heliopause
-- by anthony digirolamo

function split(s)
local t={}
local ti=split_start or 0
local start_index=1
local hex=sub(s,1,1)=="x"
for i=1,#s do
if hex and i>1 then
 t[ti]=("0x"..sub(s,i,i))+0
 ti+=1
elseif sub(s,i,i)==" " then
 t[ti]=sub(s,start_index,i-1)+0
 ti+=1
 start_index=i+1
end
end
return t
end

function new_planet(name,o,cmap)
local args=split(o)
return{
class_name=name,
noise_octaves=args[1],
noise_zoom=args[2],
noise_persistance=args[3],
mmap_color=args[4],
full_shadow=args[5] or 1,
transparent_color=args[6] or 14,
minc=args[7] or 1,
maxc=args[8] or 1,
min_size=args[9] or 16,
color_map=split(cmap)
}end

local grads3={
split"-1 1 0 ",
split"1 -1 0 ",
split"-1 -1 0 ",
split"1 0 1 ",
split"-1 0 1 ",
split"1 0 -1 ",
split"-1 0 -1 ",
split"0 1 1 ",
split"0 -1 1 ",
split"0 1 -1 ",
split"0 -1 -1 "}
grads3[0]=split"1 1 0 "

split_start=1

star_color_index=0
star_color_monochrome=0
star_colors={
split"xaecd76",
split"x98d165",
split"x421051",
split"x767676",
split"x656565",
split"x515151",
}

darkshipcolors=split"x01221562493d189"
dark_planet_colors=split"x0011055545531121"
health_colormap=split"x8899aaabbb"
damage_colors=split"x7a98507a98507a9850"
sun_colors=split"x6ea9d789ac"

ship_types={
{"fighter",
split"1.5 .25 .7 .75 .8 -2 1 14 18 "},
{"cruiser",
split"3.5 .5 .583333 0 .8125 -1 1 18 24 "},
{"freighter",
split"3 2 .2125 0 .8125 -3 1 16 22 "},
{"super freighter",
split"6 0 .7 -.25 .85 .25 1 32 45 "},
{"station",
split"4 1 .1667 -1 .3334 0 .6668 1 .8335 -1 1 30 40 "},
}

planet_types={
new_planet(
"tundra",
"5 .5 .6 6 ",
"x76545676543"),
new_planet(
"desert",
"5 .35 .3 9 ",
"x449944994499b1949949949949949"),
new_planet(
"barren",
"5 .55 .35 5 ",
"x565056765056"),
new_planet(
"lava",
"5 .55 .65 4 ",
"x040504049840405040"),
new_planet(
"gas giant",
"1 .4 .75 2 1 14 4 20 50 ",
"x76d121c"),
new_planet(
"gas giant",
"1 .4 .75 8 1 12 4 20 50 ",
"x7fe21288"),
new_planet(
"gas giant",
"1 .7 .75 10 1 14 4 20 50 ",
"xfa949a"),
new_planet(
"terran",
"5 .3 .65 11 0 ",
"x1111111dcfbb3334567"),
new_planet(
"island",
"5 .55 .65 12 0 ",
"x11111111dcfb3"),
new_planet(
"rainbow giant",
"1 .7 .75 15 1 4 4 20 50 ",
"x1dcba9e82"),
}

v={}
v.__index=v
function v.new(x,y)
return setmetatable({x=x or 0,y=y or 0},v)end
function v:add(v)
self.x+=v.x
self.y+=v.y
return self
end

function v.__add(a,b)
return v.new(a.x+b.x,a.y+b.y)end
function v.__sub(a,b)
return v.new(a.x-b.x,a.y-b.y)end
function v.__mul(a,b)
return v.new(a.x*b,a.y*b)end
function v.__div(a,b)
return v.new(a.x/b,a.y/b)end

function v:clone()
return v.new(self.x,self.y)end
function v:about_equals(v)
return ro(v.x)==self.x and ro(v.y)==self.y end
function v:angle()
return atan2(self.x,self.y)end

function v:length()
return sqrt(self.x^2+self.y^2)end
function v:scaled_length()
return 182*sqrt((self.x/182)^2+(self.y/182)^2)end
function scaled_dist(a,b)
return (b-a):scaled_length()end

function v:perpendicular()
return v.new(-self.y,self.x)end

function v:normalize()
local l=self:length()
self.x/=l
self.y/=l
return self end

function v:rotate(phi)
local c=cos(phi)
local s=sin(phi)
local x=self.x
local y=self.y
self.x=c*x-s*y
self.y=s*x+c*y
return self end

function v:ro()
self.x=ro(self.x)
self.y=ro(self.y)
return self end

function v:draw_point(c)
pset(
ro(self.x),
ro(self.y),c)end

function v:draw_line(v,c)
line(
ro(self.x),
ro(self.y),
ro(v.x),
ro(v.y),c)end

function v:draw_circle(radius,c,fill)
local method=circ
if fill then method=circfill end
method(
ro(self.x),
ro(self.y),
ro(radius),c)end

setmetatable(v,{__call=function(_,...) return v.new(...) end})

function ra(len)
return rotatedv(rnd(),len)end
function rotatedv(angle,x,y)
return v(x or 1,y):rotate(angle)end
function ro(i)
return flr(i+.5)end
function ceil(x)
return -flr(-x)end
function ri1()
return ri(3)-1 end
function ri(n,minimum)
local m=minimum or 0
return m+flr(rnd(32767))%(n-m)end
function format(num)
local n=flr(num*10+0.5)/10
return flr(n).."."..ro((n%1)*10)end

screen_center=v(63,63)

ship={}
ship.__index=ship
function ship.new(h)
local shp={
npc=false,
hostile=h,
scrpos=screen_center,
secpos=v(),
cur_deltav=0,
cur_gees=0,
angle=0,
angle_radians=0,
heading=90,
velocity_angle=0,
velocity_angle_opposite=180,
velocity=0,
velocity_vector=v(),
orders={},
last_fire_time=0
}
setmetatable(shp,ship)
return shp
end

function ship:buildship(seed,stype)
self.stypei=stype or ri(#ship_types)+1
self.ship_type=ship_types[self.stypei]

local seed_value=seed or ri(32767)
srand(seed_value)
self.seed_value=seed_value
self.name=self.ship_type[1]
local shape=self.ship_type[2]

local scs=split"x6789abcdef"
for i=1,6 do
 del(scs,scs[ri(#scs)+1])
end

local hp=0
local ship_mask={}
local rows=ri(shape[#shape]+1,shape[#shape-1])
local cols=flr(rows/2)

for y=1,rows do
add(ship_mask,{})
for x=1,cols do
add(ship_mask[y],scs[4])
end
end

local slopei,slope=2,v(1,shape[1])
local thirdy,thirdx=ro(rows/3),ro(cols/4)

for y=2,rows-1 do

for x=1,cols do

local color=scs[1]
if y>=thirdy+ri1() and
y<=2*thirdy+ri1() then
 color=scs[3]
end
if x>=thirdx+ri1() and
y>=2*thirdy+ri1() then
 color=scs[2]
end

if cols-x<max(0,flr(slope.y)) then
 if rnd()<.6 then
  ship_mask[y][x]=color
  hp+=1
  if ship_mask[y-1][x]==scs[4] then
   ship_mask[y][x]=darkshipcolors[color]
  end
 end
end

end

if y>=flr(shape[slopei+1]*rows) then
 slopei+=2
end
slope=slope+v(1,shape[slopei])

if slope.y>0 and y>3 and y<rows-1 then
 for i=1,ri(ro(slope.y/4)+1) do
  ship_mask[y][cols-i]=5
  hp+=2
 end
end

end

local odd_columns=ri(2)
for y=rows,1,-1 do
for x=cols-odd_columns,1,-1 do
add(ship_mask[y],ship_mask[y][x])
end
end

if self.stypei==#ship_types then
hp*=4
end

self.hp=hp
self.max_hp=hp
self.hp_percent=1
self.deltav=max(hp*-0.0188+4.5647,1)*0.0326
local turn_factor=1
if self.stypei==4 then
 turn_factor*=.5
end
self.turn_rate=ro(turn_factor*max(hp*-0.0470+11.4117,2))
self.sprite_rows=rows
self.sprite_columns=#ship_mask[1]
self.transparent_color=scs[4]
self.sprite=ship_mask
return self
end

function ship:set_position_near_object(obj)
local radius=obj.radius or obj.sprite_rows
self.secpos=ra(1.2*radius)+obj.secpos
self:reset_velocity()
end

function ship:clear_target()
self.target_index=nil
self.target=nil
end

function ship:targeted_color()
if self.hostile then
return 8,2
else
return 11,3
end
end

function ship:draw_sprite_rotated(offscreen_pos,angle)
if self.dead then return end
local scrpos=offscreen_pos or self.scrpos
local a=angle or self.angle_radians
local rows,cols=self.sprite_rows,self.sprite_columns
local tcolor=self.transparent_color
local projectile_hit_by
local close_projectiles={}

if self.targeted then
local targetcircle_radius=ro(rows/2)+4
local circlecolor,circleshadow=self:targeted_color()
if offscreen_pos then
 (scrpos+v(1,1)):draw_circle(targetcircle_radius,circleshadow,true)
 scrpos:draw_circle(targetcircle_radius,0,true)
end
scrpos:draw_circle(targetcircle_radius,circlecolor)
end

for p in all(projectiles) do
if p.firing_ship~=self then
 if (p.secpos and offscreen_pos and (self.secpos-p.secpos):scaled_length()<=rows) or
 scaled_dist(p.scrpos,scrpos)<rows then
  add(close_projectiles,p)
 end
end
end

for y=1,cols do
for x=1,rows do
local color=self.sprite[x][y]
if color~=tcolor and color~=nil then

local pixel1=v(
rows-x-flr(rows/2),
y-flr(cols/2)-1)
local pixel2=v(pixel1.x+1,pixel1.y)
pixel1:rotate(a):add(scrpos):ro()
pixel2:rotate(a):add(scrpos):ro()

if self.hp<1 and rnd()<.8 then
make_explosion(pixel1,rows/2,18,self.velocity_vector)
if not offscreen_pos then
 add(particles,spark.new(pixel1,ra(rnd(.25)+.25)+self.velocity_vector,color,128+ri(32)))
end

else

for projectile in all(close_projectiles) do

local impact=false
if not offscreen_pos
and (pixel1:about_equals(projectile.scrpos)
or (projectile.position2
and pixel1:about_equals(projectile.position2))) then
 impact=true
elseif offscreen_pos
and projectile.last_offscreen_pos
and pixel1:about_equals(projectile.last_offscreen_pos) then
 impact=true
end

if impact then
projectile_hit_by=projectile.firing_ship
local damage=projectile.damage or 1
self.hp-=damage
if damage>10 then
 make_explosion(pixel1,8,12,self.velocity_vector)
else
 make_explosion(pixel1,2,6,self.velocity_vector)
end
local old_hp_percent=self.hp_percent
self.hp_percent=self.hp/self.max_hp
if not self.npc and old_hp_percent>.1 and self.hp_percent<=.1 then
 note_add("thruster malfunction")
end
if rnd()<.5 then
 add(particles,spark.new(pixel1,ra(rnd(2)+1)+self.velocity_vector,color,128))
end
del(projectiles,projectile)
self.sprite[x][y]=-5
color=-5
break
end

end

if color<0 then color=5 end

rectfill(
pixel1.x,pixel1.y,
pixel2.x,pixel2.y,
color)
end

end
end
end

if projectile_hit_by then
self.last_hit_time=secondcount
self.last_hit_attacking_ship=projectile_hit_by
end
end

function ship:turn_left()
self:rotate(self.turn_rate)end

function ship:turn_right()
self:rotate(-self.turn_rate)end

function ship:rotate(signed_degrees)
self.angle=(self.angle+signed_degrees)%360
self.angle_radians=self.angle/360
self.heading=(450-self.angle)%360
end

function ship:draw()
text(self:hp_string(),0,0,self:hp_color())
local o=nil
local co=self.orders[#self.orders]
if co==self.full_stop then
o="stopping"
elseif co==self.seek then
o="following"
elseif co==self.fly_towards_destination then
o="flying to nearest planet"
end
if o then
text(o,1,22,12,true)
end

text("pixels/sec "..format(10*self.velocity),0,7)
if self.accelerating then
 text(format(self.cur_gees).." g",0,14)
end
self:draw_sprite_rotated()
end

function ship:hp_color()
return health_colormap[ceil(10*self.hp_percent)]
end

function ship:hp_string()
return "‡"..ro(100*self.hp_percent).."% "..self.hp.."/"..self.max_hp
end

function ship:data(y)
rectfill(0,y+34,127,y,0)
rect(0,y+34,127,y,6)
self:draw_sprite_rotated(v(104,y+17),0)
text(self.name.."\nmodel "..self.seed_value.."\nmax hull‡ "..self.max_hp.."\nmax thrust "..format(self.deltav*30.593514175).." g\nturn rate  "..self.turn_rate.." deg/sec",3,y+3)
end

function ship:is_visible(player_ship_pos)
local size=ro(self.sprite_rows/2)
local scrpos=(self.secpos-player_ship_pos+screen_center):ro()
self.scrpos=scrpos
return scrpos.x<128+size and
scrpos.x>0-size and
scrpos.y<128+size and
scrpos.y>0-size
end

function ship:update_location()
if self.velocity>0.0 then
 self.secpos:add(self.velocity_vector)
end
end

function ship:reset_velocity()
self.velocity_vector=v()
self.velocity=0
end

function ship:predict_sector_position()
local prediction=self.secpos:clone()
if self.velocity>0 then
 prediction:add(self.velocity_vector*4)
end
return prediction
end

function ship:set_destination(dest)
self.destination=dest.secpos
self:update_steering_velocity()
self.max_distance_to_destination=self.distance_to_destination
end

function ship:flee()
self:set_destination(self.last_hit_attacking_ship)
self:update_steering_velocity(1)
local away_from_enemy=self.steer_vel:angle()
local toward_enemy=(away_from_enemy+.5) % 1
if self.distance_to_destination<55 then
 self:rotate_towards_heading(away_from_enemy)
 self:apply_thrust()
else
 self:full_stop()
 if self.hostile and
  self.angle_radians<toward_enemy+.1 and
 self.angle_radians>toward_enemy-.1 then
  self:fire_weapon()
 end
end
end

function ship:update_steering_velocity(modifier)
local away=modifier or -1
local desired_velocity=self.secpos-self.destination
self.distance_to_destination=desired_velocity:scaled_length()
self.steer_vel=(desired_velocity-self.velocity_vector)*away
end

function ship:seek()
if self.seektime%20==0 then
 self:set_destination(self.target or pilot)
end
self.seektime+=1

local target_offset=self.destination-self.secpos
local distance=target_offset:scaled_length()
self.distance_to_destination=distance
local maxspeed=distance/50
local ramped_speed=(distance/(self.max_distance_to_destination*.7))*maxspeed
local clipped_speed=min(ramped_speed,maxspeed)
local desired_velocity=target_offset*(ramped_speed/distance)
self.steer_vel=desired_velocity-self.velocity_vector

if self:rotate_towards_heading(self.steer_vel:angle()) then
 self:apply_thrust(abs(self.steer_vel:length()))
end
if self.hostile then
 if distance<128 then
  self:fire_weapon()
  self:fire_missile()
 end
end
end

function ship:fly_towards_destination()
self:update_steering_velocity()
if self.distance_to_destination>self.max_distance_to_destination*.9 then
 if self:rotate_towards_heading(self.steer_vel:angle()) then
  self:apply_thrust()
 end
else
 self.accelerating=false
 self:reverse_direction()
 if self.distance_to_destination<=self.max_distance_to_destination*.11 then
  self:order_done(self.full_stop)
 end
end
end

function ship:approach_object(obj)
local obj=obj or sect.planets[ri(#sect.planets)+1]
self:set_destination(obj)
self:reset_orders(self.fly_towards_destination)
if self.velocity>0 then
 add(self.orders,self.full_stop)
end
end

function ship:follow_cur_order()
local order=self.orders[#self.orders]
if order then order(self) end
end

function ship:order_done(new_order)
self.orders[#self.orders]=new_order
end

function ship:reset_orders(new_order)
self.orders={}
if new_order then add(self.orders,new_order) end
end

function ship:cut_thrust()
self.accelerating=false
self.cur_deltav=self.deltav/3
end

function ship:wait()
if secondcount>self.wait_duration+self.wait_time then
 self:order_done()
end
end

function ship:full_stop()
if self.velocity>0 and self:reverse_direction() then
 self:apply_thrust()
 if self.velocity<1.2*self.deltav then
  self:reset_velocity()
  self:order_done()
 end
end
end

function ship:fire_missile(weapon)
if self.target and secondcount>3+self.last_fire_time then
 self.last_fire_time=secondcount
 add(projectiles,missile.new(self,self.target))
end
end

function ship:fire_weapon()
local hardpoints={1,-1}
if self.stypei~=2 then hardpoints={0} end
local rate=3
if (self.npc) rate=5
if framecount%rate==0 then
for y in all(hardpoints) do
 add(
 projectiles,
 cannon.new(
 rotatedv(self.angle_radians,self.sprite_rows/2-1,y*(self.sprite_columns/4))+self.scrpos,
 rotatedv(self.angle_radians,6)+self.velocity_vector,12,self))
end
end
end

function ship:apply_thrust(max_velocity)
self.accelerating=true
if self.cur_deltav<self.deltav then
 self.cur_deltav+=self.deltav/30
else
 self.cur_deltav=self.deltav
end
local dv=self.cur_deltav
if max_velocity and dv>max_velocity then
 dv=max_velocity
end
if self.hp_percent<=rnd(.1) then
 dv=0
end
self.cur_gees=dv*30.593514175
local a=self.angle_radians
local additional_velocity_vector=v(cos(a)*dv,sin(a)*dv)
local velocity_vector=self.velocity_vector
local velocity
local engine_location=rotatedv(a,self.sprite_rows*-.5)+self.scrpos
add(particles,thrustexhaust.new(
engine_location,
additional_velocity_vector*-1.3*self.sprite_rows))
velocity_vector:add(additional_velocity_vector)
velocity=velocity_vector:length()
self.velocity_angle=velocity_vector:angle()
self.velocity_angle_opposite=(self.velocity_angle+0.5)%1
self.velocity=velocity
self.velocity_vector=velocity_vector
end

function ship:reverse_direction()
if self.velocity>0.0 then
 return self:rotate_towards_heading(self.velocity_angle_opposite)
end
end

function ship:rotate_towards_heading(heading)
local delta=(heading*360-self.angle+180)%360-180
if delta~=0 then
 local r=self.turn_rate*delta/abs(delta)
 if abs(delta)>abs(r) then delta=r end
 self:rotate(delta)
end
return delta<0.1 and delta>-.1
end

function nearest_planet()
local planet
local dist=32767
for p in all(sect.planets) do
if p.planet_type then
 local d=scaled_dist(pilot.secpos,p.secpos)
 if d<dist then
  dist=d
  planet=p
 end
end
end
return planet,dist
end

function land_at_nearest_planet()
local planet,dist=nearest_planet()
if dist<planet.radius*1.4 then
if pilot.velocity<.5 then
 sect:reset_planet_visibility()
 landed_front_rendered=false
 landed_back_rendered=false
 landed_planet=planet
 landed=true
 landed_menu()
 draw_rect(128,128,0)
else
 note_add("moving too fast to land")
end
else
 note_add("too far to land")
end
return false
end

function takeoff()
sect:reset_planet_visibility()
pilot:set_position_near_object(landed_planet)
landed=false
return false
end

function clear_targeted_ship_flags()
for ship in all(npcships) do
 ship.targeted=false
end
end

function next_hostile_target(ship)
local targeting_ship=ship or pilot
local hostile
for i=1,#npcships do
 next_ship_target(ship)
 if targeting_ship.target.hostile then break end
end
return true
end

function next_ship_target(ship,random)
local targeting_ship=ship or pilot
if random then
 targeting_ship.target_index=ri(#npcships)+1
else
 targeting_ship.target_index=(targeting_ship.target_index or #npcships)%#npcships+1
end
targeting_ship.target=npcships[targeting_ship.target_index]
if targeting_ship==targeting_ship.target then
 targeting_ship.target=pilot
end
if not ship then
 clear_targeted_ship_flags()
 targeting_ship.target.targeted=true
end
return true
end

function approach_nearest_planet()
local planet,dist=nearest_planet()
pilot:approach_object(planet)
return false
end

missile={}
missile.__index=missile
function missile.new(fship,t)
return setmetatable({
secpos=fship.secpos:clone(),
scrpos=fship.scrpos:clone(),
velocity_vector=rotatedv((fship.angle_radians+.25)%1,.5)+fship.velocity_vector,
velocity=fship.velocity,
target=t,
sprite_rows=1,
firing_ship=fship,
cur_deltav=.1,
deltav=.1,
hp_percent=1,
duration=512,
damage=20
},missile)end

function missile:update()
self.destination=self.target:predict_sector_position()
self:update_steering_velocity()
self.angle_radians=self.steer_vel:angle()
if self.duration<500 then
 self:apply_thrust(abs(self.steer_vel:length()))
end
self.duration-=1
self:update_location()
end

function missile:draw(shipvel,offscreen_pos)
local scrpos=offscreen_pos or self.scrpos
self.last_offscreen_pos=offscreen_pos
if self:is_visible(pilot.secpos) or offscreen_pos then
 scrpos:draw_line(scrpos+rotatedv(self.angle_radians,4),6)
end
end

setmetatable(missile,{__index=ship})

star={}
star.__index=star
function star.new()
return setmetatable({
position=v(),
color=7,
speed=1
},star)end

function star:reset(x,y)
self.position=v(x or ri(128),y or ri(128))
self.color=ri(#star_colors[star_color_monochrome+star_color_index+1])+1
self.speed=rnd(0.75)+0.25
return self
end

sun={}
sun.__index=sun
function sun.new(radius,x,y)
local r=radius or 64+ri(128)
local c=ri(6,1)
return setmetatable({
scrpos=v(),
radius=r,
sun_color_index=c,
color=sun_colors[c+5],
secpos=v(x or 0,y or 0),
},sun)end

function sun:draw(ship_pos)
if stellar_object_is_visible(self,ship_pos) then
 for i=0,1 do
  self.scrpos:draw_circle(
   self.radius-i*3,
   sun_colors[i*5+self.sun_color_index],true)
 end
end
end

function stellar_object_is_visible(obj,ship_pos)
obj.scrpos=obj.secpos-ship_pos+screen_center
return
obj.scrpos.x<128+obj.radius and
obj.scrpos.x>0-obj.radius and
obj.scrpos.y<128+obj.radius and
obj.scrpos.y>0-obj.radius
end

starfield_count=40
sector={}
sector.__index=sector
function sector.new()
local sec={
seed=ri(32767),
planets={},
starfield={}
}
srand(sec.seed)
for i=1,starfield_count do
 add(sec.starfield,star.new():reset())
end
setmetatable(sec,sector)
return sec
end

function sector:reset_planet_visibility()
for p in all(self.planets) do
p.rendered_circle=false
p.rendered_terrain=false
end
end

function sector:new_planet_along_elipse()
local x,y,sdist
local planet_nearby=true
while(planet_nearby) do
x=rnd(150)
y=sqrt( (rnd(35)+40)^2*(1-x^2/(rnd(50)+100)^2) )
if rnd()<.5 then x*=-1 end
if rnd()<.75 then y*=-1 end
if #self.planets==0 then break end
sdist=32767
for p in all(self.planets) do
sdist=min(
sdist,
scaled_dist(v(x,y),p.secpos/33))
end
planet_nearby=sdist<15
end
return planet.new(x*33,y*33,((1-v(x,y):angle())-.25)%1)
end

function sector:draw_starfield(shipvel)
local lstart,lend
for star in all(self.starfield) do
lstart=star.position+(shipvel*star.speed*-.5)
lend=star.position+(shipvel*star.speed*.5)
local i=star_color_monochrome+star_color_index+1
local star_color_count=#star_colors[i]
local color_index=1+((star.color-1)%star_color_count)
star.position:draw_line(
lend,
star_colors[i+1][color_index])
lstart:draw_line(
star.position,
star_colors[i][color_index])
end
end

function sector:scroll_starfield(shipvel)
local diff=starfield_count-#self.starfield
for i=1,diff do
add(self.starfield,star.new():reset())
end
for star in all(self.starfield) do
star.position:add(shipvel*star.speed*-1)
if diff<0 then
 del(self.starfield,star)
 diff+=1
elseif star.position.x>134 then
 star:reset(-6)
elseif star.position.x<-6 then
 star:reset(134)
elseif star.position.y>134 then
 star:reset(false,-6)
elseif star.position.y<-6 then
 star:reset(false,134)
end
end
end

function is_offscreen(p,m)
local margin=m or 0
local mincoord=0-margin
local maxcoord=128+margin
local x,y=p.scrpos.x,p.scrpos.y
local duration_up=p.duration<0
if p.deltav then
 return duration_up
else
 return duration_up or x>maxcoord or x<mincoord or y>maxcoord or y<mincoord
end
end

spark={}
spark.__index=spark
function spark.new(p,pv,c,d)
return setmetatable({
scrpos=p,
particle_velocity=pv,
color=c,
duration=d or ri(7,2)
},spark)end

function spark:update(shipvel)
self.scrpos:add(self.particle_velocity-shipvel)
self.duration-=1
end

function spark:draw(shipvel)
pset(self.scrpos.x,self.scrpos.y,self.color)
self:update(shipvel)
end

function make_explosion(pixel1,size,colorcount,center_velocity)
add(particles,explosion.new(
pixel1,size,colorcount,
center_velocity))
end

explosion={}
explosion.__index=explosion
function explosion.new(position,size,colorcount,shipvel)
local explosion_size_factor=rnd()
return setmetatable({
scrpos=position:clone(),
particle_velocity=shipvel:clone(),
radius=explosion_size_factor*size,
radius_delta=explosion_size_factor*rnd(.5),
len=colorcount-3,
duration=colorcount
},explosion)end

function explosion:draw(shipvel)
local r=ro(self.radius)
for i=r+3,r,-1 do
local c=damage_colors[self.len-self.duration+i]
if c then
 self.scrpos:draw_circle(i,c,true)
end
end
self:update(shipvel)
self.radius-=self.radius_delta
end

setmetatable(explosion,{__index=spark})

cannon={}
cannon.__index=cannon
function cannon.new(p,pv,c,ship)
return setmetatable({
scrpos=p,
position2=p:clone(),
particle_velocity=pv+pv:perpendicular():normalize()*(rnd(2)-1),
color=c,
firing_ship=ship,
duration=16
},cannon)end

function cannon:draw(shipvel)
self.position2:draw_line(self.scrpos,self.color)
self.position2=self.scrpos:clone()
end

setmetatable(cannon,{__index=spark})

thrustexhaust={}
thrustexhaust.__index=thrustexhaust
function thrustexhaust.new(p,pv)
return setmetatable({
scrpos=p,
particle_velocity=pv,
duration=0
},thrustexhaust)end

function thrustexhaust:draw(shipvel)
local c=ri(11,9)
local pv=self.particle_velocity
local deflection=pv:perpendicular()*0.7
local flicker=(pv*(rnd(2)+2))+(deflection*(rnd()-.5))

local p0=self.scrpos+flicker
local p1=self.scrpos+pv+deflection
local p2=self.scrpos+pv+deflection*-1
local p3=self.scrpos
p1:draw_line(p0,c)
p2:draw_line(p0,c)
p2:draw_line(p3,c)
p1:draw_line(p3,c)

if rnd()>.4 then
 add(particles,spark.new(p0,shipvel+(flicker*.25),c))
end

self.scrpos:add(pv-shipvel)
self.duration-=1
end

function draw_sprite_circle(xc,yc,radius,filled,c)
local xvalues={}
local fx,fy=0,0
local x,y=-radius,0
local err=2-2*radius
while(x<0) do
xvalues[1+x*-1]=y

if not filled then
 fx=x
 fy=y
end
for i=x,fx do
 sset(xc-i,yc+y,c)
 sset(xc+i,yc-y,c)
end
for i=fy,y do
 sset(xc-i,yc-x,c)
 sset(xc+i,yc+x,c)
end

radius=err
if radius<=y then
 y+=1
 err+=y*2+1
end
if radius>x or err>y then
 x+=1
 err+=x*2+1
end
end

xvalues[1]=xvalues[2]
return xvalues
end

perms={}
for i=0,255 do perms[i]=i end
for i=0,255 do
local r=ri(32767)%256
perms[i],perms[r]=perms[r],perms[i]
end

perms12={}
for i=0,255 do
local x=perms[i]%12
perms[i+256],perms12[i],perms12[i+256]=perms[i],x,x
end

function getn_3d(ix,iy,iz,x,y,z)
local t=.6-x*x-y*y-z*z
local index=perms12[ix+perms[iy+perms[iz]]]
return max(0,(t*t)*(t*t))*(grads3[index][0]*x+grads3[index][1]*y+grads3[index][2]*z)
end

function simplex3d(x,y,z)
local s=(x+y+z)*0.333333333
local ix,iy,iz=flr(x+s),flr(y+s),flr(z+s)
local t=(ix+iy+iz)*0.166666667
local x0,y0,z0=x+t-ix,y+t-iy,z+t-iz
ix,iy,iz=band(ix,255),band(iy,255),band(iz,255)
local n0=getn_3d(ix,iy,iz,x0,y0,z0)
local n3=getn_3d(ix+1,iy+1,iz+1,x0-0.5,y0-0.5,z0-0.5)
local i1,j1,k1,i2,j2,k2
if x0>=y0 then
if y0>=z0 then
i1,j1,k1,i2,j2,k2=1,0,0,1,1,0
elseif x0>=z0 then
i1,j1,k1,i2,j2,k2=1,0,0,1,0,1
else
i1,j1,k1,i2,j2,k2=0,0,1,1,0,1
end
else
if y0<z0 then
i1,j1,k1,i2,j2,k2=0,0,1,0,1,1
elseif x0<z0 then
i1,j1,k1,i2,j2,k2=0,1,0,0,1,1
else
i1,j1,k1,i2,j2,k2=0,1,0,1,1,0
end
end
local n1=getn_3d(ix+i1,iy+j1,iz+k1,x0+0.166666667-i1,y0+0.166666667-j1,z0+0.166666667-k1)
local n2=getn_3d(ix+i2,iy+j2,iz+k2,x0+0.333333333-i2,y0+0.333333333-j2,z0+0.333333333-k2)
return 32*(n0+n1+n2+n3)end

planet={}
planet.__index=planet
function planet.new(x,y,phase,r)
local planet_type=planet_types[ri(#planet_types)+1]

local radius=r or ri(65,planet_type.min_size)
return setmetatable({
scrpos=v(),
radius=radius,
secpos=v(x,y),
bottom_right_coord=2*radius-1,
phase=phase,
planet_type=planet_type,
noise_factor_vert=ri(planet_type.maxc+1,planet_type.minc),
noisedx=rnd(1024),
noisedy=rnd(1024),
noisedz=rnd(1024),
rendered_circle=false,
rendered_terrain=false,
color=planet_type.mmap_color
},planet)end

function planet:draw(ship_pos)
if stellar_object_is_visible(self,ship_pos) then
self:render_planet()
sspr(
0,0,self.bottom_right_coord,self.bottom_right_coord,
self.scrpos.x-self.radius,
self.scrpos.y-self.radius)
end
end

function draw_rect(w,h,c)
for x=0,w-1 do
for y=0,h-1 do
sset(x,y,c)
end
end
end

function planet:render_planet(fullmap,renderback)
local s=self
local radius=s.radius-1
if fullmap then radius=47 end

if not s.rendered_circle then
s.width=s.radius*2
s.height=s.radius*2
s.x=0
s.yfromzero=0
s.y=radius-s.yfromzero
s.phi=0
sect:reset_planet_visibility()
pal()
palt(0,false)
palt(s.planet_type.transparent_color,true)
if fullmap then
 s.width=114
 s.height=96
 draw_rect(s.width,s.height,0)
else
 draw_rect(s.width,s.height,s.planet_type.transparent_color)
 s.xvalues=draw_sprite_circle(radius,radius,radius,true,0)
 draw_sprite_circle(radius,radius,radius,false,s.planet_type.mmap_color)
end
s.rendered_circle=true
end

if (not s.rendered_terrain) and s.rendered_circle then

local theta_start,theta_end=0,.5
local theta_increment=theta_end/s.width
if fullmap and renderback then
 theta_start=.5
 theta_end=1
end

if s.phi>.25 then
 s.rendered_terrain=true
else

local partialshadow=s.planet_type.full_shadow~=1
local phase_values,phase={},s.phase

local x,doublex,x1,x2,i,c1,c2
local y=radius-s.y
local xvalueindex=abs(y)+1
if xvalueindex<=#s.xvalues then
x=flr(sqrt(radius*radius-y*y))
doublex=2*x
if phase<.5 then
x1=-s.xvalues[xvalueindex]
x2=flr(doublex-2*phase*doublex-x)
else
x1=flr(x-2*phase*doublex+doublex)
x2=s.xvalues[xvalueindex]
end
for i=x1,x2 do
if partialshadow
or (phase<.5 and i>x2-2)
or (phase>=.5 and i<x1+2) then
phase_values[radius+i] = 1
else
phase_values[radius+i] = 0
end
end
end

for theta=theta_start,theta_end-theta_increment,theta_increment do

local phasevalue=phase_values[s.x]
local c=0

if (fullmap or phasevalue~=0) and sget(s.x,s.y)~=s.planet_type.transparent_color then
local freq=s.planet_type.noise_zoom
local max_amp=0
local amp=1
local value=0
for n=1,s.planet_type.noise_octaves do
value=value+simplex3d(
s.noisedx+freq*cos(s.phi)*cos(theta),
s.noisedy+freq*cos(s.phi)*sin(theta),
s.noisedz+freq*sin(s.phi)*s.noise_factor_vert)
max_amp+=amp
amp*=s.planet_type.noise_persistance
freq*=2
end
value/=max_amp
if value>1 then value=1 end
if value<-1 then value=-1 end
value+=1
value*=(#s.planet_type.color_map-1)/2
value=ro(value)

c=s.planet_type.color_map[value+1]
if not fullmap and phasevalue==1 then
 c=dark_planet_colors[c+1]
end
end
sset(s.x,s.y,c)
s.x+=1
end
s.x=0
if s.phi>=0 then
 s.yfromzero+=1
 s.y=radius+s.yfromzero
 s.phi+=.5/(s.height-1)
else
 s.y=radius-s.yfromzero
end
s.phi*=-1
end

end

return s.rendered_terrain
end

function add_npc(pos,pirate)
local t=ri(#ship_types)+1
if pirate or rnd()<.2 then
t=ri(3,1)
pirate=true
pirates+=1
end
local npc=ship.new(pirate):buildship(nil,t)
npc:set_position_near_object(pos)
npc:rotate(ri(360))
npc.npc=true
add(npcships,npc)
npc.index=#npcships
end

function load_sector()
warpsize=pilot.sprite_rows
sect=sector.new()
note_add("arriving in system ngc "..sect.seed)

add(sect.planets,sun.new())

for i=0,ri(12,1) do
add(sect.planets,sect:new_planet_along_elipse())
end

pilot:set_position_near_object(sect.planets[2])
pilot:clear_target()

pirates=0
npcships={}
shipyard={}
projectiles={}

for p in all(sect.planets) do
for i=1,ri(4) do
add_npc(p)
end
end

if pirates==0 then
add_npc(sect.planets[2],true)
end

return true
end

function _init()
paused=false
landed=false
particles={}
pilot=ship.new()
pilot:buildship(nil,1)
load_sector()
setup_mmap()
show_title_screen=true
local titlestarv=v(0,-3)
while(not btnp(4)) do
cls()
sect:scroll_starfield(titlestarv)
sect:draw_starfield(titlestarv)
circfill(64,135,90,2)
circfill(64,172,122,0)
map(0,0,6,-15)
text("            - v1.0 -\n\n      eliminate the pirates\n\n\n   ”  thrust      —  fire\n ‹  ‘  rotate  Ž  menu\n   ƒ  reverse",1,70,6)
flip()
end
end

mmap_sizes=split"24 48 128 0 "

function setup_mmap(size)
mmap_size_index=size or 0
mmap_size=mmap_sizes[mmap_size_index+1]
if mmap_size>0 then
 mmap_size_halved=mmap_size/2
 mmap_offset=v(126-mmap_size_halved,mmap_size_halved+1)
end
end

function draw_mmap_planet(obj)
local p=obj.secpos+screen_center
if obj.planet_type then p:add(v(-obj.radius,-obj.radius)) end
p=p/mmap_denominator+mmap_offset
if mmap_size>100 then
 local r=ceil(obj.radius/32)
 p:draw_circle(r+1,obj.color)
else
 p:draw_point(obj.color)
end
end

function draw_mmap_ship(obj)
local p=(obj.secpos/mmap_denominator):add(mmap_offset):ro()
local x,y=p.x,p.y
local c=obj:targeted_color()
if obj.npc then
 p:draw_point(c)
 if obj.targeted then
  p:draw_circle(2,c)
 end
else
 if obj.damage then
  line(x-1,y,x+1,y,9)
  line(x,y-1,x,y+1,9)
 else
  rect(x-1,y-1,x+1,y+1,7)
 end
end
end

function draw_mmap()
local text_height=mmap_size
if mmap_size>0 then
if mmap_size<100 then
 text_height+=4
 rectfill(126-mmap_size,1,126,mmap_size+1,0)
 rect(125-mmap_size,0,127,mmap_size+2,6,11)
else
 text_height=0
end

local x=abs(pilot.secpos.x)
local y=abs(pilot.secpos.y)
if y>x then x=y end
mmap_denominator=min(6,flr(x/5000)+1)*5000/mmap_size_halved
for p in all(sect.planets) do
 draw_mmap_planet(p)
end
if framecount%3~=0 then
for m in all(projectiles) do
 if m.deltav then
  draw_mmap_ship(m)
 end
end
for s in all(npcships) do
 draw_mmap_ship(s)
end
draw_mmap_ship(pilot)
end

end
text("•"..#npcships-pirates,112,text_height)
text("•"..pirates,112,text_height+7,8)
end

outlinedindex=split"2 2 1 2 0 2 2 0 2 1 1 1 -1 -1 1 -1 -1 1 -1 0 1 0 0 -1 0 1 "
function text(text,x,y,textcolor,outline)
local c=textcolor or 6
local s=darkshipcolors[c]
if outline then
for i=1,#outlinedindex,2 do
 if i>10 then s=c end
 print(text,
 x+outlinedindex[i],
 y+outlinedindex[i+1],s)
end
c=0
else
 print(text,x+1,y+1,s)
end
print(text,x,y,c)
end

note_text=nil
note_display_time=4

function note_add(text)
note_text=text
note_display_time=4
end

function note_draw()
if note_display_time>0 then
 text(note_text,0,121)
 if framecount>=29 then
  note_display_time-=1
 end
end
end

function call_option(i)
if cur_option_callbacks[i] then
 local return_value=cur_option_callbacks[i]()
 paused=false
 if return_value==nil then
  paused=true
 elseif return_value then
  if type(return_value)=="string" then
   note_add(return_value)
  end
  paused=true
 end
end
end

function menu(colors,options,callbacks)
if options then
 cur_options=options
 cur_menu_colors=split(colors)
 cur_option_callbacks=callbacks
end

if shipinfo then
 pilot:data(0)
elseif showyard then
 for i=0,1 do
  local s=shipyard[i+1]
  if s then s:data(i*36) end
 end
end

for a=.25,1,.25 do
local i=a*4
local text_color=cur_menu_colors[i]
if i==pressed then text_color=darkshipcolors[text_color] end
if cur_options[i] then
local p=rotatedv(a,15)+v(64,90)
if a==.5 then
 p.x-=4*#cur_options[i]
elseif a~=1 then
 p.x-=ro(4*(#cur_options[i]/2))
end
text(
cur_options[i],
p.x,p.y,text_color,true)
end
end

text("  ”  \n‹  ‘\n  ƒ",52,84,6,true)
end

function main_menu()
menu(
"xc8b7",
{"autopilot",
"fire missile",
"options",
"systems"
},{

function()
menu(
"xcc6c",
{"full stop",
"near planet",
"back",
"follow",
},{
function()
if pilot.velocity>0 then
pilot:reset_orders(pilot.full_stop)
end
return false
end,
approach_nearest_planet,
main_menu,
function()
if pilot.target then
pilot:reset_orders(pilot.seek)
pilot.seektime=0
end
return false
end,
})
end,

function()
pilot:fire_missile()
return false
end,

function()
menu(
"x6fba",
{"back",
"starfield",
"minimap size",
"debug"
},{
main_menu,

function()
menu(
"x7f6a",
{"more stars",
"~dimming",
"less stars",
"~colors",
},{
function()
starfield_count+=5
return "star count: "..starfield_count
end,
function()
star_color_index=(star_color_index+1)%2
return true
end,
function()
starfield_count=max(0,starfield_count-5)
return "star count: "..starfield_count
end,
function()
star_color_monochrome=((star_color_monochrome+1)%2)*3
return true
end
})
end,

function()
setup_mmap((mmap_size_index+1)%#mmap_sizes)
return true
end,

function()
menu(
"xc698",
{"new sector",
"back",
"spawn enemy"
},{
load_sector,
main_menu,
function()
add_npc(pilot,true)
return "npc created"
end
})
end
})
end,

function()
menu(
"x86cb",
{"target next pirate",
"back",
"land",
"target next"
},{
next_hostile_target,
main_menu,
land_at_nearest_planet,
next_ship_target
})
end
})
end

function addyardships()
shipyard={}
for i=1,2 do
add(shipyard,ship.new():buildship(nil,ri(#ship_types,1)))
end
end

function buyship(i)
pilot:buildship(shipyard[i].seed_value,shipyard[i].stypei)
shipyard[i]=nil
note_add("purchased!")
myship_menu()
end

function myship_menu()
showyard=false
shipinfo=true
menu(
"x6b66",
{"back",
"repair"
},{
landed_menu,
function()
pilot:buildship(pilot.seed_value,pilot.stypei)
note_add("hull damage repaired")
end
})
end

function landed_menu()
shipinfo=false
showyard=false
menu(
"xc67a",
{"takeoff",
nil,
"my ship",
"shipyard",
},{
takeoff,
nil,
myship_menu,
function()
showyard=true
if #shipyard==0 then addyardships() end
menu(
"x767a",
{"buy top",
"back",
"buy bottom",
"more"
},{
function()
buyship(1)
end,
landed_menu,
function()
buyship(2)
end,
addyardships
})
end
})
end

local pos=0
local mtbl={}
for i=1,96 do
 mtbl[i]={flr(-sqrt(-sin(i/193))*48+64)}
 mtbl[i][2]=(64-mtbl[i][1])*2
end
for i=0,95 do
 poke(64*i+56,peek(64*i+0x1800))
end
local cs={}
for i=0,15 do
 cs[i]={(cos(0.5+0.5/16*i)+1)/2}
 cs[i][2]=(cos(0.5+0.5/16*(i+1))+1)/2-cs[i][1]
end

function shift_sprite_sheet()
for i=0,95 do
 poke(64*i+0x1838,peek(64*i))
 memcpy(64*i,64*i+1,56)
 memcpy(64*i+0x1800,64*i+0x1801,56)
 poke(64*i+56,peek(64*i+0x1800))
end
end

function landed_update()
local p=landed_planet
if not landed_front_rendered then
landed_front_rendered=p:render_planet(true)
if landed_front_rendered then
 p.rendered_circle=false
 p.rendered_terrain=false
 for j=1,56 do
  shift_sprite_sheet()
 end
end
else
if not landed_back_rendered then
 landed_back_rendered=p:render_planet(true,true)
else
 pos=1-pos
 if pos==0 then
  shift_sprite_sheet()
 end
end
end
end

function render_landed_screen()
cls()
if landed_front_rendered and landed_back_rendered then
for i=1,96 do
local a,b=mtbl[i][1],mtbl[i][2]
pal()
local lw=ceil(b*cs[15][2])
for j=15,0,-1 do
 if j==4 then
  for ci=0,#dark_planet_colors-1 do
  pal(ci,dark_planet_colors[ci+1])
  end
 end
 if j<15 then lw=flr(a+b*cs[j+1][1])-flr(a+b*cs[j][1]) end
 sspr(pos+j*7,i-1,7,1,flr(a+b*cs[j][1]),i+16,lw,1)
end
end
pal()
text(landed_planet.planet_type.class_name,1,1)

else
sspr(0,0,127,127,0,0)
text("mapping surface...",1,1,6,true)
end
end

framecount=0
secondcount=0
btnv=split"x2031"

function _update()
framecount=(framecount+1)%30
if framecount==0 then
 secondcount+=1
end

if not landed and btnp(4,0) then
 paused=not paused
 if paused then
  main_menu()
 end
 pressed=nil
end

if landed then
 landed_update()
end

if paused or landed then

for i=1,4 do
if btn(btnv[i]) then
 pressed=i
end
if pressed then
 if pressed==i and not btn(btnv[i]) then
  pressed=nil
  call_option(i)
 end
end
end

else

if btn(0,0) then pilot:turn_left() end
if btn(1,0) then pilot:turn_right() end
if btn(3,0) then pilot:reverse_direction() end
if btn(5,0) then pilot:fire_weapon() end
if btn(2,0) then
pilot:apply_thrust()
else
if pilot.accelerating and not pilot.orders[1] then
 pilot:cut_thrust()
end
end

for p in all(projectiles) do
p:update(pilot.velocity_vector)
end

for s in all(npcships) do
if s.stypei==#ship_types then
s:rotate(.1)
else

if s.last_hit_time and s.last_hit_time+30>secondcount then

s:reset_orders()
s:flee()
if s.hostile then
 s.target=s.last_hit_attacking_ship
 s.target_index=s.target.index
end

else

if #s.orders==0 then
if s.hostile then
 s.seektime=0
 if not s.target then
  next_ship_target(s,true)
 end
 add(s.orders,s.seek)
else
 s:approach_object()
 s.wait_duration=ri(46,10)
 s.wait_time=secondcount
 add(s.orders,s.wait)
end
end
s:follow_cur_order()

end

end

s:update_location()
if s.hp<1 then

if s.hostile then
pirates-=1
if pirates<1 then
note_add("sector cleared!")
note_display_time=8
end
end

del(npcships,s)
pilot:clear_target()
end
end

pilot:follow_cur_order()
pilot:update_location()
if pirates<1 and note_display_time<=0 then
 note_add("fly to system edge for ftl jump")
 note_display_time=8
end
if pilot.secpos.x>32000 or pilot.secpos.y>32000 then
 load_sector()
end

sect:scroll_starfield(pilot.velocity_vector)
end
end

function render_game_screen()
cls()
sect:draw_starfield(pilot.velocity_vector)
for p in all(sect.planets) do
 p:draw(pilot.secpos)
end
for s in all(npcships) do
 if s:is_visible(pilot.secpos) then
  s:draw_sprite_rotated()
 end
end

if pilot.target then
last_offscreen_pos=nil
local player_screen_position=pilot.scrpos
local targeted_ship=pilot.target
if targeted_ship then
if not targeted_ship:is_visible(pilot.secpos) then
local distance=""..flr((targeted_ship.scrpos-player_screen_position):scaled_length())
local color,shadow=targeted_ship:targeted_color()
local hr=flr(targeted_ship.sprite_rows*.5)
local d=rotatedv((targeted_ship.scrpos-player_screen_position):angle())
last_offscreen_pos=d*(60-hr)+screen_center
local p2=last_offscreen_pos:clone():add(v(-4*(#distance/2)))
targeted_ship:draw_sprite_rotated(last_offscreen_pos)
if p2.y>63 then
 p2:add(v(1,-12-hr))
else
 p2:add(v(1,7+hr))
end
text(distance,ro(p2.x),ro(p2.y),color)
end
text(targeted_ship.name..targeted_ship:hp_string(),0,114,targeted_ship:hp_color())
end
end

pilot:draw()

if pilot.hp<1 then
paused=true
pilot.dead=true
menu(
"x78bb",
{"continue?",
nil,
"yes",
},{
nil,
nil,
function()
pilot.dead=false
pilot:buildship(pilot.seed_value,pilot.stypei)
return false
end
})
end

for p in all(particles) do
if is_offscreen(p,32) then
 del(particles,p)
else
 if paused then
  p:draw(v())
 else
  p:draw(pilot.velocity_vector)
 end
end
end

for p in all(projectiles) do
if is_offscreen(p,63) then
 del(projectiles,p)
else
 if last_offscreen_pos and p.secpos and pilot.target and
 (pilot.target.secpos-p.secpos):scaled_length()<=pilot.target.sprite_rows then
  p:draw(nil,(p.secpos-pilot.target.secpos)+last_offscreen_pos)
 else
  p:draw(pilot.velocity_vector)
 end
end
end

draw_mmap()
if warpsize>0 then
camera(ri(2)-1, ri(2)-1)
circfill(63,63,warpsize,7)
warpsize-=1
if warpsize==0 then camera() end
end

end

function _draw()
if landed then
render_landed_screen()
else
render_game_screen()
end
if paused or landed then
menu()
end
note_draw()
end

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
0000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000
00000000000000000000006000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000
00000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000e0000
000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000005e0000
000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000
000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000
0000000000000000000000000000008880888099999990aaa0aaa00bbbbb00333330000ddddd00ccc0ccc0011111002222222000000000000000000000000000
0000000000000000000000000000008880888099999990aaa0aaa0bbbbbbb033333300ddddddd0ccc0ccc0111111102222222000000000000000000000000000
0000000000000000000000000000078880888099999990aaa0aaa0bbbbbbb033333330ddddddd0ccc0ccc0111111102222222000000000000000000000000000
0000000000000000000000000000078880888099907000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000800
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000800
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000e00
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000e00
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa6bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa6bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000d00000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000c00000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111000002220000000000000000000000000000000
0000000000000000000000000000008880888099900000aaa0aaa0bbb0bbb033303330ddd0ddd0ccc0ccc0111000002220000000000000000000000000000000
00000000000000000000000000000077707770777000007770777077707770777077707770777077707770777000007770000000000000000000000000000000
0000000000000000000000000000008888888099999990aaa0aaa0bbb0bbb033333330ddddddd0ccc0ccc0111111002222222000000000000000000000000000
0000000000000000000000000000008888888099999990aaa0aaa0bbb0bbb033333300ddddddd0ccc0ccc0011111102222222000000000000000000000000000
0000000000000000000000000000008888888099999990aaa0aaa0bbb0bbb033333000ddddddd0ccc0ccc0000011102222222000000000000000000000000000
0000000008000000000000000000008880888099900000aaa0aaa0bbb0bbb033300000ddd0ddd0ccc0ccc0000011102220000000000000000000000000000000
000000000e000000000000000000008880888099900000aaa0aaa0bbb0bbb033300000ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
000000000e000000000000000000068880888099900000aaa0aaa0bbb0bbb033300000ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000000000000000078880888099900000aaa0aaa0bbb0bbb033300000ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
0000000000000000090000000000078880888099900000aaa0aaa0bbb0bbb033300000ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
00000000000000000a6000000000008880888099900000aaa0aaa0bbb0bbb033300000ddd0ddd0ccc0ccc0111011102220000000000000000000000000000000
00000000000000000a7000000000008880888099900000aaa0aaa0bbb2bbb233322222ddd2ddd0ccc0ccc0111011102220000000000000080000000000000000
0000000000000000000000000000008880888099900000aaa2aaa2bbb2bbb233522222ddd2ddd2ccc0ccc01110111022200000000000000e0000000000000000
0000000000000000000000000000008880888099900222aaa2aaa2bbb2bbb235322222ddd2ddd2ccc2ccc21110111022200000000000000e0000000000000000
0000000000000000000000000000008880888099922222aaa2aaa2bbb2bbb253222222ddd2ddd2ccc2ccc2111011102220000000000000000000000000000000
0000000000000000000000000000008880888299922222aaa2aaa2bbbb3b3222222222d1d2ddd2ccc2ccc2111211102220000000000000000000000000000000
0000000000000800000000000000008880888299922222aaa2a220b3b3b300000000001d10ddd2ccc2ccc2111211122220000000000000000000000000000000
0000000000000e00000000000000008882888299922220aaa000003b3b00000000000000d0d1d0ccc0ccc2111211122222000000000000000000000000000000
0000000000000e00000000000000028882888299900000aaa00aaa000000000000000000001d10ccc0ccc0111211122222220000000000000000000000000000
0000000000000000000000000022228882888099900000aaaa9a9a0000000000000000000000d0ccc0ccc01110111022222222200000000000000d0000000000
0000000000000000000000002222228880888099900000a9a9a900000000000000000000000000dcdcccc01110111022222222222000000000000d0000000000
00000000000000000000002222220088808880999000009a9a00000000000000000000000000000dcdcdc0111011102220000222222000000000000000000000
0000000000000000000022222000008880888099900000a9000000000000000000000000000000000cdc00111011102220000000222220000000000000000000
00000000000000000002220000000088808880999000900000000000000000000000000000000000000000111011102220000000000222000000000000000000
00000000000000000222000000000088808880999094940000000000000000000000000000000000000000515111102220000000000002220000000000000000
00000000000000002000000000000088808880999949400000000000000000000000000000000000000000051515102220000000000000002000000000000000
00000000000000200000000000000088808880949490000000000000000000000000000000000000000000000151002220000000000000000020000000000000
09000000000000000000000000000088808880494000000000000000000000000000000000000000000000000000005220000000000000000000000000000000
0a000000000000000000000000000088808280900000000000000000000000000000000000000000000000000000002522222200000000000000000000000000
00000000000000000000000000000088202820000000000000000000000000000000000000000000000000000000000252525200000000000000000000000000
00000000000000000000000000000082808000000000000000000000000000000000000000000000000000000000000005252500000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000060606600000066600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000065650650000065650000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000006660000065650650000065650000666000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000555000066650650000065650000055500000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000006556660060066650000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000500555005005550000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000006660600066606660666066006660666066600000666060606660000066606660666066606660666006600000000000000000000
00000000000000000000000006555650006556665065565606565065565550000065565656555000065650655656565650655655560550000000000000000000
00000000000000000000000006600650006506565065065656665065066000000065066656600000066650650660566650650660066600000000000000000000
00000000000000000000000006550650006506565065065656565065065500000065065656550000065550650656065650650655005650000000000000000000
00000000000000000000000006660666066606565666065656565065066600000065065656660000065006660656565650650666066050000000000000000000
00000000000000000000000000555055505550505055505050505005005550000005005050555000005000555050505050050055505500000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000666660000000000000000006660606066606060066066600000000000000000000000000666660000000000000000006660666066606660000
00000000000006665666000000000000000000655656565656565605506550000000000000000000000006656566000000000000000006555065565656555000
00000000000006655066500006060606000000650666566056565666006500000000000000000000000006660666500006060606000006600065066056600000
00000000000006650066500000505050500000650656565606565056506500000000000000000000000006656066500000505050500006550065065606550000
00000000000000666665500000000000000000650656565650665660506500000000000000000000000000666665500000000000000006500666065656660000
00000000000000055555000000000000000000050050505050055055000500000000000000000000000000055555000000000000000000500055505050555000
00000066666000000000006666600000000000000000066600660666066606660666000000000066666000000000000000000666066606600606000000000000
00000666556600000000066556660000000000000000065656065065565650655655500000000665556600000000000000000666565556560656500000000000
00000665506650000000066500665000060606060000066056565065066650650660000000000665606650000606060600000656566006565656500000000000
00000666006650000000066506665000005050505000065606565065065650650655000000000665056650000050505050000656565506565656500000000000
00000066666550000000006666655000000000000000065656605065065650650666000000000066666550000000000000000656566606565066500000000000
00000005555500000000000555550000000000000000005050550005005050050055500000000005555500000000000000000050505550505005500000000000
00000000000000666660000000000000000006660666060606660666006606660000000000000000000000000000000000000000000000000000000000000000
00000000000006655566000000000000000006565655565656555656560556555000000000000000000000000000000000000000000000000000000000000000
00000000000006650066500006060606000006605660065656600660566606600000000000000000000000000000000000000000000000000000000000000000
00000000000006660666500000505050500006560655066656550656005656550000000000000000000000000000000000000000000000000000000000000000
00000000000000666665500000000000000006565666006556660656566056660000000000000000000000000000000000000000000000000000000000000000
00000000000000055555000000000000000000505055500500555050505500555000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

