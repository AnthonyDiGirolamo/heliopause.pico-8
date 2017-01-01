pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- heliopause
-- by anthonydigirolamo

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

local Grads3={
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
split"0 -1 -1 ",
}
Grads3[0]=split"1 1 0 "

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

V={}
V.__index=V
function V.new(x,y)
return setmetatable({x=x or 0,y=y or 0},V)end
function V:add(v)
self.x+=v.x
self.y+=v.y
return self
end

function V.__add(a,b)
return V.new(a.x+b.x,a.y+b.y)end
function V.__sub(a,b)
return V.new(a.x-b.x,a.y-b.y)end
function V.__mul(a,b)
return V.new(a.x*b,a.y*b)end
function V.__div(a,b)
return V.new(a.x/b,a.y/b)end

function V:about_equals(v)
return ro(v.x)==self.x and ro(v.y)==self.y end

function V:angle()
return atan2(self.x,self.y)end

function V:length()
return sqrt(self.x^2+self.y^2)end
function V:scaled_length()
return 182*sqrt((self.x/182)^2+(self.y/182)^2)end
function scaled_dist(a,b)
return (b-a):scaled_length()end

function V:clone()
return V.new(self.x,self.y)end

function V:perpendicular()
return V.new(-self.y,self.x)end

function V:ro()
self.x=ro(self.x)
self.y=ro(self.y)
return self end

function V:normalize()
local l=self:length()
self.x/=l
self.y/=l
return self end

function V:rotate(phi)
local c=cos(phi)
local s=sin(phi)
local x=self.x
local y=self.y
self.x=c*x-s*y
self.y=s*x+c*y
return self end

function V:draw_point(c)
pset(
ro(self.x),
ro(self.y),c)end

function V:draw_line(v,c)
line(
ro(self.x),
ro(self.y),
ro(v.x),
ro(v.y),c)end

function V:draw_circle(radius,c,fill)
local method=circ
if fill then method=circfill end
method(
ro(self.x),
ro(self.y),
ro(radius),c)end

setmetatable(V,{__call=function(_,...) return V.new(...) end})

function ra(len)
return rotatedv(rnd(),len)end
function rotatedv(angle,x,y)
return V(x or 1,y):rotate(angle)end
function ro(i)
return flr(i+.5)end
function ceil(x)
return -flr(-x)end
function ri1()
return ri(3)-1 end
function ri(n,minimum)
local m=minimum or 0
return m+flr(rnd(32767))%(n-m) end
function format(num)
local n=flr(num*10+0.5)/10
return flr(n).."."..ro((n%1)*10) end

screen_center=V(63,63)

Ship={}
Ship.__index=Ship
function Ship.new(h)
local shp={
npc=false,
hostile=h,
scrpos=screen_center,
secpos=V(),
current_deltav=0,
current_gees=0,
angle=0,
angle_radians=0,
heading=90,
velocity_angle=0,
velocity_angle_opposite=180,
velocity=0,
velocity_vector=V(),
orders={},
last_fire_time=0
}
setmetatable(shp,Ship)
return shp
end

ship_types={
{name="fighter",
shape=split"1.5 .25 .75 -2 .7 .8 14 18 "},
{name="cruiser",
shape=split"3.5 .5 0 -1 .583333 .8125 18 24 "},
{name="freighter",
shape=split"3 2 0 -3 .2125 .8125 16 22 "},
{name="super freighter",
shape=split"6 0 -.25 .25 .7 .85 32 45 "},
}

function Ship:buildship(seed,stype)
self.ship_type_index=stype or ri(#ship_types)+1
self.ship_type=ship_types[self.ship_type_index]

local seed_value=seed or ri(32767)
srand(seed_value)
self.seed_value=seed_value

local shape=self.ship_type.shape

local ship_colors=split"x6789abcdef"
for i=1,6 do
 del(ship_colors,ship_colors[ri(#ship_colors)+1])
end

local hp=0
local ship_mask={}
local rows=ri(shape[8]+1,shape[7])
local cols=flr(rows/2)

local s1=V(1,shape[1])
local s2=V(1,shape[2])
local s3=V(1,shape[3])
local s4=V(1,shape[4])
local y2=flr(shape[5]*rows)
local y3=flr(shape[6]*rows)

for y=1,rows do
 add(ship_mask,{})
 for x=1,cols do
  add(ship_mask[y],ship_colors[4])
 end
end

local last_slope=s1
local current_slope=s2
local thirdy=ro(rows/3)
local thirdx=ro(cols/4)

for y=2,rows-1 do
 for x=1,cols do
  local color=ship_colors[1]

  if y>=thirdy+ri1() and
  y<=2*thirdy+ri1() then
   color=ship_colors[3]
  end
  if x>=thirdx+ri1() and
  y>=2*thirdy+ri1() then
   color=ship_colors[2]
  end

  if cols-x<max(0,flr(last_slope.y)) then
   if rnd()<.6 then
    ship_mask[y][x]=color
    hp+=1
    if ship_mask[y-1][x]==ship_colors[4] then
     ship_mask[y][x]=darkshipcolors[color]
    end
   end
  end
 end

 if y>=y3 then
  current_slope=s4
 elseif y>=y2 then
  current_slope=s3
 end

 last_slope=last_slope+current_slope
 if last_slope.y>0 and y>3 and y<rows-1 then
  for i=1,ri(ro(last_slope.y/4)+1) do
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

self.hp=hp
self.max_hp=hp
self.hp_percent=1

self.deltav=max(hp*-0.0188235+4.5647058,1)*0.0326867

local turn_factor=1
if self.ship_type.name=="super freighter" then
 turn_factor*=.5
end
self.turn_rate=ro(turn_factor*max(hp*-0.0470588+11.4117647,2))

self.sprite_rows=rows
self.sprite_columns=#ship_mask[1]
self.transparent_color=ship_colors[4]
self.sprite=ship_mask
return self
end

function Ship:set_position_near_object(obj)
local radius=obj.radius or obj.sprite_rows
self.secpos=ra(1.2*radius)+obj.secpos
self:reset_velocity()
end

function Ship:clear_target()
self.target_index=nil
self.target=nil
end

function Ship:targeted_color()
if self.hostile then
return 8,2
else
return 11,3
end
end

function Ship:draw_sprite_rotated(offscreen_pos,angle)
local scrpos=offscreen_pos or self.scrpos
local a=angle or self.angle_radians
local rows=self.sprite_rows
local cols=self.sprite_columns
local tcolor=self.transparent_color
local projectile_hit_by
local close_projectiles={}

if self.targeted then
 local targetcircle_radius=ro(rows/2)+4
 local circlecolor,circleshadow=self:targeted_color()
 if offscreen_pos then
  (scrpos+V(1,1)):draw_circle(targetcircle_radius,circleshadow,true)
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

local pixel1=V(
rows-x-flr(rows/2),
y-flr(cols/2)-1)
local pixel2=V(pixel1.x+1,pixel1.y)
pixel1:rotate(a):add(scrpos):ro()
pixel2:rotate(a):add(scrpos):ro()

if self.hp<1 and rnd()<.8 then
make_explosion(pixel1,rows/2,18,self.velocity_vector)
if not offscreen_pos then
 add(particles,Spark.new(pixel1,ra(rnd(.25)+.25)+self.velocity_vector,color,128+ri(32)))
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
   add(particles,Spark.new(pixel1,ra(rnd(2)+1)+self.velocity_vector,color,128))
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

function Ship:turn_left()
self:rotate(self.turn_rate)end

function Ship:turn_right()
self:rotate(-self.turn_rate)end

function Ship:rotate(signed_degrees)
self.angle=(self.angle+signed_degrees)%360
self.angle_radians=self.angle/360
self.heading=(450-self.angle)%360
end

function Ship:draw()
text("‡"..self:hp_string(),0,0,self:hp_color())
text("pixels/sec "..format(10*self.velocity),0,7)
if self.accelerating then
 text(format(self.current_gees).." gS",0,14)
end
self:draw_sprite_rotated()
end

function Ship:hp_color()
return health_colormap[ceil(10*self.hp_percent)]
end

function Ship:hp_string()
return ro(100*self.hp_percent).."% "..self.hp.."/"..self.max_hp
end

function Ship:is_visible(player_ship_pos)
local size=ro(self.sprite_rows/2)
local scrpos=(self.secpos-player_ship_pos+screen_center):ro()
self.scrpos=scrpos
return scrpos.x<128+size and
scrpos.x>0-size and
scrpos.y<128+size and
scrpos.y>0-size
end

function Ship:update_location()
if self.velocity>0.0 then
 self.secpos:add(self.velocity_vector)
end
end

function Ship:reset_velocity()
self.velocity_vector=V()
self.velocity=0
end

function Ship:predict_sector_position()
local prediction=self.secpos:clone()
if self.velocity>0 then
 prediction:add( self.velocity_vector*4 )
end
return prediction
end

function Ship:set_destination(dest)
self.destination=dest.secpos
self:update_steering_velocity()
self.max_distance_to_destination=self.distance_to_destination
end

function Ship:flee()
self:set_destination(self.last_hit_attacking_ship)
self:update_steering_velocity(1)
local away_from_enemy=self.steering_velocity:angle()
local toward_enemy=(away_from_enemy+.5) % 1
if self.distance_to_destination<55 then
 self:rotate_towards_heading(away_from_enemy)
 self:apply_thrust()
else
 self:full_stop(true)
 if self.hostile and
  self.angle_radians<toward_enemy+.1 and
 self.angle_radians>toward_enemy-.1 then
  self:fire_weapon()
 end
end
end

function Ship:update_steering_velocity(modifier)
local away=modifier or -1
local desired_velocity=self.secpos-self.destination
self.distance_to_destination=desired_velocity:scaled_length()
self.steering_velocity=(desired_velocity-self.velocity_vector)*away
end

function Ship:seek()
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
self.steering_velocity=desired_velocity-self.velocity_vector

if self:rotate_towards_heading(self.steering_velocity:angle()) then
 self:apply_thrust(abs(self.steering_velocity:length()))
end
if self.hostile then
 if distance<128 then
  self:fire_weapon()
  self:fire_missile()
 end
end
end

function Ship:fly_towards_destination()
self:update_steering_velocity()
if self.distance_to_destination>self.max_distance_to_destination*.9 then
 if self:rotate_towards_heading(self.steering_velocity:angle()) then
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

function Ship:approach_object(obj)
local obj=obj or sect.planets[ri(#sect.planets)+1]
self:set_destination(obj)
self:reset_orders(self.fly_towards_destination)
if self.velocity>0 then
 add(self.orders,self.full_stop)
end
end

function Ship:follow_current_order()
local order=self.orders[#self.orders]
if order then order(self) end
end

function Ship:order_done(new_order)
self.orders[#self.orders]=new_order
end

function Ship:reset_orders(new_order)
self.orders={}
if new_order then add(self.orders,new_order) end
end

function Ship:cut_thrust()
self.accelerating=false
self.current_deltav=self.deltav/3
end

function Ship:wait()
if secondcount>self.wait_duration+self.wait_time then
 self:order_done()
end
end

function Ship:full_stop()
if self.velocity>0 and self:reverse_direction() then
 self:apply_thrust()
 if self.velocity<1.2*self.deltav then
  self:reset_velocity()
  self:order_done()
 end
end
end

function Ship:fire_missile(weapon)
if self.target and secondcount>3+self.last_fire_time then
 self.last_fire_time=secondcount
 add(projectiles,Missile.new(self,self.target))
end
end

function Ship:fire_weapon()
local weapon_velocity=rotatedv(self.angle_radians)
local hardpoint=weapon_velocity*(self.sprite_rows/2)+self.scrpos
local rate=3
if (self.npc) rate=5
if framecount%rate==0 then
 add(
 projectiles,
 Cannon.new(
 hardpoint,
 weapon_velocity*6+self.velocity_vector,12,self))
end
end

function Ship:apply_thrust(max_velocity)
self.accelerating=true
if self.current_deltav<self.deltav then
 self.current_deltav+=self.deltav/30
else
 self.current_deltav=self.deltav
end

local dv=self.current_deltav
if max_velocity and dv>max_velocity then
 dv=max_velocity
end

if self.hp_percent<=rnd(.1) then
 dv=0
end

self.current_gees=dv*30.593514175
local a=self.angle_radians
local additional_velocity_vector=V(cos(a)*dv,sin(a)*dv)
local velocity_vector=self.velocity_vector
local velocity
local engine_location=rotatedv(a,self.sprite_rows*-.5)+self.scrpos

add(particles,ThrustExhaust.new(
 engine_location,
 additional_velocity_vector*-1.3*self.sprite_rows))

velocity_vector:add(additional_velocity_vector)
velocity=velocity_vector:length()

self.velocity_angle=velocity_vector:angle()
self.velocity_angle_opposite=(self.velocity_angle+0.5)%1

self.velocity=velocity
self.velocity_vector=velocity_vector
end

function Ship:reverse_direction()
if self.velocity>0.0 then
 return self:rotate_towards_heading(self.velocity_angle_opposite)
end
end

function Ship:rotate_towards_heading(heading)
local delta=(heading*360-self.angle+180)%360-180
if delta~=0 then
 local r=self.turn_rate*delta/abs(delta)
 if abs(delta)>abs(r) then delta=r end
 self:rotate(delta)
end
return delta<0.1 and delta>-.1
end

function Ship:data(y)
rectfill(0,y+34,127,y,0)
rect(0,y+34,127,y,6)
self:draw_sprite_rotated(V(104,y+17),0)
text("class "..self.ship_type.name.."\nmodel "..self.seed_value.."\nmax hull‡ "..self.max_hp.."\nmax thrust "..format(self.deltav*30.593514175).." g\nturn rate  "..self.turn_rate.." deg/sec",3,y+3)
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

Missile={}
Missile.__index=Missile
function Missile.new(fship,t)
return setmetatable({
secpos=fship.secpos:clone(),
scrpos=fship.scrpos:clone(),
velocity_vector=rotatedv((fship.angle_radians+.25)%1,.5)+fship.velocity_vector,
velocity=fship.velocity,
target=t,
sprite_rows=1,
firing_ship=fship,
current_deltav=.1,
deltav=.1,
hp_percent=1,
duration=512,
damage=20
},Missile)end

function Missile:update()
self.destination=self.target:predict_sector_position()
self:update_steering_velocity()
self.angle_radians=self.steering_velocity:angle()
if self.duration<500 then
 self:apply_thrust(abs(self.steering_velocity:length()))
end
self.duration-=1
self:update_location()
end

function Missile:draw(shipvel,offscreen_pos)
local scrpos=offscreen_pos or self.scrpos
self.last_offscreen_pos=offscreen_pos
if self:is_visible(pilot.secpos) or offscreen_pos then
 scrpos:draw_line(scrpos+rotatedv(self.angle_radians,4),6)
end
end

setmetatable(Missile,{__index=Ship})

Star={}
Star.__index=Star
function Star.new()
return setmetatable({
position=V(),
color=7,
speed=1
},Star)end

function Star:reset(x,y)
self.position=V(x or ri(128),y or ri(128))
self.color=ri(#star_colors[star_color_monochrome+star_color_index+1])+1
self.speed=rnd(0.75)+0.25
return self
end

Sun={}
Sun.__index=Sun
function Sun.new(radius,x,y)
local r=radius or 64+ri(128)
local c=ri(6,1)
return setmetatable({
scrpos=V(),
radius=r,
sun_color_index=c,
color=sun_colors[c+5],
secpos=V(x or 0,y or 0),
},Sun)end

function Sun:draw(ship_pos)
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
Sector={}
Sector.__index=Sector
function Sector.new()
local sec={
seed=ri(32767),
planets={},
starfield={}
}
srand(sec.seed)
for i=1,starfield_count do
 add(sec.starfield,Star.new():reset())
end
setmetatable(sec,Sector)
return sec
end

function Sector:reset_planet_visibility()
for p in all(self.planets) do
 p.rendered_circle=false
 p.rendered_terrain=false
end
end

function Sector:new_planet_along_elipse()
local x
local y
local smallest_distance
local planet_is_nearby=true
while(planet_is_nearby) do
 x=rnd(150)
 y=sqrt( (rnd(35)+40)^2*(1-x^2/(rnd(50)+100)^2) )
 if rnd()<.5 then x*=-1 end
 if rnd()<.75 then y*=-1 end
 if #self.planets==0 then break end
 smallest_distance=32767
 for p in all(self.planets) do
  smallest_distance=min(
   smallest_distance,
   scaled_dist(V(x,y),p.secpos/33))
 end
 planet_is_nearby=smallest_distance<15
end
return Planet.new(x*33,y*33,((1-V(x,y):angle())-.25)%1)
end

function Sector:draw_starfield(shipvel)
local line_start_point
local line_end_point
for star in all(self.starfield) do
 line_start_point=star.position+(shipvel*star.speed*-.5)
 line_end_point=star.position+(shipvel*star.speed*.5)
 local i=star_color_monochrome+star_color_index+1
 local star_color_count=#star_colors[i]
 local color_index=1+((star.color-1)%star_color_count)
 star.position:draw_line(
  line_end_point,
  star_colors[i+1][color_index])
 line_start_point:draw_line(
  star.position,
  star_colors[i][color_index])
end
end

function Sector:scroll_starfield(shipvel)
local stardifference=starfield_count-#self.starfield
for i=1,stardifference do
 add(self.starfield,Star.new():reset())
end
for star in all(self.starfield) do
 star.position:add(shipvel*star.speed*-1)

 if stardifference<0 then
  del(self.starfield,star)
  stardifference+=1
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
local x=p.scrpos.x
local y=p.scrpos.y
local duration_up=p.duration<0
if p.deltav then
 return duration_up
else
 return duration_up or x>maxcoord or x<mincoord or y>maxcoord or y<mincoord
end
end

Spark={}
Spark.__index=Spark
function Spark.new(p,pv,c,d)
return setmetatable({
scrpos=p,
particle_velocity=pv,
color=c,
duration=d or ri(7,2)
},Spark)end

function Spark:update(shipvel)
self.scrpos:add(self.particle_velocity-shipvel)
self.duration-=1
end

function Spark:draw(shipvel)
pset(self.scrpos.x,self.scrpos.y,self.color)
self:update(shipvel)
end

function make_explosion(pixel1,size,colorcount,center_velocity)
add(particles,Explosion.new(
 pixel1,size,colorcount,
 center_velocity))
end

Explosion={}
Explosion.__index=Explosion
function Explosion.new(position,size,colorcount,shipvel)
local explosion_size_factor=rnd()
return setmetatable({
scrpos=position:clone(),
particle_velocity=shipvel:clone(),
radius=explosion_size_factor*size,
radius_delta=explosion_size_factor*rnd(.5),
len=colorcount-3,
duration=colorcount
},Explosion)end

function Explosion:draw(shipvel)
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

setmetatable(Explosion,{__index=Spark})

Cannon={}
Cannon.__index=Cannon
function Cannon.new(p,pv,c,ship)
return setmetatable({
scrpos=p,
position2=p:clone(),
particle_velocity=pv+pv:perpendicular():normalize()*(rnd(2)-1),
color=c,
firing_ship=ship,
duration=16
},Cannon)end

function Cannon:draw(shipvel)
self.position2:draw_line(self.scrpos,self.color)
self.position2=self.scrpos:clone()
end

setmetatable(Cannon,{__index=Spark})

ThrustExhaust={}
ThrustExhaust.__index=ThrustExhaust
function ThrustExhaust.new(p,pv)
return setmetatable({
scrpos=p,
particle_velocity=pv,
duration=0
},ThrustExhaust)end

function ThrustExhaust:draw(shipvel)
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
 add(particles,Spark.new(p0,shipvel+(flicker*.25),c))
end

self.scrpos:add(pv-shipvel)
self.duration-=1
end

function draw_circle(xc,yc,radius,filled,color)
local xvalues={}
local notfilled=not filled
local fx=0
local fy=0
local x=-radius
local y=0
local err=2-2*radius
while(x<0) do
 xvalues[1+x*-1]=y

 if notfilled then
  fx=x
  fy=y
 end
 for i=x,fx do
  sset(xc-i,yc+y,color)
  sset(xc+i,yc-y,color)
 end
 for i=fy,y do
  sset(xc-i,yc-x,color)
  sset(xc+i,yc+x,color)
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

function draw_moon_at_ycoord(ycoord,xcenter,ycenter,radius,phase,xvalues,all_black)
local x,doublex,x1,x2,i,c1,c2
local y=radius-ycoord
local xvalueindex=abs(y)+1

if xvalueindex<=#xvalues then
 x=flr(sqrt(radius*radius-y*y))

 doublex=2*x
 if phase<.5 then
  x1=-xvalues[xvalueindex]
  x2=flr(doublex-2*phase*doublex-x)
 else
  x1=flr(x-2*phase*doublex+doublex)
  x2=xvalues[xvalueindex]
 end

 for i=x1,x2 do
  if not all_black or (phase<.5 and i>x2-2) or (phase>=.5 and i<x1+2) then
   c1=dark_planet_colors[sget(xcenter+i,ycenter-y)+1]
  else
   c1=0
  end
  sset(xcenter+i,ycenter-y,c1)
 end
end
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

function GetN_3d(ix,iy,iz,x,y,z)
local t=.6-x*x-y*y-z*z
local index=perms12[ix+perms[iy+perms[iz]]]
return max(0,(t*t)*(t*t))*(Grads3[index][0]*x+Grads3[index][1]*y+Grads3[index][2]*z)
end

function Simplex3D(x,y,z)
local s=(x+y+z)*0.333333333
local ix,iy,iz=flr(x+s),flr(y+s),flr(z+s)
local t=(ix+iy+iz)*0.166666667
local x0=x+t-ix
local y0=y+t-iy
local z0=z+t-iz
ix,iy,iz=band(ix,255),band(iy,255),band(iz,255)
local n0=GetN_3d(ix,iy,iz,x0,y0,z0)
local n3=GetN_3d(ix+1,iy+1,iz+1,x0-0.5,y0-0.5,z0-0.5)
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
local n1=GetN_3d(ix+i1,iy+j1,iz+k1,x0+0.166666667-i1,y0+0.166666667-j1,z0+0.166666667-k1)
local n2=GetN_3d(ix+i2,iy+j2,iz+k2,x0+0.333333333-i2,y0+0.333333333-j2,z0+0.333333333-k2)
return 32*(n0+n1+n2+n3)end

function create_planet_type(name,o,colormap,fullshadow,transparentcolor)
local ozpm=split(o)
return {
class_name=name,
noise_octaves=ozpm[1],
noise_zoom=ozpm[2],
noise_persistance=ozpm[3],
minimap_color=ozpm[4],
transparent_color=transparentcolor or 14,
full_shadow=fullshadow or "yes",
color_map=split(colormap)
}end

planet_types={
create_planet_type(
"tundra",
"5 .5 .6 6 ",
"x76545676543"),
create_planet_type(
"desert",
"5 .35 .3 9 ",
"x449944994499b1949949949949949"),
create_planet_type(
"barren",
"5 .55 .35 5 ",
"x565056765056"),
create_planet_type(
"lava",
"5 .55 .65 4 ",
"x040504049840405040"),
create_planet_type(
"gas giant",
"1 .4 .75 2 ",
"x76d121c"),
create_planet_type(
"gas giant",
"1 .4 .75 8 ",
"x7fe21288",
nil,12),
create_planet_type(
"gas giant",
"1 .7 .75 10 ",
"xfa949a"),
create_planet_type(
"terran",
"5 .3 .65 11 ",
"x1111111dcfbb3334567",
"partial shadow"),
create_planet_type(
"island",
"5 .55 .65 12 ",
"x11111111dcfb3",
"partial shadow")}

Planet={}
Planet.__index=Planet
function Planet.new(x,y,phase,r)
local planet_type=planet_types[ri(#planet_types)+1]
local noise_factor_vert=planet_type.noise_factor_vert or 1

if planet_type.class_name=="gas giant" then
 planet_type.min_size=50
 noise_factor_vert=4
 if rnd()<.5 then
  noise_factor_vert=20
 end
end

local min_size=planet_type.min_size or 10
local radius=r or ri(65,min_size)
return setmetatable({
scrpos=V(),
radius=radius,
secpos=V(x,y),
bottom_right_coord=2*radius-1,
phase=phase,
planet_type=planet_type,
noise_factor_vert=noise_factor_vert,
noisedx=rnd(1024),
noisedy=rnd(1024),
noisedz=rnd(1024),
rendered_circle=false,
rendered_terrain=false,
color=planet_type.minimap_color
},Planet)end

function Planet:draw(ship_pos)
if stellar_object_is_visible(self,ship_pos) then
 self:render_a_bit_to_sprite_sheet()
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

function Planet:render_a_bit_to_sprite_sheet(fullmap,renderback)
local radius=self.radius-1
if fullmap then radius=47 end

if not self.rendered_circle then
self.width=self.radius*2
self.height=self.radius*2
self.x=0
self.yfromzero=0
self.y=radius-self.yfromzero
self.phi=0
sect:reset_planet_visibility()
pal()
palt(0,false)
palt(self.planet_type.transparent_color,true)
if fullmap then
 self.width=114
 self.height=96
 draw_rect(self.width,self.height,0)
else
 draw_rect(self.width,self.height,self.planet_type.transparent_color)
 self.bxs=draw_circle(radius,radius,radius,true,0)
 draw_circle(radius,radius,radius,false,self.planet_type.minimap_color)
end
self.rendered_circle=true
end

if (not self.rendered_terrain) and self.rendered_circle then

local theta_start=0
local theta_end=.5
local theta_increment=theta_end/self.width
if fullmap and renderback then
 theta_start=.5
 theta_end=1
end

if self.phi>.25 then
 self.rendered_terrain=true
else
for theta=theta_start,theta_end-theta_increment,theta_increment do
 if sget(self.x,self.y)~=self.planet_type.transparent_color then
  local freq=self.planet_type.noise_zoom
  local max_amp=0
  local amp=1
  local value=0
  for n=1,self.planet_type.noise_octaves do
   value=value+Simplex3D(
    self.noisedx+freq*cos(self.phi)*cos(theta),
    self.noisedy+freq*cos(self.phi)*sin(theta),
    self.noisedz+freq*sin(self.phi)*self.noise_factor_vert)
   max_amp+=amp
   amp*=self.planet_type.noise_persistance
   freq*=2
  end
  value/=max_amp
  if value>1 then value=1 end
  if value<-1 then value=-1 end
  value+=1
  value*=(#self.planet_type.color_map-1)/2
  value=ro(value)
  sset(self.x,self.y,self.planet_type.color_map[value+1])
 end
 self.x+=1
end
if not fullmap then
 draw_moon_at_ycoord(
  self.y,radius,radius,radius,self.phase,self.bxs,
  self.planet_type.full_shadow=="yes")
end
self.x=0
if self.phi>=0 then
 self.yfromzero+=1
 self.y=radius+self.yfromzero
 self.phi+=.5/(self.height-1)
else
 self.y=radius-self.yfromzero
end
self.phi*=-1
end

end

return self.rendered_terrain
end

function add_npc(pos,pirate)
local t=ri(#ship_types)+1
if pirate or rnd()<.2 then
t=ri(3,1)
pirate=true
pirates+=1
end
local npc=Ship.new(pirate):buildship(nil,t)
npc:set_position_near_object(pos)
npc.npc=true
add(npcships,npc)
npc.index=#npcships
end

function load_sector()
sect=Sector.new()
note_add("arriving in system ngc "..sect.seed)

add(sect.planets,Sun.new())

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

pilot=Ship.new()
pilot:buildship(nil,1)

load_sector()
setup_minimap()
show_title_screen=true

local titlestarv=V(0,-3)

while(not btnp(4)) do
 cls()
 sect:scroll_starfield(titlestarv)
 sect:draw_starfield(titlestarv)
 circfill(64,135,90,2)
 circfill(64,172,122,0)
 map(0,0,6,-15)
 text("\n\n    ”  thrust      —  fire\n  ‹  ‘  rotate  Ž  menu\n    ƒ  reverse",0,70,6,true)
 flip()
end
end

minimap_sizes={16,32,48,128,false}

function setup_minimap(size)
minimap_size_index=size or 0
minimap_size=minimap_sizes[minimap_size_index+1]
if minimap_size then
 minimap_size_halved=minimap_size/2
 minimap_offset=V(126-minimap_size_halved,minimap_size_halved+1)
end
end

function draw_minimap_planet(obj)
local p=obj.secpos+screen_center
if obj.planet_type then p:add(V(-obj.radius,-obj.radius)) end
p=p/minimap_denominator+minimap_offset
if minimap_size>100 then
 local r=ceil(obj.radius/32)
 p:draw_circle(r+1,obj.color)
else
 p:draw_point(obj.color)
end
end

function draw_minimap_ship(obj)
local p=(obj.secpos/minimap_denominator):add(minimap_offset):ro()
local x=p.x
local y=p.y
local color=obj:targeted_color()
if obj.npc then
 p:draw_point(color)
 if obj.targeted then
  p:draw_circle(2,color)
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

function draw_minimap()
local text_height=minimap_size or 0
if minimap_size then
 if minimap_size>0 and minimap_size<100 then
  text_height+=4
  rectfill(126-minimap_size,1,126,minimap_size+1,0)
  rect(125-minimap_size,0,127,minimap_size+2,6,11)
 else
  text_height=0
 end
 local x=abs(pilot.secpos.x)
 local y=abs(pilot.secpos.y)
 if y>x then x=y end
 minimap_denominator=min(6,flr(x/5000)+1)*5000/minimap_size_halved

 for p in all(sect.planets) do
  draw_minimap_planet(p)
 end

 if framecount%3~=0 then
  for m in all(projectiles) do
   if m.deltav then
    draw_minimap_ship(m)
   end
  end
  for s in all(npcships) do
   draw_minimap_ship(s)
  end
  draw_minimap_ship(pilot)
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
if current_option_callbacks[i] then
 local return_value=current_option_callbacks[i]()
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

function display_menu(colors,options,callbacks)
if options then
 current_options=options
 current_menu_colors=split(colors)
 current_option_callbacks=callbacks
end

if shipinfo then
 pilot:data(0)
elseif showyard then
 for i=0,1 do
  if shipyard[i+1] then
   shipyard[i+1]:data(i*36)
  end
 end
end
for a=.25,1,.25 do
 local i=a*4
 local text_color=current_menu_colors[i]
 if i==pressed then text_color=darkshipcolors[text_color] end

 if current_options[i] then

  local p=rotatedv(a,15)+V(64,90)
  if a==.5 then
   p.x-=4*#current_options[i]
  elseif a~=1 then
   p.x-=ro(4*(#current_options[i]/2))
  end

  text(
   current_options[i],
   p.x,p.y,text_color,true)
 end
end
text("  ”  \n‹  ‘\n  ƒ",52,84,6,true)
end

function main_menu()
display_menu(
"xc8b7",
{"autopilot",
"fire missile",
"options",
"systems"
},{

function()
display_menu(
"xcc6c",
{"full stop",
"near planet",
"back",
"follow",
},{
function()
pilot:reset_orders(pilot.full_stop)
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
display_menu(
"x6fba",
{"back",
"starfield",
"minimap size",
"debug"
},{
main_menu,

function()
display_menu(
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
setup_minimap((minimap_size_index+1)%#minimap_sizes)
return true
end,

function()
display_menu(
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
display_menu(
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
 add(shipyard,Ship.new():buildship())
end
end

function buyship(i)
pilot:buildship(shipyard[i].seed_value,shipyard[i].ship_type_index)
shipyard[i]=nil
note_add("purchased!")
myship_menu()
end

function myship_menu()
showyard=false
shipinfo=true
display_menu(
"x6b66",
{"back",
"repair"
},{
landed_menu,
function()
pilot:buildship(pilot.seed_value,pilot.ship_type_index)
note_add("hull damage repaired")
end
})
end

function landed_menu()
shipinfo=false
showyard=false
display_menu(
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
if(#shipyard==0)addyardships()
display_menu(
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
 landed_front_rendered=p:render_a_bit_to_sprite_sheet(true)
 if landed_front_rendered then
  p.rendered_circle=false
  p.rendered_terrain=false
  for j=1,56 do
   shift_sprite_sheet()
  end
 end
else
 if not landed_back_rendered then
  landed_back_rendered=p:render_a_bit_to_sprite_sheet(true,true)
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
 text("planet class: "..landed_planet.planet_type.class_name,1,1)
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

   s:follow_current_order()
  end

  s:update_location()
  if s.hp<1 then
   if s.hostile then
    pirates-=1
    if pirates<1 then note_add("sector cleared!") end
   end
   del(npcships,s)
   pilot:clear_target()
  end
 end

 pilot:follow_current_order()
 pilot:update_location()

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
   local p2=last_offscreen_pos:clone():add(V(-4*(#distance/2)))
   targeted_ship:draw_sprite_rotated(last_offscreen_pos)
   if p2.y>63 then
    p2:add(V(1,-12-hr))
   else
    p2:add(V(1,7+hr))
   end
   text(distance,ro(p2.x),ro(p2.y),color)
  end
  text("target‡"..targeted_ship:hp_string(),0,114,targeted_ship:hp_color())
 end
end

if pilot.hp<1 then
 pilot:buildship()
end

pilot:draw()

for p in all(particles) do
 if is_offscreen(p,32) then
  del(particles,p)
 else
  if paused then
   p:draw(V())
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

draw_minimap()
end

function _draw()
if landed then
 render_landed_screen()
else
 render_game_screen()
end
if paused or landed then
 display_menu()
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
