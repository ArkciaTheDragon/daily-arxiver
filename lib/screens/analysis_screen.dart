import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';

class AnalysisScreen extends StatefulWidget {
  final String arxivId;

  const AnalysisScreen({super.key, required this.arxivId});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final List<String> _sections = ["full", "intro", "method", "experiments"];
  String? _selectedSection;
  String? _analysisResult;
  bool _isLoading = false;
  String? _error;
  bool _selectable = true;
  bool _useDollarSignsForLatex = true;

  Future<void> _analyzeSection(String section) async {
    setState(() {
      _isLoading = true;
      _selectedSection = section;
      _analysisResult = null;
      _error = null;
    });

    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final analysis = await apiService.analyzePaperSection(
        widget.arxivId,
        section,
      );
      if (mounted) {
        setState(() {
          _analysisResult = analysis;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to analyze paper: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paper Analysis'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _useDollarSignsForLatex = !_useDollarSignsForLatex;
              });
            },
            icon: Icon(
              Icons.monetization_on_outlined,
              color: _useDollarSignsForLatex
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            tooltip: 'Use dollar signs for LaTeX',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectable = !_selectable;
              });
            },
            icon: Icon(
              Icons.select_all_outlined,
              color: _selectable
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            tooltip: 'Selectable text',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a section to analyze for paper ${widget.arxivId}:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children: _sections.map((section) {
                return ElevatedButton(
                  onPressed: _isLoading ? null : () => _analyzeSection(section),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedSection == section
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                  ),
                  child: Text(section),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (_analysisResult != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analysis Result for "$_selectedSection":',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          Widget markdown = GptMarkdown(
                            _analysisResult!,
                            useDollarSignsForLatex: _useDollarSignsForLatex,
                            latexBuilder: (context, tex, textStyle, inline) {
                              var math = Math.tex(tex, textStyle: textStyle);
                              if (inline) {
                                return math;
                              }

                              final controller = ScrollController();
                              return Material(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface
                                    .withValues(alpha: 0.1),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Scrollbar(
                                    controller: controller,
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      controller: controller,
                                      scrollDirection: Axis.horizontal,
                                      child: math,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );

                          if (_selectable) {
                            return SelectionArea(child: markdown);
                          }
                          return markdown;
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
