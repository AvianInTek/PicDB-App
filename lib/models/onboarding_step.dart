
class OnboardingStep {
  final String image;
  final String title;
  final String subtitle;

  OnboardingStep({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}


class OnboardingHowTo {
  static const List<String> FindUs = [
    'Google',
    'Facebook',
    'Twitter',
    'LinkedIn',
    'Instagram',
    'Friend',
    'Github',
    'Other',
  ];
}


class OnboardingPurpose {
  static const List<String> OfUsing = [
    'Personal',
    'academic',
    'event',
    'Research and Development',
    'educational',
    'Professional',
    'Backup',
    'Other',
  ];
}


class OnboardingTnC {
  static const terms = {
    "0": "Welcome to PicDB (“Service”), a freemium-based storage application that provides download and view links for image files under 20 MB, with optional encryption functionality. By using our Service, you (\“User\”) agree to these Terms and Conditions (\“Terms\”). If you do not agree, please discontinue using the Service.",
    "Eligibility": "You must be at least 13 years old to use our Service. By using the Service, you represent and warrant that you are of legal age and have the capacity to agree to these Terms. Users under the age of 18 require parental or guardian consent.",
    // "Account Registration": "Information Accuracy: Users must provide accurate and complete registration details, including email address and password.",
    // "Account Security": "Users are responsible for maintaining the confidentiality of their login credentials. Notify us immediately of unauthorized use of your account.",
    "Service Usage": "Our Service only includes free plans. Users can upload, share, and manage image files. Paid plans may be offered in the future.",
    "File Restrictions": [
      "Uploaded files must adhere to the following:",
      "File type: Supported image formats (e.g., PNG, JPG).",
      "File size: Must not exceed 20 MB.",
      "Prohibited content: Files containing illegal, obscene, infringing, or otherwise harmful material are strictly prohibited.",
    ],
    "User Conduct": [
      "Users agree not to:",
      "Upload, share, or store illegal or infringing content.",
      "Use the Service for malicious purposes, such as distributing malware or spamming.",
    ],
    "Data Privacy": [
      // "Data Collection: We collect personal information as per our Privacy Policy, including email addresses and usage statistics.",
      "We are not liable for lost or inaccessible data due to misplacement of data.",
      "Third-Party Services: Some features may involve third-party services and their respective policies apply."
    ],
    "Intellectual Property": "The Service, including all content, designs, and software, is owned by or licensed to us. Users may not copy, modify, or distribute any part of the Service without prior consent.",
    "Payments and Refunds": [
      "Refund Policy: Refunds are only provided as required by applicable laws in India or the United States. Pro-rata refunds are typically not offered for cancellations.",
    ],
    "Disclaimer of Warranties": "The Service is provided “as is” and “as available,” without warranties of any kind, either expressed or implied. We do not guarantee that the Service will be error-free or uninterrupted.",
    "Limitation of Liability": [
      "To the maximum extent permitted by applicable law, we are not liable for:",
      "Indirect, incidental, or consequential damages resulting from use of the Service.",
      "Data loss, including losses due to lost encryption keys or unauthorized access."
    ],
    "Termination": "We reserve the right to suspend or terminate access to the Service for violation of these Terms or for other reasonable reasons, with or without notice.",
    "Dispute Resolution": [
        "We do not own nor exert ownership of the data uploaded by the User. Any liability caused by the user's data is the user's responsibility.",
        "India: Any disputes arising from these Terms will be governed by and construed in accordance with Indian law.",
        "United States: For US users, disputes will be governed by federal laws or the laws of the state where the User resides. Any disputes will be settled in a court of competent jurisdiction.",
    ],
    "Updates to Terms": "We may revise these Terms from time to time. Changes will be effective upon posting. Continued use of the Service signifies acceptance of the updated Terms.",
    "Contact Us": "If you have questions about these Terms, please contact us at [Support Email Address].",
  };
}