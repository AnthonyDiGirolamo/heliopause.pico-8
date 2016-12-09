pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- heliopause
-- by anthonydigirolamo

-- black       = 0
-- dark_blue   = 1
-- dark_purple = 2
-- dark_green  = 3
-- brown       = 4
-- dark_gray   = 5
-- light_gray  = 6
-- white       = 7
-- red         = 8
-- orange      = 9
-- yellow      = 10
-- green       = 11
-- blue        = 12
-- indigo      = 13
-- pink        = 14
-- peach       = 15

function sequence(definition)
  local result = {}
  for i=1,#definition,2 do
    for times=1,definition[i] do
      for n in all(definition[i+1]) do
        add(result, n)
      end
    end
  end
  return result
end

damage_colors = {7, 10, 9, 8, 5, 0}
-- damage_colors = {7, 10, 7, 9, 10, 8, 9, 8, 5 }
-- damage_colors[0] = 7
damage_colors2 = sequence({3, damage_colors})
-- damage_colors2 = sequence({4, {7, 10, 9, 8, 5}})

star_color_index = 0
star_color_monochrome = 0
star_colors = {
  {10, 14, 12, 13, 7, 6}, -- light
  {9,  8,  13, 1,  6, 5}, -- dark
  {4,  2,  1,  0,  5, 1},  -- darker
  {7, 6}, -- monochrome light
  {6, 5}, -- monochrome dark
  {5, 1}  -- monochrome darker
}

darkshipcolors = {0, 1, 2, 2, 1, 5, 6, 2, 4, 9, 3, 13, 1, 8, 9}

-- darkershipcolors = {0, 0, 1, 1, 0, 1, 5, 1, 2, 4, 2, 1, 0, 2, 4}

dark_planet_colors = {
  0,  -- black       = 0
  0,  -- dark_blue   = 1
  1,  -- dark_purple = 2
  1,  -- dark_green  = 3
  0,  -- brown       = 4
  5,  -- dark_gray   = 5
  5,  -- light_gray  = 6
  5,  -- white       = 7
  4,  -- red         = 8
  5,  -- orange      = 9
  5,  -- yellow      = 10
  3,  -- green       = 11
  1,  -- blue        = 12
  1,  -- indigo      = 13
  2,  -- pink        = 14
  13  -- peach       = 15
}

function round(i)
   return flr(i+.5)
end

function ceil(x)
	return -flr(-x)
end

function random_plus_to_minus_one()
  return random_int(3)-1
end

function random_int(n)
  return flr(rnd(32767))%n
end

function random_angle()
  return Vector(1):rotate(rnd())
end

function format_float(n)
  return flr(n) .. "." .. flr((n%1)*10)
end

Vector = {}
Vector.__index = Vector
function Vector.new(x, y)
  return setmetatable({ x = x or 0, y = y or 0 }, Vector)
end

function Vector:draw_point(color)
  pset(round(self.x),
       round(self.y),
       color)
end

function Vector:draw_line(v, color)
  line(round(self.x),
       round(self.y),
       round(v.x),
       round(v.y),
       color)
end

-- function Vector:floor()
--   self.x = flr(self.x)
--   self.y = flr(self.y)
--   return self
-- end

function Vector:round()
  self.x = round(self.x)
  self.y = round(self.y)
end

-- function Vector:max()
--    max(self.x,self.y)
-- end

function Vector:normalize()
  local len = self:length()
  self.x = self.x / len
  self.y = self.y / len
  return self
end

function Vector:rotate(phi)
  local c = cos(phi)
  local s = sin(phi)
  local x = self.x
  local y = self.y
  self.x = c * x - s * y
  self.y = s * x + c * y
  return self
end

-- function Vector:rotated(phi)
--   return self:clone():rotate(phi)
-- end

function Vector:add(v)
  self.x = self.x + v.x
  self.y = self.y + v.y
  return self
end

-- function Vector:divn(n)
--    self.x = self.x / n
--    self.y = self.y / n
-- end

-- function Vector:muln(n)
--    self.x = self.x * n
--    self.y = self.y * n
-- end

function Vector.__add(a, b) -- always assume b is a vector
  -- if type(a) == "number" then
  --    return Vector.new(b.x + a, b.y + a)
  -- elseif type(b) == "number" then
  --    return Vector.new(a.x + b, a.y + b)
  -- else
  return Vector.new(a.x + b.x, a.y + b.y)
  -- end
end

function Vector.__sub(a, b)
  -- if type(a) == "number" then
  --   return Vector.new(a - b.x, a - b.y)
  -- elseif type(b) == "number" then
  --   return Vector.new(a.x - b, a.y - b)
  -- else
  return Vector.new(a.x - b.x, a.y - b.y)
  -- end
end


function Vector.__mul(a, b) -- always assume b is a number
  -- if type(a) == "number" then
  --   return Vector.new(b.x * a, b.y * a)
  -- elseif type(b) == "number" then
  return Vector.new(a.x * b, a.y * b)
  -- else
  --   return Vector.new(a.x * b.x, a.y * b.y)
  -- end
end

function Vector.__div(a, b) -- always assume b is a number
  return Vector.new(a.x / b, a.y / b)
end

function Vector:about_equals(v)
  return round(v.x) == self.x and round(v.y) == self.y
end

function Vector:angle()
  return atan2(self.x, self.y)
end

function Vector:length()
  return sqrt(self.x^2 + self.y^2)
end

function Vector:scaled_length()
  -- divided by 182 to prevent overflow
  return sqrt((self.x/182)^2 + (self.y/182)^2)*182
end

function Vector.distance(a, b)
  return (b - a):length()
end

function Vector:tostring()
  return format_float(self.x) .. ", " .. format_float(self.y)
end

function Vector:clone()
  return Vector.new(self.x, self.y)
end

function Vector:perpendicular()
  return Vector.new(-self.y, self.x)
end

setmetatable(Vector, { __call = function(_, ...) return Vector.new(...) end })

-- function print_char(chars, p, color, character_spacing)
--   for c=0,#chars do
--     for i=0,14 do
--       if band(shr(chars[c+1], i), 1) == 1 then
--         pset(p.x+i%3+c*3+c*(character_spacing or 0),
--              p.y+flr(i/3),
--              color or 7)
--       end
--     end
--   end
-- end

-- for c=32767,0,-1 do
--   cursor(0, 120)
--   print("  "..c)
--   print_char({c, c+1}, Vector(0, 120), 7)
--   flip()
-- end

screen_center = Vector(63,63)

Ship = {}
Ship.__index = Ship
function Ship.new(
    max_acceleration_in_gs,
    turn_speed_in_degrees)
  local shp = {
    npc = false,
    screen_position = screen_center,
    sector_position = Vector(),

    gees = max_acceleration_in_gs or 4,
    turn_rate = turn_speed_in_degrees or 8,

    current_deltav = 0,
    current_gees = 0,
    angle = 0,
    angle_radians = 0,
    heading = 90,

    velocity_angle = 0,
    velocity_angle_opposite = 180,
    velocity = 0,
    velocity_vector = Vector(),

    orders = {}
  }
  shp.deltav = 9.806 * shp.gees / 300 -- 30fps * scaling factor
  setmetatable(shp,Ship)
  return shp
end

ship_types = {
  { name = "cruiser",
    min_size = 18,
    max_size = 38,
    shape = {
      3.5, -- starting point
      .5,  -- v1
      0,   -- v2
      -1,  -- v3
      .583333,
      .8125
    },
  },
  { name = "fighter",
    min_size = 14,
    max_size = 20,
    shape = {
      1.5, -- starting point
      .25, -- v1
      .75, -- v2
      -2,  -- v3
      .7,
      .8
    },
  }
}

function Ship:generate_random_ship(size, seed, shiptype)
  self.ship_type = shiptype or ship_types[random_int(#ship_types)+1]
  -- self.ship_type = ship_types[2]

  local seed_value = seed or rnd()
  srand(seed_value)

  -- Generate Bright Colors
  local ship_colors = {}
  for i=6,15 do
    add(ship_colors, i)
  end
  for i=1,6 do
    del(ship_colors, random_int(10)+6)
  end

  self.hp = 0
  self.sprite = nil
  local ship_mask = {}
  local rows = size or 16
  self.length = rows
  local columns = flr(rows/2)
  local s1 = Vector(1, self.ship_type.shape[1])
  local s2 = Vector(1, self.ship_type.shape[2])
  local s3 = Vector(1, self.ship_type.shape[3])
  local s4 = Vector(1, self.ship_type.shape[4])
  local y2 = flr( self.ship_type.shape[5] * rows)  -- 2nd x
  local y3 = flr( self.ship_type.shape[6] * rows) -- 3rd x

  for y=1,rows do
    add(ship_mask, {})
    for x=1,columns do
      -- fill with transparent
      add(ship_mask[y], ship_colors[4])
    end
  end

  local last = s1
  local cv = s2
  local thirdy = round(rows/3)
  local thirdx = round(columns/4)
  for y=2,rows-1 do
    for x=1,columns do
      -- print(cv:tostring().." "..last.y)
      -- get current bright color
      local color = ship_colors[1]
      -- set color based on part of the ship
      if y >= thirdy+random_plus_to_minus_one() and
         y <= 2*thirdy+random_plus_to_minus_one() then
        color = ship_colors[3]
      end
      if x >= thirdx+random_plus_to_minus_one() and
         y >= 2*thirdy+random_plus_to_minus_one() then
        color = ship_colors[2]
      end

      if columns-x < max(0,flr(last.y)) then
        if rnd() < .6 then
          -- set bright color
          ship_mask[y][x] = color
          self.hp = self.hp + 1
          -- if above pixel is transparent, shade darker
          if ship_mask[y-1][x] == ship_colors[4] then
            ship_mask[y][x] = darkshipcolors[color]
          end
        end

        -- if ship_mask[y][x-1] == ship_colors[4] and
        --   ship_mask[y-1][x-1] == ship_colors[4] and
        -- ship_mask[y][x] == ship_colors[4] then
        --   ship_mask[y][x] = 15
        -- end

      end
    end
    if y>=y3 then
      cv = s4
    elseif y>=y2 then
      cv = s3
    end
    last=last+cv
    -- add a dark gray ship spine
    if last.y > 0 and y>3 and y<rows-1 then
      for i=1,random_int(round(last.y/4)+1) do
        ship_mask[y][columns-i] = 5
        self.hp = self.hp + 2
      end
    end
  end

  -- for y=1,rows do
  --   for x=1,columns do
  --     print(ship_mask[y][x], x*8,y*6-6)
  --   end
  -- end

  self.sprite_has_odd_columns = random_int(2) -- 0 or 1

  for y=rows,1,-1 do
    for x=columns-self.sprite_has_odd_columns,1,-1 do
      add(ship_mask[y], ship_mask[y][x])
    end
  end
  -- self.hp = self.hp * 2
  self.max_hp = self.hp
  self.hp_percent = 1

  self.sprite_rows = #ship_mask
  self.sprite_columns = #ship_mask[1]
  self.transparent_color = ship_colors[4]
  self.sprite = ship_mask
  return self
end

-- function Ship:save_sprite()
--   draw_rect(self.sprite_rows,self.sprite_columns,0)
--   for y=1,self.sprite_rows do
--     for x=1,self.sprite_columns do
--       sset(self.sprite_rows-y,
--            x-1,
--            self.sprite[y][x])
--       sset(self.sprite_rows-y,
--            self.sprite_rows-self.sprite_has_odd_columns-x,
--            self.sprite[y][x])
--     end
--   end
--   cstore()
-- end

-- function Ship:load_sprite()
--   self.transparent_color = sget(0,0)
--   self.sprite = {}
--   for y=0,self.sprite_columns-1 do
--     self.sprite[y] = {}
--     for x=0,self.sprite_rows-1 do
--       self.sprite[y][x] = sget(x,y)
--     end
--   end
-- end

function land_at_closest_planet()
  local closest_planet
  local shortest_distance = 32767
  for p in all(thissector.planets) do
    if p.planet_type then
      local d = Vector.distance(playership.sector_position/182, p.sector_position/182)
      if d < shortest_distance then
        shortest_distance = d
        closest_planet = p
      end
    end
  end
  if shortest_distance*182 < closest_planet.radius*1.4 then
    if playership.velocity < .5 then
      thissector:reset_planet_visibility()
      landed_front_rendered = false
      landed_back_rendered = false
      landed_planet = closest_planet
      landed = true
      landed_menu()
      draw_rect(128,128,0)
    else
      notifications:add("moving too fast to land")
    end
  else
    notifications:add("too far to land")
  end
  -- return ""..(closest_planet.radius*2).."*"..(shortest_distance*182)
  return false -- unpause
end

function takeoff()
  thissector:reset_planet_visibility()
  playership:set_position_near_object(landed_planet)
  landed = false
  return false -- unpause
end

function Ship:set_position_near_object(object)
  self.sector_position = (random_angle() * 1.2*object.radius) + object.sector_position
  self:reset_velocity()
end

function clear_targeted_ship()
  for ship in all(npcships) do
    ship.targeted = false
  end
end

function next_ship_target()
  clear_targeted_ship()
  playership.target_index = (playership.target_index or #npcships)%#npcships + 1
  npcships[playership.target_index].targeted = true
  return true -- keep paused
end

function next_object_target()
  clear_targeted_ship()
  return true -- keep paused
end

function Ship:draw_sprite_rotated()
  -- self.shadow_angle = self.sector_position:angle()

  if self.targeted then
    local half_length = self.length/2+2
    rect(self.screen_position.x-half_length, self.screen_position.y-half_length, self.screen_position.x+ceil(half_length), self.screen_position.y+half_length, 11)
  end

  local close_projectiles = {}
  for projectile in all(projectiles) do
    if Vector.distance(projectile.position, self.screen_position) < self.length then
      add(close_projectiles, projectile)
    end
  end
  local projectile_hit_by

  local tcolor = self.transparent_color
  local a = self.angle_radians
  local rows = self.sprite_rows
  local columns = self.sprite_columns

  for y=1,columns do
    for x=1,rows do
      local color = self.sprite[x][y]
      if color ~= tcolor and color ~= nil then
        local pixel = Vector(
          rows-x-flr(rows/2),
          y-flr(columns/2)-1)

        -- -- draw ship shadow
        -- if abs((self.shadow_angle - pixel:angle() + .5)%1 - .5) < .25 then
        --   color = darkershipcolors[color]
        -- end

        local pixel2 = Vector(pixel.x+1, pixel.y)
        pixel:rotate(a):add(self.screen_position):round()
        pixel2:rotate(a):add(self.screen_position):round()

        if self.hp < 1 then
          -- explode
          local explosion_direction = random_angle()
          add(particles,
              Circle.new(
                pixel,
                explosion_direction*rnd(.5),--*(rnd()+.5),
                color,
                #damage_colors2-3,
                explosion_direction * self.length * .5 + pixel
          ))
          add(particles,
              Spark.new(
                pixel,
                random_angle()*(rnd(.25)+.25),
                color,
                128))
        else

          for projectile in all(close_projectiles) do
            if pixel:about_equals(projectile.position) or pixel:about_equals(projectile.position2) then

              projectile_hit_by = projectile.ship
              add(particles,
                  Circle.new(
                    pixel,
                    random_angle(),--*(rnd()+.5),
                    color,
                    #damage_colors-3
                    -- pixel+Vector(4)
                  )
              )
              if rnd() < .5 then
                add(particles,
                    Spark.new(
                      pixel,
                      random_angle()*(2*rnd()+1),
                      color,
                      128)
                )
              end
              self.hp = self.hp - 1
              self.hp_percent = self.hp/self.max_hp
              del(projectiles, projectile)
              color = -random_int(#damage_colors)
              break
            end
          end
          -- damaged pixel
          if color <= 0 then
            if -color < #damage_colors  then
              color = (-color+1)--%#damage_colors
              self.sprite[x][y] = -color
              color = damage_colors[color]
            else
              color = 5
            end
          end

          rectfill(pixel.x, pixel.y,
                   pixel2.x,
                   pixel2.y,
                   color)

        end

      end
    end
  end

  if projectile_hit_by then
    self.last_hit_time = secondcount
    self.last_hit_attacking_ship = projectile_hit_by
  end
end

function Ship:turn_left()
  self:rotate(self.turn_rate)
end

function Ship:turn_right()
  self:rotate(-self.turn_rate)
end

function Ship:rotate(signed_degrees) -- +1 or -1
  self.angle = (self.angle+signed_degrees)%360
  self.angle_radians = self.angle/360
  self.heading = (450-self.angle)%360 -- (360-self.angle+90)%360
end

-- ramped_speed=0
-- clipped_speed=0
function Ship:draw()
  print_shadowed("ram: "..format_float(stat(0)).."kb  cpu: "..stat(1), 0, 0)
  print_shadowed("heading: "..format_float(self.heading), 0, 7)

  print_shadowed(10*self.velocity.." m/s", 0, 14)
  if self.accelerating then
    print_shadowed(self.current_gees.."gS", 0, 21)
  end

  -- local ship = npcships[1]
  -- print_shadowed("position: "..ship.sector_position:tostring(), 0, 29)
  -- if ship.destination then
  --   print_shadowed("dest: "..ship.destination:tostring(), 0, 35)
  -- end
  -- if ship.steering_velocity then
  --   print_shadowed("steer: "..ship.steering_velocity:tostring(), 0, 41)
  --   print_shadowed("len: "..ship.steering_velocity:length(), 0, 47)
  --   screen_center:draw_line(screen_center+ship.steering_velocity,11)
  --   print_shadowed("dist:  "..ship.distance_to_destination, 0, 53)
  --   print_shadowed("mdist: "..ship.max_distance_to_destination, 0, 59)
  --   print_shadowed("ramped: "..ramped_speed, 0, 65)
  --   print_shadowed("clipped: "..clipped_speed, 0, 71)
  --   print_shadowed("seektime: "..ship.seektime, 0, 77)
  --   print_shadowed("angle: "..ship.angle_radians, 0, 83)
  --   print_shadowed("steerangle: "..ship.steering_velocity:angle(), 0, 89)
  -- end

  -- print_shadowed("vel: "..self.velocity.." dv: "..self.deltav, 0, 78)

  local targeted_ship = npcships[self.target_index]
  if targeted_ship then
    if not targeted_ship:is_visible(self.sector_position) then
      local d = (targeted_ship.screen_position/182 - self.screen_position/182):normalize()
      -- print_shadowed("order: "..#targeted_ship.orders.." "..co, 0, 85)
      -- self.screen_position:draw_line(targeted_ship.screen_position,7)
      local p1 = d*(self.length/2+4) + self.screen_position
      local p2 = d*(self.length/2+14) + self.screen_position
      p1:draw_line(p2, 11)
      local distance = format_float((targeted_ship.screen_position - self.screen_position):scaled_length())
      if p2.x > 63 then
        p2:add(Vector(2,-2))
      else
        p2:add(Vector(-4 * #distance,-2))
      end
      print(distance, round(p2.x), round(p2.y), 11)
    end

    print_shadowed("target hp: "..targeted_ship.hp.."/"..targeted_ship.max_hp.." "..100*targeted_ship.hp_percent.."%", 0, 107)

  end
  print_shadowed("hp: "..format_float(100*self.hp_percent), 0, 114)

  self:draw_sprite_rotated()
end

function Ship:is_visible(player_ship_pos)
  local size = self.length
  self.screen_position = self.sector_position - player_ship_pos + screen_center
  return self.screen_position.x < 128 + size and
         self.screen_position.x > 0   - size and
         self.screen_position.y < 128 + size and
         self.screen_position.y > 0   - size
end

function Ship:update_location()
  if self.velocity > 0.0 then
    self.sector_position:add(self.velocity_vector)
  end
end

function Ship:reset_velocity()
  self.velocity_vector = Vector()
  self.velocity = 0
end

function Ship:set_destination(dest)
  self.destination = dest.sector_position
  self:update_steering_velocity()
  self.max_distance_to_destination = self.distance_to_destination
end

function Ship:flee()
  self:set_destination(self.last_hit_attacking_ship)
  self:update_steering_velocity(1)
  local away_from_enemy = self.steering_velocity:angle()
  if self.distance_to_destination < 55 then
    -- co = "fleeing"
    self:rotate_towards_heading(away_from_enemy)
    self:apply_thrust()
  else
    -- co = "stopping"
    -- if self:rotate_towards_heading((away_from_enemy+.5) % 1) then
      self:full_stop(true)
      -- self:fire_weapon()
    -- end

  end
end

function Ship:update_steering_velocity(modifier) -- towards:-1 away:1
  local away = modifier or -1
  local desired_velocity = self.sector_position - self.destination
  self.distance_to_destination = desired_velocity:scaled_length()
  self.steering_velocity = (desired_velocity - self.velocity_vector) * away
end

-- function Ship:seek()
--   local targeted_ship = npcships[self.target_index]
--   self:set_destination(targeted_ship)
--   self:update_steering_velocity()
--   local away_from_enemy = self.steering_velocity:angle()
--   if self:rotate_towards_heading(away_from_enemy) then
--     self:apply_thrust()
--   -- else
--       -- self:full_stop(true)
--   end
-- end

function Ship:seek()
  if self.seektime%20 == 0 then
    self:set_destination(npcships[self.target_index] or playership)
  end
  self.seektime = self.seektime + 1

  local target_offset = self.destination - self.sector_position
  local distance = target_offset:scaled_length()
  self.distance_to_destination = distance
  local maxspeed = distance / 50
  local ramped_speed = (distance / (self.max_distance_to_destination*.7)) * maxspeed
  -- maxspeed * (distance / slowingdistance)
  local clipped_speed = min(ramped_speed, maxspeed)
  local desired_velocity = target_offset * (ramped_speed / distance)
  self.steering_velocity = desired_velocity - self.velocity_vector

  if self:rotate_towards_heading(self.steering_velocity:angle()) then
    self:apply_thrust(abs(self.steering_velocity:length()))
  end
  -- if distance < 32 then
    -- self:order_done(self.full_stop)
  -- end
end

function Ship:fly_towards_destination()
  -- co = "fly_towards"
  self:update_steering_velocity()
  if self.distance_to_destination > self.max_distance_to_destination*.9 then
    -- co = "fly_towards burn"
    if self:rotate_towards_heading(self.steering_velocity:angle()) then
      self:apply_thrust()
    end
  else
    -- self:cut_thrust()
    self.accelerating = false -- no acceleration ramp-up
    -- co = "fly_towards reverse"
    self:reverse_direction()
    if self.distance_to_destination <= self.max_distance_to_destination*.11 then
      -- co = "fly_towards stop2"
      self:order_done(self.full_stop)
    end
  end
end

function Ship:approach_object(obj)
  local object = obj or thissector.planets[random_int(#thissector.planets)+1]
  self:set_destination(object)
  add(self.orders, self.fly_towards_destination)
  if self.velocity > 0 then
    add(self.orders, self.full_stop)
  end
end

function Ship:follow_current_order()
  local order = self.orders[#self.orders]
  if order then order(self) end
end

function Ship:order_done(new_order)
  self.orders[#self.orders] = new_order
end

function Ship:clear_orders()
  self.orders = {}
end

function Ship:cut_thrust()
  self.accelerating = false
  self.current_deltav = self.deltav / 3
end

function Ship:wait()
  -- co = "waiting "..secondcount.." > "..(self.wait_duration + self.wait_time)
  if secondcount > self.wait_duration + self.wait_time then
    self:order_done()
  end
end
-- co = ""
function Ship:full_stop()
  if self.velocity > 0 and self:reverse_direction() then
    self:apply_thrust()
    if self.velocity < 1.2 * self.deltav then
      self:reset_velocity()
      self:order_done()
    end
  end
end

function Ship:fire_weapon(weapon)
  local weapon_velocity = Vector(1):rotate(self.angle_radians)
  local hardpoint_location = weapon_velocity * (self.length/2) + self.screen_position
  if framecount%3==0 then
    add(projectiles,
        MultiCannon.new(
          hardpoint_location,
          weapon_velocity*6 + self.velocity_vector,
          12,
          self))
    sfx(0)
  end
end

function Ship:apply_thrust(max_velocity)
  self.accelerating = true
  if self.current_deltav < self.deltav then
    self.current_deltav = self.current_deltav + self.deltav / 30
  else
    self.current_deltav = self.deltav
  end

  local dv = self.current_deltav
  if max_velocity and dv > max_velocity then
    dv = max_velocity
  end

  if self.hp_percent < .15+rnd(.1)-.05 then
    dv = 0
  end

  self.current_gees = dv*300/9.806
  local a = self.angle_radians
  local dv_vector = Vector(cos(a) * dv, sin(a) * dv)

  self.velocity_vector:add(dv_vector)

  if self.velocity_vector.x > 180 or self.velocity_vector.y > 180 then
    self.velocity = self.velocity_vector:scaled_length()
  else
    self.velocity = self.velocity_vector:length()
  end

  self.velocity_angle = self.velocity_vector:angle()
  self.velocity_angle_opposite = (self.velocity_angle + 0.5)%1

  local engine_location = Vector(1):rotate(a) * -(self.length/2) + self.screen_position
  if self.velocity < .05 then
    self.velocity = 0.0
    self.velocity_vector = Vector()
  else
    add(particles,
        ThrustExhaust.new(engine_location,
                          dv_vector*-1.3*self.length))
  end
end

function Ship:reverse_direction()
  if self.velocity > 0.0 then
    return self:rotate_towards_heading(self.velocity_angle_opposite)
  end
end

function Ship:rotate_towards_heading(heading) -- in radians
  local delta = (heading*360-self.angle + 180)%360 - 180
  if delta ~= 0 then
    local r = self.turn_rate * delta / abs(delta)
    if abs(delta) > abs(r) then delta = r end
    self:rotate(delta)
  end
  return delta < 0.1 and delta > -.1
end

Star = {}
Star.__index = Star
function Star.new()
  return setmetatable(
    { position = Vector(),
      color    = 7,
      speed    = 1
    }, Star)
end

function Star:reset(x,y)
  self.position.x = x or random_int(128)
  self.position.y = y or random_int(128)
  self.color = random_int(#star_colors[star_color_monochrome+star_color_index+1])+1
  self.speed = rnd(0.75)+0.25
  return self
end

sun_colors = {
  {6, 14, 10, 9,  13}, -- outer
  {7, 8,  9,  10, 12}, -- inner
}
Sun = {}
Sun.__index = Sun
function Sun.new(radius, x, y)
  local r = radius or 64+random_int(128)
  local c = random_int(5)+1
  return setmetatable(
    { screen_position = Vector(),
      radius          = r,
      sun_color_index = c,
      color           = sun_colors[2][c],
      sector_position = Vector(x or 0, y or 0),
    }, Sun)
end

function stellar_object_is_visible(object, ship_pos)
  object.screen_position = object.sector_position - ship_pos + screen_center
  return object.screen_position.x < 128 + object.radius and
         object.screen_position.x > 0   - object.radius and
         object.screen_position.y < 128 + object.radius and
         object.screen_position.y > 0   - object.radius
end

function Sun:draw(ship_pos)
  if stellar_object_is_visible(self, ship_pos) then
    for i=0,1 do
      circfill(
        self.screen_position.x,
        self.screen_position.y,
        self.radius-i*3,
        sun_colors[i+1][self.sun_color_index])
    end
  end
end

starfield_count = 50
Sector = {}
Sector.__index = Sector
function Sector.new()
  local sec = {
    seed = random_int(32767),
    planets = {},
    starfield = {}
  }
  srand(sec.seed)

  for i=1,starfield_count -- star count
  do
    sec.starfield[i] = Star.new():reset()
  end
  setmetatable(sec,Sector)
  return sec
end

function Sector:reset_planet_visibility()
  for p in all(self.planets) do
    p.rendered_circle = false
    p.rendered_terrain = false
  end
end

function Sector:new_planet_along_elipse()
  local x
  local y
  local smallest_distance
  local planet_is_nearby = true
  while(planet_is_nearby) do
    -- pick a random point on an elipse
    -- 150 wide and 75 tall
    -- elipse equation
    -- x^2/a^2 + y^2/b^2 = 1
    -- a = horizonal major axis size
    -- b = vertical axis size
    x = rnd(150)
    -- squared numbers need to be less than 180 to prevent overflow
    y = sqrt( (rnd(35)+40)^2 * (1 - x^2 / (rnd(50)+100)^2) )
    if rnd() < .5 then x = x * -1 end
    if rnd() < .75 then y = y * -1 end
    if #self.planets == 0 then break end
    -- find the closest planet
    smallest_distance = 32767
    for p in all(self.planets) do
      local d = abs(Vector.distance(Vector(x,y), p.sector_position/33))
      if d<smallest_distance then smallest_distance = d end
    end
    -- planets less than 500 units apart are too close
    planet_is_nearby = smallest_distance < 15 -- 500 / 33
    -- print("D> "..(smallest_distance*33))
    if not planet_is_nearby then
      break
    end
  end
  -- planets should be at most 5000ish units away
  -- scale the 150 units (at most) of the elipse up to that
  local phase = ((1-Vector(x,y):angle())-.25)%1
  x = x * 33
  y = y * 33
  return Planet.new(x,y,phase)
end

function Sector:draw_starfield(ship_velocity)
  local line_start_point
  local line_end_point
  for star in all(self.starfield) do
    line_start_point = star.position + (ship_velocity * star.speed * -.5)
    line_end_point = star.position + (ship_velocity * star.speed * .5)
    local i=star_color_monochrome+star_color_index+1
    local star_color_count = #star_colors[i]
    local color_index = 1+((star.color-1)%star_color_count)
    star.position:draw_line(
      line_end_point,
      star_colors[i+1][color_index])
    line_start_point:draw_line(
      star.position,
      star_colors[i][color_index])
  end
end

function Sector:scroll_starfield(ship_velocity)
  local stardifference = starfield_count - #self.starfield
  -- add new stars
  for i=1,stardifference do
    add(self.starfield, Star.new():reset())
  end
  -- update positions
  for star in all(self.starfield) do
    star.position:add(ship_velocity * star.speed * -1)

    -- remove stars if there are too many
    if stardifference < 0 then
      del(self.starfield, star)
      stardifference = stardifference + 1
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
  local mincoord = 0-margin
  local maxcoord = 128+margin
  local x = p.position.x
  local y = p.position.y
  return p.duration < 0 or x > maxcoord or x < mincoord or y > maxcoord or y < mincoord
end

MultiCannon = {}
MultiCannon.__index = MultiCannon
function MultiCannon.new(p, pv, c, firing_ship)
  local deflection = pv:perpendicular():normalize() * (rnd(2)-1)
  return setmetatable(
    { position = p,
      position2 = p:clone(),
      particle_velocity = pv + deflection,
      color = c,
      ship = firing_ship,
      duration = 256 }, MultiCannon)
end
function MultiCannon:draw(ship_velocity)
  -- find position2 slightly behind self.position by 2 or 3 pixels
  -- self.position2 = self.position:clone():add(
    -- self.particle_velocity:clone():normalize() * 2 - ship_velocity)
  self.position:add(self.particle_velocity - ship_velocity)
  self.position2:draw_line(self.position, self.color)
  self.position2 = self.position:clone()
  -- pset(self.position.x, self.position.y, self.color)
  self.duration = self.duration - 1
end

Spark = {}
Spark.__index = Spark
function Spark.new(p, pv, c, d)
  return setmetatable(
    { position = p,
      particle_velocity = pv,
      color = c,
      duration = d or random_int(5)+2 }, Spark)
end
function Spark:update(ship_velocity)
  self.position:add(self.particle_velocity - ship_velocity)
  self.duration = self.duration - 1
end
function Spark:draw(ship_velocity)
  pset(self.position.x, self.position.y, self.color)
  self:update(ship_velocity)
end

Circle = {}
Circle.__index = Circle
function Circle.new(p, pv, c, d, center)
  return setmetatable(
    { position = p:clone(),
      particle_velocity = pv,
      color = c,
      center_position = center or p:clone(),
      duration = d }, Circle)
end
function Circle:draw(ship_velocity)
  -- self.center_position:draw_line(self.position, self.color)
  local dist = flr(Vector.distance(self.position, self.center_position))
  for i=dist+3,dist,-1 do
    local c = damage_colors2[#damage_colors2-3-self.duration+i]
    if c then
      circfill(self.center_position.x, self.center_position.y, i, c)
    end
  end
  self:update(ship_velocity)
end
setmetatable(Circle,{__index = Spark})

ThrustExhaust = {}
ThrustExhaust.__index = ThrustExhaust
function ThrustExhaust.new(p, pv)
  return setmetatable(
    { position = p,
      particle_velocity = pv,
      duration = 0 }, ThrustExhaust)
end
function ThrustExhaust:draw(ship_velocity)
  local c = 9+random_int(2)
  local deflection = self.particle_velocity:perpendicular() * 0.7
  local flicker = (self.particle_velocity * (rnd(2)+2)) + (deflection * (rnd()-.5))

  local p0 = self.position + flicker
  local p1 = self.position + self.particle_velocity + deflection
  local p2 = self.position + self.particle_velocity + deflection*-1
  local p3 = self.position
  p1:draw_line(p0,c)
  p2:draw_line(p0,c)
  p2:draw_line(p3,c)
  p1:draw_line(p3,c)

  if rnd() > .4 then
    add(particles, Spark.new(p0,ship_velocity+(flicker*.25),c))
  end

  self.position:add(self.particle_velocity - ship_velocity)
  self.duration = self.duration - 1
end

function draw_circle(xc, yc, radius, filled, color)
  local xvalues = {}
  local notfilled = not filled
  local fx = 0
  local fy = 0
  local x = -radius
  local y = 0
  local err = 2-2*radius
  while(x < 0) do
    xvalues[1+x*-1] = y -- for passing to draw_moon

    if notfilled then
      fx = x
      fy = y
    end
    for i=x,fx do
      sset(xc - i, yc + y,color)
      sset(xc + i, yc - y,color)
    end
    for i=fy,y do
      sset(xc - i, yc - x,color)
      sset(xc + i, yc + x,color)
    end

    radius = err
    if radius <= y then
      y = y + 1
      err = err + y*2+1
    end
    if radius > x or err > y then
      x = x + 1
      err = err + x*2+1
    end
  end
  xvalues[1] = xvalues[2]
  return xvalues
end

function draw_moon_at_ycoord(ycoord, xcenter, ycenter, radius, phase, xvalues, all_black)
  local x
  local y
  local doublex
  local x1
  local x2
  local i
  local c1
  local c2
  y = radius-ycoord
  local xvalueindex = abs(y)+1

  if xvalueindex <= #xvalues then
    -- for y=0,radius do
    x = flr(sqrt(radius*radius - y*y))

    -- calculate the terminator location
    doublex = 2*x
    if phase < .5 then --
      x1 = -xvalues[xvalueindex] -- -x
      x2 = flr(doublex - 2*phase*doublex - x)
    else
      x1 = flr(x - 2*phase*doublex + doublex)
      x2 = xvalues[xvalueindex] -- x
    end

    -- darken a line from the terminator to the edge
    for i=x1,x2 do
      if not all_black or (phase < .5 and i>x2-2) or (phase >= .5 and i<x1+2) then
        c1 = dark_planet_colors[sget(xcenter+i,ycenter-y)+1]
      else
        c1 = 0
      end
      sset(xcenter+i,ycenter-y, c1)
    end
  end
end

-- create the permutation table
perms = {}
for i=0,255 do perms[i]=i end
-- shuffle
for i=0,255 do
  local r = random_int(32767)%256
  perms[i], perms[r] = perms[r], perms[i]
end

-- The above, mod 12 for each element --
local perms12 = {}
for i = 0, 255 do
  local x = perms[i] % 12
  perms[i + 256], perms12[i], perms12[i + 256] = perms[i], x, x
end

-- Gradients for 2D, 3D case --
local Grads3 = {
  { 1, 1, 0 }, { -1, 1, 0 }, { 1, -1, 0 }, { -1, -1, 0 },
  { 1, 0, 1 }, { -1, 0, 1 }, { 1, 0, -1 }, { -1, 0, -1 },
  { 0, 1, 1 }, { 0, -1, 1 }, { 0, 1, -1 }, { 0, -1, -1 }
}
for row in all(Grads3) do
  for i=0,2 do
    row[i]=row[i+1]
  end
end
for i=0,11 do
  Grads3[i]=Grads3[i+1]
end

-- 3D weight contribution
function GetN_3d (ix, iy, iz, x, y, z)
  local t = .6 - x * x - y * y - z * z
  local index = perms12[ix + perms[iy + perms[iz]]]
  return max(0, (t * t) * (t * t)) * (Grads3[index][0] * x + Grads3[index][1] * y + Grads3[index][2] * z)
end

--
-- @param x
-- @param y
-- @param z
-- @return Noise value in the range [-1, +1]
function Simplex3D (x, y, z)
  -- 3D skew factors:
  -- F = 1 / 3
  -- G = 1 / 6
  -- G2 = 2 * G
  -- G3 = 3 * G - 1
  -- Skew the input space to determine which simplex cell we are in.
  local s = (x + y + z) * 0.333333333 -- F
  local ix, iy, iz = flr(x + s), flr(y + s), flr(z + s)
  -- Unskew the cell origin back to (x, y, z) space.
  local t = (ix + iy + iz) * 0.166666667 -- G
  local x0 = x + t - ix
  local y0 = y + t - iy
  local z0 = z + t - iz
  -- Calculate the contribution from the two fixed corners.
  -- A step of (1,0,0) in (i,j,k) means a step of (1-G,-G,-G) in (x,y,z);
  -- a step of (0,1,0) in (i,j,k) means a step of (-G,1-G,-G) in (x,y,z);
  -- a step of (0,0,1) in (i,j,k) means a step of (-G,-G,1-G) in (x,y,z).
  ix, iy, iz = band(ix, 255), band(iy, 255), band(iz, 255)
  local n0 = GetN_3d(ix, iy, iz, x0, y0, z0)
  local n3 = GetN_3d(ix + 1, iy + 1, iz + 1, x0 - 0.5, y0 - 0.5, z0 - 0.5) -- G3
  -- Determine other corners based on simplex (skewed tetrahedron) we are in:

  local i1, j1, k1, i2, j2, k2
  if x0 >= y0 then
    if y0 >= z0 then -- X Y Z
      i1, j1, k1, i2, j2, k2 = 1,0,0,1,1,0
    elseif x0 >= z0 then -- X Z Y
      i1, j1, k1, i2, j2, k2 = 1,0,0,1,0,1
    else -- Z X Y
      i1, j1, k1, i2, j2, k2 = 0,0,1,1,0,1
    end
  else
    if y0 < z0 then -- Z Y X
      i1, j1, k1, i2, j2, k2 = 0,0,1,0,1,1
    elseif x0 < z0 then -- Y Z X
      i1, j1, k1, i2, j2, k2 = 0,1,0,0,1,1
    else -- Y X Z
      i1, j1, k1, i2, j2, k2 = 0,1,0,1,1,0
    end
  end

  local n1 = GetN_3d(ix + i1, iy + j1, iz + k1, x0 + 0.166666667 - i1, y0 + 0.166666667 - j1, z0 + 0.166666667 - k1) -- G
  local n2 = GetN_3d(ix + i2, iy + j2, iz + k2, x0 + 0.333333333 - i2, y0 + 0.333333333 - j2, z0 + 0.333333333 - k2) -- G2
  -- add contributions from each corner to get the final noise value.
  -- The result is scaled to stay just inside [-1,1]
  return 32 * (n0 + n1 + n2 + n3)
end

function create_planet_type(name,
                            octaves, zoom, persistance,
                            minimapcolor, colormap,
                            fullshadow, transparentcolor)
  return {
    class_name        = name,
    noise_octaves     = octaves,
    noise_zoom        = zoom,
    noise_persistance = persistance,
    transparent_color = transparentcolor or 14,
    minimap_color     = minimapcolor,
    full_shadow       = fullshadow or "yes",
    color_map         = colormap
  }
end

planet_types = {
  create_planet_type(
    "tundra", 5, .5, .6,
    6,
    {7, 6, 5, 4,
     5, 6,
     7, 6, 5, 4, 3}
  ),

  create_planet_type(
    "desert", 5, .35, .3,
    9,
    sequence({
        3, {4, 4, 9, 9},
        1, {11, 1},
        5, {9, 4, 9}
    })
  ),

  create_planet_type(
    "barren", 5, .55, .35,
    5,
    {5, 6, 5, 0, 5, 6,
     7,
     6, 5, 0, 5, 6}
  ),

  create_planet_type(
    "lava", 5, .55, .65,
    4,
    {0, 4, 0, 5, 0, 4, 0, 4,
     9, 8,
     4, 0, 4, 0, 5, 0, 4, 0}
  ),

  create_planet_type(
    "gas giant", 1, .4, .75,
    2,
    {7, 6, 13, 1, 2, 1, 12} -- blue/purple
  ),

  create_planet_type(
    "gas giant", 1, .4, .75,
    8,
    {7, 15, 14, 2, 1, 2, 8, 8}, -- red/purple
    nil,
    12
  ),

  create_planet_type(
    "gas giant", 1, .7, .75,
    10,
    {15, 10, 9, 4, 9, 10} -- yellow/brown
  ),

  create_planet_type(
    "terran", 5, .3, .65,
    11,
    sequence({
        7, {1}, -- deep ocean
        1, {13, 12, 15}, -- coastline
        2, {11}, 3, {3}, -- green land
        1, {4,  5,  6,  7}  -- mountains
    }),
    "partial shadow"
  ),

  create_planet_type(
    "island", 5, .55, .65,
    12,
    sequence({
        8, {1}, -- deep ocean
        1, {13, 12, 15}, -- coastline
        1, {11, 3} -- green land
    }),
    "partial shadow"
  )
}

Planet = {}
Planet.__index = Planet
function Planet.new(x, y, phase, r)
  local planet_type = planet_types[random_int(#planet_types)+1]
  local noise_factor_vert = planet_type.noise_factor_vert or 1

  if planet_type.class_name == "gas giant" then
    planet_type.min_size = 50
    noise_factor_vert = 4
    if rnd() < .5 then
      noise_factor_vert = 20
    end
  end

  local min_size = planet_type.min_size or 10
  local radius = r or min_size+random_int(64-min_size)+1
  return setmetatable(
    { screen_position    = Vector(),
      radius             = radius,
      sector_position    = Vector(x, y),
      bottom_right_coord = 2*radius-1,
      phase              = phase,
      planet_type        = planet_type,
      noise_factor_vert  = noise_factor_vert,
      noisedx            = rnd(1024),
      noisedy            = rnd(1024),
      noisedz            = rnd(1024),
      rendered_circle    = false,
      rendered_terrain   = false,
      color              = planet_type.minimap_color }, Planet)
end

function Planet:draw(ship_pos)
  if stellar_object_is_visible(self, ship_pos) then
    self:render_a_bit_to_sprite_sheet()
    sspr(0, 0, self.bottom_right_coord, self.bottom_right_coord,
         self.screen_position.x - self.radius,
         self.screen_position.y - self.radius)
  end
end

function draw_rect(w,h,c)
  for x=0,w-1 do
    for y=0,h-1 do
      sset(x,y,c)
    end
  end
end

function Planet:render_a_bit_to_sprite_sheet(fullmap, renderback)
  local radius = self.radius-1 -- make sure the circle fits inside a radius*2 square
  if fullmap then radius = 47 end

  if not self.rendered_circle then
    self.width     = self.radius*2
    self.height    = self.radius*2
    self.x         = 0
    self.yfromzero = 0
    self.y         = radius - self.yfromzero
    self.phi       = 0

    -- set other planets to not visible
    thissector:reset_planet_visibility()
    -- reset transparent colors
    pal()
    -- make black opaque
    palt(0,false)
    -- for i=0,15 do
    --   palt(i,false)
    -- end

    -- set new transparent color
    palt(self.planet_type.transparent_color, true)

    if fullmap then
      self.width  = 114
      self.height = 96
      draw_rect(self.width, self.height, 0)
    else
      -- fill sprite sheet with the transparent_color
      draw_rect(self.width, self.height, self.planet_type.transparent_color)
      self.bxs = draw_circle(radius, radius, radius, true, 0)
      -- draw scanning outline
      draw_circle(radius, radius, radius, false, self.planet_type.minimap_color)
      notifications:add("scanning surface")
    end

    self.rendered_circle = true
  end

  if (not self.rendered_terrain) and self.rendered_circle then
    local theta_start = 0
    local theta_end = .5
    local theta_increment = theta_end/self.width
    if fullmap and renderback then
      theta_start = .5
      theta_end = 1
    end

    if self.phi <= .25 then
      -- from north to south pole, pi/2 to -pi/2
      -- for phi=-.25,.25,(.5/(height-1)) do
      -- 1/2 way around the planet, only need one side, 0 to pi (all the way is 2*pi)
      for theta=theta_start,theta_end-theta_increment,theta_increment do
        -- theta = theta + offset*(.5/width)
        if sget(self.x,self.y) ~= self.planet_type.transparent_color then -- only sample a point if it's in the circle
          local freq = self.planet_type.noise_zoom
          local max_amp = 0
          local amp = 1
          local value = 0
          for n=1,self.planet_type.noise_octaves do
            value = value + Simplex3D(
              self.noisedx + freq * cos(self.phi) * cos(theta),
              self.noisedy + freq * cos(self.phi) * sin(theta),
              self.noisedz + freq * sin(self.phi) * self.noise_factor_vert)
            max_amp = max_amp + amp
            amp = amp * self.planet_type.noise_persistance
            freq = freq * 2
          end
          value = value / max_amp

          if value>1 then value = 1 end
          if value<-1 then value = -1 end
          value = value + 1
          value = value * (#self.planet_type.color_map-1)/2
          value = round(value)

          sset(self.x,self.y,self.planet_type.color_map[value+1])
        end
        self.x = self.x + 1
      end

      if not fullmap then
        draw_moon_at_ycoord(self.y,radius,radius,radius,self.phase,self.bxs,
                            self.planet_type.full_shadow == "yes")
      end

      self.x = 0
      if self.phi >= 0 then
        self.phi = self.phi + .5/(self.height-1)
        self.yfromzero = self.yfromzero + 1
        self.y = radius + self.yfromzero
      else
        self.y = radius - self.yfromzero
      end
      self.phi = self.phi * -1

    else
      -- done drawing
      self.rendered_terrain = true
      notifications:add("planet class: "..self.planet_type.class_name)
      notifications:cancel_all("scanning surface")
    end

  end

  return self.rendered_terrain
end

function load_sector()
  thissector = Sector.new()
  notifications:cancel_all()
  notifications:add("arriving in system ngc "..thissector.seed)

  for i=0,random_int(1) do -- sun count
    add(thissector.planets, Sun.new())
  end

  for i=0,1+random_int(12) do -- planet count
    add(thissector.planets, thissector:new_planet_along_elipse())
  end

  -- drop the ship near the border of the first star
  -- local p = thissector.planets[1]
  playership:set_position_near_object(thissector.planets[1])

  npcships = {}
  for p in all(thissector.planets) do
    for i=1,random_int(4) do -- npc ship count
      local npc = Ship.new(2,4):generate_random_ship(12+random_int(8))
      npc:set_position_near_object(p)
      npc.npc = true
      add(npcships, npc)
    end
  end
  npcships[1].hostile = true

  -- insert test planet
  -- add(thissector.planets, Planet.new(playership.sector_position.x+63,playership.sector_position.y+63, .6, 32))
  return true -- stay paused
end


function _init()
  paused = false
  landed = false

  particles = {}
  projectiles = {}
  notifications = Notification.new()

  playership = Ship.new()
  playership:generate_random_ship()

  load_sector()
  setup_minimap()
end

minimap_sizes = {16,32,52,128,false}

function setup_minimap(size)
  minimap_size_index = size or 0
  minimap_size = minimap_sizes[minimap_size_index+1]
  if minimap_size then
    minimap_size_halved = minimap_size/2
    minimap_offset = Vector(126-minimap_size_halved, minimap_size_halved + 1)
  end
end

function draw_minimap_planet(object)
  -- local position = (object.sector_position-Vector(object.radius,object.radius) + screen_center) / minimap_denominator + minimap_offset
  local position = object.sector_position + screen_center
  if object.planet_type then position:add(Vector(-object.radius, -object.radius)) end
  position = position / minimap_denominator + minimap_offset
  if minimap_size > 100 then
    local r = ceil(object.radius/32)
    -- circfill(position.x, position.y, r+1, 0)
    circ(position.x, position.y, r+1, object.color)
  else
    position:draw_point(object.color)
  end
end

function draw_minimap_ship(object)
  local point = (object.sector_position/minimap_denominator):add(minimap_offset)
  if object.npc then
    point:draw_point(6)
  else
    rect(point.x-1,point.y-1,point.x+1,point.y+1, 15)
  end
end

function draw_minimap()
  if minimap_size then
    if minimap_size < 100 then
      rectfill(126-minimap_size,1,126,minimap_size+1,0)
      rect(125-minimap_size,0,127,minimap_size+2,6,11)
    end
    local x = abs(playership.sector_position.x)
    local y = abs(playership.sector_position.y)
    if y>x then x=y end
    local scale_factor = min(6, flr(x/5000)+1)
    minimap_denominator = scale_factor*5000/minimap_size_halved

    -- for s in all(thissector.suns) do
    --   -- sun sector position is from the center
    --   draw_minimap_planet(s, s.sector_position / minimap_denominator)
    -- end

    for p in all(thissector.planets) do
      -- planets sector position is from the upper left corner
      draw_minimap_planet(p)
    end

    -- ships on the minimap blink
    if framecount%2 == 1 then
      for ship in all(npcships) do
        draw_minimap_ship(ship)
      end
      draw_minimap_ship(playership)
    end
  end
end

function print_shadowed(text, x, y, color, shadow_color, outline)
  local c = color or 6
  local s = shadow_color or 5
  if outline then
    local points = {
      -1, -1,
       1, -1,
      -1,  1,
      -1,  0,
       1,  0,
       0, -1,
       0,  1,
    }
    for i=1,#points,2 do
      print(text, x+points[i], y+points[i+1], s)
    end
  end
  print(text, x+1, y+1, s)
  print(text, x, y, c)
end

Notification = {}
Notification.__index = Notification
function Notification.new()
  return setmetatable(
    { messages = {},
      display_time = 4
    },Notification)
end
-- function Notification:urgent(text)
-- end
function Notification:add(text)
  add(self.messages, text)
end
function Notification:cancel_current()
  del(self.messages, self.messages[1])
  self.display_time = 4
end
function Notification:cancel_all(text)
  if text then
    del(self.messages, text)
  else
    self.messages = {}
  end
  self.display_time = 4
end
function Notification:draw()
  local count = #self.messages
  if count > 0 then
    local m = self.messages[1]
    -- print(m.." "..count.." "..self.display_time, 0, 121, 6)
    print_shadowed(m, 0, 121)
    if framecount == 29 then -- 1 second has passed
      self.display_time = self.display_time - 1
    end
    if self.display_time < 1 then
      self:cancel_current()
    end
  end
end

function call_option(i)
  if current_option_callbacks[i] then
    local return_value = current_option_callbacks[i]()
    paused = false
    if return_value == nil then
      paused = true
    elseif return_value then
      display_menu(nil, nil, i)

      if type(return_value) == "string" then
        print_shadowed(return_value, 64-round(4*#return_value/2), 40, 11, 0, true)
      end

      paused = true
    end
  end
end

function display_menu(options, callbacks, selected)
  if options then
    current_options = options
    current_option_callbacks = callbacks
  end

  if not landed then
    render_game_screen()
  end

  -- -- darken
  -- for i=0,127 do
  --   for j=0,127 do
  --     pset(i, j, darkershipcolors[ pget(i, j) ])
  --   end
  -- end
  -- rect(0,0,127,127,7)

  -- local center = Vector(64,60)
  local center = Vector(64,90)
  local arrow_offset = center + Vector(-1,2)
  for a=.25,1,.25 do
    -- draw arrows
    local i = a*4
    local text_color = 6
    local outline_color = 0
    if selected == i then
      text_color = 11
      -- outline_color = 13
    end

    -- local p = Vector(6):rotate(a) + center + arrow_offset
    local p = Vector(8):rotate(a) + arrow_offset
    p:draw_line(Vector(3):rotate(a) + arrow_offset, text_color)
    p:draw_line(Vector(5,2):rotate(a) + arrow_offset, text_color)
    p:draw_line(Vector(5,-2):rotate(a) + arrow_offset, text_color)

    if current_options[i] then
      p = Vector(14):rotate(a) + center
      -- move text into place based on string length
      if a == .5 then -- if left
        p:add(Vector(-4 * #current_options[i]))
      elseif a ~= 1 then -- if up or down (not right)
        p:add(Vector(round(-4 * (#current_options[i]/2))))
      end

      print_shadowed(
        current_options[i],
        p.x, p.y, text_color, outline_color, true)
    end
  end
end

function main_menu()
  display_menu(
    {"inventory",
     "debug",
     "display options",
     "systems"},
    { -- inventory
      nil,

      -- debug menu
      function ()
        display_menu(
          { "new ship",
            "back",
            "new sector"
          },
          { -- ship regen test
            function ()
              s=(s+2)%48
              if s < 8 then s = 8 end
              playership:generate_random_ship(s)
              return "ship size: "..s
            end,
            main_menu,
            load_sector
        })
      end, -- debug menu

      -- display options
      function ()
        display_menu(
          { "starfield",
            "back",
            "minimap size"},
          { function ()
              display_menu(
                { "more stars",
                  "~dimming",
                  "less stars",
                  "~colors",
                },
                {
                  function () -- more stars
                    starfield_count = starfield_count + 5
                    return "star count: "..starfield_count
                  end,
                  function () -- toggle star color dimming
                    star_color_index = (star_color_index+1)%2
                    return true -- stay paused
                  end,
                  function () -- less stars
                    starfield_count = max(0, starfield_count-5)
                    return "star count: "..starfield_count
                  end,
                  function () -- toggle star monochrome
                    star_color_monochrome = ((star_color_monochrome+1)%2)*3
                    return true -- stay paused
                  end,
              })
            end,
            main_menu,
            function ()
              -- toggle minimap size
              setup_minimap((minimap_size_index+1)%#minimap_sizes)
              return true -- stay paused
            end
          }
        )
      end, -- display option function

      -- ship systems menu
      function ()
        display_menu(
          { "autopilot",
            "back",
            "land",
            "target next",
          },
          { function ()
              display_menu(
                { "stop",
                  "back",
                  "seek",
                  "approach",
                },
                { function ()
                    playership:clear_orders()
                    add(playership.orders, playership.full_stop)
                    return false -- unpause
                  end,
                  main_menu,
                  function ()
                    playership:clear_orders()
                    playership.seektime = 0
                    add(playership.orders, playership.seek)
                    return false -- unpause
                  end,
                  function ()
                    playership:clear_orders()
                    playership:approach_object()
                    return false -- unpause
                  end,
              })
            end,
            main_menu,
            land_at_closest_planet,
            next_ship_target,
        })
      end, -- debug menu

    } -- root menu functions
  ) -- root menu
end

function landed_menu()
  display_menu(
    {
      "takeoff",
    },
    {
      takeoff,
    }
  )
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
    poke(64*i+0x1838, peek(64*i))
    memcpy(64*i, 64*i+1, 56)
    memcpy(64*i+0x1800, 64*i+0x1801, 56)
    poke(64*i+56, peek(64*i+0x1800))
  end
end

function landed_update()
  local p = landed_planet
  if not landed_front_rendered then
    landed_front_rendered = p:render_a_bit_to_sprite_sheet(true)
    if landed_front_rendered then
      p.rendered_circle = false
      p.rendered_terrain = false
      for j=1,56 do
        shift_sprite_sheet()
      end
    end
  else
    if not landed_back_rendered then
      landed_back_rendered = p:render_a_bit_to_sprite_sheet(true, true)
    else
      pos = 1-pos
      if pos == 0 then
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
          -- pal(1,12) pal(3,11) pal(6,7)
          for ci=0,#dark_planet_colors-1 do
            pal(ci, dark_planet_colors[ci+1])
          end
        end
        if j<15 then lw=flr(a+b*cs[j+1][1])-flr(a+b*cs[j][1]) end
        sspr(pos+j*7, i-1, 7, 1, flr(a+b*cs[j][1]), i+16, lw, 1)
      end
    end
    pal()
    print_shadowed("landed at ...",1,1,7,5,true)
  else
    sspr(0, 0, 127, 127, 0, 0)
    print_shadowed("mapping surface...",1,1,7,5,true)
  end
end

s = 8
framecount = 0
secondcount = 0
function _update()
  framecount = (framecount+1)%30
  if framecount == 0 then secondcount = secondcount + 1 end

  -- toggle paused menu
  if not landed and btnp(4,0) then
    paused = not paused
    -- set and draw initial menu if paused
    if paused then
      main_menu()
    end
  end

  if landed then
    landed_update()
  end

  if paused or landed then
    -- handle paused button presses
    if btnp(2) then call_option(1) end
    if btnp(0) then call_option(2) end
    if btnp(3) then call_option(3) end
    if btnp(1) then call_option(4) end
  else -- normal gameplay
    if btn(0,0) then playership:turn_left() end
    if btn(1,0) then playership:turn_right() end
    if btn(3,0) then playership:reverse_direction() end

    if btn(5,0) then playership:fire_weapon() end
    if btn(2,0) then
      playership:apply_thrust()
      if playership.current_deltav < playership.deltav then
        camera(random_int(2)-1, random_int(2)-1)
      else
        camera()
      end
    else
      if playership.accelerating and not playership.orders[1] then
        camera()
        playership:cut_thrust()
      end
    end

    for ship in all(npcships) do
      if ship.last_hit_time and ship.last_hit_time + 30 > secondcount then
        ship:clear_orders()
        ship:flee()
      else
        if #ship.orders == 0 then
          if ship.hostile then
            ship.seektime = 0
            add(ship.orders, ship.seek)
          else
            ship:approach_object()
            ship.wait_duration = 11+random_int(50)
            ship.wait_time = secondcount
            add(ship.orders, ship.wait)
          end
        end

        ship:follow_current_order()
      end

      -- ship:fire_weapon()
      -- if secondcount < 5 then
      -- ship:apply_thrust()
      -- ship:turn_left()
      -- end
      ship:update_location()
      if ship.hp < 1 then
        del(npcships, ship)
        playership.target_index = false
      end
    end

    playership:follow_current_order()
    playership:update_location()

    thissector:scroll_starfield(playership.velocity_vector)
  end
end

function render_game_screen()
  cls()
  thissector:draw_starfield(playership.velocity_vector)
  -- for sun in all(thissector.suns) do
  --   sun:draw(playership.sector_position)
  -- end
  for planet in all(thissector.planets) do
    planet:draw(playership.sector_position)
  end
  for ship in all(npcships) do
    if ship:is_visible(playership.sector_position) then
      ship:draw_sprite_rotated()
    end
  end
  if playership.hp < 1 then
    playership:generate_random_ship()
  end
  playership:draw()
  for particle in all(particles) do
    if is_offscreen(particle) then
      del(particles, particle)
    else
      particle:draw(playership.velocity_vector)
    end
  end

  for projectile in all(projectiles) do
    if is_offscreen(projectile, 63) then
      del(projectiles, projectile)
    else
      projectile:draw(playership.velocity_vector)
    end
  end

  draw_minimap()
  notifications:draw()
end

function _draw()
  if landed then
    render_landed_screen()
    display_menu()
  elseif not paused then
    render_game_screen()
  end
end
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
00020000276501d65013650106500c6400e63022620116300b63004630026101b6100861003610076101260013600106000d60010600116000e6001160012600116000a600066000960003600026000260002600
011100000162001600056000460003600016000160001600026000160002600036000460001600016000a600016000160001600016000160002600016000260001600016000460023600246001f600246001f600
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
