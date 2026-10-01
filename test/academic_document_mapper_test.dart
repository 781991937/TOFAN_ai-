import 'package:flutter_test/flutter_test.dart';

import 'package:tofan_ai/domain/files/academic_document_models.dart';
import 'package:tofan_ai/application/files/academic_document_mapper.dart';

void main() {
  const mapper = AcademicDocumentMapper();

  test('maps known document terms to canonical academic targets', () {
    const document = AcademicDocument(
      id: 'doc-1',
      name: 'python-notes.txt',
      content: 'مقدمة في Python والبرنامج والتعليمات والمخرجات.',
    );

    final result = mapper.map(document);

    expect(result.documentId, 'doc-1');
    expect(result.forType(AcademicDocumentTargetType.course)
        .map((match) => match.targetId), contains('python'));
    expect(result.forType(AcademicDocumentTargetType.lesson)
        .map((match) => match.targetId), contains('python-1'));
    expect(result.matches.every((match) => match.documentId == 'doc-1'), isTrue);
    expect(result.matches.every((match) => match.confidence > 0), isTrue);
  });

  test('does not invent mappings for unknown content', () {
    const document = AcademicDocument(
      id: 'doc-unknown',
      name: 'unknown.txt',
      content: 'zzzxxyyqqq content with no academic catalog terms',
    );

    final result = mapper.map(document);

    expect(result.matches, isEmpty);
  });

  test('keeps duplicate target matches unique', () {
    const document = AcademicDocument(
      id: 'doc-2',
      name: 'python.txt',
      content: 'Python Python Python',
    );

    final result = mapper.map(document);
    final keys = result.matches
        .map((match) => '${match.targetType.name}:${match.targetId}')
        .toSet();

    expect(keys.length, result.matches.length);
  });
}
