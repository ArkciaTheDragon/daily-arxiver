import 'package:daily_arxiver/models/article_model.dart';
import 'package:daily_arxiver/providers/user_provider.dart';
import 'package:daily_arxiver/screens/analysis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleCard extends StatefulWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  bool _isAuthorListExpanded = false;
  bool _isAbstractExpanded = false;
  final int maxAuthors = 3;

  Future<void> _analyzePaper() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisScreen(arxivId: widget.article.arxivId),
      ),
    );
  }

  Future<void> _openLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!mounted) return;
        _showCopyLinkDialog(context, url);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      _showErrorSnackbar(context, 'Platform error: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar(context, 'Error opening link: $e');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showCopyLinkDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Copy Link'),
        content: Text('Could not open the link. Do you want to copy the URL?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.pop(context);
              _showErrorSnackbar(context, 'Link copied to clipboard');
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isRead = userProvider.isArticleRead(widget.article.arxivId);
    final isFavorite = userProvider.isArticleFavorite(widget.article.arxivId);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          userProvider.toggleReadStatus(widget.article);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.article.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isRead
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.article.arxivId,
                style: TextStyle(
                  color: isRead
                      ? Theme.of(context).disabledColor
                      : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              _buildAuthorList(),
              const SizedBox(height: 12),
              _buildAbstract(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submitted: ${_formatTime(widget.article.submittedTime)}',
                    style: TextStyle(
                      color: isRead
                          ? Theme.of(context).disabledColor
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Added: ${_formatTime(widget.article.addedTime)}',
                    style: TextStyle(
                      color: isRead
                          ? Theme.of(context).disabledColor
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.yellow : null,
                    ),
                    onPressed: () =>
                        userProvider.toggleFavoriteStatus(widget.article),
                  ),
                  IconButton(
                    icon: const Icon(Icons.analytics_outlined),
                    onPressed: _analyzePaper,
                    tooltip: 'Analyze Paper',
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () => _openLink(widget.article.link),
                    tooltip: 'Open on ArXiv',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAbstract() {
    final isRead = Provider.of<UserProvider>(
      context,
      listen: false,
    ).isArticleRead(widget.article.arxivId);

    final textStyle = TextStyle(
      color: isRead
          ? Theme.of(context).disabledColor
          : Theme.of(context).textTheme.bodyMedium!.color,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.article.abstract, style: textStyle),
          maxLines: 5,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final showMoreButton = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.article.abstract,
              maxLines: _isAbstractExpanded ? null : 5,
              overflow: _isAbstractExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: textStyle,
            ),
            if (showMoreButton)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    _isAbstractExpanded ? 'Less' : 'More',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isAbstractExpanded = !_isAbstractExpanded;
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAuthorList() {
    final authors = widget.article.authors;
    final authorTextStyle = TextStyle(
      fontStyle: FontStyle.italic,
      color: Theme.of(context).disabledColor,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: authors.join(', '), style: authorTextStyle),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        final showMoreButton = textPainter.didExceedMaxLines;

        if (!showMoreButton) {
          return Text(authors.join(', '), style: authorTextStyle);
        }

        final displayedAuthors = _isAuthorListExpanded
            ? authors
            : authors.take(maxAuthors).toList();

        final toggleButton = TextButton(
          onPressed: () {
            setState(() {
              _isAuthorListExpanded = !_isAuthorListExpanded;
            });
          },
          child: Text(
            _isAuthorListExpanded ? 'Less' : 'More',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 12,
            ),
          ),
        );

        if (_isAuthorListExpanded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(displayedAuthors.join(', '), style: authorTextStyle),
              toggleButton,
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "${displayedAuthors.join(', ')} et al.",
                  style: authorTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              toggleButton,
            ],
          );
        }
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
  }
}
