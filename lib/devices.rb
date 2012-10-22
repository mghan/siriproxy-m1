require 'cora'


  def deviceCrossReference(deviceName)


    if (deviceName.match(/all/i))

      @dimmable = 0 #must be set to 1 in order to recognize dimmable devices
                    #otherwise, not necessary or set to 0.

    return "8730" #can be set to either a scene (#####) or a device (##%20##%20##%20#)
    #return 24409             #if set to a device, the %20 must be used in place of the space and
                              #you must use quotation marks around it ex. return "12%2034%2056%207"
                              #NOTE: If any section of your device address has a leading zero in it,
                              # it must be left off from the settings i.e. 1A.0B.9F = 1A %20 B %20 9F %20 1


    elsif (deviceName.match(/attic/i))
    return "18595"

    elsif (deviceName.match(/away/i))
    return "4597"

    elsif (deviceName.match(/exterior|porch|driveway/i))
    return "32377"

    elsif (deviceName.match(/garage/i))
    return "27356"

    elsif (deviceName.match(/home/i))
    return "39198"

    elsif (deviceName.match(/kitchen/i))
    return "20304"

    elsif (deviceName.match(/landing/i))
    return "6489"

    elsif (deviceName.match(/living/i))
    return "19496"

    elsif (deviceName.match(/master/i))
    return "25061"

    elsif (deviceName.match(/movie/i))
    return "26974"

    elsif (deviceName.match(/party/i))
    return "25568"

    elsif (deviceName.match(/stairwell/i))
    return "32068"

    elsif (deviceName.match(/theater/i))
    return "44403"

    elsif (deviceName.match(/theater ceiling/i))
    return "59332"

    elsif (deviceName.match(/theater drapes/i))
    return "37131"

    elsif (deviceName.match(/theater lamp/i))
    return "61694"

    elsif (deviceName.match(/theater valance/i))
    return "8000"

    else 
    return 0
    end
    return deviceName
  end



