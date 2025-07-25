import smtplib
import sys
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

if len(sys.argv) < 5:
    print("Usage: send_email.py <name> <address> <email> <order_items>")
    sys.exit(1)

name = sys.argv[1]
address = sys.argv[2]
email = sys.argv[3]
order_items = sys.argv[4]
bill = sys.argv[5]

# Email details
sender_email = "akshay.nov.20@gmail.com"  # Replace with your email
sender_password = "hzpxvvzjknjkaunr"  # Replace with your email password

# Email content
subject = "Order Confirmation"
body = f"""
Dear {name},

Thank you for placing your order with us! Here are your order details:

Delivery Address:
{address}

Bill:
{bill}

Your order has been successfully placed. We will deliver it to your address soon.

Best Regards,
Food Ordering Team
"""

# Create the email message
msg = MIMEMultipart()
msg["From"] = sender_email
msg["To"] = email
msg["Subject"] = subject
msg.attach(MIMEText(body, "plain"))

try:
    # Connect to the SMTP server and send the email
    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(sender_email, sender_password)
        server.send_message(msg)
    print("Email sent successfully!")
except Exception as e:
    print(f"Failed to send email: {e}")
    sys.exit(1)
