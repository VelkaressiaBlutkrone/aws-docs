import '../models/certification.dart';
import 'content_index.dart';
import 'site_data.dart';

/// 라우트 param(code) → Certification. 미존재 시 null.
Certification? certByCode(String code) {
  for (final cert in certifications) {
    if (cert.code == code) return cert;
  }
  return null;
}

/// 라우트 param(code, taskId) → ContentEntry. 미존재 시 null.
ContentEntry? entryByTask(String code, String taskId) {
  for (final entry in contentFor(code)) {
    if (entry.taskId == taskId) return entry;
  }
  return null;
}
