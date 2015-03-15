#!usr/bin/sh -x
cd /root
`mkdir rpm`
echo "Created directory rpm"

`groupadd munin`
echo "Created group munin"

`useradd -G munin munin`
echo "Created user munin"
`mkdir -p /home/munin`

#`scp -r root@dev-utility-lx08.amdc.mckinsey.com:/root/rpm/munin-2.0.11.zip /root/rpm/`

cd /root/rpm/
wget http://sourceforge.net/projects/munin/files/stable/2.0.11/munin-2.0.11.1.tar.gz/download
tar -xvf munin-2.0.11.1.tar.gz

cd /root/rpm/munin-2.0.11.1

make
make install-common-prime
make install-node-prime
make install-plugins-prime

gem install munin-plugins-rails --source=http://rubygems.org/

#echo "Enter the absolute path where munin-plugins-rails gem is installed (ex :- /usr/lib64/ruby/gems/1.8/gems/munin-plugins-rails-0.2.13/munin)"
a=`find /usr -name munin | grep -i /*/munin-plugins-rails-*.*.[0-9][0-9]/munin || find /opt -name munin | grep -i /*/munin-plugins-rails-*.*.[0-9][0-9]/munin`

cd /etc/opt/munin/plugins
`ln -s $a/munin_passenger_queue munin_passenger_queue`
`ln -s $a/munin_passenger_memory_stats munin_passenger_memory_stats`
`ln -s $a/munin_passenger_status munin_passenger_status`
`ln -s /opt/munin/lib/plugins/cpu cpu`
`ln -s /opt/munin/lib/plugins/df df`
`ln -s /opt/munin/lib/plugins/http_loadtime http_loadtime`
`ln -s /opt/munin/lib/plugins/load load`
`ln -s /opt/munin/lib/plugins/memory memory`
`ln -s /opt/munin/lib/plugins/swap swap`
/etc/init.d/apache2 status
RETVAL=$?

if [ $RETVAL -eq 0 ] || [ $RETVAL -eq 1 ]
then
cd /etc/opt/munin/plugins
`ln -s /opt/munin/lib/plugins/apache_accesses apache_accesses`
`ln -s /opt/munin/lib/plugins/apache_processes apache_processes`
`ln -s /opt/munin/lib/plugins/apache_volume apache_volume`
fi
/etc/init.d/nginx status
RETVAL=$?
if [ $RETVAL -eq 0 ] || [ $RETVAL -eq 1 ]
then
cd /etc/opt/munin/plugins
`ln -s /opt/munin/lib/plugins/nginx_request nginx_request`
`ln -s /opt/munin/lib/plugins/nginx_status nginx_status`
fi
/etc/init.d/passenger status
RETVAL=$?
if [ $RETVAL -eq 0 ] || [ $RETVAL -eq 1 ]
then
cd /etc/opt/munin/plugins
`ln -s /opt/munin/lib/plugins/nginx_request nginx_request`
`ln -s /opt/munin/lib/plugins/nginx_status nginx_status`
fi
/etc/init.d/tomcat6 status
RETVAL=$?
if [ $RETVAL -eq 0 ] || [ $RETVAL -eq 1 ]
then
cd /etc/opt/munin/plugins
`ln -s /opt/munin/lib/plugins/tomcat_access tomcat_access`
`ln -s /opt/munin/lib/plugins/tomcat_jvm tomcat_jvm`
`ln -s /opt/munin/lib/plugins/tomcat_threads tomcat_threads`
`ln -s /opt/munin/lib/plugins/tomcat_volume tomcat_volume`
fi


echo "**************************************************************************************************************************"
echo "**************************************************************************************************************************"


echo "******************************************Installing packages*************************************************************"

/usr/bin/zypper --no-gpg-checks  --quiet install -l -y perl-Net-Server
/usr/bin/zypper --no-gpg-checks  --quiet install -l -y perl-Time-modules
/usr/bin/zypper --no-gpg-checks  --quiet install -l -y perl-IO-Socket-INET6
/usr/bin/zypper --no-gpg-checks  --quiet install -l -y rrdtool-devel
/usr/bin/zypper --no-gpg-checks  --quiet install -l -y perl-HTML-Template
/usr/bin/zypper --no-gpg-checks  --quiet install -l -y perl-libwww-perl
/usr/bin/zypper --no-gpg-checks  --quiet install -l -y perl-Log-Log4perl
/usr/bin/zypper --no-gpg-checks  --quiet install -l -y perl-Socket6

echo "********************************************Done***********************************************************"

`scp root@dev-utility-lx08.amdc.mckinsey.com:/etc/init.d/munin-node /etc/init.d/`
cd /etc/opt/munin/
#echo "Enter the IP address of the server "
#read b

b=`hostname`
c=`nslookup $b.amdc.mckinsey.com | tail -2 | head -1 | cut -d " " -f2`
echo "host $c">1.txt

sed -i.bak -e '35,36d;50d' munin-node.conf

echo "allow ^157\.191\.164\.135$" >> 2.txt
echo "allow ^::1$" >> 2.txt

cat 2.txt >> /etc/opt/munin/munin-node.conf
cat 1.txt >> /etc/opt/munin/munin-node.conf

rm -rf 1.txt 2.txt

echo "***********************************************Installing Perl modules*********************************************************"

cpan -i File:Copy::Recursive
cpan -i Date:Manip


echo "**********************************************Starting Munin-Node*************************************************************"

/etc/init.d/munin-node status
RETVAL=$?

if [ $RETVAL -eq 0 ]
then
/etc/init.d/munin-node restart

else
/etc/init.d/munin-node start

fi




