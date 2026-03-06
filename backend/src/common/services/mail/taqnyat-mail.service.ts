import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

/**
 * Taqnyat API Error Response
 */
interface TaqnyatErrorResponse {
  status: number;
  ResponseStatus: 'fail';
  Data: null;
  Error: {
    ErrorCode: number;
    MessageAr: string;
    MessageEn: string;
  };
}

/**
 * Taqnyat API Success Response
 */
interface TaqnyatSuccessResponse {
  status: number;
  ResponseStatus: 'success';
  Data: {
    msgId: number;
    result: number;
    MessageAr: string;
    MessageEn: string;
    price: string;
  };
  Error: null;
}

type TaqnyatResponse = TaqnyatSuccessResponse | TaqnyatErrorResponse;

/**
 * Taqnyat Mail Service Error
 */
class TaqnyatMailError extends Error {
  constructor(
    message: string,
    public readonly errorCode?: number,
    public readonly arabicMessage?: string,
  ) {
    super(message);
    this.name = 'TaqnyatMailError';
  }
}

/**
 * Mail service using Taqnyat API for sending emails.
 * Replaces Mailgun with Taqnyat as the email provider.
 * 
 * @see https://dev.taqnyat.sa/ar/doc/mail/
 */
@Injectable()
export class TaqnyatMailService {
  private readonly logger = new Logger(TaqnyatMailService.name);
  private readonly fromEmail: string;
  private readonly fromName: string;
  private readonly bearerToken: string;
  private readonly taqnyatApiUrl: string;
  private readonly isConfigured: boolean;

  constructor(private configService: ConfigService) {
    this.bearerToken = this.configService.get<string>('TAQNYAT_BEARER_TOKEN') || '';
    this.taqnyatApiUrl = this.configService.get<string>(
      'TAQNYAT_API_URL',
      'https://api.taqnyat.sa/mailSend.php',
    );
    this.fromEmail = this.configService.get<string>('TAQNYAT_FROM_EMAIL') || '';
    this.fromName = this.configService.get<string>('TAQNYAT_FROM_NAME', 'Omlapay');

    this.isConfigured = !!(this.bearerToken && this.fromEmail);

    if (!this.isConfigured) {
      this.logger.warn(
        'Taqnyat not configured. Email functionality will be disabled. Missing: ' +
        (!this.bearerToken ? 'TAQNYAT_BEARER_TOKEN ' : '') +
        (!this.fromEmail ? 'TAQNYAT_FROM_EMAIL' : ''),
      );
    } else {
      this.logger.log('Taqnyat mail service configured successfully');
    }
  }

  /**
   * Send email via Taqnyat API
   * 
   * @param to - Recipient email address
   * @param subject - Email subject
   * @param text - Plain text content
   * @param html - HTML content
   * @param campaignName - Campaign name for tracking
   * @throws {TaqnyatMailError} When API returns an error
   * @throws {InternalServerErrorException} When network or parsing fails
   */
  private async sendTaqnyatEmail(
    to: string,
    subject: string,
    text: string,
    html: string,
    campaignName: string = 'Omlapay Notification',
  ): Promise<void> {
    if (!this.isConfigured) {
      this.logger.warn(
        `Taqnyat not configured. Would send email to ${to} with subject: ${subject}`,
      );
      console.log(`[EMAIL] To: ${to}, Subject: ${subject}`);
      if (process.env.NODE_ENV === 'development') {
        console.log(`[EMAIL CONTENT]\n${text}`);
      }
      return;
    }

    // Input validation
    if (!to || !this.isValidEmail(to)) {
      throw new TaqnyatMailError('Invalid recipient email address', 15);
    }

    if (!subject || subject.trim().length === 0) {
      throw new TaqnyatMailError('Email subject cannot be empty', 16);
    }

    const messageContent = html || text;
    if (!messageContent || messageContent.trim().length === 0) {
      throw new TaqnyatMailError('Email message cannot be empty', 17);
    }

    try {
      // Build query parameters for Taqnyat API
      const params = new URLSearchParams({
        bearerTokens: this.bearerToken,
        campaignName: campaignName,
        subject: subject,
        from: this.fromEmail,
        to: to,
        msg: messageContent,
      });

      const url = `${this.taqnyatApiUrl}?${params.toString()}`;

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      });

      // Parse response
      let result: TaqnyatResponse;
      try {
        result = await response.json();
      } catch (parseError) {
        this.logger.error('Failed to parse Taqnyat API response', parseError);
        throw new InternalServerErrorException('Failed to parse email service response');
      }

      // Handle error response
      if (result.ResponseStatus === 'fail' || result.Error) {
        const error = result.Error;
        const errorMessage = error?.MessageEn || 'Unknown error from Taqnyat API';
        
        this.logger.error(
          `Taqnyat API error (Code ${error?.ErrorCode}): ${errorMessage}`,
          {
            to,
            subject,
            errorCode: error?.ErrorCode,
            arabicMessage: error?.MessageAr,
          },
        );

        throw new TaqnyatMailError(
          errorMessage,
          error?.ErrorCode,
          error?.MessageAr,
        );
      }

      // Success
      this.logger.log(
        `Email sent successfully to ${to}. Message ID: ${result.Data?.msgId}, Price: ${result.Data?.price}`,
      );
    } catch (error) {
      if (error instanceof TaqnyatMailError) {
        // Re-throw Taqnyat-specific errors
        throw error;
      }

      // Handle network or other unexpected errors
      this.logger.error(`Failed to send email to ${to}:`, error);
      
      // Fallback to console log in development
      if (process.env.NODE_ENV === 'development') {
        console.log(`[EMAIL FAILED] To: ${to}, Subject: ${subject}\n${text}`);
      }

      throw new InternalServerErrorException(
        'Failed to send email. Please try again later.',
      );
    }
  }

  /**
   * Validate email format
   */
  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Send email verification code to user
   * 
   * @param email - Recipient email address
   * @param code - Verification code
   */
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
      await this.sendTaqnyatEmail(
        email,
        subject,
        text,
        html,
        'Email Verification',
      );
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

  /**
   * Send passcode reset OTP to user
   * 
   * @param email - Recipient email address
   * @param otp - One-time password
   */
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
      await this.sendTaqnyatEmail(
        email,
        subject,
        text,
        html,
        'Passcode Reset',
      );
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

  /**
   * Send general OTP to user
   * 
   * @param email - Recipient email address
   * @param otp - One-time password
   */
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
      await this.sendTaqnyatEmail(
        email,
        subject,
        text,
        html,
        'OTP Verification',
      );
      this.logger.log(`OTP email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send OTP to ${email}:`, error);
      console.log(`[EMAIL FAILED] OTP for ${email}: ${otp}`);
      throw error;
    }
  }

  /**
   * Send account block notification to user
   * 
   * @param email - Recipient email address
   * @param reason - Reason for blocking
   * @param supportEmail - Support contact email
   */
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
      await this.sendTaqnyatEmail(
        email,
        subject,
        text,
        html,
        'Account Restriction',
      );
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

  /**
   * Send internal notification when user is blocked (for admin/ops team)
   * 
   * @param internalEmail - Internal team email address
   * @param userIdentifier - User identifier (email, phone, ID)
   * @param reason - Reason for blocking
   * @param adminId - Admin who performed the action
   */
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
      await this.sendTaqnyatEmail(
        internalEmail,
        subject,
        text,
        html,
        'Internal Alert - User Blocked',
      );
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

  /**
   * Send support ticket response notification to user
   * 
   * @param email - Recipient email address
   * @param ticketTitle - Support ticket title
   * @param responseMessage - Admin's response message
   */
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
      await this.sendTaqnyatEmail(
        email,
        subject,
        text,
        html,
        'Support Ticket Response',
      );
      this.logger.log(`Ticket response email sent successfully to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send ticket response to ${email}:`, error);
      console.log(`[EMAIL FAILED] Ticket response for ${email}`);
      // Don't throw error - email failure shouldn't block the response
    }
  }
}
