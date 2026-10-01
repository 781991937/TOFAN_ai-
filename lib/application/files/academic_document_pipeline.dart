import '../../domain/files/academic_document_models.dart';
import 'academic_document_extractor.dart';
import 'academic_document_mapper.dart';

class AcademicDocumentPipelineResult {
  const AcademicDocumentPipelineResult({
    required this.document,
    required this.mapping,
    required this.extraction,
  });

  final AcademicDocument document;
  final AcademicDocumentMapping mapping;
  final DocumentExtractionResult extraction;

  bool get mapped => mapping.matches.isNotEmpty;
}

class AcademicDocumentPipeline {
  const AcademicDocumentPipeline({
    this.extractor = const AcademicDocumentExtractor(),
    this.mapper = const AcademicDocumentMapper(),
  });

  final AcademicDocumentExtractor extractor;
  final AcademicDocumentMapper mapper;

  AcademicDocumentPipelineResult process({
    required String id,
    required String fileName,
    required String content,
    String mimeType = 'text/plain',
    String? sourceReference,
  }) {
    final extraction = extractor.extract(
      fileName: fileName,
      bytesAsText: content,
      mimeType: mimeType,
    );
    final document = AcademicDocument(
      id: id,
      name: fileName,
      content: extraction.text,
      mimeType: mimeType,
      sourceReference: sourceReference,
    );
    final mapping = extraction.isSuccess
        ? mapper.map(document)
        : AcademicDocumentMapping(documentId: id, matches: const []);
    return AcademicDocumentPipelineResult(
      document: document,
      mapping: mapping,
      extraction: extraction,
    );
  }
}
