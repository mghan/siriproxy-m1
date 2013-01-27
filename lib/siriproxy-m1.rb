require 'siri_objects'
require 'cora'
require 'pp'
require 'devices'
require 'm1'

class SiriProxy::Plugin::M1 < SiriProxy::Plugin
  def initialize(config)
    #if you have custom configuration options, process them here!
  end


  # How to Update this Plugin
  # Copy the entire siriproxy-m1 directory to both
  #   /usr/local/rvm/gems/ruby-1.9.3-p362@SiriProxy/gems/siriproxy-0.3.2/plugins
  #   and
  #   /root/SiriProxy/plugins
  # From the /root/SiriProxy directory execute
  #   siriproxy bundle
  #   bundle install
  #   siriproxy server


  # Help

  listen_for(/help/i) { help_me }

  # Say it all at once, the text output formatting is better..
  def help_me
  say "Commands\nTurn On -name-\nTurn Off -name-\nSet -name- to -level- %\nSet Heating temp\nSet Cooling temp\nI'm Cold\nI'm Warm\nInside Temperature\nOutside Temperature\nWine Temperature\nGood Night\nGood Morning\nWatch Movie\nOpen/Close Garage\nMaster Suite Off\nDownstairs Off\nMaster Bath On/Off\nKitchen On/Off/Full\nDining Room On/Off\nLiving Room On/Off\nAccent On\nLet's Party!", spoken: "I recognize these commands. Turn On device. Turn Off device. Set device to level. Set Heating. Set Cooling. I'm Cold - to increase heat. I'm Warm - to decrease heat. Inside Temperature. Outside Temperature. Wine Temperature. Good Night. Good Morning. Watch Movie. Open/Close Garage. Master Suite Off. Downstairs Off. Master Bath On Off. Kitchen On Off Full. Dining Room On Off. Living Room On Off. Accent On. Let's Party!"
    request_completed
  end

  # Poor text formatting as each phrase is a separate message
  def help_me_old
    say "Commands",                 spoken: "I know the following commands"
    say "Turn On -name-",           spoken: "Turn On device"
    say "Turn Off -name-",          spoken: "Turn Off device"
    say "Set -name- to -level- %",  spoken: "Set device to level"
    say "Set Heating temp",         spoken: "Set Heating"
    say "Set Cooling temp",         spoken: "Set Cooling"
    say "I'm Cold",                 spoken: "I'm Cold - to increase heat setting"
    say "I'm Warm",                 spoken: "I'm Warm - to decrease heat setting"
    say "Inside Temperature"
    say "Outside Temperature"
    say "Wine Temperature"
    say "Good Night"
    say "Good Morning"
    say "Watch Movie"
    say "Open/Close Garage"
    say "Master Suite Off"
    say "Downstairs Off"
    say "Master Bath On/Off"
    say "Kitchen On/Off/Full"
    say "Dining Room On/Off"
    say "Living Room On/Off"
    say "Accent On"
    say "Let's Party!"
    request_completed
  end


  # Macros ------------------------------------

  listen_for /master(?: suite)? off/i do
    say "Shutting Master Suite Off"
    request_completed
    Thread.new {
      m1_device_off "A12" # Master Bedroom
      m1_device_off "A13" # Master Vanity
      m1_device_off "A14" # Master Bath Can
      m1_device_off "A15" # Master Shower
      m1_device_off "A16" # Master Closet
      m1_device_off "B01" # Master Toilet
      # m1_device_off "B10" # Master Outlet - automatic
      m1_device_off "D08" # Master Deck
    }
  end

  listen_for /master bath on/i do
    say "Master Bath On"
    request_completed
    Thread.new {
      m1_device_dim "A13", 99 # Master Vanity
      m1_device_dim "A14", 80 # Master Bath Can
      m1_device_dim "A15", 90 # Master Shower
      m1_device_dim "A16", 99 # Master Closet
      m1_device_dim "B01", 75 # Master Toilet
    }
  end

  listen_for /master bath off/i do
    say "Shutting Master Bath Off"
    request_completed
    Thread.new {
      m1_device_off "A13" # Master Vanity
      m1_device_off "A14" # Master Bath Can
      m1_device_off "A15" # Master Shower
      m1_device_off "A16" # Master Closet
      m1_device_off "B01" # Master Toilet
    }
  end



  listen_for(/(down stairs|downstairs) off/i) { downstairs_off }

  def downstairs_off
    say "Shutting downstairs off"
    request_completed
    Thread.new {
      m1_device_off "C04" # Family Cans
      m1_device_off "B14" # Lower Hall Cans
      m1_device_off "B12" # Guest Bath
      m1_device_off "B15" # Guest Bedroom
      m1_device_off "C09" # Wine Lights
      m1_device_off "C14" # Office Lights
      m1_device_off "C15" # Office Lamp
    }
  end


  listen_for(/let's party/i) { party_on }
  listen_for(/party time/i) { party_on }

  def party_on
    response = ask "Are you ready to Party?"
    if (response =~ /yes|sure|yep|yeah|whatever|why not|ok|I guess/i)
      say "Let the Party Begin!"
      request_completed
      Thread.new {
        m1_write "09tn00900" # Activate task 9: Party
        m1_device_dim "A02", 60 # Kitchen Can
        m1_device_dim "D11", 60 # Kitchen Accent
        m1_device_dim "A03", 70 # Kitchen Hall
        m1_device_dim "A04", 40 # Dining Table
        m1_device_dim "A05", 50 # Dining Accent
        m1_device_dim "A09", 80 # Living Cans
        m1_device_dim "A10", 50 # Living Accent
        m1_device_dim "D10", 40 # Dine Chandelier
        m1_device_dim "D13", 60 # Kitchen Sink
        m1_device_dim "E06", 90 # Foyer Vertigo
        m1_device_on  "D01"     # Landscape Light
      }
    else
      say "You could have said 'yes'!"
      request_completed
    end
  end


  listen_for(/accent on/i) { accent_on }

  def accent_on
    say "Accenting now"
    request_completed
    Thread.new {
      m1_device_dim "A02", 25 # Kitchen Can
      m1_device_dim "D11", 30 # Kitchen Accent
      m1_device_dim "A03", 40 # Kitchen Hall
    # m1_device_dim "A05", 25 # Dining Accent
      m1_device_dim "A09", 30 # Living Cans
      m1_device_dim "A10", 25 # Living Accent
      m1_device_dim "D13", 25 # Kitchen Sink
      m1_device_dim "E06", 50 # Foyer Vertigo
      m1_device_off "A05"     # Dining Accent
      m1_device_off "D10"     # Dine Chandelier
      m1_device_off "A04"     # Dining Table
    }
  end


  listen_for(/dining(?: room)? on/i) { dine_on }

  def dine_on
    say "Dining Room On"
    request_completed
    Thread.new {
      m1_device_dim "A05", 50 # Dining Accent
      m1_device_dim "D10", 50 # Dine Chandelier
      m1_device_dim "A04", 70 # Dining Table
    }
  end


  listen_for(/dining(?: room)? off/i) { dine_off }

  def dine_off
    say "Shutting Dining Room Off"
    request_completed
    Thread.new {
      m1_device_off "A05"     # Dining Accent
      m1_device_off "D10"     # Dine Chandelier
      m1_device_off "A04"     # Dining Table
    }
  end


  listen_for(/living(?: room)? on/i) { living_on }

  def living_on
    say "Living Room On"
    request_completed
    Thread.new {
      m1_device_dim "A09", 85 # Living Cans
      m1_device_dim "A10", 60 # Living Accent
    }
  end


  listen_for(/living(?: room)? off/i) { living_off }

  def living_off
    say "Shutting Living Room Off"
    request_completed
    Thread.new {
      m1_device_off "A09" # Living Cans
      m1_device_off "A10" # Living Accent
    }
  end


  listen_for(/kitchen on/i) { kitchen_on }

  def kitchen_on
    say "Kitchen On"
    request_completed
    Thread.new {
      m1_device_dim "A02", 75 # Kitchen Can
      m1_device_dim "D11", 75 # Kitchen Accent
      m1_device_dim "A03", 75 # Kitchen Hall
      m1_device_dim "D13", 60 # Kitchen Sink
      m1_device_dim "B03", 50 # Pantry Light
    }
  end


  listen_for(/kitchen (task|full)/i) { kitchen_task }

  def kitchen_task
    say "Kitchen On Full"
    request_completed
    Thread.new {
      m1_device_dim "A02", 99 # Kitchen Can
      m1_device_dim "D11", 99 # Kitchen Accent
      m1_device_dim "A03", 99 # Kitchen Hall
      m1_device_dim "D13", 99 # Kitchen Sink
      m1_device_dim "B03", 99 # Pantry Light
    }
  end


  listen_for(/kitchen off/i) { kitchen_off }

  def kitchen_off
    say "Shutting Kitchen Off"
    request_completed
    Thread.new {
      m1_device_off "A02" # Kitchen Can
      m1_device_off "D11" # Kitchen Accent
      m1_device_off "A03" # Kitchen Hall
      m1_device_off "D13" # Kitchen Sink
      m1_device_off "B03" # Pantry Light
    }
  end


  # Thermostat --------------------------------

  listen_for(/temperature.*inside/i) { show_stat_temp }
  listen_for(/temp.*inside/i) { show_stat_temp }
  listen_for(/inside.*temperature/i) { show_stat_temp }
  listen_for(/inside.*temp/i) { show_stat_temp }
  listen_for(/temperature.*in here/i) { show_stat_temp }
  listen_for(/temp.*in here/i) { show_stat_temp }

  def show_stat_temp
    current_temp = get_m1_tstat_temp.to_i
    say "The current temperature is #{current_temp} degrees"
    request_completed
  end


  # Returns mode string
  def tstat_mode_say mode
      if    mode == TMODE_OFF
        return "Off"
      elsif mode == TMODE_HEAT
        return "Heating"
      elsif mode == TMODE_COOL
        return "Cooling"
      elsif mode == TMODE_AUTO
        return "Auto"
      elsif mode == TMODE_EMER
        return "Emergency Heating"
      else return "Error"
      end
  end

  # Full Report
  listen_for(/what are(?: the)? thermostat(?:s)? settings/i) { thermostat_status_all }
  listen_for(/what is(?: the)? thermostat(?:s)? set(?:tings)?/i) { thermostat_status_all }

  def thermostat_status_all
    # Thread.new {
      # say "Checking the status of the thermostat."
      mode, fan, temp, heat_set, cool_set = get_m1_tstat_status
      say_mode = tstat_mode_say(mode)
      say "Mode is #{say_mode}\nHeating set: #{heat_set}F\nCooling set: #{cool_set}F\nCurrent temp: #{temp}F", spoken: "The mode is #{say_mode}. The heating setpoint is #{heat_set} degrees. The cooling setpoint is #{cool_set} degrees. The current temperature is #{temp} degrees"
      request_completed
    # }
  end

  # Report only what is relevant
  listen_for(/thermostat.*status/i) { thermostat_status }
  listen_for(/status.*thermostat/i) { thermostat_status }
  listen_for(/what is the heat(?:ing)? set(?:ting)?/i) { thermostat_status }
  listen_for(/what is the cool(?:ing)? set(?:ting)?/i) { thermostat_status }
  listen_for(/what is the air(?:-)?condition(ing|er) set(?:ting)?/i) { thermostat_status }

  def thermostat_status
    # Thread.new {
      # say "Checking the status of the thermostat."
      mode, fan, temp, heat_set, cool_set = get_m1_tstat_status
      if    mode == TMODE_OFF
      say "Mode is Off\nCurrent temp: #{temp}F", spoken: "The mode is Off.The current temperature is #{temp} degrees"
      elsif mode == TMODE_HEAT
      say "Mode is Heating\nHeating set: #{heat_set}F\nCurrent temp: #{temp}F", spoken: "The heating setpoint is #{heat_set} degrees. The current temperature is #{temp} degrees"
      elsif mode == TMODE_COOL
      say "Mode is Cooling\nCooling set: #{cool_set}F\nCurrent temp: #{temp}F", spoken: "The cooling setpoint is #{cool_set} degrees. The current temperature is #{temp} degrees"
      elsif mode == TMODE_AUTO
      say "Mode is Auto\nHeating set: #{heat_set}F\nCooling set: #{cool_set}F\nCurrent temp: #{temp}F", spoken: "The mode is Auto. The heating setpoint is #{heat_set} degrees. The cooling setpoint is #{cool_set} degrees. The current temperature is #{temp} degrees"
      elsif mode == TMODE_EMER
      say "Emergency Heating\nHeating set: #{heat_set}F\nCurrent temp: #{temp}F", spoken: "Emergency Heating. The heating setpoint is #{heat_set} degrees. The current temperature is #{temp} degrees"
      else return "Error"
      end
      request_completed
    # }
  end


  listen_for(/set(?: the)? heat.*([0-9]{2})/i) { |temp| set_heating(temp) }
  listen_for(/set(?: the)? heating.*([0-9]{2})/i) { |temp| set_heating(temp) }

  # Returns setpt and success flag
  def attempt_set_heating(heat_set)
    temp_set = heat_set.to_i
    # Ignore 2 when we said: 'set heat to 50' is it's interpreted as 'set heat 250'
    if (temp_set > 199) and (temp_set < 300) then
      temp_set %= 100 # toss the misinterpreted 2
    end
    # sanity
    if (temp_set < 85) and (temp_set > 50)
      m1_tstat_heat temp_set
      return temp_set, true
    else
      return temp_set, false
    end
  end

  def set_heating(heat_set)
    try_set, success = attempt_set_heating(heat_set)
    if success == true
      say "Heat set to #{try_set}F",  spoken: "Ok, the heat is set to #{try_set} degrees."
    else
      say "Oh no! I can't set the heat to #{try_set} degrees"
    end
    request_completed
  end


  listen_for(/set(?: the)? air conditioning.*([0-9]{2})/i) { |temp| set_cooling(temp) }
  listen_for(/set(?: the)? cooling.*([0-9]{2})/i) { |temp| set_cooling(temp) }

  # Returns setpt and success flag
  def attempt_set_cooling(cool_set)
    temp_set = cool_set.to_i
    # Ignore 2 when we said: 'set cool to 50' is it's interpreted as 'set cool 250'
    if (temp_set > 199) and (temp_set < 300) then
      temp_set %= 100 # toss the misinterpreted 2
    end
    # sanity
    if (temp_set < 85) and (temp_set > 50)
      m1_tstat_cool temp_set
      return temp_set, true
    else
      return temp_set, false
    end
  end


  def set_cooling(cool_set)
    try_set, success = attempt_set_cooling(cool_set)
    if success == true
        say "Cool set to #{try_set}F",  spoken: "Ok, the air conditioning is set to #{try_set} degrees."
      # current_temp = get_m1_tstat_temp.to_i
      # say "The current temperature is #{current_temp} degrees"
    else
      say "What! I can't set the air conditioning to #{temp_set} degrees"
    end
    request_completed
  end


  listen_for(/(I'm|I am)(?: so)? cold/i) { bump_heating }

  def bump_heating
    response = ask "Shall I raise the heat by 2 degrees?"
    if (response =~ /(yes|sure|yep|yeah|whatever|why not|ok|I guess)/i)
        heat_set = get_m1_tstat_heat.to_i
        heat_set = heat_set + 2
        try_set, success = attempt_set_heating(heat_set)
        if success == true
          say "Heat set to #{try_set}F",  spoken: "Ok, I raised the heat to #{try_set} degrees."
        #  current_temp = get_m1_tstat_temp.to_i
        #  say "Current temp: #{current_temp}F",  spoken: "The current temperature is #{current_temp} degrees"
        else
          say "Oh no! I can't set the heat to #{try_set} degrees"
        end
        request_completed
    else
      say "You could try dressing warmer!"
      request_completed
    end
  end


  listen_for(/(I'm|I am)(?: so)? hot/i) { drop_heating }
  listen_for(/(I'm|I am)(?: so)? warm/i) { drop_heating }

  def drop_heating
    response = ask "Shall I lower the heat by 2 degrees?"
    if (response =~ /(yes|sure|yep|yeah|whatever|why not|ok|I guess)/i)
      heat_set = get_m1_tstat_heat.to_i
      heat_set = heat_set - 2
      try_set, success = attempt_set_heating(heat_set)
      if success == true
        say "Heat set to #{try_set}F",  spoken: "Ok, I lowered the heat to #{try_set} degrees."
       # current_temp = get_m1_tstat_temp.to_i
       # say "Current temp: #{current_temp}F",  spoken: "The current temperature is #{current_temp} degrees"
      else
        say "Oh no! I can't set the heat to #{try_set} degrees"
      end
      request_completed
    else
      say "Try a glass of ice water instead"
      request_completed
    end
  end


  # Devel
  # listen_for(/set thermostat.*([0-9]{2})/i) { |temp| set_thermostat(temp) }
  # This should check the current mode for heat or cool (but not auto - it's ambiguous)


  # Show Temperatures ------------------------------------------

  # Temperature IDs 15=Outside 16=Wine Room

  listen_for(/wine.*temperature/i) { show_wine_temp }
  listen_for(/wine.*temp/i) { show_wine_temp }

  def show_wine_temp
    temp = get_m1_temp 16
    say "Wine Room is #{temp}F",  spoken: "The wine room temperature is #{temp} degrees"
    request_completed
  end


  listen_for(/outside.*temperature/i) { show_outside_temp }
  listen_for(/outside.*temp/i) { show_outside_temp }

  def show_outside_temp
    temp = get_m1_temp 15
    say "Outside is #{temp}F",  spoken: "The outside temperature is #{temp} degrees"
    request_completed
  end


  # Tasks --------------------------------------

  listen_for /(good night|bed time)/i do
    say "Good Night!",  spoken: "I am securing and shutting down the house now. Good night!"
    m1_write "09tn00400" # Activate task 4: Good Night
    request_completed
  end


  listen_for /(good morning|wake up)/i do
    say "Good Morning!"
    m1_write "09tn00500" # Activate task 5: Good Morning
    request_completed
  end


  listen_for /watch(?: a)? movie/i do
    say "Let's watch a movie!"
    m1_write "09tn00700" # Activate task 7: Movie
    request_completed
  end


  # "Close garage" - only if opened
  listen_for (/close(?: the)? garage/i)  { close_garages }
  listen_for (/close all(?: of)?(?: the)? (garage|garages|garage doors)/i)  { close_garages}
  listen_for (/close both(?: of)?(?: the)? (garage|garages|garage doors)/i)  { close_garages}

  def close_garages
    response = ask "Make sure nothing is in the way. Shall I Close the Garage?"
    if (response =~ /(yes|sure|yep|yeah|ok)/i)
      say "Closing Garage Door"
      m1_write "09tn01800" # Activate task 18: Close Garage
      request_completed
    else
      say "Oops. I won't do that."
      request_completed
    end
  end


  # "Open garage" - only if disarmed
  listen_for /open(?: the)? (garage|pod bay doors)/i do
    response = ask "Shall I Open the Garage?"
    if (response =~ /(yes|sure|yep|yeah|ok)/i)
      say "Opening Garage Door"
      m1_write "09tn01900" # Activate task 19: Open Garage West
      request_completed
    else
      say "I'm sorry Dave. I'm afraid I can't do that."
      request_completed
    end
  end


  # Alarm Control -----------------------------------

  # Arm Stay
  listen_for /arm stay/i do
    response = ask "Shall I Arm Stay?"
    if (response =~ /(yes|sure|yep|yeah|whatever|why not|ok|I guess)/i)
      say "Arming Stay"
      m1_arm_stay
      request_completed
    else
      say "Canceled!"
      request_completed
    end
  end

  # Arm Away
  listen_for /arm away/i do
    response = ask "Shall I Arm Away?"
    if (response =~ /(yes|sure|yep|yeah|ok)/i)
      say "Arming Away"
      m1_arm_away
      request_completed
    else
      say "Canceled!"
      request_completed
    end
  end

  # Leaving|Leave House
  listen_for /(leaving|leave)(?: the)? house/i do
    response = ask "Ready to leave?"
    if (response =~ /(yes|sure|yep|yeah|ok)/i)
      say "Arming Away"
      m1_write "09tn02000" # Activate task 20: Leave House
      request_completed
    else
      say "Canceled!"
      request_completed
    end
  end

  # "Alarm Status" or "Give me a Security Report" or ..."the Security Status" etc
  listen_for(/(alarm|m 1|m1|and one|security) (status|report)/i) { alarm_status }

  def armed_status_msg(armed_status)
    if    armed_status == ARM_STATUS_DISARM
      return "Disarmed"
    elsif armed_status == ARM_STATUS_AWAY
      return "Armed Away"
    elsif armed_status == ARM_STATUS_STAY
      return "Armed Stay"
    elsif armed_status == ARM_STATUS_STAYINS
      return "Armed Stay Instant"
    elsif armed_status == ARM_STATUS_NITE
      return "Armed Night"
    elsif armed_status == ARM_STATUS_NITEINS
      return "Armed Night Instant"
    else return "Error"
    end
  end

  def arm_up_msg(arm_up_state)
    if     arm_up_state == ARMUP_NOTRDY
      return "Not Ready"
    elsif  arm_up_state == ARMUP_READY
      return "Ready"
    elsif  arm_up_state == ARMUP_RDYFRC
      return "Forced Zone"
    elsif  arm_up_state == ARMUP_EXIT
      return "Exit Countdown"
    elsif  arm_up_state == ARMUP_FULL
      return "Fully Armed"
    elsif  arm_up_state == ARMUP_FULLVIO
      return "Force Zone Violated"
    elsif  arm_up_state == ARMUP_BYPASS
      return "Zone Bypassed"
    else return "Error"
    end
  end

  def alarm_state_msg(alarm_state)
    if     alarm_state == ALM_STATE_NONE
      return "No Alarms Active"
    elsif  alarm_state == ALM_STATE_ENTER
      return "Entrance Delay"
    elsif  alarm_state == ALM_STATE_ABORT
      return "Abort Delay"
    # Otherwise we're in Full Alarm
    else return "System in Full Alarm"
    end
  end

  # get_m1_alarm_status
  # Returns armed_status, arm_up_state, alarm_state  for Area 1
  def alarm_status
    armed_status, arm_up_state, alarm_state = get_m1_alarm_status
    say_armed = armed_status_msg(armed_status)
    say_arm_up = arm_up_msg(arm_up_state)
    say_alarm_state = alarm_state_msg(alarm_state)
    say "#{say_armed}, #{say_arm_up}\n#{say_alarm_state}", spoken: "Alarm is #{say_armed}, #{say_arm_up} with #{say_alarm_state}"
    request_completed
  end


  # Device Control ----------------------------------

  listen_for (/turn on(?: the)? (.*)/i) { |device| turn_on(device) }

  # Don't use this syntax, it can be ambiguous
# listen_for (/turn (.*) on/i) { |device| turn_on(device) }

  def turn_on(device)
    deviceAddress = deviceCrossReference(device)
    puts device.capitalize+" On"
    # puts deviceAddress
    if deviceAddress != 0
      say "Turning on #{device.capitalize}",  spoken: "OK. I'm turning on #{device} now"
      m1_device_on deviceAddress
    else say "Can't control #{device.capitalize}", spoken: "I'm sorry, but I am not programmed to control #{device}"
    end
    request_completed
  end

  listen_for (/turn off(?: the)? (.*)/i) { |device| turn_off(device) }

  # Don't use this syntax, it can be ambiguous
# listen_for (/turn (.*) off/i) { |device| turn_off(device) }

  def turn_off(device)
    deviceAddress = deviceCrossReference(device)
    puts device.capitalize+" Off"
    # puts deviceAddress
    if deviceAddress != 0
      say "Turning off #{device.capitalize}",  spoken: "OK. I'm turning off #{device} now."
      m1_device_off deviceAddress
    else say "Can't control #{device.capitalize}", spoken: "I'm sorry, but I am not programmed to control #{device}"
    end
    request_completed
  end


# listen_for (/(dim|damn|jim|jimmer|set|set dimmer on|set(?: the)? level on) (.*)(?: level)? ([0-9,]*[0-9])/i) { |keywords, device, level| dimmer(device, level) }
  listen_for (/set(?: the)? (.*)(?: level)?(?: to)? ([0-9,]*[0-9])(?: percent)?/i) { |device, level| dimmer(device, level) }

  def dimmer(device, level)
    device = device.sub(" to", "")
    device = device.sub(" level", "")
    deviceAddress = deviceCrossReference(device)
    deviceLevel = level.to_i
    puts device.capitalize+" "+level+"%"
    # puts level
    #puts deviceAddress
    # Ignore 2 when we said: 'dim office to 50' is it's interpreted as 'dim office 250'
    if (deviceLevel > 199) and (deviceLevel < 300) then
      deviceLevel %= 100 # toss the misinterpreted 2
    end
    # sanity
    if (deviceLevel < 101) and (deviceLevel > -1) and deviceAddress != 0
      say "Setting #{device.capitalize} to #{deviceLevel}%", spoken: "OK. I'm setting #{device} to #{deviceLevel}% now"
      m1_device_dim deviceAddress, deviceLevel
      # say "Dim complete"
    else say "Can't control #{device.capitalize}", spoken: "I'm sorry, but I am not programmed to control #{device}"
    end
    request_completed
  end


  # Example Code --------------------------------

  # /i means ignore case
  listen_for /test siri proxy/i do
    say "Siri Proxy is up and running!" #say something to the user!

    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  #Demonstrate that you can have Siri say one thing and write another"!
  listen_for /you don't say/i do
    say "Sometimes I don't write what I say", spoken: "Sometimes I don't say what I write"
    request_completed
  end

  #demonstrate state change
  listen_for /siri proxy test state/i do
    set_state :some_state #set a state... this is useful when you want to change how you respond after certain conditions are met!
    say "I set the state, try saying 'confirm state change'"
    request_completed
  end

  listen_for /confirm state change/i, within_state: :some_state do #this only gets processed if you're within the :some_state state!
    say "State change works fine!"
    set_state nil #clear out the state!
    request_completed
  end

  #demonstrate asking a question
  listen_for /siri proxy test question/i do
    response = ask "Is this thing working?" #ask the user for something

    if(response =~ /yes/i) #process their response
      say "Great!"
    else
      say "You could have just said 'yes'!"
    end

    request_completed
  end

  #demonstrate capturing data from the user (e.x. "Siri proxy number 15")
  listen_for /siri proxy number ([0-9,]*[0-9])/i do |number|
    say "Detected number: #{number}"
    request_completed
  end

  #demonstrate capturing data from the user (e.x. "testing number 15 and 27")
  listen_for /testing number ([0-9,]*[0-9]) and ([0-9,]*[0-9])/i do |number, number2|
    say "Detected numbers #{number} and #{number2} "
    request_completed
  end


  #demonstrate injection of more complex objects without shortcut methods.
  listen_for /test map/i do
    add_views = SiriAddViews.new
    add_views.make_root(last_ref_id)
    map_snippet = SiriMapItemSnippet.new
    map_snippet.items << SiriMapItem.new
    utterance = SiriAssistantUtteranceView.new("Testing map injection!")
    add_views.views << utterance
    add_views.views << map_snippet

    #you can also do "send_object object, target: :guzzoni" in order to send an object to guzzoni
    send_object add_views #send_object takes a hash or a SiriObject object

    request_completed
  end
end
