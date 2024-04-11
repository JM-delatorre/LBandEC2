#!/bin/bash
yum install -y httpd
systemctl start httpd
systemctl enable httpd

echo "<h1>Deployed via Terraform</h1>" > /var/www/html/index.html
echo "<h3>Additional information for instance</h3>" >> /var/www/html/index.html
echo "<ul>" >> /var/www/html/index.html
echo "<li>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</li>" >> /var/www/html/index.html
echo "<li>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</li>" >> /var/www/html/index.html
echo "</ul>" >> /var/www/html/index.html

systemctl restart httpd