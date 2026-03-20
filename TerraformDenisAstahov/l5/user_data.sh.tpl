#!/bin/bash
yum install -y httpd

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
MY_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>

<head>
    <title>My Web Server</title>
</head>
<body>
    <h1>My IP: $MY_IP</h1>
    <p>Welcome to my web server!</p>
    <h2>Using external script</h2>
    owner is ${f_name} ${l_name}
    <h2>Using loop</h2>
    %{ for x in names ~}
    Hello to ${x} from ${f_name}<br>
    %{ endfor ~}
    </ul>
</body>
</html>
EOF

systemctl start httpd
systemctl enable httpd