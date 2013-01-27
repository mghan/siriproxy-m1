require 'cora'

  # /i means ignore case
  def deviceCrossReference(deviceName)

    if (deviceName.match(/office/i))
    return "C14" # Office Lights

    # elsif !!!!
    elsif  (deviceName.match(/kitchen/i))
    return "A02" # Kitchen Can

    elsif  (deviceName.match(/(sink|sync)/i))
    return "D13" # Kitchen Sink

    elsif  (deviceName.match(/counter/i))
    return "D11" # Kitchen Accent

    elsif  (deviceName.match(/(bedroom|bed room)/i))
    return "A12" # Master Bedroom

    elsif  (deviceName.match(/(down stairs|downstairs)/i))
    return "B14" # Lower Hall Cans

    elsif  (deviceName.match(/(family|media)/i))
    return "C04" # Family Cans

    elsif  (deviceName.match(/powder/i))
    return "B16" # Powder Lights

    elsif  (deviceName.match(/fireplace/i))
    return "B11" # Fireplace

    elsif  (deviceName.match(/deck/i))
    return "A06" # Deck Lights

    elsif  (deviceName.match(/living/i))
    return "A09" # Living Cans

    elsif  (deviceName.match(/accent/i))
    return "A10" # Living Accent

    elsif  (deviceName.match(/(laundry|utility)/i))
    return "A11" # Utility Lights

    elsif  (deviceName.match(/pantry/i))
    return "B03" # Pantry Light

    elsif  (deviceName.match(/outside/i))
    return "C01" # Ext Front Light

    elsif  (deviceName.match(/landscape/i))
    return "D01" # Landscape Light

    elsif  (deviceName.match(/garage/i))
    return "D04" # Garage Lights

    elsif  (deviceName.match(/master deck/i))
    return "D08" # Master Deck

    elsif  (deviceName.match(/pendant/i))
    return "D10" # Dine Pendant

    elsif  (deviceName.match(/dining table/i))
    return "A04" # Dining Table Cans

    elsif  (deviceName.match(/dining wall/i))
    return "A05" # Dining Accent

    elsif  (deviceName.match(/(foyer|entry)/i))
    return "E06" # Foyer Vertigo

    elsif  (deviceName.match(/wine/i))
    return "C09" # Wine Lights

    else
    return 0
    end
    return deviceName
  end


