env | grep DBT | awk '{ print "export", $0 }' | tee -a ~/.bash_profile >> ~/.bashrc && /
 echo "cd ${PWD}" | tee -a ~/.bash_profile >> ~/.bashrc && / 
 apt-get update && /
 apt-get install -y openssh-server && /
 mkdir -p /root/.ssh && /
 chmod 700 /root/.ssh && /
 touch /root/.ssh/authorized_keys && /
 chmod 600 /root/.ssh/authorized_keys && /
 cat /ssh_keys/*.pub >> /root/.ssh/authorized_keys && /
 /etc/init.d/ssh start && /
 tail -f /dev/null