-- heliopause
-- by anthonydigirolamo

function split_number_string(s)
  local t = {}
  local ti = split_number_string_start_index
  local substr_start_index = 1
  for i=1,#s do
    if sub(s,i,i) == " " then
      t[ti] = sub(s, substr_start_index, i-1)+0
      ti = ti + 1
      substr_start_index = i+1
    end
  end
  return t
end

split_number_string_start_index = 0

local Grads3 = {
  split_number_string "-1 1 0 ",
  split_number_string "1 -1 0 ",
  split_number_string "-1 -1 0 ",
  split_number_string "1 0 1 ",
  split_number_string "-1 0 1 ",
  split_number_string "1 0 -1 ",
  split_number_string "-1 0 -1 ",
  split_number_string "0 1 1 ",
  split_number_string "0 -1 1 ",
  split_number_string "0 1 -1 ",
  split_number_string "0 -1 -1 "
}
Grads3[0] = split_number_string "1 1 0 "

split_number_string_start_index = 1

damage_colors = split_number_string "7 10 9 8 5 0 "
damage_colors2 = split_number_string "7 10 9 8 5 0 7 10 9 8 5 0 7 10 9 8 5 0 "

star_color_index = 0
star_color_monochrome = 0
star_colors = {
  split_number_string "10 14 12 13 7 6 ", -- light
  split_number_string "9 8 13 1 6 5 ", -- dark
  split_number_string "4 2 1 0 5 1 ", -- darker
  split_number_string "7 6 ", -- monochrome light
  split_number_string "6 5 ", -- monochrome dark
  split_number_string "5 1 ",  -- monochrome darker
}

darkshipcolors = split_number_string "0 1 2 2 1 5 6 2 4 9 3 13 1 8 9 "

dark_planet_colors = split_number_string "0 0 1 1 0 5 5 5 4 5 5 3 1 1 2 1 "

function round(i)
   return flr(i+.5)
end

function ceil(x)
	return -flr(-x)
end

function random_plus_to_minus_one()
  return random_int(3)-1
end

function random_int(n, minimum)
  local m = minimum or 0
  return flr(rnd(32767))%(n-m) + m
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

function Vector:draw_circle(radius, color, filled)
  local circle_method = circ
  if filled then circle_method = circfill end
  circle_method(
    round(self.x),
    round(self.y),
    round(radius),
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
  return self
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

function random_angle(length)
  return rotated_vector(rnd(), length)
end

function rotated_vector(angle, x, y)
  return Vector(x or 1, y):rotate(angle)
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
  -- self = self + v
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
  -- divided by 182 to prevent overflow - looses some percision
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

    orders = {},

    last_fire_time = 0
  }
  shp.deltav = 9.806 * shp.gees / 300 -- 30fps * scaling factor
  setmetatable(shp,Ship)
  return shp
end

-- ship shape number definition:
-- start pixel height,
-- slope1, slope2, slope3,
-- slope2 start x coord %, slope3 start x coord %
-- min length, max length
ship_types = {
  { name = "cruiser",
    shape = split_number_string "3.5 .5 0 -1 .583333 .8125 18 24 "
  },
  { name = "freighter",
    shape = split_number_string "3 2 0 -3 .2125 .8125 16 22 "
  },
  { name = "fighter",
    shape = split_number_string "1.5 .25 .75 -2 .7 .8 14 18 "
  }
}

function Ship:generate_random_ship(size, seed, shiptype)
  self.ship_type = shiptype or ship_types[random_int(#ship_types)+1]
  local ship_type_shape = self.ship_type.shape

  local seed_value = seed or rnd()
  srand(seed_value)

  -- Generate Bright Colors
  local ship_colors = {}
  for i=6,15 do
    add(ship_colors, i)
  end
  for i=1,6 do
    del(ship_colors, random_int(16,6))
  end

  local hp = 0
  local ship_mask = {}
  local rows = size or random_int(ship_type_shape[8]+1, ship_type_shape[7])
  local columns = flr(rows/2)

  local s1 = Vector(1, ship_type_shape[1])
  local s2 = Vector(1, ship_type_shape[2])
  local s3 = Vector(1, ship_type_shape[3])
  local s4 = Vector(1, ship_type_shape[4])
  local y2 = flr( ship_type_shape[5] * rows)  -- 2nd x
  local y3 = flr( ship_type_shape[6] * rows) -- 3rd x

  for y=1,rows do
    add(ship_mask, {})
    for x=1,columns do
      -- fill with transparent
      add(ship_mask[y], ship_colors[4])
    end
  end

  local last_slope = s1
  local current_slope = s2
  local thirdy = round(rows/3)
  local thirdx = round(columns/4)

  for y=2,rows-1 do
    for x=1,columns do
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

      if columns-x < max(0,flr(last_slope.y)) then
        if rnd() < .6 then
          -- set bright color
          ship_mask[y][x] = color
          hp = hp + 1
          -- if above pixel is transparent, shade darker
          if ship_mask[y-1][x] == ship_colors[4] then
            ship_mask[y][x] = darkshipcolors[color]
          end
        end
      end
    end

    if y>=y3 then
      current_slope = s4
    elseif y>=y2 then
      current_slope = s3
    end

    last_slope = last_slope + current_slope
    -- add a dark gray ship spine
    if last_slope.y > 0 and y>3 and y<rows-1 then
      for i=1,random_int(round(last_slope.y/4)+1) do
        ship_mask[y][columns-i] = 5
        hp = hp + 2
      end
    end
  end

  -- for y=1,rows do
  --   for x=1,columns do
  --     print(ship_mask[y][x], x*8,y*6-6)
  --   end
  -- end

  -- mirror ship colors
  local sprite_has_odd_columns = random_int(2) -- 0 or 1
  for y=rows,1,-1 do
    for x=columns-sprite_has_odd_columns,1,-1 do
      add(ship_mask[y], ship_mask[y][x])
    end
  end

  self.hp = hp
  self.max_hp = hp
  self.hp_percent = 1

  self.sprite_rows = rows
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

function nearest_planet()
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
  return closest_planet, shortest_distance*182
end

function land_at_nearest_planet()
  local closest_planet, shortest_distance = nearest_planet()
  if shortest_distance < closest_planet.radius*1.4 then
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
  local radius = object.radius or object.sprite_rows
  self.sector_position = random_angle(1.2*radius) + object.sector_position
  self:reset_velocity()
end

function Ship:clear_target()
  self.target_index = nil
  self.target = nil
end

function clear_targeted_ship_flags()
  for ship in all(npcships) do
    ship.targeted = false
  end
end

function next_hostile_target(ship)
  local targeting_ship = ship or playership
  local hostile
  for i=1,#npcships do
    next_ship_target(ship)
    if targeting_ship.target.hostile then break end
  end
  return true
end

function next_ship_target(ship, random)
  local targeting_ship = ship or playership
  if random then
    targeting_ship.target_index = random_int(#npcships)+1
  else
    targeting_ship.target_index = (targeting_ship.target_index or #npcships)%#npcships + 1
  end
  targeting_ship.target = npcships[targeting_ship.target_index]
  if targeting_ship == targeting_ship.target then
    targeting_ship.target = playership
  end
  if not ship then
    clear_targeted_ship_flags()
    targeting_ship.target.targeted = true
  end
  return true -- keep paused
end

function Ship:targeted_color()
  if self.hostile then
    return 8,2
  else
    return 11,3
  end
end

function Ship:draw_sprite_rotated(offscreen_pos)
  -- self.shadow_angle = self.sector_position:angle()

  local screen_position = offscreen_pos or self.screen_position
  local a       = self.angle_radians
  local rows    = self.sprite_rows
  local columns = self.sprite_columns
  local tcolor  = self.transparent_color

  if self.targeted then
    local targetcircle_radius = round(rows/2)+4
    local circlecolor, circleshadow = self:targeted_color()
    if offscreen_pos then
      (screen_position+Vector(1,1)):draw_circle(targetcircle_radius, circleshadow, true)
      screen_position:draw_circle(targetcircle_radius, 0, true)
    end
    screen_position:draw_circle(targetcircle_radius, circlecolor)
  end

  local close_projectiles = {}
  for projectile in all(projectiles) do
    if projectile.firing_ship ~= self then
      if (projectile.sector_position and offscreen_pos and (self.sector_position - projectile.sector_position):scaled_length() <= rows) or
      Vector.distance(projectile.screen_position, screen_position) < rows then
        add(close_projectiles, projectile)
      end
    end
  end

  local projectile_hit_by

  for y=1,columns do
    for x=1,rows do
      local color = self.sprite[x][y]
      if color ~= tcolor and color ~= nil then
        local pixel1 = Vector(
          rows-x-flr(rows/2),
          y-flr(columns/2)-1)

        -- -- draw ship shadow
        -- if abs((self.shadow_angle - pixel1:angle() + .5)%1 - .5) < .25 then
        --   color = darkershipcolors[color]
        -- end

        local pixel2 = Vector(pixel1.x+1, pixel1.y)
        pixel1:rotate(a):add(screen_position):round()
        pixel2:rotate(a):add(screen_position):round()

        if self.hp < 1 then
          -- explode
          make_explosion(pixel1, rows/2)
          if not offscreen_pos then
            add(particles,
                Spark.new(
                  pixel1,
                  random_angle(rnd(.25)+.25)+self.velocity_vector,
                  color,
                  128 + random_int(32)))
          end
        else

          for projectile in all(close_projectiles) do
            -- tokens 7610
            local impact = false

            if not offscreen_pos
              -- and projectile.firing_ship ~= self
              and (pixel1:about_equals(projectile.screen_position)
                   or (projectile.position2 and pixel1:about_equals(projectile.position2))) then
              impact = true
            elseif offscreen_pos
              and projectile.last_offscreen_pos
              and pixel1:about_equals(projectile.last_offscreen_pos) then
              impact = true
            end

            if impact then
              projectile_hit_by = projectile.firing_ship
              local damage = projectile.damage or 1
              self.hp = self.hp - damage
              if damage > 10 then make_explosion(pixel1) end
              self.hp_percent = self.hp/self.max_hp
              add(particles,
                  Circle.new(
                    pixel1,
                    random_angle(),
                    color,
                    #damage_colors-3)
              )
              if rnd() < .5 then
                add(particles,
                    Spark.new(
                      pixel1,
                      random_angle(2*rnd()+1)+self.velocity_vector,
                      color,
                      128)
                )
              end
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

          rectfill(
            pixel1.x, pixel1.y,
            pixel2.x, pixel2.y,
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

function Ship:draw()
  print_shadowed("prj:"..#projectiles, 100, 100)
  print_shadowed("cpu:"..stat(1), 100, 107)
  print_shadowed("ram:"..stat(0), 100, 114)

  -- print_shadowed("heading: "..format_float(self.heading), 0, 7)
  local hp_color = 11
  if self.hp_percent <= .3 then hp_color = 9 end
  if self.hp_percent <= .1 then hp_color = 8 end
  print_shadowed(self:hp_string(), 0, 0, hp_color, darkshipcolors[hp_color])

  print_shadowed(10*self.velocity.." pixels/sec", 0, 7)
  if self.accelerating then
    print_shadowed(self.current_gees.."gS", 0, 14)
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

  self:draw_sprite_rotated()

  -- screen_center:draw_line(self:predict_sector_position() - self.sector_position + screen_center,11)
end

function Ship:hp_string()
  return "hp: "..self.hp.."/"..self.max_hp.." "..round(100*self.hp_percent).."%"
end

function Ship:is_visible(player_ship_pos)
  local size = round(self.sprite_rows/2)
  local screen_position = (self.sector_position - player_ship_pos + screen_center):round()
  self.screen_position = screen_position
  return screen_position.x < 128 + size and
         screen_position.x > 0   - size and
         screen_position.y < 128 + size and
         screen_position.y > 0   - size
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

function Ship:predict_sector_position()
  local prediction = self.sector_position:clone()
  if self.velocity > 0 then
    prediction:add( self.velocity_vector * 4 )
  end
  return prediction
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
  local toward_enemy = (away_from_enemy+.5) % 1
  if self.distance_to_destination < 55 then
    self:rotate_towards_heading(away_from_enemy)
    self:apply_thrust()
  else
    self:full_stop(true)
    if self.hostile and
      self.angle_radians < toward_enemy+.1 and
      self.angle_radians > toward_enemy-.1 then
      self:fire_weapon()
    end
  end
end

function Ship:update_steering_velocity(modifier) -- towards:-1 away:1
  local away = modifier or -1
  local desired_velocity = self.sector_position - self.destination
  self.distance_to_destination = desired_velocity:scaled_length()
  self.steering_velocity = (desired_velocity - self.velocity_vector) * away
end

function Ship:seek()
  if self.seektime%20 == 0 then
    self:set_destination(self.target or playership)
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
  if self.hostile then
    if distance < 128 then
      self:fire_weapon()
      self:fire_missile()
    end
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

function approach_nearest_planet()
  local closest_planet, shortest_distance = nearest_planet()
  playership:approach_object(closest_planet)
  return false -- unpause
end

function Ship:approach_object(obj)
  local object = obj or thissector.planets[random_int(#thissector.planets)+1]
  self:set_destination(object)
  self:reset_orders(self.fly_towards_destination)
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

function Ship:reset_orders(new_order)
  self.orders = {}
  if new_order then add(self.orders, new_order) end
end

function Ship:cut_thrust()
  self.accelerating = false
  self.current_deltav = self.deltav / 3
end

function Ship:wait()
  if secondcount > self.wait_duration + self.wait_time then
    self:order_done()
  end
end

function Ship:full_stop()
  if self.velocity > 0 and self:reverse_direction() then
    self:apply_thrust()
    if self.velocity < 1.2 * self.deltav then
      self:reset_velocity()
      self:order_done()
    end
  end
end

function Ship:fire_missile(weapon)
  if self.target and secondcount > 3 + self.last_fire_time then
    self.last_fire_time = secondcount
    add(projectiles, HomingWeapon.new(self, self.target))
  end
end

function Ship:fire_weapon(weapon)
  local weapon_velocity = rotated_vector(self.angle_radians)
  local hardpoint_location = weapon_velocity * (self.sprite_rows/2) + self.screen_position
  if framecount%3==0 then
    add(projectiles,
        MultiCannon.new(
          hardpoint_location,
          weapon_velocity*6 + self.velocity_vector,
          12,
          self))
    -- sfx(0)
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
  -- cut thrust if less than 10%
  if self.hp_percent < .15+rnd(.1)-.05 then
    dv = 0
  end

  self.current_gees = dv*300/9.806
  local a = self.angle_radians
  local additional_velocity_vector = Vector(cos(a) * dv, sin(a) * dv)
  local velocity_vector = self.velocity_vector
  local velocity
  local engine_location = rotated_vector(a, self.sprite_rows * -.5) + self.screen_position

  add(particles,
      ThrustExhaust.new(
        engine_location,
        additional_velocity_vector*-1.3*self.sprite_rows))

  velocity_vector:add(additional_velocity_vector)
  -- if velocity_vector.x > 180 or velocity_vector.y > 180 then
    -- velocity = velocity_vector:scaled_length()
  -- else
  velocity = velocity_vector:length()
  -- end

  self.velocity_angle = velocity_vector:angle()
  self.velocity_angle_opposite = (self.velocity_angle + 0.5)%1

  if velocity < .05 then
    velocity = 0.0
    velocity_vector = Vector()
  end

  self.velocity = velocity
  self.velocity_vector = velocity_vector
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

HomingWeapon = {}
HomingWeapon.__index = HomingWeapon
function HomingWeapon.new(firing_ship, target_ship)
  local pa = (firing_ship.angle_radians+.25)%1
  -- local deflection = pv:perpendicular():normalize() * (rnd(2)-1)
  return setmetatable(
    { sector_position = firing_ship.sector_position:clone(),
      screen_position = firing_ship.screen_position:clone(),
      velocity_vector = rotated_vector(pa, .5)+firing_ship.velocity_vector,
      velocity = firing_ship.velocity,
      target = target_ship,
      sprite_rows = 1,
      firing_ship = firing_ship,
      current_deltav = .1, -- 9.806 * 8 / 300,
      deltav = .1, -- 9.806 * 8 / 300, -- 30fps * scaling factor
      hp_percent = 1,
      duration = 512,
      damage = 20
    }, HomingWeapon)
end
function HomingWeapon:draw(ship_velocity, offscreen_pos)
  local screen_position = offscreen_pos or self.screen_position
  self.last_offscreen_pos = offscreen_pos
  self.destination = self.target:predict_sector_position()
  self:update_steering_velocity()
  -- self.screen_position:draw_line(self.screen_position + self.steering_velocity, 11)
  self.angle_radians = self.steering_velocity:angle()
  if self.duration < 500 then
    self:apply_thrust(abs(self.steering_velocity:length()))
  end
  self.duration = self.duration - 1
  self:update_location()
  -- print(self.sector_position:tostring().." "..(playership.target.sector_position - self.sector_position):scaled_length() , 0, 80, 7)
  if self:is_visible(playership.sector_position) or offscreen_pos then
    screen_position:draw_line(screen_position+rotated_vector(self.angle_radians,4), 6)
  end
end
setmetatable(HomingWeapon,{__index = Ship})


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
  self.position = Vector(x or random_int(128), y or random_int(128))
  self.color = random_int(#star_colors[star_color_monochrome+star_color_index+1])+1
  self.speed = rnd(0.75)+0.25
  return self
end

sun_colors = {
 split_number_string "6 14 10 9 13 ", -- outer
 split_number_string "7 8 9 10 12 " -- inner
}
Sun = {}
Sun.__index = Sun
function Sun.new(radius, x, y)
  local r = radius or 64+random_int(128)
  local c = random_int(6,1)
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
      self.screen_position:draw_circle(
        self.radius-i*3,
        sun_colors[i+1][self.sun_color_index],
        true)
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
    add(sec.starfield, Star.new():reset())
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
      smallest_distance = min(
        smallest_distance,
        Vector.distance(Vector(x,y), p.sector_position/33))
    end
    -- planets less than 500 units apart are too close
    planet_is_nearby = smallest_distance < 15 -- 500 / 33
  end
  -- planets should be at most 5000ish units away
  -- scale the 150 units (at most) of the elipse up to that
  return Planet.new(x*33, y*33,
                    ((1-Vector(x,y):angle())-.25)%1) -- phase
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
  local x = p.screen_position.x
  local y = p.screen_position.y
  if p.deltav then -- if this is a homingweapon
    return p.duration < 0
  else
    return p.duration < 0 or x > maxcoord or x < mincoord or y > maxcoord or y < mincoord
  end
end

Spark = {}
Spark.__index = Spark
function Spark.new(p, pv, c, d)
  return setmetatable(
    { screen_position = p,
      particle_velocity = pv,
      color = c,
      duration = d or random_int(7,2)
    }, Spark)
end
function Spark:update(ship_velocity)
  self.screen_position:add(self.particle_velocity - ship_velocity)
  self.duration = self.duration - 1
end
function Spark:draw(ship_velocity)
  pset(self.screen_position.x, self.screen_position.y, self.color)
  self:update(ship_velocity)
end

Circle = {}
Circle.__index = Circle
function Circle.new(p, pv, c, d, center)
  return setmetatable(
    { screen_position = p:clone(),
      particle_velocity = pv,
      color = c,
      center_position = center or p:clone(),
      duration = d
    }, Circle)
end
function Circle:draw(ship_velocity)
  local dist = flr(Vector.distance(self.screen_position, self.center_position))
  for i=dist+3,dist,-1 do
    local c = damage_colors2[#damage_colors2-3-self.duration+i]
    if c then
      self.center_position:draw_circle(i, c, true)
    end
  end
  self:update(ship_velocity)
end
setmetatable(Circle,{__index = Spark})

function make_explosion(pixel1, size)
  local explosion_direction = random_angle()
  add(particles,
      Circle.new(
        pixel1,
        explosion_direction*rnd(.5),--*(rnd()+.5),
        color,
        #damage_colors2-3,
        (explosion_direction * (size or 4)) + pixel1
  ))
end

MultiCannon = {}
MultiCannon.__index = MultiCannon
function MultiCannon.new(p, pv, c, ship)
  local deflection = pv:perpendicular():normalize() * (rnd(2)-1)
  return setmetatable(
    { screen_position = p,
      position2 = p:clone(),
      particle_velocity = pv + deflection,
      color = c,
      firing_ship = ship,
      duration = 16
    }, MultiCannon)
end
function MultiCannon:draw(ship_velocity)
  self:update(ship_velocity)
  self.position2:draw_line(self.screen_position, self.color)
  self.position2 = self.screen_position:clone()
end
setmetatable(MultiCannon,{__index = Spark})

ThrustExhaust = {}
ThrustExhaust.__index = ThrustExhaust
function ThrustExhaust.new(p, pv)
  return setmetatable(
    { screen_position = p,
      particle_velocity = pv,
      duration = 0
    }, ThrustExhaust)
end
function ThrustExhaust:draw(ship_velocity)
  local c = random_int(11,9)
  local pv = self.particle_velocity
  local deflection = pv:perpendicular() * 0.7
  local flicker = (pv * (rnd(2)+2)) + (deflection * (rnd()-.5))

  local p0 = self.screen_position + flicker
  local p1 = self.screen_position + pv + deflection
  local p2 = self.screen_position + pv + deflection*-1
  local p3 = self.screen_position
  p1:draw_line(p0,c)
  p2:draw_line(p0,c)
  p2:draw_line(p3,c)
  p1:draw_line(p3,c)

  if rnd() > .4 then
    add(particles, Spark.new(p0,ship_velocity+(flicker*.25),c))
  end

  self.screen_position:add(pv - ship_velocity)
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

function GetN_3d (ix, iy, iz, x, y, z)
  local t = .6 - x * x - y * y - z * z
  local index = perms12[ix + perms[iy + perms[iz]]]
  return max(0, (t * t) * (t * t)) * (Grads3[index][0] * x + Grads3[index][1] * y + Grads3[index][2] * z)
end

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
    split_number_string "7 6 5 4 5 6 7 6 5 4 3 "
  ),

  create_planet_type(
    "desert", 5, .35, .3,
    9,
    split_number_string "4 4 9 9 4 4 9 9 4 4 9 9 11 1 9 4 9 9 4 9 9 4 9 9 4 9 9 4 9 "
    -- sequence({
    --     3, {4, 4, 9, 9},
    --     1, {11, 1},
    --     5, {9, 4, 9}
    -- })
  ),

  create_planet_type(
    "barren", 5, .55, .35,
    5,
    split_number_string "5 6 5 0 5 6 7 6 5 0 5 6 "
  ),

  create_planet_type(
    "lava", 5, .55, .65,
    4,
    split_number_string "0 4 0 5 0 4 0 4 9 8 4 0 4 0 5 0 4 0 "
  ),

  create_planet_type(
    "gas giant", 1, .4, .75,
    2,
    split_number_string "7 6 13 1 2 1 12 " -- blue/purple
  ),

  create_planet_type(
    "gas giant", 1, .4, .75,
    8,
    split_number_string "7 15 14 2 1 2 8 8 ", -- red/purple
    nil,
    12
  ),

  create_planet_type(
    "gas giant", 1, .7, .75,
    10,
    split_number_string "15 10 9 4 9 10 " -- yellow/brown
  ),

  create_planet_type(
    "terran", 5, .3, .65,
    11,
    split_number_string "1 1 1 1 1 1 1 13 12 15 11 11 3 3 3 4 5 6 7 ",
    -- sequence({
    --     7, {1}, -- deep ocean
    --     1, {13, 12, 15}, -- coastline
    --     2, {11}, 3, {3}, -- green land
    --     1, {4,  5,  6,  7}  -- mountains
    -- }),
    "partial shadow"
  ),

  create_planet_type(
    "island", 5, .55, .65,
    12,
    split_number_string "1 1 1 1 1 1 1 1 13 12 15 11 3 ",
    -- sequence({
    --     8, {1}, -- deep ocean
    --     1, {13, 12, 15}, -- coastline
    --     1, {11, 3} -- green land
    -- }),
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
  local radius = r or random_int(65, min_size)
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
        self.yfromzero = self.yfromzero + 1
        self.y = radius + self.yfromzero
        self.phi = self.phi + .5/(self.height-1)
      else
        self.y = radius - self.yfromzero
      end
      self.phi = self.phi * -1

    else
      -- done drawing
      self.rendered_terrain = true
    end

  end

  return self.rendered_terrain
end

function add_npc(p)
  local position = p or playership
  local npc = Ship.new(2,4):generate_random_ship()
  npc:set_position_near_object(position)
  npc.npc = true
  add(npcships, npc)
  npc.index = #npcships
  if npc.ship_type.name ~= "freighter" and rnd() < .2 then
    npc.hostile = true
  end
end

function load_sector()
  thissector = Sector.new()
  notifications:cancel_all()
  notifications:add("arriving in system ngc "..thissector.seed)

  -- for i=0,random_int(1) do -- sun count
  add(thissector.planets, Sun.new())
  -- end

  for i=0,random_int(12) do -- planet count
    add(thissector.planets, thissector:new_planet_along_elipse())
  end

  -- drop the ship near the border of the first planet
  playership:set_position_near_object(thissector.planets[2])
  playership:clear_target()

  npcships = {}
  for p in all(thissector.planets) do
    for i=1,random_int(4) do -- npc ship count per planet
      add_npc(p)
    end
  end

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
  show_title_screen = true

  local title_screen_starfield_velocity = Vector(0,-3)

  while(not btnp(4)) do
    cls()
    thissector:scroll_starfield(title_screen_starfield_velocity)
    thissector:draw_starfield(title_screen_starfield_velocity)
    circfill(64,135,90,2)
    circfill(64,172,122,0)
    map(0,0,6,-15)
    print("\n\n    ”  thrust      —  fire\n  ‹  ‘  rotate  Ž  menu\n    ƒ  reverse",0,70,7)
    flip()
  end
end

minimap_sizes = {16,32,48,128,false}

function setup_minimap(size)
  minimap_size_index = size or 0
  minimap_size = minimap_sizes[minimap_size_index+1]
  if minimap_size then
    minimap_size_halved = minimap_size/2
    minimap_offset = Vector(126-minimap_size_halved, minimap_size_halved + 1)
  end
end

function draw_minimap_planet(object)
  local position = object.sector_position + screen_center
  if object.planet_type then position:add(Vector(-object.radius, -object.radius)) end
  position = position / minimap_denominator + minimap_offset
  if minimap_size > 100 then
    local r = ceil(object.radius/32)
    position:draw_circle(r+1, object.color)
  else
    position:draw_point(object.color)
  end
end

function draw_minimap_ship(object)
  local point = (object.sector_position/minimap_denominator):add(minimap_offset):round()
  local color = object:targeted_color()
  if object.npc then
    point:draw_point(color)
    if object.targeted then
      point:draw_circle(2, color)
    end
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

    for p in all(thissector.planets) do
      -- planets sector position is from the upper left corner
      draw_minimap_planet(p)
    end

    -- ships on the minimap blink
    if framecount%3 ~= 0 then
      for missile in all(projectiles) do
        if missile.deltav then
          draw_minimap_ship(missile)
        end
      end
      for ship in all(npcships) do
        draw_minimap_ship(ship)
      end
      draw_minimap_ship(playership)
    end
  end
end

outlined_text_draw_points = split_number_string "-1 -1 1 -1 -1 1 -1 0 1 0 0 -1 0 1 "
function print_shadowed(text, x, y, color, shadow_color, outline)
  local c = color or 6
  local s = shadow_color or 5
  if outline then
    for i=1,#outlined_text_draw_points,2 do
      print(text,
            x+outlined_text_draw_points[i],
            y+outlined_text_draw_points[i+1], s)
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
  if #self.messages > 0 then
    print_shadowed(self.messages[1], 0, 121)
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

    local p = rotated_vector(a, 8) + arrow_offset
    p:draw_line(rotated_vector(a, 3) + arrow_offset, text_color)
    p:draw_line(rotated_vector(a, 5, 2) + arrow_offset, text_color)
    p:draw_line(rotated_vector(a, 5, -2) + arrow_offset, text_color)

    if current_options[i] then
      p = rotated_vector(a, 14) + center
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
    { "autopilot",
      "fire missile",
      "options",
      "systems"},
    { -- autopilot
      function ()
        display_menu(
          {
            "full stop",
            "planet",
            "back",
            "follow",
          },
          {
            function ()
              playership:reset_orders(playership.full_stop)
              return false -- unpause
            end,
            approach_nearest_planet,
            main_menu,
            function ()
              playership:reset_orders(playership.seek)
              playership.seektime = 0
              return false -- unpause
            end,
        })
      end,
      function ()
        playership:fire_missile()
        return false -- unpause
      end,

      -- options
      function ()
        display_menu(
          { "back",
            "starfield",
            "minimap size",
            "debug"
          },
          { main_menu,
            function ()
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
            function ()
              -- toggle minimap size
              setup_minimap((minimap_size_index+1)%#minimap_sizes)
              return true -- stay paused
            end,

            -- debug menu
            function ()
              display_menu(
                { "new ship",
                  "back",
                  "new sector",
                  "spawn enemy",
                },
                { -- ship regen test
                  function ()
                    s = max((s+1)%48,8)
                    playership:generate_random_ship(s)
                    return playership.ship_type.name.." "..s
                  end,
                  main_menu,
                  load_sector,
                  function ()
                    add_npc()
                    npcships[#npcships].hostile = true
                    return "npc created"
                  end,
              })
            end, -- debug menu
          }
        )
      end, -- display option function

      -- ship systems menu
      function ()
        display_menu(
          { "target next hostile", -- "inventory",
            "back",
            "land",
            "target next",
          },
          { next_hostile_target,
            main_menu,
            land_at_nearest_planet,
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
    print_shadowed("planet class: "..landed_planet.planet_type.class_name,1,1,7,5,true)
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
  if framecount == 0 then
    secondcount = secondcount + 1
  end

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
        ship:reset_orders()
        ship:flee() -- run away
        if ship.hostile then
          ship.target = ship.last_hit_attacking_ship
          ship.target_index = ship.target.index
        end
      else
        if #ship.orders == 0 then
          if ship.hostile then
            ship.seektime = 0
            if not ship.target then
              next_ship_target(ship, true)
            end
            add(ship.orders, ship.seek)
          else
            ship:approach_object()
            ship.wait_duration = random_int(46, 10)
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
        playership:clear_target()
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

  if playership.target then
    last_offscreen_pos = nil
    local player_screen_position = playership.screen_position
    local targeted_ship = playership.target
    if targeted_ship then
      if not targeted_ship:is_visible(playership.sector_position) then
        local distance = format_float((targeted_ship.screen_position - player_screen_position):scaled_length())
        local color, shadow = targeted_ship:targeted_color()

        local hr = flr(targeted_ship.sprite_rows*.5)
        local d = rotated_vector((targeted_ship.screen_position - player_screen_position):angle())
        last_offscreen_pos = d*(60 - hr) + screen_center
        local p2 = last_offscreen_pos:clone():add(Vector(-4 * (#distance/2)))
        targeted_ship:draw_sprite_rotated(last_offscreen_pos)
        if p2.y > 63 then
          p2:add(Vector(1,-12 - hr))
        else
          p2:add(Vector(1,7+hr))
        end
        print_shadowed(distance, round(p2.x), round(p2.y), color, shadow)
      end -- if not visible
      print_shadowed("target "..targeted_ship:hp_string(), 0, 114)
    end
  end

  if playership.hp < 1 then
    playership:generate_random_ship()
  end
  playership:draw()
  for particle in all(particles) do
    if is_offscreen(particle, 32) then
      del(particles, particle)
    else
      particle:draw(playership.velocity_vector)
    end
  end

  for projectile in all(projectiles) do
    if is_offscreen(projectile, 63) then
      del(projectiles, projectile)
    else
      if last_offscreen_pos and projectile.sector_position and playership.target and
      (playership.target.sector_position - projectile.sector_position):scaled_length() <= playership.target.sprite_rows then
        projectile:draw(
          nil,
          (projectile.sector_position - playership.target.sector_position) +
            last_offscreen_pos
        )
      else
        projectile:draw(playership.velocity_vector)
      end
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
