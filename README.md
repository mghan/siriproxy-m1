siriproxy-isy99i
================

About
-----

Siriproxy-isy99i is a [SiriProxy] (https://github.com/plamoni/SiriProxy) plugin that allows you to control home automation devices using the [Universal Devices ISY-99i Series] (http://sales.universal-devices.com) controller through Apple's Siri interface on any iOS device that supports Siri.   It does not require a jailbreak, nor do I endorse doing so.   

Utilizing the REST interface of the ISY-99i, this plugin matches certain voice commands and sends the appropriate command via http to the controller.  See below for specific usage.

My fork of [Hoopty3’s plugin] (https://github.com/hoopty3/siriproxy-isy99i) is just that.  If you already have an ISY-99i and made it here, then you are already a tweaker and know it is impossible to provide a single solution that will suit everyone’s needs and configuration.  I do not intend to merge any changes unless those are improvements in reliability or control. The baseline changes I made from Hoopty3’s plugin include:
- Added Elk M1 Gold control for arming, disarming, and relay output control.
- Added ability to push IP camera and custom images to Siri.     
- Removed the Insteon thermostat control since I have a [Nest] (http://www.nest.com) thermostat which can also be controlled by SiriProxy thanks to [Chilitechno.] (https://github.com/chilitechno/SiriProxy-NestLearningThermostat)
- Removed dimmer control and device status since I mostly have CFL’s in my home and already have visual feedback.  Seemed like a lot of extra code to maintain for little value added, not to mention I think there were some problems correctly parsing device status.    

See the following video for a short demonstration: http://www.youtube.com/watch?v=rhiAsf3PV_k  

I would also like to point out that I am not a programmer, and haven't coded in Ruby before, so go easy on me. I gave myself a crash course in Ruby once I learned of this project, and that is it.  Google has been a very close friend over the past week or so.

I am fully aware of the fact that the code could be cleaner, done differently, done better, or whatever.  Feel free to point out mistakes/corrections, offer constructive criticism, etc. This is a work in progress and I'm counting on the community to help make it better.

**Above all: Use all the available resources out there if you have problems.  Trust me.  If I can put this together having never really programmed, you can figure out how to get it running.**

Installation
------------

First and foremost, [SiriProxy] (https://github.com/plamoni/SiriProxy) must be installed and working.  Do not attempt to do anything with this plugin until you have installed SiriProxy and have verified that it is working correctly. If this is your first SiriProxy venture, I highly recommend you do all your initial setup and tweaking on a [Virtual Machine] (http://www.virtualbox.org) running [Ubuntu Linux.] (http://www.ubuntu.com) In my case, I have SiriProxy installed a Marvell SheevaPlug computer which I can leave on 24/7.   For more information on SiriProxy on other platforms, I started a [SiriProxy Wiki] (https://github.com/plamoni/SiriProxy/wiki/Installation-How-Tos) page to capture everyone’s efforts.  

Once SiriProxy is up and running, you'll want to add the siriproxy-isy99i plugin.  This will have to be done manually, as it is necessary to add your specific devices and their addresses to a configuration file (devices.rb).  This process is a bit more complicated that some other plugins, but I will walk you through the steps I used.  

It may also be helpful to look at this [video by jbaybayjbaybay] (http://www.youtube.com/watch?v=A48SGUt_7lw) as it's the one I used to figure this process out.  The video includes info on creating a new plugin and editing the files, which can be helpful when it comes to experimenting with your own plugins, but it won't be necessary in order to just install this plugin.  So, I'll skip those particular instructions below.

1.  Download the repository as a [zip file] (https://github.com/elvisimprsntr/siriproxy-isy99i/zipball/master).
2.  Extract the full directory (i.e. elvisimprsntr-siriproxy-isy99i-######), depending on your distribution, to:    
 - `~/.rvm/gems/ruby-1.9.3-p###@SiriProxy/gems/siriproxy-0.3.#/plugins`    
 - `/usr/local/rvm/gems/ruby-1.9.3-p###@SiriProxy/gems/siriproxy-0.3.#/plugins`   
and rename it siriproxy-isy99i or create a symbolic link. You will need to go to View and select 'Show Hidden Files' in order to see .rvm directory.
3.  Navigate to the `siriproxy-isy99i/lib` directory and open devices.rb for editing.  Gedit or vim works just fine.
4.  Here you will need to enter your specific device info, such as what you will call them and their addresses.  This file is populated with examples and should be pretty self explanatory.  
5.  If a device is dimmable, set the @dimmable variable to 1, otherwise it is not necessary or should be set to some number other than 1.  You can control devices or scenes, but you cannot currently get the status of a scene (scenes don't have a status).
6.  Copy the siriproxy-99i directory to `~/SiriProxy/plugins` directory
7.  Open up siriproxy-isy99i/config-info.yml and copy all the settings listed there.
8.  Navigate to `~/.siriproxy` and open config.yml for editing.
9.  Paste the settings copied from config-info.yml into config.yml making sure to keep format and line spacing same as the examples.  
10. Set the host, username, and password fields for your system's configuration.  Don't forget to save the file when you're done.
11. Open a terminal and navigate to ~/SiriProxy
12. Type `siriproxy bundle` <enter>
13. Type `bundle install` <enter>
14. Type `rvmsudo siriproxy server` <enter> followed by your password.
15. SiriProxy with ISY99i control is now ready for use.

Usage
-----

**Turn on, turn off (device name)**

- Will turn on or off the device. 

**Arm away, arm stay, disarm alarm**

- Siri will change the alarm to the state requested and pushes a custom image to Siri.  Currently it does not confirm the state change, but I have not had any reliability problems.
- NOTE: Siri has a lot of trouble with “S” sounds so you may have to alter you speech slightly to get Siri to recognize “arm stay” or you can change the syntax to look for a different pattern.  

**Open garage, close garage**

- Siri will push an image from your IP camera and check the status of the door.  If the door is already in the requested position, it will let you know.  
- If the garage door is closed it will open without any need for confirmation.
- If the door is open, Siri will ask you to confirm the door is clear before closing the door. Obviously, this was for safety reasons. 

Above are the main arguments that have been coded so far for use with the ISY-99i controller.  I have programmed in some specific phrases and instructions for my use.  These can be found in the siriproxy-isy99i.rb file.  Feel free to edit these and make it your own.  I only ask that you share any funny or neat applications that you come up with.

**NOTE: If/when you make changes to either devices.rb or siriproxy-isy99i.rb, you must copy it to the other plugin directory.  Remember, you put a copy in** `~/.rvm/gems/ruby-1.9.3-p###@SiriProxy/gems/siriproxy-0.3.#/plugins` **AND** `~/SiriProxy/plugins`**.  They both have to match!  Then follow steps 11 - 15 of the installation procedure to load up your changes and start the server again.**

To Do List
----------

- Add authenticated IP camera access.
- Add ability to launch a live IP camera feed or at least provide a button to do so.
- Perhaps develop code for self awareness of devices/addresses (would require major overhaul and be completely different from current methods)
- The sky's the limit!  Accepting any and all suggetions.

Acknowledgements
----------------

I really gotta thank [plamoni] (https://github.com/plamoni) for developing the SiriProxy and putting it out there for the rest of us tinkerers to play with.  It has been a lot of fun exploring how to use it in new and different ways.

I also have to thank all the other plugin developers for sharing their code as well.  I couldn't have put this thing together without the examples that they put forward.

Thanks guys!

Licensing
---------

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).

Disclaimer
----------

I'm not affiliated with Apple in any way. They don't endorse this application. They own all the rights to Siri (and all associated trademarks). 

This software is provided as-is with no warranty whatsoever. Use at your own risk!  I am not responsible for any damages/corruption which may occure to your system.  (It's not gonna happen, but I gotta say it...)

Apple could do things to block this kind of behavior if they want. Also, if you cause problems (by sending lots of trash to the Guzzoni servers or anything), I fully support Apple's right to ban your UDID (making your phone unable to use Siri). They can, and I wouldn't blame them if they do.

I'm a huge fan of Apple and the work that they do. Siri is a very cool feature and I'm pretty excited to explore it and add functionality. Please refrain from using this software for anything malicious.

