#!/bin/bash

username=Puneet
password=trinaz#872465sdffs
os_flavour_type=`hostnamectl | grep "Operating System" | awk '{print $3}'`
full_os_name=`hostnamectl | grep "Operating System" | awk '{for(i=3;i<=NF;++i) printf("%s ",  $i) }'`

BR='\033[1;31m'     # ${BR}
BG='\033[1;32m'     # ${BG}
NC='\033[0m'        # ${NC}
BY='\033[1;33m'     # ${BY}
mark100='\U01F4AF'
wrong='\u274c\n'
r_text="Detected OS type :"

check_for_root_user(){
    if [[ $EUID -ne 0 ]]; then
        echo -e "${BR}\n Script must be run as root or sudo ${wrong}${NC}" 1>&2
        exit 1
    fi
}
#check_for_root_user

case $os_flavour_type in
   "Ubuntu")
		echo -e "1)${BY} ${r_text} $full_os_name${mark100}${NC}"
		user_group=sudo
      ;;
   "CentOS")
		echo -e "1)${BY} ${r_text} $full_os_name${mark100}${NC}" 
		user_group=wheel
      ;;
   "SUSE")
		echo -e "1)${BY} ${r_text} $full_os_name${mark100}${NC}" 
		user_group=wheel
      ;;
   "Red")
		echo -e "1)${BY} ${r_text} $full_os_name${mark100}${NC}" 
		user_group=wheel
      ;;
   "Oracle")
		echo -e "1)${BY} ${r_text} $full_os_name${mark100}${NC}" 
		user_group=wheel
      ;;
   "Amazon")
		echo -e "1)${BY} ${r_text} $full_os_name${mark100}${NC}" 
		user_group=wheel
      ;;
   *)
		echo -e "1)${BY} OS Type not detected , Exiting${wrong}${NC}";
		exit 1
     ;;
esac

echo -e "${BY}You are going to create user ${NC}${username}${BY},You can also change public key ${NC}"
read -p " Press any key to continue... OR Press CTRL + c to Exit " -n1 -s
echo " "

sudo useradd ${username} && usermod -aG ${user_group} ${username} && echo -e "2)${BG} User created and added as sudo user ${mark100}${NC}"

erroCode=$?

if [[ $erroCode != 0 ]]
then

   echo -e "2) ${BR}Error while creating user,Exiting ${wrong}${NC}"
   exit 1

else

sudo echo ${username}:${password} | chpasswd && echo -e "${BG}Password adedd to user ${mark100}${NC}"

sudo grep "+ : ${username} : ALL" /etc/security/access.conf 
erroCode1=$?

if [[ $erroCode1 != 0 ]]
then
  sudo  echo "+ : ${username} : ALL" >> /etc/security/access.conf && echo -e "3)${BG} witten acces.conf ${mark100}${NC}"
fi

sudo grep "auth   \[default=1 ignore=ignore success=ok\] pam_localuser.so" /etc/pam.d/sshd
erroCode2=$?

if [[ $erroCode2 != 0 ]]
then
   sudo echo "auth   [default=1 ignore=ignore success=ok] pam_localuser.so" >> /etc/pam.d/sshd && echo -e "4)${BG} Added parameter in sshd ${mark100}${NC}"
fi

sudo grep "${username} ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
erroCode3=$?

if [[ $erroCode3 != 0 ]]
then
 sudo   echo "${username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && echo -e "5)${BG} Added passwordless sudo user swithch ${mark100}${NC}"
fi

sudo mkdir -p /home/${username}/.ssh && echo -e "6)${BG} created .ssh dir ${mark100}${NC}"
sudo touch /home/${username}/.ssh/authorized_keys && echo -e "7)${BG} created file authorized_keys ${mark100}${NC}"
sudo chmod 700 /home/${username}/.ssh && echo -e "8)${BG} permission changed 700 on .ssh ${mark100}${NC}"
sudo chmod 600 /home/${username}/.ssh/authorized_keys && echo -e "9)${BG} permission changed 600 on authorized_keys ${mark100}${NC}"
sudo chown -R ${username} /home/${username}/.ssh && echo -e "10)${BG} changed ownership ${mark100}${NC}"

sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDgqrnLnkW+5xJeFxDXLF8hundVkvUc4ykNOjjk/GDxB8SHxpkEPQ63P0scbZfuqmrY74KlN60rxG4m/iSPcWYFtkEAmvPwGyGvGqBVDRzsCr+X/NIoBID/fenZvrliQCtxY+26uFv+jLrGB6aVfAlU+C73ZUCFBXZXa3e/vokN9zPzXDcg/60aXzNAAj27qii71npcu3mrc0mJ+EJ7J9pG+Z4KhnAFwgaK8YfXC7ixwYrj7KAcSpPsbE23I5cF2qQeDUeCj6v0oiJy7l6rNWuWF8v6gv7Tt7UqJu8Sz1hLsqB6kQlYDazGGl3NdvGgpPOFPnAbbNfg5DMMBx8JKVZbMz87mkXqac2T5K4PunsgLSh2Iv8A7gI8bIzwZqE5Uh4RT6lUnA7n4vBXYQPOveXrmRZwyz9pFO5uXhTHPCiT6EWhO/vtl66wjDTTrLpm+Ko1qgzrP4vMcm7w0y0NFbP8jxjcaKWqoRUznWzxIEHGTgmeIYd4lijiK5r6yB99X48= TRIANZ+puneet.chauhan@DESKTOP-DPV83G5" > /home/${username}/.ssh/authorized_keys && echo -e "11)${BG} key added ${mark100}${NC}"

## Repalce your public key in above line in echo 

sudo service sshd restart && echo -e "12)${BY} restarted SSH Daemon ${mark100}${NC}"

fi