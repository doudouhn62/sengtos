#!/bin/bash
#cat /etc/ssh/sshd_config
#rm -rf /root/.ssh
#rm -rf /home/$your_user/.ssh
rm -rf .ssh

mkdir .ssh

chmod 700 .ssh

cd .ssh

echo -e "\n" | ssh-keygen -t rsa -b 4096 -N ""

cat id_rsa.pub > authorized_keys

chmod 600 authorized_keys

cd


sed -i -e 's@\(.*X11Forwarding.*\)@#\1@g' /etc/ssh/sshd_config

echo -e "RSAAuthentication yes\nPubkeyAuthentication yes" >> /etc/ssh/sshd_config

echo -e "ClientAliveInterval 60\nClientAliveCountMax 5\nMaxAuthTries 5" >> /etc/ssh/sshd_config

systemctl restart sshd


read -p "请设置你的linux自定义用户名:" your_user
read -p "请设置你的ssh端口号:" ssh_port
read -p "请设置你的自定义用户名的密码(可以和root密码相同):" user_password

if [ "$ssh_port" -gt 0 ];then
	if [ "$ssh_port" -le 59999 -a "$ssh_port" -ge 10001 ];then
		echo "你设置的linux用户名是:$your_user"
		echo "你设置的ssh端口号是:$ssh_port"
	else
		echo "你设置的ssh端口号不属于用户端可用的范围，请重新输入"
		exit 5
	fi
else
	echo "输入有误，请重新输入全数字的ssh端口号"
	exit 6
fi


sed -i -e 's@^#\?Port.*@Port '$ssh_port'@g' /etc/ssh/sshd_config


useradd $your_user


cp -a /root/.ssh /home/$your_user

chmod 700 /home/$your_user/.ssh

chmod 600 /home/$your_user/.ssh/authorized_keys

chown -R $your_user:$your_user /home/$your_user/.ssh


sed -i -e '/^root/a'$your_user' ALL=(ALL) ALL' /etc/sudoers


echo "$user_password" | passwd --stdin $your_user


#curl -O https://raw.githubusercontent.com/doudouhn62/sengtos/master/user_port_key.sh && bash user_port_key.sh
#cat user_port_key.sh

#(恢复)使用自定义用户名及端口和密钥登录
#sed -i -e 's@^PasswordAuthentication.*@PasswordAuthentication no@g' -e 's@^#\?PermitRootLogin.*@PermitRootLogin no@g' /etc/ssh/sshd_config -e 's@^#\?Port\(.*\)@Port\1@g' ; systemctl restart sshd

#恢复使用root和密码登录
#sed -i -e 's@^PasswordAuthentication.*@PasswordAuthentication yes@g' -e 's@^#\?PermitRootLogin.*@PermitRootLogin yes@g' -e 's@^#\?\(Port.*\)@#\1@g' /etc/ssh/sshd_config ; systemctl restart sshd
