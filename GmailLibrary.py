import imaplib
import smtplib
import email
from email.header import decode_header
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from robot.api import logger
import re

class GmailLibrary:
    """Custom library for Gmail automation using IMAP and SMTP"""
    
    def __init__(self):
        self.imap = None
        self.username = None
        self.password = None
        
    def connect_to_gmail(self, email_address, password):
        """Connects to Gmail using IMAP"""
        try:
            self.username = email_address
            self.password = password
            self.imap = imaplib.IMAP4_SSL("imap.gmail.com")
            self.imap.login(email_address, password)
            logger.info(f"Successfully connected to Gmail as {email_address}")
        except Exception as e:
            logger.error(f"Failed to connect to Gmail: {str(e)}")
            raise
    
    def select_mailbox(self, mailbox="inbox"):
        """Selects a mailbox/folder"""
        if not self.imap:
            raise Exception("Not connected to Gmail. Use Connect To Gmail first.")
        
        status, messages = self.imap.select(mailbox)
        logger.info(f"Selected mailbox: {mailbox}")
        return status
    
    def search_emails(self, criteria="ALL"):
        """Searches for emails based on criteria"""
        if not self.imap:
            raise Exception("Not connected to Gmail. Use Connect To Gmail first.")
        
        status, messages = self.imap.search(None, criteria)
        # Convert bytes to list of byte strings
        email_ids = messages[0].split()
        logger.info(f"Found {len(email_ids)} emails matching criteria: {criteria}")
        return email_ids
    
    def get_latest_email_id(self, criteria="ALL"):
        """Gets the ID of the most recent email matching criteria"""
        email_ids = self.search_emails(criteria)
        
        if not email_ids:
            raise Exception(f"No emails found matching criteria: {criteria}")
        
        # Return the last (most recent) email ID as bytes
        latest_id = email_ids[-1]
        logger.info(f"Latest email ID: {latest_id}")
        return latest_id
    
    def get_email_subject(self, email_id):
        """Gets the subject of an email"""
        # Ensure email_id is bytes
        if isinstance(email_id, str):
            email_id = email_id.encode()
            
        status, msg_data = self.imap.fetch(email_id, "(RFC822)")
        
        for response_part in msg_data:
            if isinstance(response_part, tuple):
                msg = email.message_from_bytes(response_part[1])
                subject = decode_header(msg["Subject"])[0][0]
                
                if isinstance(subject, bytes):
                    subject = subject.decode()
                
                logger.info(f"Email subject: {subject}")
                return subject
    
    def get_email_body(self, email_id):
        """Gets the body of an email"""
        # Ensure email_id is bytes
        if isinstance(email_id, str):
            email_id = email_id.encode()
            
        status, msg_data = self.imap.fetch(email_id, "(RFC822)")
        
        for response_part in msg_data:
            if isinstance(response_part, tuple):
                msg = email.message_from_bytes(response_part[1])
                
                if msg.is_multipart():
                    for part in msg.walk():
                        if part.get_content_type() == "text/plain":
                            body = part.get_payload(decode=True).decode()
                            return body
                else:
                    body = msg.get_payload(decode=True).decode()
                    return body
    
    def verify_email_contains_text(self, email_id, expected_text):
        """Verifies that an email body contains specific text"""
        body = self.get_email_body(email_id)
        
        if expected_text in body:
            logger.info(f"Email contains expected text: {expected_text}")
            return True
        else:
            raise AssertionError(f"Email does not contain expected text: {expected_text}")
    
    def send_email(self, to_address, subject, body):
        """Sends an email using Gmail SMTP"""
        if not self.username or not self.password:
            raise Exception("Not connected to Gmail. Use Connect To Gmail first.")
        
        try:
            # Create message
            msg = MIMEMultipart()
            msg['From'] = self.username
            msg['To'] = to_address
            msg['Subject'] = subject
            msg.attach(MIMEText(body, 'plain'))
            
            # Connect to SMTP server and send
            server = smtplib.SMTP('smtp.gmail.com', 587)
            server.starttls()
            server.login(self.username, self.password)
            server.send_message(msg)
            server.quit()
            
            logger.info(f"Email sent successfully to {to_address} with subject: {subject}")
        except Exception as e:
            logger.error(f"Failed to send email: {str(e)}")
            raise
    
    def extract_urls_from_email(self, email_id):
        """Extracts all URLs from an email body"""
        body = self.get_email_body(email_id)
        
        # Regular expression to find URLs
        url_pattern = r'https?://[^\s<>"{}|\\^`\[\]]+'
        urls = re.findall(url_pattern, body)
        
        logger.info(f"Found {len(urls)} URLs in email: {urls}")
        return urls
    
    def get_first_url_from_email(self, email_id):
        """Gets the first URL from an email body"""
        urls = self.extract_urls_from_email(email_id)
        
        if urls:
            logger.info(f"First URL: {urls[0]}")
            return urls[0]
        else:
            raise Exception("No URLs found in email body")
    
    def disconnect_from_gmail(self):
        """Closes the IMAP connection"""
        if self.imap:
            self.imap.close()
            self.imap.logout()
            logger.info("Disconnected from Gmail")
