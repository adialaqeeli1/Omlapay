import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private readonly fromEmail: string;
  private readonly fromName: string;
  private readonly mailgunApiKey: string;
  private readonly mailgunDomain: string;
  private readonly mailgunBaseUrl: string;

  constructor(private configService: ConfigService) {
    this.mailgunApiKey = this.configService.get<string>('MAILGUN_API_KEY') || '';
    this.mailgunDomain = this.configService.get<string>('MAILGUN_SANDBOX_DOMAIN') || '';
    this.mailgunBaseUrl = this.configService.get<string>('MAILGUN_BASE_URL') || '';
    this.fromEmail = `noreply@${this.mailgunDomain}`;
    this.fromName = 'Omlapay';

    if (!this.mailgunApiKey || !this.mailgunDomain || !this.mailgunBaseUrl) {
      this.logger.warn(
        'Mailgun not configured. Email functionality will be disabled. Missing: ' +
        (!this.mailgunApiKey ? 'MAILGUN_API_KEY ' : '') +
        (!this.mailgunDomain ? 'MAILGUN_SANDBOX_DOMAIN ' : '') +
        (!this.mailgunBaseUrl ? 'MAILGUN_BASE_URL' : '')
      );
    } else {
      this.logger.log('Mailgun configured successfully');
    }
  }

  private async sendMailgunEmail(
    to: string,
    subject: string,
    text: string,
    html: string,
  ): Promise<void> {
    if (!this.mailgunApiKey || !this.mailgunDomain) {
      this.logger.warn(
        `Mailgun not configured. Would send email to ${to} with subject: ${subject}`,
      );
      console.log(`[EMAIL] To: ${to}, Subject: ${subject}`);
      if (process.env.NODE_ENV === 'development') {
        console.log(`[EMAIL CONTENT]\n${text}`);
      }
      return;
    }

    try {
      const formData = new URLSearchParams();
      formData.append('from', `${this.fromName} <${this.fromEmail}>`);
      formData.append('to', to);
      formData.append('subject', subject);
      formData.append('text', text);
      formData.append('html', html);

      const auth = Buffer.from(`api:${this.mailgunApiKey}`).toString('base64');
      const url = `${this.mailgunBaseUrl}/v3/${this.mailgunDomain}/messages`;

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${auth}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString(),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Mailgun API error: ${response.status} ${response.statusText} - ${errorText}`);
      }

      const result = await response.json();
      this.logger.log(`Email sent successfully to ${to}. Message ID: ${result.id}`);
    } catch (error) {
      this.logger.error(`Failed to send email to ${to}:`, error);
      // Fallback to console log in development
      if (process.env.NODE_ENV === 'development') {
        console.log(`[EMAIL FAILED] To: ${to}, Subject: ${subject}\n${text}`);
      }
      throw error;
    }
  }

  async sendVerificationEmail(email: string, code: string): Promise<void> {
    const subject = 'Verify Your Email - Omlapay';
    const text = `Your Omlapay email verification code is: ${code}. This code is valid for 5 minutes. If you didn't request this, please ignore this email.`;
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Verify Your Email</h2>
        <p>Your Omlapay email verification code is:</p>
        <div style="background-color: #f5f5f5; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
          ${code}
        </div>
        <p style="color: #666;">This code is valid for 5 minutes.</p>
        <p style="color: #666;">If you didn't request this verification, please ignore this email.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        <p style="color: #999; font-size: 12px;">This is an automated email from Omlapay. Please do not reply.</p>
      </div>
    `;

    try {
      await this.sendMailgunEmail(email, subject, text, html);
      this.logger.log(`Verification email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(
        `Failed to send verification email to ${email}:`,
        error,
      );
      console.log(`[EMAIL FAILED] Verification code for ${email}: ${code}`);
      throw error;
    }
  }

  async sendPasscodeResetOTP(email: string, otp: string): Promise<void> {
    const subject = 'Passcode Reset Request - Omlapay';
    const text = `Your Omlapay passcode reset code is: ${otp}. This code is valid for 60 seconds. If you didn't request this, please ignore this email and contact support immediately.`;
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Passcode Reset Request</h2>
        <p>You requested to reset your passcode. Your verification code is:</p>
        <div style="background-color: #f5f5f5; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
          ${otp}
        </div>
        <p style="color: #666;">This code is valid for 60 seconds.</p>
        <p style="color: #d9534f; font-weight: bold;">⚠️ Security Alert:</p>
        <p style="color: #666;">If you didn't request a passcode reset, please ignore this email and contact our support team immediately.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        <p style="color: #999; font-size: 12px;">This is an automated email from Omlapay. Please do not reply.</p>
      </div>
    `;

    try {
      await this.sendMailgunEmail(email, subject, text, html);
      this.logger.log(`Passcode reset OTP email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(
        `Failed to send passcode reset OTP to ${email}:`,
        error,
      );
      console.log(`[EMAIL FAILED] Passcode reset OTP for ${email}: ${otp}`);
      throw error;
    }
  }

  async sendOTP(email: string, otp: string): Promise<void> {
    const subject = 'Your Verification Code - Omlapay';
    const text = `Your Omlapay verification code is: ${otp}. This code is valid for 60 seconds. Do not share this code with anyone.`;
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Your Verification Code</h2>
        <p>Your Omlapay verification code is:</p>
        <div style="background-color: #f5f5f5; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
          ${otp}
        </div>
        <p style="color: #666;">This code is valid for 60 seconds.</p>
        <p style="color: #666;">Do not share this code with anyone.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        <p style="color: #999; font-size: 12px;">This is an automated email from Omlapay. Please do not reply.</p>
      </div>
    `;

    try {
      await this.sendMailgunEmail(email, subject, text, html);
      this.logger.log(`OTP email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send OTP to ${email}:`, error);
      console.log(`[EMAIL FAILED] OTP for ${email}: ${otp}`);
      throw error;
    }
  }

  async sendUserBlockNotification(
    email: string,
    reason: string,
    supportEmail: string = 'support@gmail.com',
  ): Promise<void> {
    const subject = 'Account Restriction Notice - Omlapay';
    const text = `Your Omlapay account has been restricted. Reason: ${reason}. Please contact support at ${supportEmail} for more details.`;
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #d9534f;">Account Restriction Notice</h2>
        <p>Your Omlapay account has been restricted.</p>
        <div style="background-color: #f8f9fa; padding: 20px; margin: 20px 0; border-left: 4px solid #d9534f;">
          <p style="margin: 0;"><strong>Reason:</strong></p>
          <p style="margin: 10px 0 0 0;">${reason}</p>
        </div>
        <p style="color: #666;">Your account is restricted. Please contact support for more details.</p>
        <p style="color: #666;">Support Email: <a href="mailto:${supportEmail}">${supportEmail}</a></p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        <p style="color: #999; font-size: 12px;">This is an automated email from Omlapay. Please do not reply.</p>
      </div>
    `;

    try {
      await this.sendMailgunEmail(email, subject, text, html);
      this.logger.log(`Block notification email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(
        `Failed to send block notification to ${email}:`,
        error,
      );
      console.log(`[EMAIL FAILED] Block notification for ${email}: ${reason}`);
      // Don't throw error - email failure shouldn't block the user blocking action
    }
  }

  async sendInternalBlockNotification(
    internalEmail: string,
    userIdentifier: string,
    reason: string,
    adminId: string,
  ): Promise<void> {
    const subject = 'User Blocked - Suspicious Activity Alert';
    const text = `A user has been blocked by Admin ${adminId}. User: ${userIdentifier}. Reason: ${reason}.`;
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #d9534f;">User Blocked - Suspicious Activity</h2>
        <p><strong>User Identifier:</strong> ${userIdentifier}</p>
        <p><strong>Status Change:</strong> Active → Blocked</p>
        <p><strong>Reason:</strong> ${reason}</p>
        <p><strong>Action Performed By:</strong> Admin ${adminId}</p>
        <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        <p style="color: #999; font-size: 12px;">This is an automated notification from Omlapay Admin System.</p>
      </div>
    `;

    try {
      await this.sendMailgunEmail(internalEmail, subject, text, html);
      this.logger.log(
        `Internal block notification email sent successfully to ${internalEmail}`,
      );
    } catch (error) {
      this.logger.error(
        `Failed to send internal block notification to ${internalEmail}:`,
        error,
      );
      console.log(
        `[EMAIL FAILED] Internal block notification for ${internalEmail}`,
      );
      // Don't throw error - email failure shouldn't block the user blocking action
    }
  }

  async sendTicketResponse(
    email: string,
    ticketTitle: string,
    responseMessage: string,
  ): Promise<void> {
    const subject = `Response to Your Support Ticket: ${ticketTitle}`;
    const text = `Your support ticket "${ticketTitle}" has received a response:\n\n${responseMessage}\n\nPlease log in to your account to view the full conversation.`;
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Support Ticket Response</h2>
        <p><strong>Ticket:</strong> ${ticketTitle}</p>
        <div style="background-color: #f8f9fa; padding: 20px; margin: 20px 0; border-left: 4px solid #007bff;">
          <p style="margin: 0; white-space: pre-wrap;">${responseMessage}</p>
        </div>
        <p style="color: #666;">Please log in to your account to view the full conversation and respond if needed.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        <p style="color: #999; font-size: 12px;">This is an automated email from Omlapay. Please do not reply.</p>
      </div>
    `;

    try {
      await this.sendMailgunEmail(email, subject, text, html);
      this.logger.log(`Ticket response email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send ticket response to ${email}:`, error);
      console.log(`[EMAIL FAILED] Ticket response for ${email}`);
      // Don't throw error - email failure shouldn't block the response
    }
  }
}

