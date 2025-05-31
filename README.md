# 🚀 Event Announcement System

A fully serverless, event-driven web application built with AWS and Terraform. This project allows users to submit event announcements via a web form, stores the data in Amazon S3, and sends notifications to subscribers using Amazon SNS. All infrastructure is provisioned using Terraform and deployed via GitHub Actions.

---

## 🛠️ Tech Stack

- **Frontend:** HTML, CSS, JavaScript
- **Backend:** AWS Lambda (Python)
- **API Gateway:** REST API (Lambda Proxy Integration)
- **Storage:** Amazon S3 (event data in JSON)
- **Notifications:** Amazon SNS (email/SMS subscribers)
- **Infrastructure as Code:** Terraform
- **CI/CD:** GitHub Actions

---

## 📦 Features

- Submit event announcements (title, description, date)
- Automatically store event data as JSON in S3
- Notify subscribers via SNS (email/SMS)
- CI/CD pipeline using GitHub Actions
- Fully managed and scalable with serverless infrastructure

---

## 🧱 Architecture

```plaintext
[ User (Browser) ]
       |
       v
[HTML Form (Frontend)]
       |
       v
[API Gateway (POST /event)]
       |
       v
[AWS Lambda Function]
  ├── Store JSON to S3
  └── Publish to SNS Topic
