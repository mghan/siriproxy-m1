require 'cora'


  def deviceCrossReference(deviceName)


    if (deviceName.match(/all lights|all scene/i))

      @dimmable = 0 #must be set to 1 in order to recognize dimmable devices
                    #otherwise, not necessary or set to 0.

    return "8730" #can be set to either a scene (#####) or a device (##%20##%20##%20#)
    #return 24409             #if set to a device, the %20 must be used in place of the space and
                              #you must use quotation marks around it ex. return "12%2034%2056%207"
                              #NOTE: If any section of your device address has a leading zero in it,
                              # it must be left off from the settings i.e. 1A.0B.9F = 1A %20 B %20 9F %20 1


    elsif (deviceName.match(/attic lights|attic scene/i))
    return "18595"

    elsif (deviceName.match(/away mode|away scene/i))
    return "4597"

    elsif (deviceName.match(/exterior lights|exterior scene/i))
    return "32377"

    elsif (deviceName.match(/garage lights|garage scene/i))
    return "27356"

    elsif (deviceName.match(/home mode|home scene/i))
    return "39198"

    elsif (deviceName.match(/kitchen lights|kitchen scene/i))
    return "20304"

    elsif (deviceName.match(/landing lights|landing scene/i))
    return "6489"

    elsif (deviceName.match(/living lights|living scene/i))
    return "19496"

    elsif (deviceName.match(/master lights|master scene/i))
    return "25061"

    elsif (deviceName.match(/movie mode|movie scene/i))
    return "26974"

    elsif (deviceName.match(/party mode|party scene/i))
    return "25568"

    elsif (deviceName.match(/stairwell lights|stairwell scene/i))
    return "32068"

    elsif (deviceName.match(/theater lights|theater scene/i))
    return "44403"

    elsif (deviceName.match(/theather ceiling/i))
    return "59332"

    elsif (deviceName.match(/theather drapes/i))
    return "37131"

    elsif (deviceName.match(/theather lamp/i))
    return "61694"

    elsif (deviceName.match(/theather valance/i))
    return "8000"

    else 
    return 0
    end
    return deviceName
  end

