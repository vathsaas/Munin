Munin-Install
=============
There are two major pre-requisites.

i> git

ii> rubygems

Both of the above softwares must be installed before running the script. 


1> clone the script to the server on which munin has to be installed.
   
2> Then run the script munin1.sh

   . ./munin1.sh
   
3> When the script prompts for the password throughout the setup please use "mckinsey" as the password.


After the installation is complete, if there are any components like apache, nginx, tomcat please follow the below steps.
   
   If any other component needs to be monitored please check in the following path for the plugins /opt/munin/lib/plugins/
   and then create symlinks under /etc/opt/munin/plugins.

************************************************************************************************************************
   
   For Apache
   ----------
   
      goto /etc/sysconfig/apache2 file

      In the "APACHE_MODULES" tag add "mod_status"

      goto /etc/apache2/mod_status file

      add "ExtendedStatus on" at the end of the file

      goto /etc/opt/munin/plugins and check by running the command "./apache_processes autoconf" the output should be yes
   
   For Nginx
   ---------
   
      goto /opt/nginx/conf/nginx.conf file
    
      Add a new server module.

      server {
        listen 127.0.0.1;
        server_name localhost;
        location /nginx_status {
                stub_status on;
                access_log   off;
                allow 127.0.0.1;
                deny all;
        }
     }

     Then restart nginx server and goto /etc/opt/munin/plugins and check
    
     ./nginx_request autoconf and the output should be yes

     Special Case dev-utility-lx44.amdc.mckinsey.com
   
   For Tomcat
   ----------
   
    Check if the admin module is installed for tomcat if not install it through zypper

      The goto /etc/tomcat6/tomcat-users.xml and add the following
   
	   <role rolename="manager"/>
	   <user username="munin" password="munin" roles="manager"/>
 	
      Then within /etc/opt/munin/plugin-conf.d/ create a file munin-node and add the following

       [tomcat_*]
       env.host 127.0.0.1
       env.port 8080
       env.request /manager/status?XML=true
       env.user munin
       env.timeout 30
   
      The restart tomcat and check the following

      wget http://munin:munin@localhost:8080/manager/status this should download a index file.
   
   
   After doing the above please do the following :-
   
   1> /etc/init.d/munin-node restart
   
   2> Then logon to dev-utility-lx08.amdc.mckinsey.com and open the file 
      "vi /etc/opt/munin/munin.conf"
      
      In the above file add the server name and the IP address on which you installed munin client and you can customize the warning and critical levels of the servers by referring to the other servers which are already configured.
      
   3> Then restart the munin and cron services.
   
      /etc/init.d/munin-node restart
      
      /etc/init.d/cron restart
      
      
   

