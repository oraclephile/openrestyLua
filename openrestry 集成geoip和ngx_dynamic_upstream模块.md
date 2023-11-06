<!--
 * @Description: 
 * @Author: chonphile
 * @Github: https://github.com/oraclephile
 * @Date: 2023-10-26 20:33:58
 * @FilePath: /openrestyLua/openrestry 集成geoip和ngx_dynamic_upstream模块.md
 * @LastEditors: chonphile
 * @LastEditTime: 2023-10-26 20:34:22
-->
openrestry 集成geoip和ngx_dynamic_upstream模块
1.下载
wget https://openresty.org/download/openresty-1.19.9.1.tar.gz

2.基础依赖安装
yum install -y gcc glibc gcc-c++ openssl-devel pcre-devel

3.geoip2动态识别库安装
下载地址
https://github.com/maxmind/libmaxminddb/releases
wget https://github.com/maxmind/libmaxminddb/releases/download/1.6.0/libmaxminddb-1.6.0.tar.gz
tar xf libmaxminddb-*
#2.编译安装
cd libmaxminddb-*
./configure 
make 
make install
默认情况下上述操作会将libmaxminddb.so部署到/usr/local/lib目录下，通过如下步骤更新ldconfig，可以让动态链接库为系统所共享。
echo /usr/local/lib >> /etc/ld.so.conf.d/local.conf
ldconfig


4.集成geoip2模块
下载地址：wget https://github.com/leev/ngx_http_geoip2_module/archive/refs/tags/3.3.tar.gz
解压生成扩展包
tar -zxvf 3.3.tar.gz

5.下载ngx_dynamic_upstream模块
https://github.com/ZigzagAK/ngx_dynamic_upstream/archive/refs/tags/2.3.2.tar.gz
解压得到扩展包
tar -zxvf 2.3.2.tar.gz
/opt/soft/ngx_dynamic_upstream-2.3.2/src


6.下载geoip数据( 可以自行下载也可以开通账户使用收费版的)
官方地址：https://www.maxmind.com/en/accounts/322721/geoip/downloads
github地址：https://github.com/ar414-com/nginx-geoip2

git clone https://github.com/ar414-com/nginx-geoip2
cd /opt/soft/nginx-geoip2
tar -zxvf GeoLite2-City_20200519.tar.gz
mkdir -p /data/GeoIP/
mv GeoLite2-City_20200519/* /data/GeoIP/

7.编译启动Openrestry
cd /opt/soft
tar -zxvf openresty-1.19.9.1.tar.gz
cd /opt/soft/openresty-1.19.9.1

./configure -j2 --prefix=/usr/local/openresty --with-pcre-jit --with-ipv6 --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_sub_module --with-http_gzip_static_module --with-pcre --with-stream=dynamic --with-http_flv_module --add-module=/opt/soft/ngx_http_geoip2_module-3.3 --add-module=/opt/soft/ngx_dynamic_upstream-2.3.2


make -j2
make install



8.修改环境变量
cat > /etc/profile.d/openresty.sh << EOF
export OPEN_HOME=/usr/local/openresty/
export PATH=$OPEN_HOME/bin:$PATH
EOF
source /etc/profile.d/openresty.sh

9.opm安装lua-resty-maxminddb
需要先安装perl-Digest-MD5
yum install perl-Digest-MD5

opm get anjia0532/lua-resty-maxminddb
