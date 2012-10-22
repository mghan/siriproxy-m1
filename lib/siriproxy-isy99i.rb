require 'uri'
require 'cora'
require 'httparty'
require 'rubygems'
require 'devices'
require 'siri_objects'
require 'cgi'

class SiriProxy::Plugin::Isy99i < SiriProxy::Plugin
  attr_accessor :isyip
  attr_accessor :isyid
  attr_accessor :isypw
  attr_accessor :elkcode
  attr_accessor :camip
  attr_accessor :camid
  attr_accessor :campw
  attr_accessor :webip
  
  def initialize(config)  
    self.isyip = config["isyip"]
    self.isyid = config["isyid"]
    self.isypw = config["isypw"]
    self.elkcode = config["elkcode"]
    self.camip = config["camip"]
    self.camid = config["camid"]
    self.campw = config["campw"]
    self.webip = config["webip"]
    @isyauth = {:username => "#{self.isyid}", :password => "#{self.isypw}"}
    @camauth = {:username => "#{self.camid}", :password => "#{self.campw}"}

end

  class Rest
    include HTTParty
    format :xml
  end

listen_for(/arm away/i) {arm_away}

listen_for(/arm stay/i) {arm_stay}

listen_for(/disarm alarm/i) {disarm_alarm}

listen_for(/open garage/i) {open_garage}

listen_for(/close garage/i) {close_garage}

listen_for(/ring doorbell/i) {ring_doorbell}

  listen_for (/turn on (.*)/i) do |device|
    deviceName = URI.unescape(device.strip)
    deviceAddress = deviceCrossReference(deviceName)
    puts "deviceName = #{deviceName}"
    puts "deviceAddress = #{deviceAddress}"
    if deviceAddress != 0
	say "OK. I am turning on #{deviceName} now."
	Rest.get("#{self.isyip}/rest/nodes/#{deviceAddress}/cmd/DON", :basic_auth => @isyauth)
    else say "I'm sorry, but I am not programmed to control #{deviceName}."
    end
    request_completed
  end

  listen_for (/turn off (.*)/i) do |device|
    deviceName = URI.unescape(device.strip)
    deviceAddress = deviceCrossReference(deviceName)
    puts "deviceName = #{deviceName}"
    puts "deviceAddress = #{deviceAddress}"
    if deviceAddress != 0
	say "OK. I am turning off #{deviceName} now."
	Rest.get("#{self.isyip}/rest/nodes/#{deviceAddress}/cmd/DOF", :basic_auth => @isyauth)
    else say "I'm sorry, but I am not programmed to control #{deviceName}."
    end
    request_completed
  end

  def arm_away
    say "OK. I am arming your security system to away mode."
    Rest.get("#{self.isyip}/rest/elk/area/1/cmd/arm?armType=1&code=#{self.elkcode}", :basic_auth => @isyauth)
	object = SiriAddViews.new
	object.make_root(last_ref_id)
	answer = SiriAnswer.new("Arming Station", [SiriAnswerLine.new('logo',"#{self.webip}/elk-kp2-away.png")])
	object.views << SiriAnswerSnippet.new([answer])
	send_object object
    request_completed 
  end

  def arm_stay
    say "OK. I am armimg your security system to stay mode."
    Rest.get("#{self.isyip}/rest/elk/area/1/cmd/arm?armType=2&code=#{self.elkcode}", :basic_auth => @isyauth)
	object = SiriAddViews.new
	object.make_root(last_ref_id)
	answer = SiriAnswer.new("Arming Station", [SiriAnswerLine.new('logo',"#{self.webip}/elk-kp2-stay.png")])
	object.views << SiriAnswerSnippet.new([answer])
	send_object object
    request_completed 
  end

  def disarm_alarm
    say "OK. I am disarming your security system."
    Rest.get("#{self.isyip}/rest/elk/area/1/cmd/disarm?code=#{self.elkcode}", :basic_auth => @isyauth)
	object = SiriAddViews.new
	object.make_root(last_ref_id)
	answer = SiriAnswer.new("Arming Station", [SiriAnswerLine.new('logo',"#{self.webip}/elk-kp2-disarmed.png")])
	object.views << SiriAnswerSnippet.new([answer])
	send_object object
    request_completed 
  end

  def open_garage
	# turn on garage scene to see the door
	Rest.get("#{self.isyip}/rest/nodes/27356/cmd/DON", :basic_auth => @isyauth)
	# push garage camera image to phone	
	object = SiriAddViews.new
	object.make_root(last_ref_id)
	answer = SiriAnswer.new("Garage Camera", [SiriAnswerLine.new('logo',"#{self.camip}/cgi/jpg/image.cgi")])
	object.views << SiriAnswerSnippet.new([answer])
	send_object object
	# check status of garage door
	check_status = Rest.get("#{self.isyip}/rest/elk/zone/14/query/voltage", :basic_auth => @isyauth).inspect
    	status = check_status.gsub(/^.*val\D+/, "")
   	status = status.gsub(/\D+\D+.*$/, "")
    	status_zone = status.to_f / 10
	# garage door is open
	if status_zone > 7.0
		say "Your garage door is already open, Cabrone."  
	else
		# open garage door
		say "OK. I am opening your garage door."
		Rest.get("#{self.isyip}/rest/elk/output/3/cmd/on?offTimerSeconds=2", :basic_auth => @isyauth)
	end
	# turn off garage scene	
	Rest.get("#{self.isyip}/rest/nodes/27356/cmd/DOF", :basic_auth => @isyauth)
    request_completed
  end

  def close_garage
	# turn on garage scene to see the door
	Rest.get("#{self.isyip}/rest/nodes/27356/cmd/DON", :basic_auth => @isyauth)
	# push garage camera image to phone	
	object = SiriAddViews.new
	object.make_root(last_ref_id)
	answer = SiriAnswer.new("Garage Camera", [SiriAnswerLine.new('logo',"#{self.camip}/cgi/jpg/image.cgi")])
	object.views << SiriAnswerSnippet.new([answer])
	send_object object
	# check status of garage door
	check_status = Rest.get("#{self.isyip}/rest/elk/zone/14/query/voltage", :basic_auth => @isyauth).inspect
    	status = check_status.gsub(/^.*val\D+/, "")
   	status = status.gsub(/\D+\D+.*$/, "")
    	status_zone = status.to_f / 10
	# garage door is closed
	if status_zone < 7.0
		say "Your garage door is already closed, Cabrone."  
	else
		# ask if garage door is clear and take action	
		response = ask "I would not want to cause injury or damage. Is the garage door clear?"
		if (response =~ /yes|yep|yeah|ok/i)
    			say "Thank you. I am closing your garage door."
    			Rest.get("#{self.isyip}/rest/elk/output/3/cmd/on?offTimerSeconds=2", :basic_auth => @isyauth)
		else
			say "OK. I will not close your garage door."
		end
	end
	# turn off garage scene
	Rest.get("#{self.isyip}/rest/nodes/27356/cmd/DOF", :basic_auth => @isyauth)
    request_completed 
  end

  def ring_doorbell
    say "It seems rather pointless, but OK I am ringing your doorbell."
    Rest.get("#{self.isyip}/rest/nodes/1C%207%2049%202/cmd/DON", :basic_auth => @isyauth)
    	sleep(2) 
    Rest.get("#{self.isyip}/rest/nodes/1C%207%2049%202/cmd/DOF", :basic_auth => @isyauth)
	object = SiriAddViews.new
	object.make_root(last_ref_id)
	answer = SiriAnswer.new("Doorbell", [SiriAnswerLine.new('logo',"#{self.webip}/doorbell.jpg")])
	object.views << SiriAnswerSnippet.new([answer])
	send_object object
    request_completed 
  end
  
end
