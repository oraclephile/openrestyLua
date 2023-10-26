--[[
Description:判定客户端ip地址属性（国家区域、黑白名单）进行相应的处理 
Author: chonphile
Github: https://github.com/oraclephile
Date: 2023-10-26 20:13:37
FilePath: /openrestyLua/ipblock.lua
LastEditors: chonphile
LastEditTime: 2023-10-26 20:14:07
--]]

--ngx.say("<br>IP location query result:<hr><br>")

local cjson=require 'cjson'
local geo=require 'resty.maxminddb'
--ngx.say("IP:",arg_ip,", node:",arg_node,"<br>")

function get_client_ip()
    local headers=ngx.req.get_headers()
    local xff=headers["X_FORWARDED_FOR"]
    local clixff = ''
    if xff then
    	clixff = string.match(xff, "([^,]+)")
    end
    local ip = ''
    if clixff ~= nil and clixff ~='' then
	ip=clixff
    else
	ip=headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
    end
    return ip
end
--白名单list
local whitelist = {"1.1.1.1","2.2.2.2","8.8.8.8"}
--黑名单list
local blacklist = {"114.114.114.114","123.123.2.2","18.18.18.18"}
function in_arr(c, arr)
    if c and c ~= "" then
        for k,v in
        pairs(arr) do
            if v == c then
                return true;
            end
        end
    end
    return false;
end

if not geo.initted() then
    --mmdb地址库
        --geo.init("/data/GeoIP/GeoLite2-Country.mmdb")
        geo.init("/data/GeoIP/GeoIP2-City.mmdb")
end

local arg_ip=get_client_ip()
--local arg_ip='66.249.93.206'
--ngx.say(arg_ip)

local res,err=geo.lookup(arg_ip or ngx.var.remote_addr)
if in_arr(arg_ip,whitelist) then
    --ngx.say(arg_ip)
else
	--ngx.say(arg_ip)
	if not res then
        --ngx.say("Please check the ip address you provided: <div style='color:red'>",arg_ip,"</div>")
        --ngx.log(ngx.ERR,' failed to lookup by ip , reason :',err)
	else
		if res['country'] ~= nil and res['country'] ~= '' then
			iso_code=res['country']['iso_code']
            --屏蔽中国区域的IP地址
			if ( iso_code == 'CN' )  then
				ngx.exit(403)
			end
            --屏蔽黑名单列表中的ip地址
			if in_arr(arg_ip,blacklist)  then
				ngx.exit(403)
			end
		end
	end
end