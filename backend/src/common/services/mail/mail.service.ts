import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as sgMail from '@sendgrid/mail';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private readonly fromEmail: string;
  private readonly fromName: string;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('SENDGRID_API_KEY');
    this.fromEmail =
      this.configService.get<string>('SENDGRID_FROM_EMAIL') ||
      'noreply@omlapay.com';
    this.fromName =
      this.configService.get<string>('SENDGRID_FROM_NAME') || 'OmlaPay';

    if (!apiKey) {
      this.logger.warn(
        'SendGrid API key not configured. Email functionality will be disabled.',
      );
    } else {
      sgMail.setApiKey(apiKey);
    }
  }

  async sendVerificationEmail(email: string, code: string): Promise<void> {
    try {
      const msg = {
        to: email,
        from: {
          email: this.fromEmail,
          name: this.fromName,
        },
        subject: 'Verify Your Email - OmlaPay',
        text: `Your OmlaPay email verification code is: ${code}. This code is valid for 5 minutes. If you didn't request this, please ignore this email.`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #333;">Verify Your Email</h2>
            <p>Your OmlaPay email verification code is:</p>
            <div style="background-color: #f5f5f5; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
              ${code}
            </div>
            <p style="color: #666;">This code is valid for 5 minutes.</p>
            <p style="color: #666;">If you didn't request this verification, please ignore this email.</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
            <p style="color: #999; font-size: 12px;">This is an automated email from OmlaPay. Please do not reply.</p>
          </div>
        `,
      };

      if (!this.configService.get<string>('SENDGRID_API_KEY')) {
        this.logger.warn(
          `SendGrid not configured. Would send verification email to ${email}`,
        );
        console.log(`[EMAIL] Verification code for ${email}: ${code}`);
        return;
      }

      await sgMail.send(msg);
      this.logger.log(`Verification email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(
        `Failed to send verification email to ${email}:`,
        error,
      );
      // Fallback to console log in development
      console.log(`[EMAIL FAILED] Verification code for ${email}: ${code}`);
      throw error;
    }
  }

  async sendPasscodeResetOTP(email: string, otp: string): Promise<void> {
    try {
      const msg = {
        to: email,
        from: {
          email: this.fromEmail,
          name: this.fromName,
        },
        subject: 'Passcode Reset Request - OmlaPay',
        text: `Your OmlaPay passcode reset code is: ${otp}. This code is valid for 60 seconds. If you didn't request this, please ignore this email and contact support immediately.`,
        html: `
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
            <p style="color: #999; font-size: 12px;">This is an automated email from OmlaPay. Please do not reply.</p>
          </div>
        `,
      };

      if (!this.configService.get<string>('SENDGRID_API_KEY')) {
        this.logger.warn(
          `SendGrid not configured. Would send passcode reset OTP to ${email}`,
        );
        console.log(`[EMAIL] Passcode reset OTP for ${email}: ${otp}`);
        return;
      }

      await sgMail.send(msg);
      this.logger.log(`Passcode reset OTP email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(
        `Failed to send passcode reset OTP to ${email}:`,
        error,
      );
      // Fallback to console log in development
      console.log(`[EMAIL FAILED] Passcode reset OTP for ${email}: ${otp}`);
      throw error;
    }
  }

  async sendOTP(email: string, otp: string): Promise<void> {
    try {
      const msg = {
        to: email,
        from: {
          email: this.fromEmail,
          name: this.fromName,
        },
        subject: 'Your Verification Code - OmlaPay',
        text: `Your OmlaPay verification code is: ${otp}. This code is valid for 60 seconds. Do not share this code with anyone.`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #333;">Your Verification Code</h2>
            <p>Your OmlaPay verification code is:</p>
            <div style="background-color: #f5f5f5; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
              ${otp}
            </div>
            <p style="color: #666;">This code is valid for 60 seconds.</p>
            <p style="color: #666;">Do not share this code with anyone.</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
            <p style="color: #999; font-size: 12px;">This is an automated email from OmlaPay. Please do not reply.</p>
          </div>
        `,
      };

      if (!this.configService.get<string>('SENDGRID_API_KEY')) {
        this.logger.warn(`SendGrid not configured. Would send OTP to ${email}`);
        console.log(`[EMAIL] OTP for ${email}: ${otp}`);
        return;
      }

      await sgMail.send(msg);
      this.logger.log(`OTP email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send OTP to ${email}:`, error);
      // Fallback to console log in development
      console.log(`[EMAIL FAILED] OTP for ${email}: ${otp}`);
      throw error;
    }
  }

  async sendUserBlockNotification(
    email: string,
    reason: string,
    supportEmail: string = 'support@gmail.com',
  ): Promise<void> {
    try {
      const msg = {
        to: email,
        from: {
          email: this.fromEmail,
          name: this.fromName,
        },
        subject: 'Account Restriction Notice - OmlaPay',
        text: `Your OmlaPay account has been restricted. Reason: ${reason}. Please contact support at ${supportEmail} for more details.`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #d9534f;">Account Restriction Notice</h2>
            <p>Your OmlaPay account has been restricted.</p>
            <div style="background-color: #f8f9fa; padding: 20px; margin: 20px 0; border-left: 4px solid #d9534f;">
              <p style="margin: 0;"><strong>Reason:</strong></p>
              <p style="margin: 10px 0 0 0;">${reason}</p>
            </div>
            <p style="color: #666;">Your account is restricted. Please contact support for more details.</p>
            <p style="color: #666;">Support Email: <a href="mailto:${supportEmail}">${supportEmail}</a></p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
            <p style="color: #999; font-size: 12px;">This is an automated email from OmlaPay. Please do not reply.</p>
          </div>
        `,
      };

      if (!this.configService.get<string>('SENDGRID_API_KEY')) {
        this.logger.warn(
          `SendGrid not configured. Would send block notification to ${email}`,
        );
        console.log(`[EMAIL] Block notification for ${email}: ${reason}`);
        return;
      }

      await sgMail.send(msg);
      this.logger.log(`Block notification email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(
        `Failed to send block notification to ${email}:`,
        error,
      );
      // Fallback to console log in development
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
    try {
      const msg = {
        to: internalEmail,
        from: {
          email: this.fromEmail,
          name: this.fromName,
        },
        subject: 'User Blocked - Suspicious Activity Alert',
        text: `A user has been blocked by Admin ${adminId}. User: ${userIdentifier}. Reason: ${reason}.`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #d9534f;">User Blocked - Suspicious Activity</h2>
            <p><strong>User Identifier:</strong> ${userIdentifier}</p>
            <p><strong>Status Change:</strong> Active → Blocked</p>
            <p><strong>Reason:</strong> ${reason}</p>
            <p><strong>Action Performed By:</strong> Admin ${adminId}</p>
            <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
            <p style="color: #999; font-size: 12px;">This is an automated notification from OmlaPay Admin System.</p>
          </div>
        `,
      };

      if (!this.configService.get<string>('SENDGRID_API_KEY')) {
        this.logger.warn(
          `SendGrid not configured. Would send internal block notification to ${internalEmail}`,
        );
        console.log(
          `[EMAIL] Internal block notification for ${internalEmail}: User ${userIdentifier} blocked by ${adminId}`,
        );
        return;
      }

      await sgMail.send(msg);
      this.logger.log(
        `Internal block notification email sent successfully to ${internalEmail}`,
      );
    } catch (error) {
      this.logger.error(
        `Failed to send internal block notification to ${internalEmail}:`,
        error,
      );
      // Don't throw error - email failure shouldn't block the user blocking action
      console.log(
        `[EMAIL FAILED] Internal block notification for ${internalEmail}`,
      );
    }
  }

  async sendTicketResponse(
    email: string,
    ticketTitle: string,
    responseMessage: string,
  ): Promise<void> {
    try {
      const msg = {
        to: email,
        from: {
          email: this.fromEmail,
          name: this.fromName,
        },
        subject: `Response to Your Support Ticket: ${ticketTitle}`,
        text: `Your support ticket "${ticketTitle}" has received a response:\n\n${responseMessage}\n\nPlease log in to your account to view the full conversation.`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #333;">Support Ticket Response</h2>
            <p><strong>Ticket:</strong> ${ticketTitle}</p>
            <div style="background-color: #f8f9fa; padding: 20px; margin: 20px 0; border-left: 4px solid #007bff;">
              <p style="margin: 0; white-space: pre-wrap;">${responseMessage}</p>
            </div>
            <p style="color: #666;">Please log in to your account to view the full conversation and respond if needed.</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
            <p style="color: #999; font-size: 12px;">This is an automated email from OmlaPay. Please do not reply.</p>
          </div>
        `,
      };

      if (!this.configService.get<string>('SENDGRID_API_KEY')) {
        this.logger.warn(
          `SendGrid not configured. Would send ticket response to ${email}`,
        );
        console.log(`[EMAIL] Ticket response for ${email}: ${ticketTitle}`);
        return;
      }

      await sgMail.send(msg);
      this.logger.log(`Ticket response email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send ticket response to ${email}:`, error);
      // Don't throw error - email failure shouldn't block the response
      console.log(`[EMAIL FAILED] Ticket response for ${email}`);
    }
  }
}

