#!/bin/bash

sudo sysctl -w fs.file-max=12000500;
sudo sysctl -w fs.nr_open=20000500;
ulimit -n 1048576;
sudo sysctl -w net.ipv4.tcp_mem='10000000 10000000 10000000';
sudo sysctl -w net.ipv4.tcp_rmem='1024 4096 16384';
sudo sysctl -w net.ipv4.tcp_wmem='1024 4096 16384';
sudo sysctl -w net.core.rmem_max=16384;
sudo sysctl -w net.core.wmem_max=16384;

echo "fs.file-max = 1048576" >> /etc/sysctl.conf
echo "# limits
* soft     nproc          1048576
* hard     nproc          1048576
* soft     nofile         1048576
* hard     nofile         1048576
root soft     nproc          1048576
root hard     nproc          1048576
root soft     nofile         1048576
root hard     nofile         1048576
" >> /etc/security/limits.conf
echo "session required pam_limits.so" >> /etc/pam.d/common-session
sysctl -p

touch /root/setup_log
echo "COMPLETE AT: $(date)" >> /root/limits_log
