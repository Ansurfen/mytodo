package main

import (
	"fmt"
	"html/template"
	"net/smtp"
	"strings"
)

func sendEmail() {
	smtpHost := "smtp.qq.com" // QQ 邮箱的 SMTP 服务器
	smtpPort := "587"         // 使用 587 端口
	senderEmail := ""         // 发件人邮箱
	senderPassword := ""      // 在 QQ 邮箱设置的应用专用密码
	receiverEmail := ""       // 收件人邮箱

	// 验证码
	code := "123456"

	// 定义 HTML 邮件模板
	emailTemplate := ``

	// 创建邮件内容，使用模板渲染验证码
	tmpl, err := template.New("email").Parse(emailTemplate)
	if err != nil {
		fmt.Println("Error parsing template:", err)
		return
	}

	// 渲染模板
	var body strings.Builder
	err = tmpl.Execute(&body, map[string]interface{}{
		"Code": code,
	})
	if err != nil {
		fmt.Println("Error executing template:", err)
		return
	}

	subject := "Subject: MyTodo 验证邮件\n" +
		"Content-Type: text/html; charset=UTF-8\n" +
		"From: " + senderEmail + "\n" +
		"To: " + receiverEmail + "\n" +
		"\n"
	message := []byte(subject + body.String())

	// 认证信息
	auth := smtp.PlainAuth("", senderEmail, senderPassword, smtpHost)

	// 发送邮件
	err = smtp.SendMail(smtpHost+":"+smtpPort, auth, senderEmail, []string{receiverEmail}, message)
	if err != nil {
		fmt.Println("Error sending email:", err)
		return
	}

	fmt.Println("Email sent successfully!")
}

func main() {
	sendEmail()
}
