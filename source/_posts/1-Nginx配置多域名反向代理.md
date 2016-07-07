---
title: Nginx配置多域名反向代理
date: 2015-12-03 19:55:58
tags: [Linux, Nginx]
---

Nginx是一款用C语言编写的高性能Web服务器，常常架设在其他Web服务的外层，用于负载均衡、缓存静态文件、反向代理等。所谓反向代理，就是部署在服务器端转发请求的代理服务，用户请求通过它到达真正的后端资源。<!-- more -->与此对应的“正向”代理，是部署在客户端的代理服务，对外的网络请求实际由它发出。打个比方，正向代理就像是你叫你儿子帮你去打酱油，你儿子就是一个正向代理。反向代理就是你去酱油店买酱油，酱油实际上是老板找隔壁借来再卖给你，你并不知情，此时酱油店老板就是一个反向代理。从这个比方中也很好理解，正向代理对请求方是可知的，而反向代理对于请求方来说一般是透明的、不可知的。

## 安装Nginx

使用Yum，我们可以很方便的安装Nginx(apt-get是完全类似的):

```bash
yum install nginx
```

打开nginx的配置文件/etc/nginx/nginx.conf，长这样:

```bash
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
	worker_connections 1024;
}

http {
	log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
						'$status $body_bytes_sent "$http_referer" '
						'"$http_user_agent" "$http_x_forwarded_for"';

	access_log  /var/log/nginx/access.log  main;

	sendfile            on;
	tcp_nopush          on;
	tcp_nodelay         on;
	keepalive_timeout   65;
	types_hash_max_size 2048;

	include             /etc/nginx/mime.types;
	default_type        application/octet-stream;

	# Load modular configuration files from the /etc/nginx/conf.d directory.
	# See http://nginx.org/en/docs/ngx_core_module.html#include
	# for more information.
	include /etc/nginx/conf.d/*.conf;

	server {
		listen       80 default_server;
		listen       [::]:80 default_server;
		server_name  _;
		root         /usr/share/nginx/html;

		# Load configuration files for the default server block.
		include /etc/nginx/default.d/*.conf;

		location / {
		}

		error_page 404 /404.html;
			location = /40x.html {
		}

		error_page 500 502 503 504 /50x.html;
			location = /50x.html {
		}
	}
}
```

## 配置反向代理

在/etc/nginx/conf.d/目录下新建一个配置文件reverse_proxy.conf，输入以下内容:

```bash
upstream wx_server {
	server localhost:8001;
}

proxy_temp_path     /etc/nginx/proxy_temp;
proxy_cache_path    /etc/nginx/proxy_cache levels=1:2 keys_zone=cache_one:100m inactive=1d max_size=1g;

server {
	listen 80;
	server_name blog.hustlibraco.com hustlibraco.com;

	location ~ .*\.(gif|jpg|png|css|js|ico|swf)(.*) {
		proxy_pass http://localhost:8000;
		proxy_redirect off;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

		proxy_cache cache_one;
		proxy_cache_valid 200 304 5m;
		proxy_cache_key $host$uri$is_args$args;
		expires 30d;
	}

	location / {
		proxy_pass http://localhost:8000;
		proxy_redirect off;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	}
	access_log  /var/log/nginx/blog_hustlibraco_com_access.log;
}

server {
	listen 80;
	server_name wx.hustlibraco.com;
	location / {
		proxy_pass http://wx_server;
		proxy_redirect off;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	}
	access_log  /var/log/nginx/wx_hustlibraco_com_access.log;
}
```

其中两段server开头的配置指明了代理的规则，我们逐一解释下这些配置:

- `listen 80` 
  监听80端口

- `server_name blog.hustlibraco.com hustlibraco.com` 
  接受这两个域名的请求

- `location ~ .\*\.(gif|jpg|png|css|js|ico|swf)(.\*){}` 
  指定文件的缓存配置

- `location / {}` 
  接受server_name下所有路径的请求

- `proxy_pass http://localhost:8000` 
  转发到localhost的8000端口上

- `proxy_pass http://wx_server` 
  转发到wx_server节点上，由upstream配置

- `proxy_redirect off` 
  不重写被代理服务器返回给客户端的Location和Refresh

- `proxy_set_header Host $host` 
  设置请求头的Host为反向代理服务器的Host

- `proxy_set_header X-Real-IP $remote_addr` 
  设置请求头的X-Real-IP为客户端真实IP

- `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for` 
  把请求来源的IP添加到请求头的X-Forwarded-For字段

  > X-Forwarded-For:简称XFF头，它代表客户端，也就是HTTP的请求端真实的IP，只有在通过了HTTP代理或者负载均衡服务器时才会添加该项。 它不是RFC中定义的标准请求头信息，在squid缓存代理服务器开发文档中可以找到该项的详细介绍。 标准格式如下：X-Forwarded-For: client1, proxy1, proxy2。

- `access_log /var/log/nginx/blog_hustlibraco_com_access.log` 
  请求日志文件

了解这些配置项的意义之后，可以知道发送给blog.hustlibraco.com, hustlibraco.com的请求都会被转发到本地8000服务上，而发送给wx.hustlibraco.com的请求被转发到wx_server节点上（localhost:8001）。

配置好以后使用命令service nginx reload使配置生效。

## 设置开机自启动

CentOS7引入了systemctl命令，结合了service和chkconfig的功能，一行命令设设置开机自启动:

```bash
systemctl enable nginx.service
ln -s '/usr/lib/systemd/system/nginx.service' '/etc/systemd/system/multi-user.target.wants/nginx.service'
```