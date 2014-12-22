#!/bin/sh
# script atualizador de IP
#daniel.uramg 2010

echo Script iniciado...

#VERIFICA SE ESTA AGENDADO NO CRON, SE N�O TIVER SE AGENDA
CRONFILE="/var/spool/cron/crontabs/root"
[ -z "`grep dnsomatic.sh $CRONFILE`" ] && echo "*/5 * * * * /partition/scriptsteste/./dnsomatic.sh" >> $CRONFILE && cron.reload

#Se n�o existir o arquivo dnsomatic.txt o cria
[ ! -e /partition/tmp/dnsomatic.txt ] && touch /partition/tmp/dnsomatic.txt

#Variavel para pegar o IP v�lido, caso a primeira falhe tenta outras vezes
IPATUAL="`wget -O - http://myip.dnsomatic.com/`"
[ -z "$IPATUAL" ] && IPATUAL="`wget -O - http://checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`"
[ -z "$IPATUAL" ] && IPATUAL="`wget -O - http://dynupdate.no-ip.com/ip.php`"


#Fun��o que atualiza o IP nos hosts e envia email
UPDATE(){
CFemail=""
CFtoken=""
CFhosts=""
GETcf=`/usr/local/bin/./curl -k https://www.cloudflare.com/api_json.html -d "email=$CFemail" -d "tkn=$CFtoken" -d "hosts=$CFhosts" -d "a=DIUP" -d "ip=$IPATUAL"`

ZEuser=""
ZEpass=""
ZEhosts=""
#GETze="`wget -O - http://$ZEuser:$ZEpass@dynamic.zoneedit.com/auth/dynamic.html?host=$ZEhosts`"

DNSomaticuser=""
DNSomaticapass=""
DNSomatichosts="all.dnsomatic.com"
#GETdnsomatic="`wget -O - http://$DNSomaticuser:$DNSomaticpass@updates.dnsomatic.com/nic/update?host=$DNSomatichosts`"

NOipuser=""
NOippass=""
NOiphosts=""
GETnoip="`wget -O - http://$NOipuser:$NOippass@www.noip.com/nic/update?hostname=$NOIPhosts`"

FREEDNStoken="=="
GETfreedns="`/usr/local/bin/./curl -k https://freedns.afraid.org/dynamic/update.php?$FREEDNStoken`"

SENDSMSto=""
#SENDSMS="`/partition/scriptsteste/SendSMS/./sendsms.sh $SENDSMSto "Gateway Digipaper: O IP do servidor foi atualizado. O novo IP � $IPATUAL"`"

echo "IP atualizado: $IPATUAL"
/partition/scriptsteste/./sendmail.sh "`[ -z "$GETcf" -o -z "$GETnoip" ] && echo "ATEN��O!"` IP Atualizado $IPATUAL" "
`[ -z "$GETcf" -o -z "$GETnoip" ] && echo "HOUVE ERRO EM ALGUM DOS SERVI�OS! VERIFIQUE COM ATEN��O."`


IPATUAL = http://$IPATUAL

Retorno do CloudFlare:
$GETcf

Retorno FreeDNS
$GETfreedns

Retorno do No-IP:
$GETnoip

Retorno do ZoneEdit:
$GETze

Retorno do DNSomatic:
$GETdnsomatic

SENDSMS= $SENDSMS

Execute os seguintes comandos no DOS para verificar se os Hosts foram atualizados:
nslookup digipaper.zapto.org 8.8.8.8
nslookup webtracker.zapto.org 8.8.8.8
nslookup rastreador.zapto.org 8.8.8.8
nslookup recicladigital.com.br 8.8.8.8"

#Carrega valor do IP e dos Hosts no arquivo dnsomatic.txt
echo "IP: $IPATUAL" > /partition/tmp/dnsomatic.txt
echo "dnsomatic: $GETdnsomatic" >> /partition/tmp/dnsomatic.txt
echo "freedns: $GETfreedns" >> /partition/tmp/dnsomatic.txt
echo "zoneedit: $GETze" >> /partition/tmp/dnsomatic.txt
echo "no-ip: $GETnoip" >> /partition/tmp/dnsomatic.txt
echo "cloudflare: $GETcf" >> /partition/tmp/dnsomatic.txt

[ -z "$CONT" ] && CONT="1" || CONT="$(($CONT+1))"

#DEBUG
cat /partition/tmp/dnsomatic.txt
echo "sendsms: $SENDSMS"
echo -e "\a"
echo CONT=$CONT

#[ -z "` echo "$GET" | grep "good"`" ] && sleep 30 && UPDATE
#[ ! -z "` echo "$GETze" | grep "Too many updates too quickly"`" ] && echo "deu zica" && exit 1
#[ -z "` echo "$GETze" | grep "SUCCESS"`" -a "$CONT" -lt 5 ] && sleep 30 && UPDATE
}

#Fun��o para verificar se a entrada A foi atualizada em cada dom�nio
#verificadns_func(){
#echo "Entra na verifica��o dos Hosts, aguardando 5 minutos..."
#sleep 300 #300 - aguarda 5 minutos

#DOMINIOS="digipaperinformatica.com\nwebtracker.com.br\nrecicladigital.com.br"

#DNSCHECK_FUNC() {
#	wget -O - "http://www.dnswatch.info/dns/dnslookup?la=en&host=$1&type=A&submit=Resolve" | grep "A record found" | cut -f 4 -d' '
#}

##DESATIVADO TEMPORARIAMENTE
#	echo -e $DOMINIOS | while read DOMINIO; do
#		if [ "`DNSCHECK_FUNC "$DOMINIO"`" -a "`DNSCHECK_FUNC "$DOMINIO"`" != "$IPATUAL" ]; then
#echo "Dominio $DOMINIO n�o atualizado, nova tentativa"
#/partition/scriptsteste/./sendmail.sh "Dom�nio $DOMINIO" "O dom�nio $DOMINIO parece n�o ter sido atualizado com sucesso
#A entrada A deste dom�nio �: `DNSCHECK_FUNC $DOMINIO` e o IP atual �: $IPATUAL.
#Ser� feita uma nova tentativa de atualiza��o"
#			UPDATE
#		fi
#	done

#}

[ "$IPATUAL" -a -z "`grep "$IPATUAL" /partition/tmp/dnsomatic.txt`" ] && UPDATE || echo "sem necessidade" #&& verificadns_func
