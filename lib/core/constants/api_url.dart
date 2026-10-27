class ApiUrl{
  static String baseUrl = "http://10.0.2.2:8000/api";
  static String storageBase = "http://10.0.2.2:8000/storage";

  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) {
      final uri = Uri.parse(path);
      if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
        return uri.replace(host: '10.0.2.2').toString();
      }
      return path;
    }
    return '$storageBase/$path';
  }
}
