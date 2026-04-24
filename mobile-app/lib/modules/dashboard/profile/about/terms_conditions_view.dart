import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extentions/context_extensions.dart';
import '../../../../widgets/common_back_button.dart';
import '../../../../widgets/markdown_html_view.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        leading: CommonBackButton(onPressed: () => GoRouter.of(context).pop()),
        title: Text(
          l10n.termsAndConditions,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: MarkdownHtmlView(
          data: '''<h1 align="center">Terms of Use</h1>

These Terms and Conditions (**"Terms"**) govern your access to and use of the custodial wallet services, physical and virtual payment cards, and associated digital applications (**"Services"**) provided by [Omlapay] through our mobile application and website, and form a legally binding agreement between {Omlapay}, a company incorporated in **Georgia** ("we," "us," or "our") and You ("You", "Your" or "User").

If you do not agree with these Terms, you must refrain from registering for an account in our Platform or using our services provided in our Platform.

---

## 1. Definitions

- **"Platform"** means the mobile application and web-based services offered by [Omlapay].
- **"User"** means any individual who owns an account or uses the Platform.
- **"Account"** refers to the user-specific profile created for accessing and utilizing the Services. Depending on the nature of the Services provided, this may include, but is not limited to, a Custodian Account, a Credit Account, a Self-Custody Wallet, and/or a Virtual Account, as applicable.
- **"Wallet"** refers to the custodial cryptocurrency wallet provided to Users.
- **"Cryptocurrency"** means any supported digital asset on the Platform.
- **"Binance"** refers to the third-party custodian with whom we have partnered for secure custody services.
- **"Blockchain Network Fees"** refers to third-party transaction processing fees paid to blockchain networks.
- **"Cards"** refer to the virtual or physical payment cards issued to Users for transactional use.

---

## 2. Acceptance of Terms of Use

1. By accessing or registering for an account on our mobile application or website, or service provided by {Omlapay} (collectively, the **"Platform"**), you confirm that you have read, understood and agree to be bound by these Terms, our Privacy Policy, and any other applicable guidelines or documents referenced herein.

2. You warrant that you are a natural person with at least eighteen (18) years old and have the legal capacity to enter into this binding agreement.

3. We reserve the right to revise these Terms of Use at any time by updating this page and notifying you through reasonable means, including but not limited to, email communication. Your continued use of our platform and/or Services after the effective date of any changes constitutes your acceptance of the updated terms. If you do not agree to the amended terms, you must discontinue use of our services and the Platform immediately and may contact us to close your account.

4. All communications from us may be sent electronically. You are responsible for ensuring that your email remains accurate and updated in your account settings.

5. Full Know Your Customer (KYC) and Anti-Money Laundering (AML) identity verification is required prior to accessing any features of the Platform, including wallet services and card issuance. Verification may require submission of national ID, passport, or any other documents deemed necessary.

---

## 3. Use of the Platform and Services

1. Our Platform does not provide investment advice or recommendations regarding digital currencies, crypto assets, or any related financial instruments. Users are encouraged to seek independent financial advice and conduct thorough research before engaging in any transactions.

2. We utilize third-party service providers for banking, custodial, and payment processing functions. Their failure may result in loss of assets. Users should assess risks accordingly and obtain appropriate advice before using credit cards or other financial instruments in connection with our Services.

3. The Platform offers custodial wallet services, enabling Users to store, receive, and send supported cryptocurrencies.

4. We do not offer crypto trading, staking, lending, borrowing, or fiat-to-crypto conversion services.

5. All crypto assets are held in custody via integration with **Binance**, a licensed third-party digital asset custodian.

6. Wallet private keys and infrastructure security are managed in collaboration with **Binance**, in accordance with industry-standard security practices.

---

## 4. Jurisdictional Restrictions

1. We reserve the right to limit or restrict access to our Services in certain jurisdictions for legal, regulatory, or commercial reasons. Where feasible, advance notice of such restrictions will be provided to allow for the withdrawal of account balances.

2. Services may remain accessible during travel unless the user is located in a jurisdiction subject to sanctions or restrictions (collectively **"Prohibited Jurisdictions"**), where use of Services is expressly prohibited.

3. You agree to promptly notify our website of any change in your country of residence.

---

## 5. Account Registration and Suspension

1. Access to certain features or Services requires user registration. To register, you must provide your name, email address, phone number, identity verification details, and create login credentials. You must confirm your acceptance of these Terms of Use during registration.

2. All Users must complete identity verification procedures prior to using custodial services or receiving issued cards.

3. We reserve the right to request further documentation at any time for compliance or risk evaluation purposes.

4. Failure to comply with verification requests may result in account suspension or denial of service.

5. Identity verification is conducted via third-party service providers and may leave a soft footprint on your credit report. These checks do not affect your credit score and are solely used for verification purposes.

6. We retain sole discretion to approve or reject account applications based on risk assessment, legal compliance, and internal policy considerations.

7. We reserve the right to suspend, restrict, or terminate your access to the Platform without prior notice under any of the following circumstances:

    - Detection of suspicious or fraudulent activities.
    - Breach of these Terms or any applicable law.
    - Upon the request of regulatory authorities.

8. Duplicate account applications using the same information may be rejected. If you have previously been denied or had an account closed, replication may be restricted.

9. Upon termination, we may restrict access to your custodial wallet. Stored digital assets may be subject to a regulatory hold or forfeiture if required by law.

---

## 6. User Obligations and Acceptable Use

You agree to use the Platform solely for lawful purposes.

You shall not:

- Violate any applicable laws, including those related to anti-money laundering or anti-terrorism.
- Open or operate multiple accounts under the same identity. Multiple accounts by the same person are strictly prohibited.
- Use the Platform to conduct or facilitate fraudulent transactions, including repeated or identical operations intended to conceal or disguise the nature, origin, or destination of funds, or to obscure user activity.
- Upload malicious code, attempt unauthorized access, or interfere with Platform operations.
- Use the Platform in a manner that violates intellectual property or data privacy laws.

---

## 7. Our Services

1. We offer custodial wallet services, allowing users to hold, buy, sell, and manage supported digital assets through accounts maintained on the Platform. All transactions are carried out pursuant to the user's instructions. Users are solely responsible for verifying the accuracy of submitted transaction data, including wallet addresses, memos, tags, and usernames.

    {Omlapay} shall not be liable for any loss or damage arising from errors, omissions, or inaccuracies in the information provided by the user.

2. The Instant Buy feature enables users to purchase supported digital assets using authorized debit or credit cards. Applicable processing fees may apply. Users confirm that they are using payment cards issued in their name and acknowledge that their bank may treat such transactions as cash advances, which could incur additional fees or interest.

3. Only supported networks, tokens, and transfer methods should be used when funding or withdrawing from your custodial account. Attempting to deposit unsupported assets or through incorrect protocols may result in permanent loss. If recovery is feasible, any associated fees or network costs will be charged to your account.

4. Users are solely responsible for the accuracy of withdrawal details, including the recipient wallet address and blockchain network selection. {Omlapay} assumes no responsibility for failed or lost transactions due to user error, blockchain congestion, or external network conditions.

5. Once a digital asset transaction is initiated and submitted to the blockchain or executed within the custodial system, it is final and irreversible. Network delays or confirmation times may vary depending on blockchain activity and are beyond the control of {Omlapay}.

---

## 8. Intellectual Property and Copyright

1. All content, design, text, graphics, logos, images, software, and other materials available on or through the Website and Services are the intellectual property of {Omlapay} or its licensors and are protected by applicable copyright, trademark, and other intellectual property laws.

2. You may not copy, reproduce, distribute, modify, publicly display, perform, or create derivative works from any content or materials on the Website without the express prior written consent of {Omlapay}.

3. Any unauthorized use of the Website or its content may result in termination of your access to the Services and may also constitute a violation of law.

---

## 9. Fees

1. {Omlapay} does not charge platform usage or service fees. However, you remain solely responsible for any applicable blockchain network fees incurred when performing transactions (e.g., token transfers).

2. All blockchain fees are determined by the relevant network protocols and are non-refundable. You acknowledge and agree that you are responsible for reviewing and confirming applicable network fees before initiating any transaction.

3. You remain responsible for ensuring sufficient balance to cover blockchain transaction costs. If insufficient balance exists to complete a transaction, it may fail or be rejected without liability to {Omlapay}.

---

## 10. Usage of App

1. The functions of the App, which may be updated from time to time at {Omlapay}'s sole discretion without prior notice, allow you to perform various actions, including but not limited to:

    - Request the issuance and management of crypto custodial wallets.
    - View your wallet balances and transaction history.
    - Deposit crypto assets into your custodial account.
    - Withdraw crypto assets from your custodial account.
    - Transfer crypto assets to other users within the platform.
    - Enable, disable, or block services associated with your account.
    - Access Third-Party Services via integrated providers.

2. Subject to your continued compliance with these Terms, we grant you a limited, non-exclusive, non-transferable license to use the App on your compatible device solely for your personal use and in accordance with these Terms. All other rights are reserved.

3. Certain components of the App may be governed by separate open-source or third-party licenses. In the event of a conflict with these Terms, the third-party or open-source terms shall prevail to the extent of such conflict.

4. You acknowledge and agree that your use of the App and related services is conditional upon your full compliance with these Terms and any other applicable policies issued by {Omlapay}.

---

## 11. Your Device

You are solely responsible, at your own cost, for:

- Procuring all hardware, software, and network access necessary to use the App.
- Installing appropriate mobile or cybersecurity protection on your device.
- Keeping both your device and the App updated to the latest versions to ensure secure and proper functioning.

You are fully responsible for any activity conducted via your device, even if unauthorized. {Omlapay} shall not be liable for any losses resulting from such unauthorized access or usage.

If your device is lost, stolen, or compromised, you must promptly notify us at support@Omlapay.com and reset any relevant access credentials as soon as possible.

---

## 12. Custody and Third-Party Services

1. Your assets are held in custody through **Binance**. We are not liable for any loss or damage arising from the actions or omissions of **Binance** or any other third-party services integrated with the Platform.

2. By using the Platform, you acknowledge and agree to **Binance**'s applicable terms of service, which govern custody operations.

---

## 13. Card Services

- Virtual and physical cards are issued to verified Users.
- Cards may be used for supported online and in-store purchases.
- Usage is subject to applicable spending limits, regulatory compliance, and security monitoring.
- Misuse of cards, attempts at identity fraud, or chargeback abuse may lead to card deactivation and account suspension.

---

## 14. Operational Limits

1. Limits on deposits, transfers, and withdrawals are based on your verification status, risk profile, and transaction behavior.

2. Limits are subject to change at our discretion for compliance or risk mitigation.

3. You will be notified of applicable limits in your account dashboard.

---

## 15. Data Privacy

1. By using the Services, you acknowledge and agree to our data protection practices as outlined in our Privacy Policy. While we do not collect personally identifiable information, we may collect limited technical data, including but not limited to device information, IP addresses, and transaction logs.

2. This data is used strictly for security, analytics, operational efficiency, and to facilitate your use of the Services. It may be shared, where necessary, with the Company, affiliated Partners, Custodian, service providers, and relevant third parties, but only to the extent required for platform functionality or to comply with applicable legal obligations.

3. We are committed to handling your data in accordance with all applicable data protection laws in the Kingdom of Saudi Arabia and do not sell your data to any third parties.

4. For further details, please refer to our Privacy Policy.

---

## 16. Wallet Access Recovery

1. As a custodial wallet provider, we manage wallet keys in partnership with **Binance**. If you lose access to your account, we may provide recovery support through identity verification processes as applicable.

2. We are not responsible for losses resulting from the inability to verify your identity or from your failure to maintain secure credentials.

---

## 17. Force Majeure

We shall not be liable for any delay or failure in performance caused by events beyond our reasonable control, including but not limited to natural disasters, acts of war or terrorism, labor disputes, electrical failures, internet disruptions, or actions of government or regulatory authorities.

---

## 18. Limitation of Liability

1. The Platform is provided on an "as is" and "as available" basis without warranties of any kind.

2. We disclaim all implied warranties, including fitness for a particular purpose, accuracy, and non-infringement.

3. Except as expressly stated in these Terms, and to the extent permitted by law, we disclaim all other warranties—express or implied—including but not limited to warranties of merchantability, fitness for a particular purpose, or suitability of the Services or any incidental goods provided.

4. Where warranties cannot be excluded, our liability is limited, at our discretion, to either: re-supplying, repairing, or replacing the relevant Services; or paying the cost of such re-supply, repair, or replacement.

5. To the extent permitted by law, we shall not be liable for:

    - Any indirect, incidental, special, or consequential damages, including but not limited to loss of profits, revenue, or data, even if foreseeable or advised of the possibility.
    - Any loss or damage resulting from:
        - Service interruptions, delays, or failures;
        - Rejection or failure of any transaction or feature within the App;
        - Maintenance, breakdowns, or unavailability of the App, network, systems, or infrastructure;
        - Use or misuse of your device, whether authorized or unauthorized;
        - Loss or theft of your device;
        - Compliance with applicable laws, regulatory requirements, or card network rules.

6. In any case, our total liability to you shall not exceed the balance held in your Wallet or Virtual Account at the time the claim arises.

7. We are not liable for the acts or omissions of third-party service providers. Our responsibility is limited to exercising reasonable care in their selection and instruction.

8. Nothing in these Terms excludes or limits liability for death or personal injury caused by negligence, or for fraud.

---

## 19. Indemnification

You agree to indemnify, defend, and hold harmless us, third-party service providers along with their respective officers, directors, employees, and agents, from any claims, damages, liabilities, and expenses arising out of:

- Your violation of these Terms or misuse of the Platform.
- Your use of the App and Services.
- Your violation of applicable laws or third-party rights.
- Any fraud, gross negligence, or willful misconduct on your part.

---

## 20. Severability

If any provision of these Terms is found to be invalid or unenforceable, the remainder of the Terms shall remain in effect. The invalid provision shall be modified to the extent necessary to reflect the original intent while complying with applicable law.

---

## 21. Amendments

1. We reserve the right to amend these Terms at any time. Users will be notified of material changes via email or Platform notification.

2. Continued use after the effective date of any change constitutes acceptance of the updated Terms.

---

## 22. Governing Law and Dispute Resolution

1. These Terms are governed by the laws of Georgia.

2. Any disputes arising out of or related to these Terms shall be submitted to the exclusive jurisdiction of the competent courts in Saudi Arabia.

---

## 23. Contact Us

If you have questions about these Terms or need assistance, please contact us:

**Email:** [support@Omlapay.com](mailto:support@Omlapay.com)
''',
        ),
      ),
    );
  }
}
