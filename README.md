siriproxy-m1
================

About
-----

Siriproxy-m1 is a [SiriProxy] (https://github.com/plamoni/SiriProxy) plugin that allows you to control the Elk M1 home automation system through Apple's Siri interface on any iOS device that supports Siri.   It does not require a jailbreak, nor do I endorse doing so.

Utilizing a simple TCP socket interface to the M1, this plugin matches certain voice commands and sends the appropriate command via TCP to the controller.  See below for specific usage.

My fork of [elvisimprsntr's plugin] (https://github.com/elvisimprsntr/siriproxy-isy99i) is just a starting point.  I did pull together bits and pieces from numerous other repositories.

This is my first ruby project so please be gentle.


Installation
------------

First and foremost, [SiriProxy] (https://github.com/plamoni/SiriProxy) must be installed and working.  Do not attempt to do anything with this plugin until you have installed SiriProxy and have verified that it is working correctly. If this is your first SiriProxy venture, I highly recommend you do all your initial setup and tweaking on a [Virtual Machine] (http://www.virtualbox.org) running [Ubuntu Linux.] (http://www.ubuntu.com) In my case, I have SiriProxy installed a Marvell SheevaPlug computer which I can leave on 24/7.   For more information on SiriProxy on other platforms, I started a [SiriProxy Wiki] (https://github.com/plamoni/SiriProxy/wiki/Installation-How-Tos) page to capture everyone’s efforts.

Once SiriProxy is up and running, you'll want to add the siriproxy-m1 plugin.  This will have to be done manually, as it is necessary to add your specific devices and their addresses to a configuration file (devices.rb).  This process is a bit more complicated that some other plugins, but I will walk you through the steps I used.

It may also be helpful to look at this [video by jbaybayjbaybay] (http://www.youtube.com/watch?v=A48SGUt_7lw) as it's the one I used to figure this process out.  The video includes info on creating a new plugin and editing the files, which can be helpful when it comes to experimenting with your own plugins, but it won't be necessary in order to just install this plugin.  So, I'll skip those particular instructions below.


1.  Download the repository as a [zip file] (https://github.com/m1/siriproxy-m1/zipball/master).
2.  Extract the full directory (i.e. mghan-siriproxy-m1-######), depending on your distribution, to:
 - `~/.rvm/gems/ruby-1.9.3-p###@SiriProxy/gems/siriproxy-0.3.#/plugins`
 - `/usr/local/rvm/gems/ruby-1.9.3-p###@SiriProxy/gems/siriproxy-0.3.#/plugins`
and rename it siriproxy-m1 or create a symbolic link. You will need to go to View and select 'Show Hidden Files' in order to see .rvm directory.
3.  Navigate to the `siriproxy-m1/lib` directory and open devices.rb for editing.  Gedit or vim works just fine but I did my editting in Windows and used WinSCP to syncronize changes.
4.  Here you will need to enter your specific device info, such as what you will call them and their addresses.  This file is populated with examples and should be pretty self explanatory.
5.  Copy the siriproxy-99i directory to `~/SiriProxy/plugins` directory
6.  Open up siriproxy-m1/config-info.yml and copy all the settings listed there.
7.  Navigate to `~/.siriproxy` and open config.yml for editing.
8.  Paste the settings copied from config-info.yml into config.yml making sure to keep format and line spacing same as the examples.
9 . Set the host, username, and password fields for your system's configuration.  Don't forget to save the file when you're done.
10. All the files might have to be copied to both the SiriProxy/plugins directory as well as the /usr/local/rvm/gems/ruby-1.9.3-p362@SiriProxy/gems/siriproxy-0.3.2/plugins directory.  I created a simple script to do this.
11. Open a terminal and navigate to ~/SiriProxy
12. Type `siriproxy bundle` <enter>
13. Type `bundle install` <enter>
14. Type `rvmsudo siriproxy server` <enter> followed by your password.
15. SiriProxy with M1 control is now ready for use.
16. Optional - I consider my Raspberry Pi to be a dedicated Siri interface.  I am running SiriProxy on the root account and have it launched automatically.

NOTES:

If/when you make changes to either devices.rb or siriproxy-m1.rb, you must copy it to the other plugin directory.  Remember, you put a copy in** `~/.rvm/gems/ruby-1.9.3-p###@SiriProxy/gems/siriproxy-0.3.#/plugins` **AND** `~/SiriProxy/plugins`**.  They both have to match!  Then follow steps 11 - 15 of the installation procedure to load up your changes and start the server again.

Its take over an hour to install Ruby on a Raspberry Pi!

I chose to point my iThing's DNS to the Raspberry Pi - simply edit the DNS setting under Settings>WiFi to use the Pi's IP address.

Next change the Pi to handle DNS requests:
   sudo nano /etc/dnsmasq.conf     at around line 63, find the following

   #address=double-click.net/127.0.0.1     under it, add this...

   address=/guzzoni.apple.com/YOUR.Pi.IP.ADDR

To close dnsmasq.conf, press CTRL+O then Enter then CTRL+X.

Then restart dnsmasq with the following.

   sudo /etc/init.d/dnsmasq restart


Usage
-----


Turn On -name-,
Turn Off -name-,
Set -name- to -level- %,
Set Heating temp,
Set Cooling temp,
I'm Cold,
I'm Warm,
Inside Temperature
Outside Temperature
Wine Temperature
Good Night
Good Morning
Watch Movie
Open/Close Garage
Master Suite Off
Downstairs Off
Master Bath On/Off
Kitchen On/Off/Full
Dining Room On/Off
Living Room On/Off
Accent On
Let's Party!


- If the garage door is closed it will open without any need for confirmation.
- If the door is open, Siri will ask you to confirm the door is clear before closing the door. Obviously, this was for safety reasons.



Licensing
---------

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).

