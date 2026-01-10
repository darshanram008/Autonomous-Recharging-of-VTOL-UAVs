-- CAUTION: This script only works for Copter
--    a) runs in auto mode
--    b) record the waypoint i.e. bottom_left_loc when altitude becomes = 10 after takeoff
--    c) sets the home location when the copter lands at the waypoint
--    d) monitors SOC and if it is < 20
--	  e) Goes to the bottom_left_loc location
--    f) lands near home location but disarms but better accuracy than new.lua but same issue as darshan.lua
--    g) Distance = (SOC * battery capacity * battery efficiency * motor efficiency) / energy consumption rate; energy consumption rate is ampere's
--    h) Power consumption = battery voltage * current, Energy consumption rate = (Power consumption / distance) * (time / 3600)

local takeoff_alt_above_home = 10

local copter_guided_mode_num = 4

local copter_auto_mode_num = 3

local copter_rtl_mode_num = 6

local copter_land_mode_num = 9

local battery_capacity = 3300  -- mah

local rated_voltage = 12.6 -- volts

local delta_t = 0.1  -- seconds

local stage = 0

local safe_dist = 20 -- meters change it to 500 for practical cases

local bool_land = false

function vol_to_soc(voltage)

	local SOC

	if (voltage >= 12.6) then
	
		SOC = 100
		
	elseif ((voltage >= 12.45) and (voltage < 12.6)) then
	
		SOC = 95
		
	elseif ((voltage >= 12.33) and (voltage < 12.45)) then
		
		SOC = 90
		
	elseif ((voltage >= 12.25) and (voltage < 12.33)) then
		
		SOC = 85
		
	elseif ((voltage >= 12.07) and (voltage < 12.25)) then
		
		SOC = 80
	
	elseif ((voltage >= 11.95) and (voltage < 12.07)) then
		
		SOC = 75
		
	elseif ((voltage >= 11.86) and (voltage < 11.95)) then
	
		SOC = 70
		
	elseif ((voltage >= 11.74) and (voltage < 11.86)) then
		
		SOC = 65
		
	elseif ((voltage >= 11.62) and (voltage < 11.74)) then
		
		SOC = 60
		
	elseif ((voltage >= 11.56) and (voltage < 11.62)) then
		
		SOC = 55
	
	elseif ((voltage >= 11.51) and (voltage < 11.56)) then
		
		SOC = 50
		
	elseif ((voltage >= 11.45) and (voltage < 11.51)) then
		
		SOC = 45
		
	elseif ((voltage >= 11.39) and (voltage < 11.45)) then
		
		SOC = 40
		
	elseif ((voltage >= 11.36) and (voltage < 11.39)) then
		
		SOC = 35
	
	elseif ((voltage >= 11.30) and (voltage < 11.36)) then
		
		SOC = 30

	elseif ((voltage >= 11.24) and (voltage < 11.30)) then
		
		SOC = 25
		
	elseif ((voltage >= 11.18) and (voltage < 11.24)) then
	
		SOC = 20
		
	elseif ((voltage >= 11.12) and (voltage < 11.18)) then
		
		SOC = 15
		
	elseif ((voltage >= 11.06) and (voltage < 11.12)) then
		
		SOC = 10
		
	elseif ((voltage >= 10.83) and (voltage < 11.06)) then
		
		SOC = 5
		
	elseif (voltage < 10.83) then
		
		SOC = 0
		
	end
	
	return SOC;

end

function soc_to_vol(SOC)

	local voltage

	if (SOC == 100) then
	
		voltage = 12.6
		
	elseif ((SOC >= 95) and (SOC < 100)) then
	
		voltage = 12.45

	elseif ((SOC >= 90) and (SOC < 95)) then
	
		voltage = 12.33
		
	elseif ((SOC >= 85) and (SOC < 90)) then
	
		voltage = 12.25
		
	elseif ((SOC >= 80) and (SOC < 85)) then
	
		voltage = 12.07
		
	elseif ((SOC >= 75) and (SOC < 80)) then
	
		voltage = 11.95
		
	elseif ((SOC >= 70) and (SOC < 75)) then
	
		voltage = 11.86
		
	elseif ((SOC >= 65) and (SOC < 70)) then
	
		voltage = 11.74
		
	elseif ((SOC >= 60) and (SOC < 65)) then
	
		voltage = 11.62
		
	elseif ((SOC >= 55) and (SOC < 60)) then
	
		voltage = 11.56
		
	elseif ((SOC >= 50) and (SOC < 55)) then
	
		voltage = 11.51
		
	elseif ((SOC >= 45) and (SOC < 50)) then
	
		voltage = 11.45
		
	elseif ((SOC >= 40) and (SOC < 45)) then
	
		voltage = 11.39
		
	elseif ((SOC >= 35) and (SOC < 40)) then
	
		voltage = 11.36
		
	elseif ((SOC >= 30) and (SOC < 35)) then
	
		voltage = 11.30
		
	elseif ((SOC >= 25) and (SOC < 30)) then
	
		voltage = 11.24
		
	elseif ((SOC >= 20) and (SOC < 25)) then
	
		voltage = 11.18
		
	elseif ((SOC >= 15) and (SOC < 20)) then
	
		voltage = 11.12
		
	elseif ((SOC >= 10) and (SOC < 15)) then
	
		voltage = 11.06

	elseif ((SOC >= 5) and (SOC < 10)) then
	
		voltage = 10.83
				
	elseif (SOC < 5) then
		
		voltage = 9.32
		
	end
	
	return voltage;

end

function current_percentage(SOC_ini, battery_capacity, delta_t)     -- Gives the SOC(t) using SOC(t-1)

	--current = current_ini + current

	local current = battery:current_amps(0)
	
	local SOC = SOC_ini + ((current/(battery_capacity * 1000))* (delta_t/3600))

	return SOC;
	
end

function drone_voltage_SOC()  -- Gives the SOC using voltage parameter
	
	local voltage = battery:voltage(0)
	
	local SOC = vol_to_soc(voltage)
	
	return SOC;

end

function drone_velocity()

	local velocity_vector = ahrs:get_velocity_NED()

	local velocity = math.sqrt((velocity_vector:x()^2) + (velocity_vector:y()^2) + (velocity_vector:z()^2))
	
	return velocity;
	
end

function ener_con_rate(avg_velocity, time_of_flight, SOC)

	local voltage = soc_to_vol(SOC)

	local current = battery:current_amps(0)

	local power_consumption = current * voltage
	
	local distance_travelled = avg_velocity * time_of_flight
	
	local energy_consumption = power_consumption * (time_of_flight/3600)
	
	local energy_consumption_rate = energy_consumption / distance_travelled
	
	return energy_consumption_rate
	
end

function soc_distance(SOC, time_of_flight, avg_velocity)
	
	--local rem_bat_cap = ((battery_capacity * rated_voltage) / 1000) * (SOC / 100)  -- in watt hours
	local rem_bat_cap = (battery_capacity * 1000) * (SOC / 100)  -- in watt hours

	local energy_consumption_rate = ener_con_rate(avg_velocity, time_of_flight, SOC)
	
	local rem_distance = rem_bat_cap / energy_consumption_rate
	
	return rem_distance;

end	


-- the main update function that uses the takeoff and velocity controllers to fly a rough square pattern
function update()

  if not (arming:is_armed() or bool_land) then -- reset state when disarmed
  
    stage = 0
	
  else
  
    gcs:send_text(0, "Current Stage: " .. tostring(stage))
	
	local home = ahrs:get_home()
	  
    local curr_loc = ahrs:get_location()
	  
    if (stage == 0 ) then   -- Stage 1: auto mode
	
	  SOC_current = drone_voltage_SOC()  -- Initial SOC using voltage as parameter
	  
	  battery:reset_remaining(0, SOC_current)
	  
	  velocity_avg = 0
	
	  n = 0
	  
	  tof = 0  -- time of flight	  
	  	  
	  -- vehicle:set_mode(copter_auto_mode_num)

      stage = stage + 1
	  
	  gcs:send_text(0, "finished square, switching to Auto")
	  
	elseif (stage == 1) then  --stage 2: monitoring battery
	  
	  if home and curr_loc then
	  
		local vec_from_home = home:get_distance_NED(curr_loc)
		
		local distance_home = curr_loc:get_distance(home)
	  
		if not arming:is_armed() then -- setting the land location after landing
				
			if (distance_home > 5) then
			
				bool_land = false
						
				checkpoint_1 = curr_loc
						
				gcs:send_text(0, "Got charging pad 1 location ")
						
			end
					
		else

			if (distance_home > 5) then
					
				bool_land = true
					
				if checkpoint_1 then
			
					stage = stage + 1
			
				end
	  
			end
					
		end
		
	  end

	elseif (stage == 2) then
	
		if home and curr_loc then
		
			distance_safe = checkpoint_1:get_distance(curr_loc)
			
			if (distance_safe > 5) then
	  
				local vec_from_home = home:get_distance_NED(curr_loc)
		
				local distance_home = curr_loc:get_distance(home)
				
				if not arming:is_armed() then -- setting the land location after landing
				
					if (distance_home > 5) then
			
						bool_land = false
						
						checkpoint_2 = curr_loc
						
						gcs:send_text(0, "Got charging pad 2 location ")
						
					end
					
				else

					if (distance_home > 5) then
					
						bool_land = true
					
						if checkpoint_2 then
			
							stage = stage + 1
			
						end
	  
					end
					
				end
				
			end
			
		end	
	
	elseif (stage == 3) then  --stage 2: monitoring battery
	
		SOC_current = current_percentage(SOC_current)
		
		n = n + 1 -- for calculating average for velocity
		
		velocity_avg = (velocity_avg + drone_velocity())/n  -- for calculating average velocity in m/s
		
		tof = tof + 0.1 -- for calculating time of flight in seconds
		
		distance_1 = checkpoint_1:get_distance(curr_loc)
			
		distance_2 = checkpoint_2:get_distance(curr_loc)
			
			if distance_1 < distance_2 then
				
				distance = distance_1
				
				pad_location =  1
				
			else
				
				distance = distance_2
				
				pad_location = 2
				
			end	
		
		rem_distance = soc_distance(SOC_current, tof, velocity_avg)
		
		gcs:send_text(0, "Current distance: " .. tostring(rem_distance))
	  
		if ((rem_distance + safe_dist) <= distance) then  -- monitoring SOC while in auto
	  
			vehicle:set_mode(copter_guided_mode_num)
		
			stage = stage + 1
	  
			gcs:send_text(0, "finished square, going to charging pad")
			
		end
		
		
	elseif (stage == 4) then
	  
	  if home and curr_loc then
	  
		local vec_from_home = home:get_distance_NED(curr_loc)
		
		if (pad_location == 1) then
		
			vehicle:set_target_location(checkpoint_1)
		
		elseif (pad_location == 2) then
		
			vehicle:set_target_location(checkpoint_2)
		
		end
		
		gcs:send_text(0, "finished square, landing on charging pad")
		
		if (math.abs(vec_from_home:z()) < 1) then  
			
				stage = stage + 1
			
		end
		
	  end
	
	elseif (stage == 5) then  -- after landing if vehicle is charged then set to auto mode

	  SOC_charging = drone_voltage_SOC()
	  
	  if (SOC_charging >= 90) then  -- monitoring SOC while charging
		
		vehicle:set_mode(copter_auto_mode_num)
		
		battery:reset_remaining(0, SOC_charging)
		
		velocity_avg = 0
	
		n = 0
		
		tof = 0

		stage = 3
		
	  end
	  
    end
	
  end

  return update, 100
  
end

return update()