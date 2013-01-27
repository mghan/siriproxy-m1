# M1 Interface

#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
# M1 Doc (without checksums) -------------------------------------------

# Turn On C14        09pnC1400
# Turn Off C14       09pfC1400
# Dim C14 to 25%     11pcC140925tttt00  tttt=On  time in secs, range - 1 to 9999 decimal, 0 = continuous
# Dim C12 to 99%     11pcC120999tttt00  tttt=Off time in secs, range - 1 to 9999 decimal, 0 = continuous

# Read Temp 2        09st00200  Response  0CST00211000  = 50 deg = 110 - 60
# Read TStat1 Temp   09st20100  Response  0CST20107100  = 71 deg

# Read TStat1 Status 08tr0100   Response  13TRNNMHFTTHHCCRR00
#                                         NN - TStat # 01-16
#                                         M  - Mode 0=Off,1=Heat,2=Cool,3=Auto, 4=Emergency Heat
#                                         H  - Hold current temperature. 0=False, 1=True
#                                         F  - Fan 0=Fan Auto, 1=Fan turned on
#                                         TT - Current temperature, deg.F 0=invalid, 70=70F
#                                         HH - Heat setpoint 70=70F
#                                         CC - Cool setpoint 75=75F
#                                         RR - Relative humidity, 01 to 99%, 0 = invalid

# Set Heat           0Bts0172500   Set TStat 1 Heat to 72
# Set Cool           0Bts0175400   Set TStat 1 Cool to 75

# Arm Away           0Da11xxxxxx00   Area 1, xxxxxx = 6 digit code
# Arm Stay           0Da21xxxxxx00   Area 1, xxxxxx = 6 digit code
# Arm Vacation       0Da61xxxxxx00   Area 1, xxxxxx = 6 digit code

# Alarm Status       06as00   Response 1EASssssssssuuuuuuuuaaaaaaaa00
#                                      s = Array of 8 area armed status.
#                                          0=Disarmed, 1=Armed Away, 2=Armed Stay, 3=Armed Stay Instant, 4=Armed to Night, 5=Armed to Night Instant, 6=Armed to Vacation
#                                      u = Array of 8 area arm up state
#                                          0=Not Ready To Arm, 1=Ready To Arm, 2=Ready To Arm, but a zone is violated and can be Force Armed.
#                                          3=Armed with Exit Timer working, 4=Armed Fully, 5=Force Armed with a force arm zone violated, 6=Armed with a bypass
#                                      a = Array of 8 area alarm state.
#                                          0=No Alarm Active, 1=Entrance Delay is Active, 2=Alarm Abort Delay Active, 3 to B= Area is in Full Alarm, see ASCII alarm table

# Activate Task      09tn00200  Activate task 2

# Ask Output Status  06cs00    Response  D6CSxxxx...00
#                                        xxx = 208 "0"(Off) or "1"(On) chars


require 'socket'

# M1 IP Address & Port
M1_IP = '192.168.1.201'   # Replace with your M1's IP Address
M1_PORT = 2101
M1_ARMCODE = ######  # 6 digit M1 code.  Define the M1 user "Siri" as arm only



# Append checksum to M1 message
def m1_add_checksum(message)
  # calc the checksum
  chk = 0
  message.each_byte do |b|
    chk = (chk + b ) & 0xff
  end

  # two's compliment
  chk = 0x100 - chk

  # add leading zero
  #  if chk < 16
  #    chkstr='0'+chk.to_s(16)
  #  else
  #    chkstr=chk.to_s(16)
  #  end

  # format with leading zero
  chkstr = ("0"+chk.to_s(16)).slice(-2,2)

  # return as 2 digit uppercase hex string
  return message+chkstr.upcase
end

# my_msg = m1_add_checksum '09st20100'
# puts my_msg


# Query the M1.
# The response_template must be a 4 character string
# Example:  m1_read "09st20100", "0CST"
def m1_read(message, response_template)

  # Open Socket
  m1_s = TCPSocket.new M1_IP, M1_PORT

  # hard-coded
  # m1_s.send "09st20100BD\n", 0
  # line = m1_s.gets # Read lines from socket
  # puts line         # and print them

  m1_s.send (m1_add_checksum message)+"\n", 0

  # Note: the M1 periodically sends status & event messages.
  # We may not receive the response we are expecting right away
  # so we'll try a few times until we receive a match to our template.
  timeout = 0

  begin
    m1_resp = m1_s.readline # Read line from socket
    # puts m1_resp            # and print it
    timeout +=1;
  end while (response_template != m1_resp.byteslice(0,4)) or timeout > 3

  m1_s.close             # close socket when done

  return m1_resp

end

# my_msg = m1_read "09st20100", "0CST"
# puts my_msg


# Simply Send the command and return *any* response - aka Write-Only
# Example:  m1_write "09pfC1400"
def m1_write(message)

  # Open Socket
  m1_s = TCPSocket.new M1_IP, M1_PORT

  m1_s.send (m1_add_checksum message)+"\n", 0
  m1_resp = m1_s.readline # Read line from socket

  m1_s.close             # close socket when done

end


#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

# M1 Thermostat Control -----------------------------------

TMODE_OFF  = 0
TMODE_HEAT = 1
TMODE_COOL = 2
TMODE_AUTO = 3
TMODE_EMER = 4

TFAN_AUTO = 0
TFAN_ON   = 1

# Get current thermostat status
# Read TStat1 Status 08tr0100   Response  13TRNNMHFTTHHCCRR00
#                                         NN - TStat # 01-16
#                                         M  - Mode 0=Off,1=Heat,2=Cool,3=Auto, 4=Emergency Heat
#                                         H  - Hold current temperature. 0=False, 1=True
#                                         F  - Fan 0=Fan Auto, 1=Fan turned on
#                                         TT - Current temperature, deg.F 0=invalid, 70=70F
#                                         HH - Heat setpoint 70=70F
#                                         CC - Cool setpoint 75=75F
#                                         RR - Relative humidity, 01 to 99%, 0 = invalid
# Returns numeric values for  mode, fan, temp, heat_set, cool_set
# Return strings can be converted to a number with to_i
def get_m1_tstat_status

  m1_resp = m1_read "08tr0100", "13TR"
  return m1_resp.byteslice(6,1).to_i, m1_resp.byteslice(8,1).to_i, m1_resp.byteslice(9,2).to_i, m1_resp.byteslice(11,2).to_i, m1_resp.byteslice(13,2).to_i

end

# mode, fan, temp, heat_set, cool_set = get_m1_tstat_status
# puts mode, fan, temp, heat_set, cool_set


# Read TStat 1  09st20100  Response  0CST20107100  = 71 deg
# Returns a string (can be converted to a number with get_m1_tstat_temp.to_i
def get_m1_tstat_temp

  m1_resp = m1_read "09st20100", "0CST"
  return m1_resp.byteslice(8,2)

end

# puts get_m1_tstat_temp
# puts get_m1_tstat_temp.to_i


# Get current heating setpoint
# Read TStat1 Status 08tr0100  Response  13TRNNMHFTTHHCCRR00
# Returns a string (can be converted to a number with get_m1_tstat_heat.to_i
def get_m1_tstat_heat

  m1_resp = m1_read "08tr0100", "13TR"
  return m1_resp.byteslice(11,2)

end

# puts get_m1_tstat_heat
# puts get_m1_tstat_heat.to_i


# Get current cooling setpoint
# Read TStat1 Status 08tr0100  Response  13TRNNMHFTTHHCCRR00
# Returns a string (can be converted to a number with get_m1_tstat_cool.to_i
def get_m1_tstat_cool

  m1_resp = m1_read "08tr0100", "13TR"
  return m1_resp.byteslice(13,2)

end


# Set Heat  0Bts0172500   Set TStat 1 Heat to 72
def m1_tstat_heat(setpt)

  m1_write "0Bts01"+setpt.to_s+"500"

end

# Set Cool  0Bts0175400   Set TStat 1 Cool to 75
def m1_tstat_cool(setpt)

  m1_write "0Bts01"+setpt.to_s+"400"

end


# Get Temperatures

# Read Temp 2        09st00200  Response  0CST00211000  = 50 deg = 110 - 60
# Returns a string (can be converted to a number with get_m1_temp.to_i
def get_m1_temp(id)

  format_id = ("0"+id.to_s).slice(-2,2)
  m1_resp = m1_read "09st0"+format_id+"00", "0CST"

  # M1 returns temp + 60
  my_temp = m1_resp.byteslice(7,3).to_i - 60
  return my_temp

end


#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

# M1 "PLC" Z-Wave Interface ----------------------------------

# Example:  m1_device_on "C14"
def m1_device_on(id)

  m1_write "09pn"+id+"00"

end


# Example:  m1_device_off "C14"
def m1_device_off(id)

  m1_write "09pf"+id+"00"

end


# Dim device to a level
# Example:   m1_device_dim "C14", 50
def m1_device_dim(id, level)

  # For some reason values of 99 don't work as expected so we clip to 98
  if level > 98
    level = 98
  end
  if level < 0
    level = 0
  end

  # format with leading zero
  levstr = ("0"+level.to_s).slice(-2,2)

  m1_write "11pc"+id+"09"+levstr+"000000"

end


#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

# M1 Alarm Commands ----------------------------------

# Arm Stay           0Da21xxxxxx00   Area 1, xxxxxx = 6 digit code
def m1_arm_stay

  m1_write "0Da21"+M1_ARMCODE.to_s+"00"

end


# Arm Away           0Da11xxxxxx00   Area 1, xxxxxx = 6 digit code
def m1_arm_away

  m1_write "0Da11"+M1_ARMCODE.to_s+"00"

end


# Alarm Status       06as00   Response 1EASssssssssuuuuuuuuaaaaaaaa00
#                                      s = Array of 8 area armed status.
#                                      u = Array of 8 area arm up state
#                                      a = Array of 8 area alarm state.

ARM_STATUS_DISARM   = 0  # Disarmed
ARM_STATUS_AWAY     = 1  # Armed Away
ARM_STATUS_STAY     = 2  # Armed Stay
ARM_STATUS_STAYINS  = 3  # Armed Stay Instant
ARM_STATUS_NITE     = 4  # Armed to Night
ARM_STATUS_NITEINS  = 5  # Armed to Night Instant
ARM_STATUS_VACATION = 6  # Armed to Vacation

ARMUP_NOTRDY  = 0  # Not Ready To Arm
ARMUP_READY   = 1  # Ready To Arm
ARMUP_RDYFRC  = 2  # Ready To Arm, but a zone is violated and can be Force Armed
ARMUP_EXIT    = 3  # Armed with Exit Timer working
ARMUP_FULL    = 4  # Armed Fully
ARMUP_FULLVIO = 5  # Force Armed with a force arm zone violated
ARMUP_BYPASS  = 6  # Armed with a bypass

ALM_STATE_NONE  = 0  # No Alarm Active
ALM_STATE_ENTER = 1  # Entrance Delay is Active
ALM_STATE_ABORT = 2  # Alarm Abort Delay Active
ALM_STATE_FULL  = 3  # 3 to B = Area is in Full Alarm, see ASCII alarm table

# Returns armed_status, arm_up_state, alarm_state  for Area 1
def get_m1_alarm_status

  m1_resp = m1_read "06as00", "1EAS"
  return m1_resp.byteslice(4,1).to_i, m1_resp.byteslice(12,1).to_i, m1_resp.byteslice(20,1).to_i(16)

end



#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
# Get Output States ----------------------------

# Ask Output Status  06cs00    Response  D6CSxxxx...00
#                                        xxx = 208 "0"(Off) or "1"(On) chars

# Returns an integer 0 or 1 (off or on)
def get_m1_output(output)

  offset = output + 3   # 4-1 (0based)
  m1_resp = m1_read "06cs00", "D6CS"
  return m1_resp.byteslice(offset,1).to_i

end


