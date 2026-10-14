import 'dart:async';
import 'dart:io';

import 'package:tofan_ai/backend/api/api_models.dart';
import 'package:tofan_ai/backend/api/tofan_api_server.dart';

Future<void> main() async {
  TofanApiServer? api;
  try {
    final environment = Platform.environment;
    final config = SupabaseApiConfig.fromEnvironment(environment);
    final host = environment['TOFAN_API_HOST']?.trim().isNotEmpty == true
        ? environment['TOFAN_API_HOST']!.trim()
        : '127.0.0.1';
    final port = int.tryParse(environment['TOFAN_API_PORT'] ?? '8080');
    if (port == null || port < 1 || port > 65535) {
      throw const FormatException(
        'TOFAN_API_PORT must be between 1 and 65535.',
      );
    }
    final addresses = await InternetAddress.lookup(host);
    if (addresses.isEmpty) {
      throw const SocketException('No bind address resolved.');
    }

    final allowedOrigins = (environment['TOFAN_API_ALLOWED_ORIGINS'] ?? '')
        .split(',')
        .map((origin) => origin.trim())
        .where((origin) => origin.isNotEmpty)
        .toSet();
    api = TofanApiServer(config: config, allowedOrigins: allowedOrigins);
    final server = await api.start(bindAddress: addresses.first, port: port);
    stdout.writeln(
      'TOFAN API listening on ${server.address.address}:${server.port}',
    );
    stdout.writeln('Health endpoint: /health');

    final stopped = Completer<void>();
    ProcessSignal.sigint.watch().listen((_) {
      if (!stopped.isCompleted) stopped.complete();
    });
    ProcessSignal.sigterm.watch().listen((_) {
      if (!stopped.isCompleted) stopped.complete();
    });
    await stopped.future;
  } catch (error) {
    stderr.writeln('TOFAN API failed to start: $error');
    exitCode = 1;
  } finally {
    await api?.close();
  }
}
