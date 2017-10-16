#!/usr/bin/perl
##########################################################
## pop-backup.pl                                        ##
## Version 1.0                                          ##
## Martes 9 de Septiembre del 2008                      ##
##                                                      ## 
## Script de respaldo de configuraciones de los         ##
## POPs de clientes a nivel nacional                    ##
## Directorio de respaldos: /usr/respaldos              ##
## Base de datos: ttco_pops, Tabla: pop                 ##
##                                                      ##
## Desarrollado por: Msig. Adriana Collaguazo Jaramillo ##
## Departamento: IAC                                    ##
##########################################################

use DBI;
use Net::Telnet::Cisco;

$user="acollaguazo";
$pass="acollaguazo";
$bkp_srv="201.218.2.3";
$bkp_path="/usr/respaldos/backbone";
$date=`date +"%F"`;
chomp($date);

$dbh = DBI->connect ("DBI:mysql:TTCO_NACIONAL", "root", "chitita27", {RaiseError => 1});
$sth = $dbh->prepare ("select GROUP_CONCAT(DISTINCT ip ORDER BY ip DESC SEPARATOR' ') from backbone GROUP BY ip");
$sth->execute();

while(@items = $sth->fetchrow_array()){push @pops, $items[0];}
foreach $lista_pops(@pops)
        { 
	$session = Net::Telnet::Cisco->new(Host => $lista_pops, errmode => 'return');
        print "$lista_pops";
          if ($session)
             {  
                $session->login("$user", "$pass");
                @HOSTNAME = $session->cmd("sh run | inc hostname");
                $hostname = `echo '@HOSTNAME' |awk '{print \$2}'|head -1 `;
                chomp($hostname);
                print "$sth - $hostname \n";
                if ( ! -d "$bkp_path/$hostname")
                   { 
                     system("mkdir $bkp_path/$hostname");
                     system("chmod -Rf 777 $bkp_path/$hostname/");
                   }
//NO OLVIDAR SI TENGO COMO VARIABLE /USR/RESPALDOS/POP Y LUEGO EN LA VARIABLE SESSION DEBO COLOCAR NUEVAMENTE LA CARPETA POP:
                @out = $session->cmd("copy running-config tftp://$bkp_srv/backbone/$hostname/$hostname-$date.cfg\n\n");
               # @out = $session->cmd("copy running-config ftp://guest:respaldos@190.95.180.79/$hostname/$hostname-$date.cfg\n\n");
                print "@out\n";
             }
         }

