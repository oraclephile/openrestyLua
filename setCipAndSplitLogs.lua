--[[
Description: 
Author: chonphile
Github: https://github.com/oraclephile
Date: 2023-10-26 19:23:28
FilePath: /openrestyLua/setCipAndSplitLogs.lua
LastEditors: chonphile
LastEditTime: 2023-10-26 19:56:03
--]]
--获取cookie
local ck = require "resty.cookie";
local cookie, err = ck:new();
if not cookie then
    ngx.log(ngx.ERR, err);
    return;
end

--设置日志切割变量及运算方法
ngx.var.fmt_localtime = ngx.localtime();
ngx.var.fmt_localtime_days = string.sub(ngx.var.fmt_localtime,0,string.len(ngx.var.fmt_localtime)-9);
ngx.var.fmt_localtime_hours = string.sub(ngx.var.fmt_localtime,string.len(ngx.var.fmt_localtime)-7,string.len(ngx.var.fmt_localtime)-6);
ngx.var.fmt_localtime_days_hours = table.concat({ngx.var.fmt_localtime_days,"_",ngx.var.fmt_localtime_hours});
--传递变量给client_ip赋值
ngx.var.client_ip = ngx.var.cookie_traceIp;

if ngx.var.client_ip == nil or ngx.var.client_ip == "" then
   ngx.var.client_ip = ngx.var.remote_addr;
end

if ngx.var.client_ip == nil or ngx.var.client_ip == "" then
   ngx.var.client_ip = "0.0.0.0";
end
--给特定header-cip设置一个IP地址
local headers=ngx.req.get_headers()
ngx.var.cip=headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"