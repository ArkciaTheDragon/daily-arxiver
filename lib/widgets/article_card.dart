import 'package:daily_arxiv_flutter/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  Future<void> _openLink(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      // Use launch URL directly without checking first
      if (await launchUrl(
        uri,
        mode:
            LaunchMode
                .externalApplication, // Try using external application mode
      )) {
        return; // Successfully launched
      }
    } on PlatformException catch (e) {
      // Handle platform exception
      _showErrorSnackbar(context, 'Platform error: ${e.message}');
      return;
    } catch (e) {
      // Handle other exceptions
      _showErrorSnackbar(context, 'Error opening link: $e');
      return;
    }

    // If we get here, launchUrl returned false
    _showErrorSnackbar(context, 'Could not open the link: $url');

    // Offer to copy the URL to clipboard as a fallback
    _showCopyLinkDialog(context, url);
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCopyLinkDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Could not open link'),
            content: const Text('Do you want to copy the link to clipboard?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard')),
                  );
                },
                child: const Text('Copy'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openLink(context, article.link),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Authors: ${article.authors.join(', ')}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Text(
                article.abstract,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submitted: ${_formatTime(article.submittedTime)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Added: ${_formatTime(article.addedTime)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View Paper'),
                  onPressed: () => _openLink(context, article.link),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
  }
}
