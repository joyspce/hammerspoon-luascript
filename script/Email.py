#!/usr/bin/python
# -*- coding: UTF-8 -*-

import smtplib
from email.mime.text import MIMEText

mail_host = 'smtp.qq.com'
mail_user = '501919181'

mail_pass = 
sender = '501919181@qq.com'
receivers = 'joysnipple@icloud.com'
subject = 'auot sent mail'
text = 'key :verticalAccuracy var :10.0key :horizontalAccuracy var :65.0key :latitude var :28.306581094129key :longitude var :117.71447359876key :speed var :-1.0key :timestamp var :1539620150.2165key :__luaSkinType var :CLLocationkey :course var :-1.0key :altitude var :58.81619644165 time :2018-10-16 00:15'
message = MIMEText(text, 'plain', 'utf-8')
message['From'] = sender
message['To'] = receivers
message['Subject'] = subject
try:
    smtpObj = smtplib.SMTP()
    smtpObj.connect(mail_host, 25)
    smtpObj.login(mail_user,mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print "邮件发送成功"
except smtplib.SMTPException:
    print "Error: 无法发送邮件"
