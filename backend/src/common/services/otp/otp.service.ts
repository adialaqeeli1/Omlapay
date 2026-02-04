import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);
  private readonly apiKey: string | null;
  private readonly apiUrl: string;
  private readonly senderName: string;
  private readonly isConfigured: boolean;

  constructor(private configService: ConfigService) {
    this.apiKey = this.configService.get<string>('TAQNYAT_API_KEY') || '';
    this.apiUrl =
      this.configService.get<string>('TAQNYAT_API_URL') || '';
    this.senderName =
      this.configService.get<string>('TAQNYAT_SENDER_NAME') || '';

    if (!this.apiKey) {
      this.logger.warn(
        'Taqnyat API key not configured. SMS functionality will be disabled.',
      );
      this.isConfigured = false;
    } else {
      this.isConfigured = true;
    }
  }

  async sendOTP(phoneNumber: string, otp: string): Promise<void> {
    try {
      if (!this.isConfigured || !this.apiKey) {
        this.logger.warn(
          `Taqnyat not configured. Would send OTP ${otp} to ${phoneNumber}`,
        );
        console.log(`[SMS] OTP for ${phoneNumber}: ${otp}`);
        return;
      }

      const message = `Your OmlaPay verification code is: ${otp}. Valid for 60 seconds. Do not share this code with anyone.`;

      // Remove '+' and convert to number for recipients array
      const recipientNumber = parseInt(phoneNumber.replace('+', ''));

      const response = await fetch(`${this.apiUrl}/messages`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          recipients: [recipientNumber],
          body: message,
          sender: this.senderName,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(
          `Taqnyat API error: ${response.status} - ${JSON.stringify(data)}`,
        );
      }

      this.logger.log(
        `OTP sent successfully to ${phoneNumber}. Status: ${data.statusCode}`,
      );
    } catch (error) {
      console.log(error);
      this.logger.error(`Failed to send OTP to ${phoneNumber}:`, error);
      // Fallback to console log in development
      console.log(`[SMS FAILED] OTP for ${phoneNumber}: ${otp}`);
      throw error;
    }
  }

  async sendPasscodeResetOTP(phoneNumber: string, otp: string): Promise<void> {
    try {
      if (!this.isConfigured || !this.apiKey) {
        this.logger.warn(
          `Taqnyat not configured. Would send passcode reset OTP ${otp} to ${phoneNumber}`,
        );
        console.log(`[SMS] Passcode Reset OTP for ${phoneNumber}: ${otp}`);
        return;
      }

      const message = `Your OmlaPay passcode reset code is: ${otp}. Valid for 60 seconds. If you didn't request this, please ignore.`;

      // Remove '+' and convert to number for recipients array
      const recipientNumber = parseInt(phoneNumber.replace('+', ''));

      const response = await fetch(`${this.apiUrl}/messages`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          recipients: [recipientNumber],
          body: message,
          sender: this.senderName,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(
          `Taqnyat API error: ${response.status} - ${JSON.stringify(data)}`,
        );
      }

      this.logger.log(
        `Passcode reset OTP sent successfully to ${phoneNumber}. Status: ${data.statusCode}`,
      );
    } catch (error) {
      this.logger.error(
        `Failed to send passcode reset OTP to ${phoneNumber}:`,
        error,
      );
      // Fallback to console log in development
      console.log(
        `[SMS FAILED] Passcode Reset OTP for ${phoneNumber}: ${otp}`,
      );
      throw error;
    }
  }
}

