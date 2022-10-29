#!/bin/sh

#init
mkdir /home/runner/data

#download
##caddy
    curl -L https://github.com/lxhao61/integrated-examples/releases/latest/download/caddy-linux-amd64.tar.gz -o /home/runner/data/caddy.tar.gz
    cd /home/runner/data
    tar -zxvf caddy.tar.gz
    rm -f sha256 && rm -f caddy.tar.gz
    chmod +x /home/runner/data/caddy

##diffuse
    curl -L https://github.com/icidasset/diffuse/releases/download/3.2.0/diffuse-web.tar.gz -o /home/runner/data/diffuse-web.tar.gz
    cd /home/runner/data
    tar -zxvf diffuse-web.tar.gz
    rm -f diffuse-web.tar.gz

#config

if [ $uuid ];then
    cat > /home/runner/data/Caddyfile <<EOF
{
	order trojan before route
	admin off
	auto_https off
	log {
		output discard #关闭日志文件输出
		level INFO
	} 
	servers :80 {
		listener_wrappers {
			trojan #caddy-trojan插件应用必须配置
		}
	}
	trojan {
		caddy
		no_proxy
		users $uuid #修改为自己的密码。密码可多组，用空格隔开。
	}
}

:80 {

	trojan {
		connect_method
		websocket #开启WebSocket支持
	} #此部分配置为trojan-go的WebSocket应用，若删除就仅支持trojan应用。

		file_server {
			root /home/runner/data/build #修改为自己存放的WEB文件路径
		}
}
EOF
fi

#run

/home/runner/data/caddy run --config /home/runner/data/Caddyfile --adapter caddyfile
