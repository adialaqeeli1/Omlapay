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

    if (!this.apiKey || !this.apiUrl || !this.senderName) {
      this.logger.warn(
        'Taqnyat not fully configured (missing API key, URL, or sender name). SMS functionality will be disabled.',
      );
      this.isConfigured = false;
    } else {
      this.isConfigured = true;
      this.logger.log('Taqnyat SMS service configured successfully');
    }
  }

  async sendOTP(phoneNumber: string, otp: string): Promise<void> {
    // Check if it's an Indian number
    const isIndianNumber = phoneNumber.startsWith('+91');

    // In development & Indian numbers, use default OTP - don't send actual SMS
    if (process.env.NODE_ENV !== 'production' || isIndianNumber) {
      console.log(`[DEV] OTP for ${phoneNumber}: ${otp}`);
      return;
    }

    // Production: Send actual SMS for Saudi numbers
    try {
      if (!this.isConfigured) {
        this.logger.error(
          `Taqnyat not configured in production. Cannot send OTP to ${phoneNumber}`,
        );
        throw new Error('SMS service not configured');
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
      this.logger.error(`Failed to send OTP to ${phoneNumber}:`, error);
      throw error;
    }
  }

  async sendPasscodeResetOTP(phoneNumber: string, otp: string): Promise<void> {
    // Check if it's an Indian number
    const isIndianNumber = phoneNumber.startsWith('+91');

    // In development & Indian numbers, use default OTP - don't send actual SMS
    if (process.env.NODE_ENV !== 'production' || isIndianNumber) {
      console.log(`[DEV] Passcode Reset OTP for ${phoneNumber}: ${otp}`);
      return;
    }

    // Production: Send actual SMS for Saudi numbers
    try {
      if (!this.isConfigured) {
        this.logger.error(
          `Taqnyat not configured in production. Cannot send passcode reset OTP to ${phoneNumber}`,
        );
        throw new Error('SMS service not configured');
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
      throw error;
    }
  }
}

