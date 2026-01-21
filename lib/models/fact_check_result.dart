import 'package:flutter/material.dart';

// 1. Define the possible outcomes
enum Verdict { trueClaim, falseClaim, misleading, unclear }

class FactCheckResult {
  final String report;
  final List<Article> articles;
  final int articleCount;
  final Map<String, dynamic> perspectives;
  final String language;

  FactCheckResult({
    required this.report,
    required this.articles,
    required this.articleCount,
    required this.perspectives,
    required this.language,
  });

  factory FactCheckResult.fromJson(Map<String, dynamic> json) {
    List<Article> articleList = [];

    if (json['articles'] != null) {
      articleList = (json['articles'] as List)
          .map((article) => Article.fromJson(article))
          .toList();
    }

    return FactCheckResult(
      report: json['result'] ?? json['report'] ?? 'No report content returned',
      articles: articleList,
      articleCount: json['article_count'] ?? articleList.length,
      perspectives: json['perspectives'] ?? {},
      language: json['language'] ?? 'English',
    );
  }

  // --- IMPROVED VERDICT LOGIC ---
  Verdict get verdict {
    final text = report.toLowerCase();

    // Check for "False" indicators
    if (text.contains('false') ||
        text.contains('fake') ||
        text.contains('incorrect') ||
        text.contains('debunked') ||
        text.contains('baseless') ||
        text.contains('no evidence') ||
        text.contains('unsubstantiated')) {
      return Verdict.falseClaim;
    }

    // Check for "True" indicators
    // (We check false first because "not true" contains "true")
    if (text.contains('true') ||
        text.contains('accurate') ||
        text.contains('correct') ||
        text.contains('verified') ||
        text.contains('factual')) {
      // Double check it doesn't say "not true"
      if (!text.contains('not true') && !text.contains('partially true')) {
        return Verdict.trueClaim;
      }
    }

    // Check for "Misleading" indicators
    if (text.contains('misleading') ||
        text.contains('out of context') ||
        text.contains('partially') ||
        text.contains('exaggerated') ||
        text.contains('mixed')) {
      return Verdict.misleading;
    }

    return Verdict.unclear;
  }

  // --- UI HELPERS ---
  Color get verdictColor {
    switch (verdict) {
      case Verdict.trueClaim:
        return const Color(0xFF4A90E2); // Blue
      case Verdict.falseClaim:
        return const Color(0xFFe51324); // Red
      case Verdict.misleading:
        return Colors.orangeAccent;
      case Verdict.unclear:
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String get verdictLabel {
    switch (verdict) {
      case Verdict.trueClaim:
        return "VERIFIED TRUE";
      case Verdict.falseClaim:
        return "FALSE CLAIM";
      case Verdict.misleading:
        return "MISLEADING";
      case Verdict.unclear:
      default:
        return "UNCLEAR / NEUTRAL";
    }
  }
}

class Article {
  final String title;
  final String url;
  final String source;

  Article({required this.title, required this.url, required this.source});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'Untitled',
      url: json['url'] ?? '',
      source: _cleanSource(json['source'] ?? json['domain'] ?? 'Unknown'),
    );
  }

  static String _cleanSource(String rawSource) {
    try {
      return rawSource
          .replaceAll('https://', '')
          .replaceAll('http://', '')
          .replaceAll('www.', '')
          .split('/')[0];
    } catch (e) {
      return rawSource;
    }
  }
}