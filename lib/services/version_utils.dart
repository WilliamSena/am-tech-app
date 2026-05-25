class VersionUtils {
  static int compare(String v1, String v2) {
    List<int> a = v1.split('.').map(int.parse).toList();
    List<int> b = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < a.length; i++) {
      if (a[i] > b[i]) return 1;
      if (a[i] < b[i]) return -1;
    }
    return 0;
  }
}