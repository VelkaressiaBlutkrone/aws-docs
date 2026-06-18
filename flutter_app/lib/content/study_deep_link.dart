/// 학습문서 딥링크 URL. [section]이 비어있지 않으면 ?at= 앵커를 붙인다.
String studyDeepLink(String certCode, String taskId, String section) {
  final base = '/cert/$certCode/study/$taskId';
  return section.isEmpty ? base : '$base?at=$section';
}
