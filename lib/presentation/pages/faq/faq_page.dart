// lib/presentation/pages/faq/faq_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class FaqPage extends ConsumerWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final faqItems = [
      FaqItem(
        question: 'What file formats can I convert to PDF?',
        answer:
            'MegaPDF supports converting various file formats to PDF, including Word (DOC, DOCX), Excel (XLS, XLSX), PowerPoint (PPT, PPTX), images (JPG, PNG, GIF), and text files (TXT).',
      ),
      FaqItem(
        question: 'How do I compress a PDF file?',
        answer:
            'To compress a PDF file, navigate to the Tools tab, select "Compress PDF," upload your file, and then click the "Compress" button. The app will optimize your PDF to reduce its file size while maintaining quality.',
      ),
      FaqItem(
        question: 'Can I merge multiple PDF files?',
        answer:
            'Yes, you can merge multiple PDF files using our "Merge PDFs" feature. Navigate to the Tools tab, select "Merge PDFs," upload the files you want to combine, arrange them in the desired order, and click "Merge" to create a single PDF document.',
      ),
      FaqItem(
        question: 'How do I add password protection to my PDF?',
        answer:
            'To protect your PDF with a password, go to the Tools tab, select "Protect PDF," upload your file, enter your desired password, configure the permission settings, and click "Protect." Your PDF will be encrypted and password-protected.',
      ),
      FaqItem(
        question: 'Is there a limit to the file size I can process?',
        answer:
            'Free users can process PDF files up to 10MB in size. Premium subscribers can process files up to 100MB. For very large files, we recommend splitting them into smaller parts first or using our desktop application.',
      ),
      FaqItem(
        question: 'How do I split a PDF into multiple files?',
        answer:
            'To split a PDF, go to the Tools tab, select "Split PDF," upload your file, choose your preferred split method (by page ranges, extract all pages, or split every N pages), and click "Split." The app will create separate PDF files according to your specifications.',
      ),
      FaqItem(
        question: 'Can I add page numbers to my PDF?',
        answer:
            'Yes, you can add page numbers using our "Page Numbers" feature. Go to the Tools tab, select "Page Numbers," upload your PDF, configure the positioning, format, and styling of the page numbers, and click "Add Page Numbers."',
      ),
      FaqItem(
        question: 'How do I add a watermark to my PDF?',
        answer:
            'To add a watermark, navigate to the Tools tab, select "Watermark," upload your PDF, choose between text or image watermark, configure the appearance and positioning, and click "Add Watermark." Your PDF will be processed with the watermark applied.',
      ),
      FaqItem(
        question: 'Is my data secure?',
        answer:
            'Yes, we take data security seriously. All file uploads are encrypted using TLS/SSL. Files are temporarily stored for processing and automatically deleted afterward. We do not access or analyze the content of your files.',
      ),
      FaqItem(
        question: 'How do I rotate pages in my PDF?',
        answer:
            'To rotate pages, go to the Tools tab, select "Rotate PDF," upload your file, choose the rotation angle (90°, 180°, or 270°), select which pages to rotate, and click "Rotate." The app will process your PDF with the specified rotation applied.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        elevation: 0,
        backgroundColor: AppColors.surface(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary(context),
                      AppColors.primary(context).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary(context).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Frequently Asked Questions',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Find answers to common questions about MegaPDF',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.question_answer,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Common Questions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqItems.length,
                itemBuilder: (context, index) {
                  return FaqItemWidget(item: faqItems[index]);
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.info(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.info(context).withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppColors.info(context), size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Still have questions?',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.info(context),
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'If you couldn\'t find the answer to your question, please feel free to contact our support team.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/contact');
                      },
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('Contact Support'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({
    required this.question,
    required this.answer,
  });
}

class FaqItemWidget extends StatefulWidget {
  final FaqItem item;

  const FaqItemWidget({super.key, required this.item});

  @override
  State<FaqItemWidget> createState() => _FaqItemWidgetState();
}

class _FaqItemWidgetState extends State<FaqItemWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.border(context),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          widget.item.question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _isExpanded
                    ? AppColors.primary(context)
                    : AppColors.textPrimary(context),
              ),
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        trailing: Icon(
          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: _isExpanded
              ? AppColors.primary(context)
              : AppColors.textSecondary(context),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.answer,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary(context),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
