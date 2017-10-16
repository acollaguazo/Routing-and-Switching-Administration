#!/usr/bin/perl
##########################################################
## Programa: pop-comandos.pl  Version 1.0               ##
## Viernes 12 de Septiembre del 2008                    ##
##                                                      ## 
## Script para ingresar comandos en los POPs            ##
## de clientes a Nivel Nacional                         ##
## Base de datos: ttco_pops, Tabla: pop                 ##
##                                                      ##
## Desarrollado por: Msig. Adriana Collaguazo Jaramillo ##
##                                                      ##
##########################################################

use DBI;
use Net::Telnet::Cisco;

$user="acollaguazo";
$pass="acollaguazo";
$bkp_srv="190.95.180.79";
$bkp_path="/usr/respaldos/";
$date=`date +"%F"`;
chomp($date);

$dbh = DBI->connect ("DBI:mysql:ttco_pops", "root", "bariloche2004", {RaiseError => 1});
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
          @command = ('conf t','username automatico privilege 15 secret ttcobackbone2008','end','write memory');
        foreach $execute(@command)
        {
         @out = $session->cmd("$execute");    
        }  
        print "@out \n"; 
        print "\t Ingresando los comandos... Espere :) \n";
        }
}
 print "Proceso completo";

