enum DocumentExtractionStatus { extracted, unsupported, empty }

class DocumentExtractionResult {
  const DocumentExtractionResult({
    required this.status,
    required this.text,
    this.reason = '',
  });

  final DocumentExtractionStatus status;
  final String text;
  final String reason;

  bool get isSuccess =>
      status == DocumentExtractionStatus.extracted && text.trim().isNotEmpty;
}

/// Deterministic extraction boundary for formats the client can safely decode
/// without pretending to parse binary academic documents.
class AcademicDocumentExtractor {
  const AcademicDocumentExtractor();

  DocumentExtractionResult extract({
    required String fileName,
    required String bytesAsText,
    String? mimeType,
  }) {
    final name = fileName.toLowerCase();
    final mime = (mimeType ?? '').toLowerCase();
    final isText = mime.startsWith('text/') ||
        name.endsWith('.txt') ||
        name.endsWith('.md') ||
        name.endsWith('.csv') ||
        name.endsWith('.json') ||
        name.endsWith('.xml') ||
        name.endsWith('.html') ||
        name.endsWith('.htm');
    if (!isText) {
      return const DocumentExtractionResult(
        status: DocumentExtractionStatus.unsupported,
        text: '',
        reason: 'Binary document extraction requires a dedicated parser.',
      );
    }
    if (bytesAsText.trim().isEmpty) {
      return const DocumentExtractionResult(
        status: DocumentExtractionStatus.empty,
        text: '',
        reason: 'Document contains no extractable text.',
      );
    }
    return DocumentExtractionResult(
      status: DocumentExtractionStatus.extracted,
      text: bytesAsText,
    );
  }
}
