pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- heliopause
-- by anthony digirolamo

local object = {}
object.__index = object
function object:new() end

function object:extend()
  local cls = {}
  for k, v in pairs(self) do
    if sub(k, 1, 2) == "__" then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  setmetatable(cls, self)
  return cls
end

function object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end

function split(s)
  local t, start_index, ti = {}, 2, split_start or 0
  local mode = sub(s, 1, 1)
  for i = 2, #s do
    local c = sub(s, i, i)
    if mode == "x" then
      t[ti] = ("0x" .. c) + 0
      ti+=1
    elseif c == "," then
      local sstr = sub(s, start_index, i - 1)
      if mode == "a" then
        if sstr == "nil" then
          sstr = nil
        end
        t[ti] = sstr
      else
        t[ti] = sstr + 0
      end
      ti+=1
      start_index = i + 1
    end
  end
  return t
end

function nsplit(s)
  local t, start_index, ti = {}, 1, split_start or 0
  for i = 1, #s do
    if sub(s, i, i) == "|" then
      t[ti] = split(sub(s, start_index, i - 1))
      ti+=1
      start_index = i + 1
    end
  end
  return t
end

v = object:extend()
function v:new(x, y)
  self.x = x or 0
  self.y = y or 0
end
function v:add(v)
  self.x+=v.x
  self.y+=v.y
  return self
end

function v.__add(a, b)
  return v(a.x + b.x, a.y + b.y)
end
function v.__sub(a, b)
  return v(a.x - b.x, a.y - b.y)
end
function v.__mul(a, b)
  return v(a.x * b, a.y * b)
end
function v.__div(a, b)
  return v(a.x / b, a.y / b)
end

function v:clone()
  return v(self.x, self.y)
end
function v:about_equals(v)
  return ro(v.x) == self.x and ro(v.y) == self.y
end
function v:angle()
  return atan2(self.x, self.y)
end

function v:length()
  return sqrt(self.x ^ 2 + self.y ^ 2)
end
function v:scaled_length()
  return 182 * sqrt((self.x / 182) ^ 2 + (self.y / 182) ^ 2)
end
function scaled_dist(a, b)
  return (b - a):scaled_length()
end

function v:perpendicular()
  return v(-self.y, self.x)
end

function v:normalize()
  local l = self:length()
  self.x/=l
  self.y/=l
  return self
end

function v:rotate(phi)
  local c = cos(phi)
  local s = sin(phi)
  local x = self.x
  local y = self.y
  self.x = c * x - s * y
  self.y = s * x + c * y
  return self
end

function v:ro()
  self.x = ro(self.x)
  self.y = ro(self.y)
  return self
end

function v:draw_point(c)
  pset(ro(self.x), ro(self.y), c)
end

function v:draw_line(v, c)
  line(ro(self.x), ro(self.y), ro(v.x), ro(v.y), c)
end

function v:draw_circle(radius, c, fill)
  local method = circ
  if fill then
    method = circfill
  end
  method(ro(self.x), ro(self.y), ro(radius), c)
end

function ra(len)
  return rotatedv(rnd(), len)
end
function rotatedv(angle, x, y)
  return v(x or 1, y):rotate(angle)
end
function ro(i)
  return flr(i + .5)
end
function ceil(x)
  return -flr(-x)
end
function ri(n, minimum)
  local m = minimum or 0
  return m + flr(rnd(32767)) % (n - m)
end
function format(num)
  local n = flr(num * 10 + 0.5) / 10
  return flr(n) .. "." .. ro((n % 1) * 10)
end

ship = object:extend()
function ship:new(h)
  self.npc = false
  self.hostile = h
  self.scrp = screen_center
  self.secp = v()
  self.cur_deltav = 0
  self.cur_gees = 0
  self.angle = 0
  self.angle_radians = 0
  self.heading = 90
  self.velocity_angle = 0
  self.velocity_angle_opposite = 180
  self.velocity = 0
  self.velocity_vector = v()
  self.orders = {}
  self.last_fire_time = -6
end

function ship:buildship(seed, stype)
  self.stypei = stype or ri(#ship_types) + 1

  local seed_value = seed or ri(32767)
  srand(seed_value)
  self.seed_value = seed_value
  self.name = ship_names[self.stypei]
  local shape = ship_types[self.stypei]

  local scs = split "x6789abcdef"
  for i = 1, 6 do
    del(scs, scs[ri(#scs) + 1])
  end

  local hp = 0
  local ship_mask = {}
  local rows = ri(shape[#shape] + 1, shape[#shape - 1])
  local cols = flr(rows / 2)

  for y = 1, rows do
    add(ship_mask, {})
    for x = 1, cols do
      add(ship_mask[y], scs[4])
    end
  end

  local slopei, slope = 2, v(1, shape[1])

  for y = 2, rows - 1 do

    for x = 1, cols do

      local color = scs[1 + flr((y + ri(3) - 1) / rows * 3)]

      if cols - x < max(0, flr(slope.y)) then
        if rnd() < .6 then
          ship_mask[y][x] = color
          hp+=1
          if ship_mask[y - 1][x] == scs[4] then
            ship_mask[y][x] = darkshipcolors[color]
          end
        end
      end

    end

    if y >= flr(shape[slopei + 1] * rows) then
      slopei+=2
    end
    slope+=v(1, shape[slopei])

    if slope.y > 0 and y > 3 and y < rows - 1 then
      for i = 1, ri(ro(slope.y / 4) + 1) do
        ship_mask[y][cols - i] = 5
        hp+=2
      end
    end

  end

  local odd_columns = ri(2)
  for y = rows, 1, -1 do
    for x = cols - odd_columns, 1, -1 do
      add(ship_mask[y], ship_mask[y][x])
    end
  end

  if self.stypei == #ship_types then
    hp*=4
  end

  self.hp = hp
  self.max_hp = hp
  self.hp_percent = 1
  self.deltav = max(hp * -0.0188 + 4.5647, 1) * 0.0326
  local turn_factor = 1
  if self.stypei == 4 then
    turn_factor*=.5
  end
  self.turn_rate = ro(turn_factor * max(hp * -0.0470 + 11.4117, 2))
  self.sprite_rows = rows
  self.sprite_columns = #ship_mask[1]
  self.transparent_color = scs[4]
  self.sprite = ship_mask
  return self
end

function ship:set_position_near_object(obj)
  local radius = obj.radius or obj.sprite_rows
  self.secp = ra(1.2 * radius) + obj.secp
  self:reset_velocity()
end

function ship:clear_target()
  self.target_index = nil
  self.target = nil
end

function ship:targeted_color()
  if self.hostile then
    return 8, 2
  else
    return 11, 3
  end
end

function ship:draw_sprite_rotated(offscreen_pos, angle)
  if self.dead then
    return
  end
  local scrp = offscreen_pos or self.scrp
  local a = angle or self.angle_radians
  local rows, cols = self.sprite_rows, self.sprite_columns
  local tcolor = self.transparent_color
  local projectile_hit_by
  local close_projectiles = {}

  if self.targeted then
    local targetcircle_radius = ro(rows / 2) + 4
    local circlecolor, circleshadow = self:targeted_color()
    if offscreen_pos then
      (scrp + v(1, 1)):draw_circle(targetcircle_radius, circleshadow, true)
      scrp:draw_circle(targetcircle_radius, 0, true)
    end
    scrp:draw_circle(targetcircle_radius, circlecolor)
  end

  for p in all(projectiles) do
    if p.firing_ship ~= self then
      if (p.secp and offscreen_pos and (self.secp - p.secp):scaled_length() <= rows) or scaled_dist(p.scrp, scrp) < rows then
        add(close_projectiles, p)
      end
    end
  end

  for y = 1, cols do
    for x = 1, rows do
      local color = self.sprite[x][y]
      if color ~= tcolor and color ~= nil then

        local pixel1 = v(rows - x - flr(rows / 2), y - flr(cols / 2) - 1)
        local pixel2 = v(pixel1.x + 1, pixel1.y)
        pixel1:rotate(a):add(scrp):ro()
        pixel2:rotate(a):add(scrp):ro()

        if self.hp < 1 and rnd() < .8 then
          add(particles, explosion(pixel1, rows / 2, 18, self.velocity_vector))
          sfx(55, 2)
          if not offscreen_pos then
            add(particles, spark(pixel1, ra(rnd(.25) + .25) + self.velocity_vector, color, 128 + ri(32)))
          end

        else

          for projectile in all(close_projectiles) do

            local impact = false
            if not offscreen_pos and
              (pixel1:about_equals(projectile.scrp) or
                (projectile.position2 and pixel1:about_equals(projectile.position2))) then
              impact = true
            elseif offscreen_pos and projectile.last_offscreen_pos and
              pixel1:about_equals(projectile.last_offscreen_pos) then
              impact = true
            end

            if impact then
              projectile_hit_by = projectile.firing_ship
              local damage = projectile.damage or 1
              self.hp-=damage
              if damage > 10 then
                add(particles, explosion(pixel1, 8, 12, self.velocity_vector))
                sfx(57, 1)
              else
                add(particles, explosion(pixel1, 2, 6, self.velocity_vector))
                sfx(56, 2)
              end
              local old_hp_percent = self.hp_percent
              self.hp_percent = self.hp / self.max_hp
              if not self.npc and old_hp_percent > .1 and self.hp_percent <= .1 then
                note_add("thruster malfunction")
              end
              if rnd() < .5 then
                add(particles, spark(pixel1, ra(rnd(2) + 1) + self.velocity_vector, color, 128))
              end
              del(projectiles, projectile)
              self.sprite[x][y] = -5
              color = -5
              break
            end

          end

          if color < 0 then
            color = 5
          end

          rectfill(pixel1.x, pixel1.y, pixel2.x, pixel2.y, color)
        end

      end
    end
  end

  if projectile_hit_by then
    self.last_hit_time = secondcount
    self.last_hit_attacking_ship = projectile_hit_by
  end
end

function ship:turn_left()
  self:rotate(self.turn_rate)
end

function ship:turn_right()
  self:rotate(-self.turn_rate)
end

function ship:rotate(signed_degrees)
  self.angle = (self.angle + signed_degrees) % 360
  self.angle_radians = self.angle / 360
  self.heading = (450 - self.angle) % 360
end

function ship:draw()
  text(self:hp_string(), 0, 0, self:hp_color())
  local o = nil
  local co = self.orders[#self.orders]
  if co == self.full_stop then
    o = "stopping"
  elseif co == self.seek then
    o = "following"
  elseif co == self.fly_towards_destination then
    o = "flying to nearest planet"
  end
  if o then
    text(o, 1, 22, 12, true)
  end
  if self.last_fire_time + 5 >= secondcount then
    text("reloading", 1, 31, 10, true)
  end
  text("pixels/sec " .. format(10 * self.velocity), 0, 7)
  if self.accelerating then
    text(format(self.cur_gees) .. " g", 0, 14)
  end
  self:draw_sprite_rotated()
end

function ship:hp_color()
  return health_colormap[ceil(10 * self.hp_percent)]
end

function ship:hp_string()
  return "♥"..ro(100*self.hp_percent).."% "..self.hp.."/"..self.max_hp
end

function ship:data(y)
  rectfill(0,y+34,127,y,0)
  rect(0,y+34,127,y,6)
  self:draw_sprite_rotated(v(104,y+17),0)
  text(self.name.."\nmodel "..self.seed_value.."\nmax hull♥ "..self.max_hp.."\nmax thrust "..format(self.deltav*30.593514175).." g\nturn rate  "..self.turn_rate.." deg/sec",3,y+3)
end

function ship:is_visible(player_ship_pos)
  local size = ro(self.sprite_rows / 2)
  local scrp = (self.secp - player_ship_pos + screen_center):ro()
  self.scrp = scrp
  return scrp.x < 128 + size and scrp.x > 0 - size and scrp.y < 128 + size and scrp.y > 0 - size
end

function ship:update_location()
  if self.velocity > 0 then
    self.secp:add(self.velocity_vector)
  end
end

function ship:reset_velocity()
  self.velocity_vector = v()
  self.velocity = 0
end

function ship:predict_sector_position()
  if self.velocity > 0 then
    return self.secp + self.velocity_vector * 4
  else
    return self.secp
  end
end

function ship:set_destination(dest)
  if dest == nil then
    self:reset_orders()
    return
  end
  self.destination = dest.secp
  self:update_steering_velocity()
  self.max_distance_to_destination = self.distance_to_destination
end

function ship:flee()
  self:set_destination(self.last_hit_attacking_ship)
  self:update_steering_velocity(1)
  local away_from_enemy = self.steer_vel:angle()
  local toward_enemy = (away_from_enemy + .5) % 1
  if self.distance_to_destination < 55 then
    self:rotate_towards_heading(away_from_enemy)
    self:apply_thrust()
  else
    self:full_stop()
    if self.hostile and self.angle_radians < toward_enemy + .1 and self.angle_radians > toward_enemy - .1 then
      self:fire_weapon()
    end
  end
end

function ship:update_steering_velocity(modifier)
  local desired_velocity = self.secp - self.destination
  self.distance_to_destination = desired_velocity:scaled_length()
  self.steer_vel = (desired_velocity - self.velocity_vector) * (modifier or -1)
end

function ship:seek()
  if self.seektime % 20 == 0 then
    self:set_destination(self.target)
  end
  self.seektime+=1

  local target_offset = self.destination - self.secp
  local distance = target_offset:scaled_length()
  self.distance_to_destination = distance
  local maxspeed = distance / 50
  local ramped_speed = (distance / (self.max_distance_to_destination * .7)) * maxspeed
  local clipped_speed = min(ramped_speed, maxspeed)
  local desired_velocity = target_offset * (ramped_speed / distance)
  self.steer_vel = desired_velocity - self.velocity_vector

  if self:rotate_towards_heading(self.steer_vel:angle()) then
    self:apply_thrust(self.steer_vel:scaled_length())
  end
  if self.hostile then
    if distance < 128 then
      self:fire_weapon()
      self:fire_missile()
    end
  end
end

function ship:fly_towards_destination()
  self:update_steering_velocity()
  if self.distance_to_destination > self.max_distance_to_destination * .9 then
    if self:rotate_towards_heading(self.steer_vel:angle()) then
      self:apply_thrust()
    end
  else
    self.accelerating = false
    self:reverse_direction()
    if self.distance_to_destination <= self.max_distance_to_destination * .11 then
      self:order_done(self.full_stop)
    end
  end
end

function ship:approach_object(obj)
  local obj = obj or sect.planets[ri(#sect.planets) + 1]
  self:set_destination(obj)
  self:reset_orders(self.fly_towards_destination)
  if self.velocity > 0 then
    add(self.orders, self.full_stop)
  end
end

function ship:follow_cur_order()
  local order = self.orders[#self.orders]
  if order then
    order(self)
  end
end

function ship:order_done(new_order)
  self.orders[#self.orders] = new_order
end

function ship:reset_orders(new_order)
  self.orders = {}
  if new_order then
    add(self.orders, new_order)
  end
end

function ship:cut_thrust()
  self.accelerating = false
  self.cur_deltav = 0
end

function ship:wait()
  if secondcount > self.wait_duration + self.wait_time then
    self:order_done()
  end
end

function ship:full_stop()
  if self.velocity > 0 and self:reverse_direction() then
    self:apply_thrust()
    if self.velocity < 1.2 * self.deltav then
      self:reset_velocity()
      self:order_done()
    end
  end
end

function ship:fire_missile(weapon)
  if self.target and secondcount > 5 + self.last_fire_time then
    self.last_fire_time = secondcount
    add(projectiles, missile(self, self.target))
    self:pilotsfx(54)
  end
end

function ship:pilotsfx(n, c)
  if self == pilot then
    sfx(n, c or 1)
  end
end

function ship:fire_weapon()
  local hardpoints = {1, -1}
  if self.stypei ~= 2 then
    hardpoints = {0}
  end
  local rate = 3
  if self.npc then
    rate = 5
  end
  if framecount % rate == 0 then
    for y in all(hardpoints) do
      add(projectiles,
          cannon(rotatedv(self.angle_radians, self.sprite_rows / 2 - 1, y * (self.sprite_columns / 4)) + self.scrp,
                 rotatedv(self.angle_radians, 6) + self.velocity_vector, 12, self))
    end
    self:pilotsfx(36)
  end
end

function ship:apply_thrust(max_velocity)
  self.accelerating = true
  if self.cur_deltav < self.deltav then
    self.cur_deltav+=self.deltav / 30
  else
    self.cur_deltav = self.deltav
  end
  local dv = self.cur_deltav
  self:pilotsfx(38 + flr(12 * dv / self.deltav), 2)
  if max_velocity and dv > max_velocity then
    dv = max_velocity
  end
  if self.hp_percent <= rnd(.1) then
    dv = 0
  end
  self.cur_gees = dv * 30.593514175
  local a = self.angle_radians
  local additional_velocity_vector = v(cos(a) * dv, sin(a) * dv)
  local velocity_vector = self.velocity_vector
  local velocity
  local engine_location = rotatedv(a, self.sprite_rows * -.5) + self.scrp
  add(particles, thrustexhaust(engine_location, additional_velocity_vector * -1.3 * self.sprite_rows))
  velocity_vector:add(additional_velocity_vector)
  velocity = velocity_vector:length()
  self.velocity_angle = velocity_vector:angle()
  self.velocity_angle_opposite = (self.velocity_angle + 0.5) % 1
  self.velocity = velocity
  self.velocity_vector = velocity_vector
end

function ship:reverse_direction()
  if self.velocity > 0 then
    return self:rotate_towards_heading(self.velocity_angle_opposite)
  end
end

function ship:rotate_towards_heading(heading)
  local delta = (heading * 360 - self.angle + 180) % 360 - 180
  if delta ~= 0 then
    local r = self.turn_rate * delta / abs(delta)
    if abs(delta) > abs(r) then
      delta = r
    end
    self:rotate(delta)
  end
  return delta < 0.1 and delta > -.1
end

function nearest_planet()
  local planet
  local dist = 32767
  for p in all(sect.planets) do
    if p.planet_type then
      local d = scaled_dist(pilot.secp, p.secp)
      if d < dist then
        dist = d
        planet = p
      end
    end
  end
  return planet, dist
end

function land_at_nearest_planet()
  local planet, dist = nearest_planet()
  if dist < planet.radius * 1.4 then
    if pilot.velocity < .5 then
      sect:reset_planet_visibility()
      landed_front_rendered = false
      landed_back_rendered = false
      landed_planet = planet
      landed = true
      landed_menu()
      draw_rect(128, 128, 0)
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
  landed = false
  return false
end

function clear_targeted_ship_flags()
  foreach(npcships, function(ship)
    ship.targeted = false
  end)
end

function next_hostile_target(ship)
  local targeting_ship = ship or pilot
  local hostile
  for i = 1, #npcships do
    next_ship_target(ship)
    if targeting_ship.target.hostile then
      break
    end
  end
  return true
end

function next_ship_target(ship, random)
  local targeting_ship = ship or pilot
  if random then
    targeting_ship.target_index = ri(#npcships) + 1
  else
    targeting_ship.target_index = (targeting_ship.target_index or #npcships) % #npcships + 1
  end
  targeting_ship.target = npcships[targeting_ship.target_index]
  if targeting_ship == targeting_ship.target then
    targeting_ship.target = pilot
  end
  if not ship then
    clear_targeted_ship_flags()
    targeting_ship.target.targeted = true
  end
  return true
end

missile = ship:extend()
function missile:new(fship, t)
  self.secp = fship.secp:clone()
  self.scrp = fship.scrp:clone()
  self.velocity_vector = fship.velocity_vector:clone()
  self.velocity = fship.velocity
  self.target = t
  self.sprite_rows = 1
  self.firing_ship = fship
  self.cur_deltav = .1
  self.deltav = .1
  self.hp_percent = 1
  self.duration = 512
  self.damage = 20
end

function missile:update()
  self.destination = self.target:predict_sector_position()
  self:update_steering_velocity()
  self.angle_radians = self.steer_vel:angle()
  self:apply_thrust(self.steer_vel:scaled_length())
  self.duration-=1
  self:update_location()
end

function missile:draw(shipvel, offscreen_pos)
  local scrp = offscreen_pos or self.scrp
  self.last_offscreen_pos = offscreen_pos
  if self:is_visible(pilot.secp) or offscreen_pos then
    scrp:draw_line(scrp + rotatedv(self.angle_radians, 4), 6)
  end
end

star = object:extend()
function star:new()
  self.position = v()
  self.color = 7
  self.speed = 1
  return self
end

function star:reset(x, y)
  self.position = v(x or ri(128), y or ri(128))
  self.color = ri(#star_colors[star_color_monochrome + star_color_index + 1]) + 1
  self.speed = rnd(0.75) + 0.25
  return self
end

sun = object:extend()
function sun:new(radius, x, y)
  local r = radius or 64 + ri(128)
  local c = ri(6, 1)
  self.scrp = v()
  self.radius = r
  self.sun_color_index = c
  self.color = sun_colors[c + 5]
  self.secp = v(x or 0, y or 0)
end

function sun:draw(ship_pos)
  if stellar_object_is_visible(self, ship_pos) then
    for i = 0, 1 do
      self.scrp:draw_circle(self.radius - i * 3, sun_colors[i * 5 + self.sun_color_index], true)
    end
  end
end

function stellar_object_is_visible(obj, ship_pos)
  obj.scrp = obj.secp - ship_pos + screen_center
  return
    obj.scrp.x < 128 + obj.radius and obj.scrp.x > 0 - obj.radius and obj.scrp.y < 128 + obj.radius and obj.scrp.y > 0 -
      obj.radius
end

starfield_count = 40
sector = object:extend()
function sector:new()
  self.seed = ri(32767)
  self.planets = {}
  self.starfield = {}
  srand(self.seed)
  for i = 1, starfield_count do
    add(self.starfield, star():reset())
  end
end

function sector:reset_planet_visibility()
  foreach(self.planets, function(p)
    p.rendered_circle = false
    p.rendered_terrain = false
  end)
end

function sector:new_planet_along_elipse()
  local x, y, sdist
  local planet_nearby = true
  while (planet_nearby) do
    x = rnd(150)
    y = sqrt((rnd(35) + 40) ^ 2 * (1 - x ^ 2 / (rnd(50) + 100) ^ 2))
    if rnd() < .5 then
      x*=-1
    end
    if rnd() < .75 then
      y*=-1
    end
    if #self.planets == 0 then
      break
    end
    sdist = 32767
    for p in all(self.planets) do
      sdist = min(sdist, scaled_dist(v(x, y), p.secp / 33))
    end
    planet_nearby = sdist < 15
  end
  return planet(x * 33, y * 33, ((1 - v(x, y):angle()) - .25) % 1)
end

function sector:draw_starfield(shipvel)
  local lstart, lend
  for star in all(self.starfield) do
    lstart = star.position + (shipvel * star.speed * -.5)
    lend = star.position + (shipvel * star.speed * .5)
    local i = star_color_monochrome + star_color_index + 1
    local star_color_count = #star_colors[i]
    local color_index = 1 + ((star.color - 1) % star_color_count)
    star.position:draw_line(lend, star_colors[i + 1][color_index])
    lstart:draw_line(star.position, star_colors[i][color_index])
  end
end

function sector:scroll_starfield(shipvel)
  local diff = starfield_count - #self.starfield
  for i = 1, diff do
    add(self.starfield, star():reset())
  end
  for star in all(self.starfield) do
    star.position:add(shipvel * star.speed * -1)
    if diff < 0 then
      del(self.starfield, star)
      diff+=1
    elseif star.position.x > 134 then
      star:reset(-6)
    elseif star.position.x < -6 then
      star:reset(134)
    elseif star.position.y > 134 then
      star:reset(false, -6)
    elseif star.position.y < -6 then
      star:reset(false, 134)
    end
  end
end

function is_offscreen(p, m)
  local margin = m or 0
  local mincoord = 0 - margin
  local maxcoord = 128 + margin
  local x, y = p.scrp.x, p.scrp.y
  local duration_up = p.duration < 0
  if p.deltav then
    return duration_up
  else
    return duration_up or x > maxcoord or x < mincoord or y > maxcoord or y < mincoord
  end
end

spark = object:extend()
function spark:new(p, pv, c, d)
  self.scrp = p
  self.particle_velocity = pv
  self.color = c
  self.duration = d or ri(7, 2)
end

function spark:update(shipvel)
  self.scrp:add(self.particle_velocity - shipvel)
  self.duration-=1
end

function spark:draw(shipvel)
  pset(self.scrp.x, self.scrp.y, self.color)
  self:update(shipvel)
end

explosion = spark:extend()
function explosion:new(position, size, colorcount, shipvel)
  local explosion_size_factor = rnd()
  self.scrp = position:clone()
  self.particle_velocity = shipvel:clone()
  self.radius = explosion_size_factor * size
  self.radius_delta = explosion_size_factor * rnd(.5)
  self.len = colorcount - 3
  self.duration = colorcount
end

function explosion:draw(shipvel)
  local r = ro(self.radius)
  for i = r + 3, r, -1 do
    local c = damage_colors[self.len - self.duration + i]
    if c then
      self.scrp:draw_circle(i, c, true)
    end
  end
  self:update(shipvel)
  self.radius-=self.radius_delta
end

cannon = object:extend()
function cannon:new(p, pv, c, ship)
  self.scrp = p
  self.position2 = p:clone()
  self.particle_velocity = pv + pv:perpendicular():normalize() * (rnd(2) - 1)
  self.color = c
  self.firing_ship = ship
  self.duration = 16
end

function cannon:update(shipvel)
  self.position2 = self.scrp:clone()
  self.scrp:add(self.particle_velocity - shipvel)
  self.duration-=1
end
function cannon:draw(shipvel)
  self.position2:draw_line(self.scrp, self.color)
end

thrustexhaust = object:extend()
function thrustexhaust:new(p, pv)
  self.scrp = p
  self.particle_velocity = pv
  self.duration = 0
end

function thrustexhaust:draw(shipvel)
  local c, pv = ri(11, 9), self.particle_velocity
  local deflection, flicker = pv:perpendicular() * 0.7, pv * (rnd(2) + 2)
  flicker+=deflection * (rnd() - .5)
  local p0, p1a = self.scrp + flicker, self.scrp + pv
  for a in all {p1a + deflection, p1a + deflection * -1} do
    for b in all {p0, self.scrp} do
      a:draw_line(b, c)
    end
  end
  if rnd() > .4 then
    add(particles, spark(p0, shipvel + (flicker * .25), c))
  end
  self.scrp:add(pv - shipvel)
  self.duration-=1
end

function draw_rect(w, h, c)
  for x = 0, w - 1 do
    for y = 0, h - 1 do
      sset(x, y, c)
    end
  end
end

function draw_sprite_circle(xc, yc, radius, filled, c)
  local xvalues = {}
  local fx, fy = 0, 0
  local x, y = -radius, 0
  local err = 2 - 2 * radius
  while (x < 0) do
    xvalues[1 + x * -1] = y

    if not filled then
      fx, fy = x, y
    end
    for i = x, fx do
      sset(xc - i, yc + y, c)
      sset(xc + i, yc - y, c)
    end
    for i = fy, y do
      sset(xc - i, yc - x, c)
      sset(xc + i, yc + x, c)
    end

    radius = err
    if radius <= y then
      y+=1
      err+=y * 2 + 1
    end
    if radius > x or err > y then
      x+=1
      err+=x * 2 + 1
    end
  end
  xvalues[1] = xvalues[2]
  return xvalues
end

perms = {}
for i = 0, 255 do
  perms[i] = i
end
for i = 0, 255 do
  local r = ri(32767) % 256
  perms[i], perms[r] = perms[r], perms[i]
end

perms12 = {}
for i = 0, 255 do
  local x = perms[i] % 12
  perms[i + 256], perms12[i], perms12[i + 256] = perms[i], x, x
end

function getn_3d(ix, iy, iz, x, y, z)
  local t = .6 - x * x - y * y - z * z
  local index = perms12[ix + perms[iy + perms[iz]]]
  return max(0, (t * t) * (t * t)) * (grads3[index][0] * x + grads3[index][1] * y + grads3[index][2] * z)
end

function simplex3d(x, y, z)
  local s = (x + y + z) * 0.333333333
  local ix, iy, iz = flr(x + s), flr(y + s), flr(z + s)
  local t = (ix + iy + iz) * 0.166666667
  local x0, y0, z0 = x + t - ix, y + t - iy, z + t - iz
  ix, iy, iz = band(ix, 255), band(iy, 255), band(iz, 255)
  local n0 = getn_3d(ix, iy, iz, x0, y0, z0)
  local n3 = getn_3d(ix + 1, iy + 1, iz + 1, x0 - 0.5, y0 - 0.5, z0 - 0.5)
  local ijk
  if x0 >= y0 then
    if y0 >= z0 then
      ijk = ijks[1]
    elseif x0 >= z0 then
      ijk = ijks[2]
    else
      ijk = ijks[3]
    end
  else
    if y0 < z0 then
      ijk = ijks[4]
    elseif x0 < z0 then
      ijk = ijks[5]
    else
      ijk = ijks[6]
    end
  end
  local n1 = getn_3d(ix + ijk[1], iy + ijk[2], iz + ijk[3], x0 + 0.166666667 - ijk[1], y0 + 0.166666667 - ijk[2],
                     z0 + 0.166666667 - ijk[3])
  local n2 = getn_3d(ix + ijk[4], iy + ijk[5], iz + ijk[6], x0 + 0.333333333 - ijk[4], y0 + 0.333333333 - ijk[5],
                     z0 + 0.333333333 - ijk[6])
  return 32 * (n0 + n1 + n2 + n3)
end

function new_planet(a)
  local p = nsplit(a)
  local args = p[2]
  return {
    class_name = p[1][1],
    noise_octaves = args[1],
    noise_zoom = args[2],
    noise_persistance = args[3],
    mmap_color = args[4],
    full_shadow = args[5] or 1,
    transparent_color = args[6] or 14,
    minc = args[7] or 1,
    maxc = args[8] or 1,
    min_size = args[9] or 16,
    color_map = p[3]
  }
end

planet = object:extend()
function planet:new(x, y, phase, r)
  local planet_type = planet_types[ri(#planet_types) + 1]
  local radius = r or ri(65, planet_type.min_size)
  self.scrp = v()
  self.radius = radius
  self.secp = v(x, y)
  self.bottom_right_coord = 2 * radius - 1
  self.phase = phase
  self.planet_type = planet_type
  self.noise_factor_vert = ri(planet_type.maxc + 1, planet_type.minc)
  self.noisedx = rnd(1024)
  self.noisedy = rnd(1024)
  self.noisedz = rnd(1024)
  self.rendered_circle = false
  self.rendered_terrain = false
  self.color = planet_type.mmap_color
end

function planet:draw(ship_pos)
  if stellar_object_is_visible(self, ship_pos) then
    self:render_planet()
    sspr(0, 0, self.bottom_right_coord, self.bottom_right_coord, self.scrp.x - self.radius, self.scrp.y - self.radius)
  end
end

function planet:render_planet(fullmap, renderback)
  local s = self
  local radius = s.radius - 1
  if fullmap then
    radius = 47
  end

  if not s.rendered_circle then
    s.width = s.radius * 2
    s.height = s.radius * 2
    s.x = 0
    s.yfromzero = 0
    s.y = radius - s.yfromzero
    s.phi = 0
    sect:reset_planet_visibility()
    pal()
    palt(0, false)
    palt(s.planet_type.transparent_color, true)
    if fullmap then
      s.width, s.height = 114, 96
      draw_rect(s.width, s.height, 0)
    else
      draw_rect(s.width, s.height, s.planet_type.transparent_color)
      s.xvalues = draw_sprite_circle(radius, radius, radius, true, 0)
      draw_sprite_circle(radius, radius, radius, false, s.planet_type.mmap_color)
    end
    s.rendered_circle = true
  end

  if (not s.rendered_terrain) and s.rendered_circle then

    local theta_start, theta_end = 0, .5
    local theta_increment = theta_end / s.width
    if fullmap and renderback then
      theta_start = .5
      theta_end = 1
    end

    if s.phi > .25 then
      s.rendered_terrain = true
    else

      local partialshadow = s.planet_type.full_shadow ~= 1
      local phase_values, phase = {}, s.phase

      local x, doublex, x1, x2, i, c1, c2
      local y = radius - s.y
      local xvalueindex = abs(y) + 1
      if xvalueindex <= #s.xvalues then
        x = flr(sqrt(radius * radius - y * y))
        doublex = 2 * x
        if phase < .5 then
          x1 = -s.xvalues[xvalueindex]
          x2 = flr(doublex - 2 * phase * doublex - x)
        else
          x1 = flr(x - 2 * phase * doublex + doublex)
          x2 = s.xvalues[xvalueindex]
        end
        for i = x1, x2 do
          if partialshadow or (phase < .5 and i > x2 - 2) or (phase >= .5 and i < x1 + 2) then
            phase_values[radius + i] = 1
          else
            phase_values[radius + i] = 0
          end
        end
      end

      for theta = theta_start, theta_end - theta_increment, theta_increment do

        local phasevalue = phase_values[s.x]
        local c = 0

        if (fullmap or phasevalue ~= 0) and sget(s.x, s.y) ~= s.planet_type.transparent_color then
          local freq = s.planet_type.noise_zoom
          local max_amp = 0
          local amp = 1
          local value = 0
          for n = 1, s.planet_type.noise_octaves do
            value = value +
                      simplex3d(s.noisedx + freq * cos(s.phi) * cos(theta), s.noisedy + freq * cos(s.phi) * sin(theta),
                                s.noisedz + freq * sin(s.phi) * s.noise_factor_vert)
            max_amp+=amp
            amp*=s.planet_type.noise_persistance
            freq*=2
          end
          value/=max_amp
          if value > 1 then
            value = 1
          end
          if value < -1 then
            value = -1
          end
          value+=1
          value*=(#s.planet_type.color_map - 1) / 2
          value = ro(value)

          c = s.planet_type.color_map[value + 1]
          if not fullmap and phasevalue == 1 then
            c = dark_planet_colors[c + 1]
          end
        end
        sset(s.x, s.y, c)
        s.x+=1
      end
      s.x = 0
      if s.phi >= 0 then
        s.yfromzero+=1
        s.y = radius + s.yfromzero
        s.phi+=.5 / (s.height - 1)
      else
        s.y = radius - s.yfromzero
      end
      s.phi*=-1
    end

  end

  return s.rendered_terrain
end

function add_npc(pos, pirate)
  local t = ri(#ship_types) + 1
  if pirate or rnd() < .2 then
    t = ri(3, 1)
    pirate = true
    pirates+=1
  end
  local npc = ship(pirate):buildship(nil, t)
  npc:set_position_near_object(pos)
  npc:rotate(ri(360))
  npc.npc = true
  add(npcships, npc)
  npc.index = #npcships
end

function load_sector()
  warpsize = pilot.sprite_rows
  sect = sector()
  note_add("arriving in system ngc " .. sect.seed)
  add(sect.planets, sun())
  for i = 0, ri(12, 1) do
    add(sect.planets, sect:new_planet_along_elipse())
  end
  pilot:set_position_near_object(sect.planets[2])
  pilot:clear_target()
  pirates = 0
  npcships = {}
  shipyard = {}
  projectiles = {}
  for p in all(sect.planets) do
    for i = 1, ri(4) do
      add_npc(p)
    end
  end
  if pirates == 0 then
    add_npc(sect.planets[2], true)
  end
  return true
end

function _init()
  screen_center = v(63, 63)
  grads3 =
    nsplit "n1,1,0,|n-1,1,0,|n1,-1,0,|n-1,-1,0,|n1,0,1,|n-1,0,1,|n1,0,-1,|n-1,0,-1,|n0,1,1,|n0,-1,1,|n0,1,-1,|n0,-1,-1,|"
  mmap_sizes = split "n24,48,128,0,"
  music_tracks = split "n13,0,-1,"
  mousemodes = split "agamepad,two button mouse,stylus (pocketchip),"
  framecount, secondcount, mousemode, mmap_size_index, music_track = 0, 0, 0, 0, 0
  split_start = 1
  btnv = split "x2031"
  ijks = nsplit "n1,0,0,1,1,0,|n1,0,0,1,0,1,|n0,0,1,1,0,1,|n0,0,1,0,1,1,|n0,1,0,0,1,1,|n0,1,0,1,1,0,|"
  outlinedindex = split "n2,2,1,2,0,2,2,0,2,1,1,1,-1,-1,1,-1,-1,1,-1,0,1,0,0,-1,0,1,"
  star_color_index = 0
  star_color_monochrome = 0
  star_colors = nsplit "xaecd76|x98d165|x421051|x767676|x656565|x515151|"
  darkshipcolors = split "x01221562493d189"
  dark_planet_colors = split "x0011055545531121"
  health_colormap = split "x8899aaabbb"
  damage_colors = split "x7a98507a98507a9850"
  sun_colors = split "x6ea9d789ac"
  ship_names = split "afighter,cruiser,freighter,superfreighter,station,"
  ship_types =
    nsplit "n1.5,.25,.7,.75,.8,-2,1,14,18,|n3.5,.5,.583333,0,.8125,-1,1,18,24,|n3,2,.2125,0,.8125,-3,1,16,22,|n6,0,.7,-.25,.85,.25,1,32,45,|n4,1,.1667,-1,.3334,0,.6668,1,.8335,-1,1,30,40,|"
  planet_types = {
    new_planet("atundra,|n5,.5,.6,6,|x76545676543|"),
    new_planet("adesert,|n5,.35,.3,9,|x449944994499b1949949949949949|"),
    new_planet("abarren,|n5,.55,.35,5,|x565056765056|"), new_planet("alava,|n5,.55,.65,4,|x040504049840405040|"),
    new_planet("agas giant,|n1,.4,.75,2,1,14,4,20,50,|x76d121c|"),
    new_planet("agas giant,|n1,.4,.75,8,1,12,4,20,50,|x7fe21288|"),
    new_planet("agas giant,|n1,.7,.75,10,1,14,4,20,50,|xfa949a|"),
    new_planet("aterran,|n5,.3,.65,11,0,|x1111111dcfbb3334567|"),
    new_planet("aisland,|n5,.55,.65,12,0,|x11111111dcfb3|"),
    new_planet("arainbow giant,|n1,.7,.75,15,1,4,4,20,50,|x1dcba9e82|")
  }

  poke(0x5f2d, 1)
  note_text = nil
  note_display_time = 4
  paused = false
  landed = false
  particles = {}
  pilot = ship()
  pilot:buildship(nil, 1)
  load_sector()
  setup_mmap()
  music(13)
  local titlestarv = v(0, -3)
  while (not btnp(4)) do
    cls()
    sect:scroll_starfield(titlestarv)
    sect:draw_starfield(titlestarv)
    circfill(64, 135, 90, 2)
    circfill(64, 172, 122, 0)
    map(0, 0, 6, -15)
    map(16, 0, 0, 70)
    flip()
  end
end

function setup_mmap()
  mmap_size = mmap_sizes[mmap_size_index]
  if mmap_size > 0 then
    mmap_size_halved = mmap_size / 2
    mmap_offset = v(126 - mmap_size_halved, mmap_size_halved + 1)
  end
end

function draw_mmap_ship(obj)
  if obj.deltav then
    local p = (obj.secp / mmap_denominator):add(mmap_offset):ro()
    local x, y = p.x, p.y
    local c = obj:targeted_color()
    if obj.npc then
      p:draw_point(c)
      if obj.targeted then
        p:draw_circle(2, c)
      end
    else
      if obj.damage then
        p:draw_circle(1, 9)
      else
        rect(x - 1, y - 1, x + 1, y + 1, 7)
      end
    end
  end
end

function draw_mmap()
  local text_height = mmap_size
  if mmap_size > 0 then
    if mmap_size < 100 then
      text_height+=4
      rectfill(125 - mmap_size, 0, 127, mmap_size + 2, 1)
    else
      text_height = 0
    end

    local x, y = abs(pilot.secp.x), abs(pilot.secp.y)
    if y > x then
      x = y
    end
    mmap_denominator = min(6, ceil(x / 5000)) * 5000 / mmap_size_halved
    for obj in all(sect.planets) do
      local p = obj.secp + screen_center
      if obj.planet_type then
        p:add(v(-obj.radius, -obj.radius))
      end
      p= (p / mmap_denominator) + mmap_offset
      if mmap_size > 100 then
        p:draw_circle(ceil(obj.radius / 32) + 1, obj.color)
      else
        p:draw_point(obj.color)
      end
    end

    if framecount % 3 ~= 0 then
      foreach(projectiles, draw_mmap_ship)
      foreach(npcships, draw_mmap_ship)
      draw_mmap_ship(pilot)
    end

  end
  text("ˇ"..#npcships-pirates,112,text_height)
  text("ˇ"..pirates,112,text_height+7,8)
end

function text(text, x, y, textcolor, outline)
  local c = textcolor or 6
  local s = darkshipcolors[c]
  if outline then
    for i = 1, #outlinedindex, 2 do
      if i > 10 then
        s = c
      end
      print(text, x + outlinedindex[i], y + outlinedindex[i + 1], s)
    end
    c = 0
  else
    print(text, x + 1, y + 1, s)
  end
  print(text, x, y, c)
end

function note_add(text)
  note_text = text
  note_display_time = 4
end

function note_draw()
  if note_display_time > 0 then
    text(note_text, 0, 121)
    if framecount >= 29 then
      note_display_time-=1
    end
  end
end

function myship_menu()
  showyard = false
  shipinfo = true
  menu("x6b66|aback,repair,|", {
    landed_menu, function()
      pilot:buildship(pilot.seed_value, pilot.stypei)
      note_add("hull damage repaired")
    end
  })
end

function addyardships()
  shipyard = {}
  for i = 1, 2 do
    add(shipyard, ship():buildship(nil, ri(#ship_types, 1)))
  end
end

function buyship(i)
  pilot:buildship(shipyard[i].seed_value, shipyard[i].stypei)
  shipyard[i] = nil
  note_add("purchased!")
  myship_menu()
end

function call_option(i)
  if cur_option_callbacks[i] then
    local return_value = cur_option_callbacks[i]()
    paused = false
    if return_value == nil then
      paused = true
    elseif return_value then
      if type(return_value) == "string" then
        note_add(return_value)
      end
      paused = true
    end
  end
  if paused then
    sfx(53, 2)
  else
    sfx(52, 2)
  end
end

function menu(coptions, callbacks)
  if coptions then
    local c = nsplit(coptions)
    cur_menu_colors = c[1]
    cur_options = c[2]
    cur_option_callbacks = callbacks
  end

  if shipinfo then
    pilot:data(0)
  elseif showyard then
    for i = 0, 1 do
      local s = shipyard[i + 1]
      if s then
        s:data(i * 36)
      end
    end
  end

  for a = .25, 1, .25 do
    local i = a * 4
    local text_color = cur_menu_colors[i]
    if i == pressed then
      text_color = darkshipcolors[text_color]
    end
    if cur_options[i] then
      local p = rotatedv(a, 15) + v(64, 90)
      if a == .5 then
        p.x-=4 * #cur_options[i]
      elseif a ~= 1 then
        p.x-=ro(4 * (#cur_options[i] / 2))
      end
      text(cur_options[i], p.x, p.y, text_color, true)
    end
  end

  text("  ⬆️  \n⬅️  ➡️\n  ⬇️",52,84,6,true)
end

function main_menu()
  menu("xc8b7|aautopilot,fire missile,options,system,|", {
    function()
      menu("xcc6c|afull stop,near planet,back,follow,|", {
        function()
          if pilot.velocity > 0 then
            pilot:reset_orders(pilot.full_stop)
          end
          return false
        end, function()
          local planet, dist = nearest_planet()
          pilot:approach_object(planet)
          return false
        end, main_menu, function()
          if pilot.target then
            pilot:reset_orders(pilot.seek)
            pilot.seektime = 0
          end
          return false
        end
      })
    end, function()
      pilot:fire_missile()
      return false
    end, function()
      menu("x6fba|aback,starfield,minimap size,mouse+♪,|", {
        main_menu, function()
          menu("x7f6a|amore stars,~dimming,less stars,~colors,|", {
            function()
              starfield_count+=5
              return "star count: " .. starfield_count
            end, function()
              star_color_index+=1
              star_color_index%=2
              return true
            end, function()
              starfield_count = max(0, starfield_count - 5)
              return "star count: " .. starfield_count
            end, function()
              star_color_monochrome+=1
              star_color_monochrome%=2
              star_color_monochrome*=3
              return true
            end
          })
        end, function()
          mmap_size_index+=1
          mmap_size_index%=#mmap_sizes
          setup_mmap()
          return true
        end, function()
          menu("xc698|a❎control mode,back,♪music,|", {
            function()
              mousemode+=1
              mousemode%=3
              note_add(mousemodes[mousemode])
            end, main_menu, function()
              music_track+=1
              music_track%=3
              music(music_tracks[music_track])
            end
          })
        end
      })
    end, function()
      menu("x86cb|atarget next pirate,back,land,target next,|",
           {next_hostile_target, main_menu, land_at_nearest_planet, next_ship_target})
    end
  })
end

function landed_menu()
  shipinfo = false
  showyard = false
  menu("xc67a|atakeoff,nil,my ship,shipyard,|", {
    takeoff, nil, myship_menu, function()
      showyard = true
      if #shipyard == 0 then
        addyardships()
      end
      menu("x767a|abuy top,back,buy bottom,more,|", {
        function()
          buyship(1)
        end, landed_menu, function()
          buyship(2)
        end, addyardships
      })
    end
  })
end

pos = 0
mtbl = {}
for i = 1, 96 do
  mtbl[i] = {flr(-sqrt(-sin(i / 193)) * 48 + 64)}
  mtbl[i][2] = (64 - mtbl[i][1]) * 2
end
for i = 0, 95 do
  poke(64 * i + 56, peek(64 * i + 0x1800))
end
cs = {}
for i = 0, 15 do
  cs[i] = {(cos(0.5 + 0.5 / 16 * i) + 1) / 2}
  cs[i][2] = (cos(0.5 + 0.5 / 16 * (i + 1)) + 1) / 2 - cs[i][1]
end

function shift_sprite_sheet()
  for i = 0, 95 do
    poke(64 * i + 0x1838, peek(64 * i))
    memcpy(64 * i, 64 * i + 1, 56)
    memcpy(64 * i + 0x1800, 64 * i + 0x1801, 56)
    poke(64 * i + 56, peek(64 * i + 0x1800))
  end
end

function landed_update()
  local p = landed_planet
  if not landed_front_rendered then
    landed_front_rendered = p:render_planet(true)
    if landed_front_rendered then
      p.rendered_circle = false
      p.rendered_terrain = false
      for j = 1, 56 do
        shift_sprite_sheet()
      end
    end
  else
    if not landed_back_rendered then
      landed_back_rendered = p:render_planet(true, true)
    else
      pos = 1 - pos
      if pos == 0 then
        shift_sprite_sheet()
      end
    end
  end
end

function render_landed_screen()
  cls()
  if landed_front_rendered and landed_back_rendered then
    for i = 1, 96 do
      local a, b = mtbl[i][1], mtbl[i][2]
      pal()
      local lw = ceil(b * cs[15][2])
      for j = 15, 0, -1 do
        if j == 4 then
          for ci = 0, #dark_planet_colors - 1 do
            pal(ci, dark_planet_colors[ci + 1])
          end
        end
        if j < 15 then
          lw = flr(a + b * cs[j + 1][1]) - flr(a + b * cs[j][1])
        end
        sspr(pos + j * 7, i - 1, 7, 1, flr(a + b * cs[j][1]), i + 16, lw, 1)
      end
    end
    pal()
    text(landed_planet.planet_type.class_name, 1, 1)
  else
    sspr(0, 0, 127, 127, 0, 0)
    text("scanning for a\nsuitable landing site...", 1, 1, 6)
  end
end

function _update()
  framecount+=1
  framecount%=30
  if framecount == 0 then
    secondcount+=1
  end

  mbtn = stat(34)
  local m = v(stat(32), stat(33))
  mv = m - screen_center

  if not landed and btnp(4, 0) then
    paused = not paused
    if paused then
      sfx(51, 2)
      main_menu()
    else
      sfx(52, 2)
    end
    pressed = nil
  end

  if landed then
    landed_update()
  end

  if paused or landed then

    mi = m - v(64, 90)
    mi.x*=.4
    mi = mi:angle() - .375
    mi = flr(4 * mi) + 1
    mi%=4

    for i = 1, 4 do
      if btn(btnv[i]) or (mousemode > 0 and mbtn == 1 and i == mi + 1 and secondcount > msel) then
        pressed = i
      end
      if pressed then
        if pressed == i and not btn(btnv[i]) then
          pressed = nil
          msel = secondcount
          call_option(i)
        end
      end
    end

  else
    local no_orders = not pilot.orders[1]
    if no_orders and (mousemode == 1 or (mousemode == 2 and mbtn > 0)) then
      pilot:rotate_towards_heading(mv:angle())
    end

    if (mousemode == 1 and mbtn > 1) or (mousemode == 2 and mbtn > 0 and mv:length() > 38) or btn(2, 0) then
      pilot:apply_thrust()
    else
      if pilot.accelerating and no_orders then
        pilot:cut_thrust()
      end
    end

    if btn(0, 0) then
      pilot:reset_orders()
      pilot:turn_left()
    end
    if btn(1, 0) then
      pilot:reset_orders()
      pilot:turn_right()
    end
    if btn(3, 0) then
      pilot:reset_orders()
      pilot:reverse_direction()
    end
    if btn(5, 0) or (mousemode == 1 and mbtn == 1 or mbtn == 3) then
      pilot:fire_weapon()
    end

    foreach(projectiles, function(p)
      p:update(pilot.velocity_vector)
    end)

    for s in all(npcships) do
      if s.stypei == #ship_types then
        s:rotate(.1)
      else

        if s.last_hit_time and s.last_hit_time + 30 > secondcount then

          s:reset_orders()
          s:flee()
          if s.hostile then
            s.target = s.last_hit_attacking_ship
            s.target_index = s.target.index
          end

        else

          if #s.orders == 0 then
            if s.hostile then
              s.seektime = 0
              if not s.target then
                next_ship_target(s, true)
              end
              add(s.orders, s.seek)
            else
              s:approach_object()
              s.wait_duration = ri(46, 10)
              s.wait_time = secondcount
              add(s.orders, s.wait)
            end
          end
          s:follow_cur_order()

        end

      end

      s:update_location()
      if s.hp < 1 then

        if s.hostile then
          pirates-=1
          if pirates < 1 then
            note_add("sector cleared!")
            note_display_time = 8
          end
        end

        del(npcships, s)
        pilot:clear_target()
      end
    end

    pilot:follow_cur_order()
    pilot:update_location()
    if pirates < 1 and note_display_time <= 0 then
      note_add("fly to system edge for ftl jump")
      note_display_time = 8
    end
    if pilot.secp.x > 32000 or pilot.secp.y > 32000 then
      load_sector()
    end

    sect:scroll_starfield(pilot.velocity_vector)
  end
end

function render_game_screen()
  cls()
  sect:draw_starfield(pilot.velocity_vector)
  for p in all(sect.planets) do
    p:draw(pilot.secp)
  end
  for s in all(npcships) do
    if s:is_visible(pilot.secp) then
      s:draw_sprite_rotated()
    end
  end

  if pilot.target then
    last_offscreen_pos = nil
    local player_screen_position = pilot.scrp
    local targeted_ship = pilot.target
    if targeted_ship then
      if not targeted_ship:is_visible(pilot.secp) then
        local distance = "" .. flr((targeted_ship.scrp - player_screen_position):scaled_length())
        local color, shadow = targeted_ship:targeted_color()
        local hr = flr(targeted_ship.sprite_rows * .5)
        local d = rotatedv((targeted_ship.scrp - player_screen_position):angle())
        last_offscreen_pos = d * (60 - hr) + screen_center
        local p2 = last_offscreen_pos:clone():add(v(-4 * (#distance / 2)))
        targeted_ship:draw_sprite_rotated(last_offscreen_pos)
        if p2.y > 63 then
          p2:add(v(1, -12 - hr))
        else
          p2:add(v(1, 7 + hr))
        end
        text(distance, ro(p2.x), ro(p2.y), color)
      end
      text(targeted_ship.name .. targeted_ship:hp_string(), 0, 114, targeted_ship:hp_color())
    end
  end

  pilot:draw()

  if pilot.hp < 1 then
    paused = true
    pilot.dead = true
    menu("x78bb|acontinue?,nil,yes,|", {
      nil, nil, function()
        pilot.dead = false
        pilot:buildship(pilot.seed_value, pilot.stypei)
        return false
      end
    })
  end

  for p in all(particles) do
    if is_offscreen(p, 32) then
      del(particles, p)
    else
      if paused then
        p:draw(v())
      else
        p:draw(pilot.velocity_vector)
      end
    end
  end

  for p in all(projectiles) do
    if is_offscreen(p, 63) then
      del(projectiles, p)
    else
      if last_offscreen_pos and p.secp and pilot.target and (pilot.target.secp - p.secp):scaled_length() <=
        pilot.target.sprite_rows then
        p:draw(nil, (p.secp - pilot.target.secp) + last_offscreen_pos)
      else
        p:draw(pilot.velocity_vector)
      end
    end
  end

  draw_mmap()
  if warpsize > 0 then
    camera(ri(2) - 1, ri(2) - 1)
    circfill(63, 63, warpsize, 7)
    warpsize-=1
    if warpsize == 0 then
      camera()
    end
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
  if mousemode > 0 then
    (mv + screen_center):draw_circle(1, 8)
  end
end

__gfx__
00000000000000000000000000000000000000007700070077700700777077700007700777070707770770007707770000000000000000000000000000000000
00000000000000000000000000000000707070707570757057507570575075500007570755070707550757075507550000000000000000000000000000060000
00000000000000000000000000000000000000007070707007007070070077000007070770070707700707057007700070007077707000700000000000060000
00000000000000000000000000000000000000007750707007007770070075000007750750070707500775005707500077077075507700700000000000006000
00000000000000000000000000000000000000007570575007007570070077700007570777057507770757077507770075757077007570700000000000000600
00000000707070707070707070700000000000005050050005005050050055500005050555005005550505055005550070507075007057700000000070707060
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070007077707005700000000000000060
00000000000000007000000000700000000000000000000000000000000000000000000000000000000000000000000050005055505000500000000000000060
00000000000000000000000000000000000000000000055500000000000000000000000000000000000000000000000000000000000000000000700000000000
00000000700000000000000000000000000000000006661666700000000000000000000000000000000000000000000000000000007000000000007000000000
00000000000000000000000000000000000000000066661666600000000007770707077007070077077700007770707700777000000000000000000070700000
00666666666666666666666666666660000000000666661666760000000005750707075707070755057500007550707570755000007000000000000070700000
06666666c66666666666666666ddd666000000000666661666660000000000700777070707070570007000007700707070770000000000000000000070700000
6666666ccc666666666666666ddddd66607070706666661666666000707070700757077507070057007070707500707750750070007000000000000070700000
666666ccccc6666666666666dd7d7dd6600000006666661666666000000000700707075705770775007000007000707570777000000000000000000057700000
66666611c116666666666666ddd7ddd6600000006661116111666000000000500505050500550550005000005000505050555000007000000000000005500000
6666c6661666c66666666666dd7d7dd6600000006116666666116000000000000000000000000000000000000000000000000000000000000000000000000000
666cc6666666cc66666ddd661ddddd16600000001666666666661000000000000000000700007700000000000000000000000000000000000000000000000000
66cccc66666cccc666ddddd661ddd166600000006666666666666000000000000000007700076670000000000000000000000000000000000000000000000000
661cc1666661cc166dd777dd66111666600000006666666666666000000000000000006700060070000000000000000000000000000000000000000000000000
6661c6666666c1666dd7d7dd66666666600000006666666666666000070707070070700700000760000000000000000000000000000000000000000000000000
66661666c66616666dd777dd67676767670707006666666666666000000000000070700700007600000000000000000000000000000000000000000000000000
666666ccccc6667661ddddd166666666600000006666666666666000000000000067600707077770000000000000000000000000000000000000000000000000
6666661ccc166666661ddd1666666666600000006666666666666000000000000006000606066660000000000000000000000000000000000000000000000000
66666661c16666676661116666666666600000006666666666666000000000000000000000000000000000000000000000000000000000000000000000000000
d6666666166666666666666666666666d0000000d66666766666d00000aaa0a000a0a000aa00a00aaa0aaa0a0000000000000000000000000000000000000000
1d66666666666666766666666666666d100000001d666666666d100000a990a000a0a00a990a9a0a990a990a0000000000000000000000000000000000000000
01dddddddddddddddd7dddddddddddd10000000001dddd7dddd1000000a000a000a0a009a00a0a0a000a000a0000000000000000000000000000000000000000
0011111171111111111171111111111000000000001111111110000000aa00a0009a90009a0aaa0aa00aa00a0000000000000000000000000000000000000000
0000000000000000000000700000000000000000000000700000000000a900a0000a00000a0a9a0a900a90090000000000000000000000000000000000000000
0000000070000000000000007000000000000000000000000000000000a000aaa00a000aa90a0a0a000aaa0a0000000000000000000000000000000000000000
00000000000000000000000000700000000000000000007000000000009000999009000990090909000999090000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888228228888228822888222822888888822888888ff8888
88888888888888888888888888888888888888888888888888888888888888888888888888888888882288822888222222888222822888882282888888fff888
88888888888888888888888888888888888888888888888888888888888888888888888888888888882288822888282282888222888888228882888888f88888
888888888888888888888888888888888888888888888888888888888888888888888888888888888822888228882222228888882228882288828888fff88888
88888888888888888888888888888888888888888888888888888888888888888888888888888888882288822888822228888228222888882282888ffff88888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888228228888828828888228222888888822888fff888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555555555555555555555555555555558595a505555b595a505555c595a5055558595a505555d5e5f50555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555556666666665566666666655666666666556666666665577777777755555555555555555555555555555555555
555566656665666566656665666566555555e55565556555655655565556556555656565565556555655755575777555e5555555551555555555555555555555
55556565656556555655655565656565555ee55565656665655656566656556565656565565656566655757575777555ee555555551155555155155511115555
5555666566655655565566556655656555eee55565656555655656566556556565655565565656555655757575557555eee55551111115551155155511115555
55556555656556555655655565656565555ee55565656566655656566656556565666565565656665655757575757555ee555551001105511111155511115555
555565556565565556556665656565655555e55565556555655655565556556555666565565556555655755575557555e5555551551055501100055511115555
55555555555555555555555555555555555555556666666665566666666655666666666556666666665577777777755555555550550555550155555500005555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555055555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555500000000055555555555555555555550000000005555555555555555555555000000000555555555555555555555555555555555555555555555
55555666665506660666055555555555555566666550666060005555555555555556666655066606660555555555555555666665555555555555555555555555
55555655565506060600055555555555555565556550606060005555555555555556555655060600060555555555555555655565555555555555555555555555
55555657565506060666055555555555555565756550606066605555555555555556575655060600060555555555555555655565555555555555555555555555
55555655565506060006055555555555555565556550606060605555555555555556555655060600060555555555555555655565555555555555555555555555
55555666665506660666055555555555555566666550666066605555555555555556666655066600060555555555555555666665555555555555555555555555
55555555555500000000055555555555555555555550000000005555555555555555555555000000000555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507770000066600eee00c0c00ddd005507770707066600eee00c0c00ddd005507770707066000eee00c0c00ddd005505555555555555555555555555550555
55507070000000600e0000c0c00d00005507000777000600e0000c0c00d00005507000777006000e0000c0c00d00005505555555555555555555555555550555
55507700000066600eee00ccc00ddd005507700707066600eee00ccc00ddd005507700707006000eee00ccc00ddd005505555555555555555555555555550555
5550707000006000000e0000c0000d00550700077706000000e0000c0000d00550700077700600000e0000c0000d005505555555555555555555555555550555
55507770000066600eee0000c00ddd005507000707066600eee0000c00ddd005507000707066600eee0000c00ddd005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507770000066000eee00c0c00ddd005500770707066600eee00c0c00ddd005507770707066600eee00c0c00ddd005505555555555555555555555555550555
55507070000006000e0000c0c00d00005507000777000600e0000c0c00d00005507000777000600e0000c0c00d00005505555555555555555555555555550555
55507700000006000eee00ccc00ddd005507000707006600eee00ccc00ddd005507700707006600eee00ccc00ddd005505555555555555555555555555550555
5550707000000600000e0000c0000d00550700077700060000e0000c0000d00550700077700060000e0000c0000d005505555555555555555555555555550555
55507770000066600eee0000c00ddd005500770707066600eee0000c00ddd005507000707066600eee0000c00ddd005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507770000066600eee00c0c00ddd005507770000066600eee00c0c00ddd005507770000066000eee00c0c00ddd005505555555555555555555555555550555
55507070000000600e0000c0c00d00005507000000000600e0000c0c00d00005507000000006000e0000c0c00d00005505555555555555555555555555550555
55507700000066600eee00ccc00ddd005507700000066600eee00ccc00ddd005507700000006000eee00ccc00ddd005505555555555555555555555555550555
5550707000006000000e0000c0000d00550700000006000000e0000c0000d00550700000000600000e0000c0000d005505555555555555555555555555550555
55507770000066600eee0000c00ddd005507770000066600eee0000c00ddd005507770000066600eee0000c00ddd005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
555000000000000000000000000000005501111111aaaaa111111111111111055000000000000000000000000000005505555555555555555555555555550555
55507770000066000eee00c0c00ddd005501771717a66611eee11c1c11ddd105507770000066600eee00c0c00ddd005505555555555555555555555555550555
55507070000006000e0000c0c00d00005507111777aaa171e1111c1c11d11105507000000000600e0000c0c00d00005505555555555555555555555555550555
55507700000006000eee00ccc00ddd005507111717aa61771ee11ccc11ddd105507700000066600eee00ccc00ddd005505555555555555555555555555550555
5550707000000600000e0000c0000d005507171777aaa17771e1111c1111d10550700000006000000e0000c0000d005505555555555555555555555555550555
55507770000066600eee0000c00ddd005507771717a661777711111c11ddd105507770000066600eee0000c00ddd005505555555555555555555555555550555
555000000000000000000000000000005501111111aaa17711111111111111055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000001171000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507770000066600eee00c0c00ddd005507700000066600eee00c0c00ddd005507700000066600eee00c0c00ddd005505555555555555555555555555550555
55507070000000600e0000c0c00d00005507070000000600e0000c0c00d00005507070000000600e0000c0c00d00005505555555555555555555555555550555
55507770000066600eee00ccc00ddd005507070000006600eee00ccc00ddd005507070000066600eee00ccc00ddd005505555555555555555555555555550555
5550707000006000000e0000c0000d00550707000000060000e0000c0000d00550707000006000000e0000c0000d005505555555555555555555555555550555
55507070000066600eee0000c00ddd005507770000066600eee0000c00ddd005507770000066600eee0000c00ddd005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507770000066000eee00c0c00ddd005507770000066600eee00c0c00ddd005507700000066600eee00c0c00ddd005505555555555555555555555555550555
55507070000006000e0000c0c00d00005507070000000600e0000c0c00d00005507070000000600e0000c0c00d00005505555555555555555555555555550555
55507700000006000eee00ccc00ddd005507770000006600eee00ccc00ddd005507070000006600eee00ccc00ddd005505555555555555555555555555550555
5550707000000600000e0000c0000d00550707000000060000e0000c0000d00550707000000060000e0000c0000d005505555555555555555555555555550555
55507770000066600eee0000c00ddd005507070000066600eee0000c00ddd005507770000066600eee0000c00ddd005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507770000066600eee00c0c00ddd005507770000066600eee00c0c00ddd005507770000066600eee00c0c00ddd005505555555555555555555555555550555
55507070000000600e0000c0c00d00005507000000000600e0000c0c00d00005507000000000600e0000c0c00d00005505555555555555555555555555550555
55507770000066600eee00ccc00ddd005507700000006600eee00ccc00ddd005507700000066600eee00ccc00ddd005505555555555555555555555555550555
5550707000006000000e0000c0000d00550700000000060000e0000c0000d00550700000006000000e0000c0000d005505555555555555555555555555550555
55507070000066600eee0000c00ddd005507770000066600eee0000c00ddd005507770000066600eee0000c00ddd005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507770000066000eee00c0c00ddd005500770707066600eee00c0c00ddd005507770000066600eee00c0c00ddd005505555555555555555555555555550555
55507070000006000e0000c0c00d00005507000777000600e0000c0c00d00005507000000000600e0000c0c00d00005505555555555555555555555555550555
55507700000006000eee00ccc00ddd005507000707006600eee00ccc00ddd005507700000006600eee00ccc00ddd005505555555555555555555555555550555
5550707000000600000e0000c0000d00550707077700060000e0000c0000d00550700000000060000e0000c0000d005505555555555555555555555555550555
55507770000066600eee0000c00ddd005507770707066600eee0000c00ddd005507770000066600eee0000c00ddd005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55505050505050505050505050505050550505050505050505050505050505055050505050505050505050505050505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500770707066600eee00c0c00ddd00550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507000777000600e0000c0c00d0000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507000707066600eee00ccc00ddd00550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
5550707077706000000e0000c0000d00550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507770707066600eee0000c00ddd00550020002000200002000020000200055002000200020000200002000020005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507770000066000eee00c0c00ddd00550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507070000006000e0000c0c00d0000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507700000006000eee00ccc00ddd00550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
5550707000000600000e0000c0000d00550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507770000066600eee0000c00ddd00550020002000200002000020000200055002000200020000200002000020005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55500770707066600eee00c0c00ddd00550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507000777000600e0000c0c00d0000550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507000707066600eee00ccc00ddd00550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
5550707077706000000e0000c0000d00550000000000000000000000000000055000000000000000000000000000005505555555555555555555555555550555
55507770707066600eee0000c00ddd00550020002000200002000020000200055002000200020000200002000020005505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__map__
00000000000000000000c0c20000c0c028290000021718191a0101010f030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c2c2c2000000000000000000c0c00000001011121314011b1c0115160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c2c20000000000000000c2c2c0c000000020212223240c0d1f0025260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c20000000000000000c2c2c2c00000000030313233340000000035360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c2c3d4c5c6c7c8c9cadbc2c20000000008090a0b1e050607040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c2c3e4c5d6d7e8c9eaebc2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d2c2c2d3c4e5f6e7d8d9dacbc2c200c2c200000000003738393a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c3e4c5d6f7e8c9eaebc2c200c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c3e4d5e600f8e9eaebc2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000e3f4c000000000fafbc200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011c0000235252f525235252f525235252f525235252f525235252f525235252f525235252f525235252f525235252f525235252f525235252f525235252f525235252f525235252f525235252e525235252e525
01e000001e5251b525195251b525125050f5050d5050f5052450524505245050c5050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
01e00000125250f5250d5250f5251e5051b505195051b505005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
011c0000235352f535235352f535215352f535215352f535205352f535205352f535215352f5352053521535235352f535235352f535215352f535215352f535205352f535205352f535215352f535215352f535
011c0000235352f535235352f535215352f535215352f535205352f535205352f535215352f535205352d535235352f535235352f535265352f535265352f535255352f535255352f535215352f535215352f535
011c00002f545235452f545235452d545235452d545235452c545235452c545235452d545235452c5452d5452f545235452f545235452d545235452d545235452c545235452c545235452d545235452d54523545
017000001e545255451c545205451a545215451c54520545125052a505105051c5051a505265051c5052850500500005000050000500005000050000500005000050000500005000050000500005000050000500
01700000125451e545105451c5450e5451a545105451c545005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
011c0000235352f535235352f535235352f535235352f535235352f535235352f535235352f535235352f535235352f535235352f535235352f535235352f535235352f535235352f535235352e535235352e535
01e000001e5351b535195351b5351e5051b505195051b505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01e00000125350f5350d5350f535125050f5050d5050f505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
011c00002f545235452f545235453254526545325452654531545255453154525545325452654532545265452f545235452f5452354532545265453254526545315452554531545255452d545215452d54521545
017000001e545255051c545205051a545215051c545205051e5052a5051c505285051a505265051c505285051e505255051c5052c505265052d505285052c505125052a505105051c5051a505265051c50528505
01700000125451e545105451c5450e5451a545105451c5451e505255051c5052c505265052d505285052c505125052a505105051c5051a505265051c505285050000000000000000000000000000000000000000
011c0000235152f515235152f515235152f515235152f515235152f515235152f515235152f515235152f515235152f515235152f515235152f515235152f515235152f515235152f515235152e515235152e515
017000002f51532515315152d5152f51532515315152d515005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
01e000001751500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01e000002f51500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011c0000183032b6052b6052b605183032b6052b60515303153032b6052b6052b6052b6052b6052b6052b605183032b6052b6252b625183232b6052b62515323153032b6152b6252b6352b6452b6552b6552b605
011c00002b6352b63518333374052b6351833318333183032b6352b635183332b6052b63515333153331f2052b6352b63518333374052b6351833318333183032b6352b635183332b6052b635153331533315303
011c00002b6352b63518333374052b6351833318333183032b6352b635183332b6052b63515333153331f2052b6352b63518333374052b6351833318333183032b6252b625183232b6052b625153231532315303
011c00001752523525175252352517525235251752523525175252352517525235251752523525175252352517525235251752523525175252352517525235251752523525175252352517525225251752522525
01e00000125250f5250d5250f525125050f5050d5050f5052450524505245050c5050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
01e00000065250352501525035251e5051b505195051b505005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
011c00001753523535175352353515535235351553523535145352353514535235351553523535145351553517535235351753523535155352353515535235351453523535145352353515535235351553523535
01e00000125350f5350d5350f5351e5051b505195051b505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01e0000006535035350153503535125050f5050d5050f505065050350501505035050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
011c000017535235351753523535155352353515535235351453523535145352353515535235351453515535175352353517535235351a535235351a535235351953523535195352353515535235351553523535
011c00001753523535175352353517535235351753523535175352353517535235351753523535175352353517535235351753523535175352353517535235351753523535175352353517535225351753522535
011c00002354517545235451754521545175452154517545205451754520545175452154517545205452154523545175452354517545215451754521545175452054517545205451754521545175452154517545
01700000125451954510545205451a545215451c54520545125052a505105051c5051a505265051c5052850500500005000050000500005000050000500005000050000500005000050000500005000050000500
01700000065451e54504545105450e5451a545105451c545125050050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
011c000023545175452354517545265451a545265451a54525545195452554519545265451a545265451a54523545175452354517545265451a545265451a5452554519545255451954521545155452154515545
017000001254525505105452c5051a5452d5051c5452c5051e5052a5051c505285051a505265051c505285051e505255051c5052c505265052d505285052c505125052a505105051c5051a505265051c50528505
01700000065451e54504545105450e5451a545105451c5451e505255051c5052c505265052d505285052c505125052a505105051c5051a505265051c505285050000000000000000000000000000000000000000
011c00001751523515175152351517515235151751523515175152351517515235151751523515175152351517515235151751523515175152351517515235151751523515175152351517515225151751522515
011500000c6250c605016050160523605236050160501605256052560502605026052760527605046050460525605256050460504605246052460502605026052260522605016050160520605206050160501605
01070000300333e033260032400337003390033b0033c0033e03330033160031700318003190031a0031b0031c0031d0031e0031f003200032100322003230030000300003000030000300003000030000300003
011800000e6140e6100e61512600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500600006000060000600006000060000600
0118000010610106151c60512600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
0118000012610126151060012600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
0118000014610146151060012600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
0118000016610166151060012600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
0118000017610176151060012600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
0118000018610186151060012600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
011800001a6101a6151060012600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
011800001c6101c6151060012600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
011800001e6101e6151060012600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
0118000020610206152360512600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
0118000022610226152360512600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
0119000024610246151060012600146001660017600186001a6001c6001e6002060022600236051a6001b6001c6001d6001e6001f600206002160022600236002360500600006000060000600006000060000600
01070000300333e033260032400337003390033b0033c0033e00330003160031700318003190031a0031b0031c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
000700003e03330033260032400337003390033b0033c0033e00330003160031700318003190031a0031b0031c6001d6001e6001f600206002160022600236002360500000000000000000000000000000000000
010500003e03300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
010a00003f7463f7563f7463f7463f7303f7303e7203e7203e7103d7103d71439700397042d7042c7042b704007040070400704007041330415304173040c3040d3040f3041230414304186000c0040c0040c104
000400002367001610186600266008650056500465003640026400163001630016200162001610016100161001610016100161001610016100160000000000000000000000000000000000000000000000000000
00030000166500f640036300162001610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000b670026100b660086600a6500b6500d6500e640106401163012630136201362014610146101561015610146100f61008610066100160000000000000000000000000000000000000000000000000000
__music__
01 00424344
00 00014344
00 00010244
00 03090a44
00 04090a44
00 08090a52
00 05060713
00 05060713
00 0b0c0d14
00 03090a56
00 00014344
00 0e0f5144
00 10114344
00 15424344
00 15164344
00 15161744
00 18191a44
00 1b191a44
00 1c191a52
00 1d1e1f13
00 1d1e1f13
00 20212214
00 1c191a44
00 15164344
00 230f5144
02 10114344

