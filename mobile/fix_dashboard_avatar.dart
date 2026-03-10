import 'dart:io';

void main() {
  var file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\dashboard_screen.dart');
  var content = file.readAsStringSync();

  // First, find and replace the _loadUserData() where it reads the path to properly format the URL if it's from backend
  if (content.contains('_loadProfileImage') == false) {
    var oldLoadUserData = '''
    final imagePath = prefs.getString('profile_image_path_\$_userId');
    if (mounted) {
      setState(() {
        _profileImagePath = imagePath;
      });
    }
''';
    var newLoadUserData = '''
    String? imagePath = prefs.getString('profile_image_path_\$_userId');
    if (imagePath == null && userDataString != null) {
        final userData = jsonDecode(userDataString);
        if (userData['profile_image'] != null && userData['profile_image'].toString().isNotEmpty) {
           String backendImg = userData['profile_image'];
           String baseUrl = ApiService.baseUrl.replaceAll('/backend/api', '');
           if(!baseUrl.endsWith('/')) baseUrl += '/';
           imagePath = baseUrl + backendImg;
        }
    }

    if (mounted) {
      setState(() {
        _profileImagePath = imagePath;
      });
    }
''';
    content = content.replaceFirst(oldLoadUserData, newLoadUserData);
  }

  // Update CircleAvatars
  // We need a helper getter like in profile_edit
  String getAvatarCode(double radius) {
    return '''
CircleAvatar(
  radius: $radius,
  backgroundColor: Theme.of(context).primaryColor,
  backgroundImage: _profileImagePath != null && _profileImagePath!.isNotEmpty
    ? (_profileImagePath!.startsWith('http')
      ? NetworkImage(_profileImagePath!) as ImageProvider
      : FileImage(File(_profileImagePath!)))
    : null,
  child: _profileImagePath == null || _profileImagePath!.isEmpty
    ? Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white))
    : null,
)
''';
  }

  // Mobile drawer avatar (around line 538)
  var regex1 = RegExp(
      r"CircleAvatar\(\s*child:\s*Text\(_userName\.isNotEmpty \? _userName\[0\] : 'U'\),\s*\)");
  content = content.replaceFirst(regex1, getAvatarCode(20.0).trim());

  // Desktop AppBar avatar (around line 743)
  var regex2 = RegExp(
      r"CircleAvatar\(\s*backgroundColor:\s*Theme\.of\(context\)\.primaryColor,\s*child:\s*Text\(_userName\.isNotEmpty \? _userName\[0\] : 'U',\s*style:\s*const\s*TextStyle\(color:\s*Colors\.white\)\),\s*\)");
  content = content.replaceFirst(regex2, getAvatarCode(20.0).trim());

  // Profile Content Avatar (around line 865)
  var oldProfileAvatar = '''
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                backgroundImage: _profileImagePath != null &&
                        _profileImagePath!.isNotEmpty
                    ? FileImage(File(_profileImagePath!))
                    : null,
                child: _profileImagePath == null || _profileImagePath!.isEmpty
                    ? Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                        style: GoogleFonts.plusJakartaSans(
                            color: theme.primaryColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold))
                    : null,
              ),
''';
  var newProfileAvatar = '''
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                backgroundImage: _profileImagePath != null && _profileImagePath!.isNotEmpty
                    ? (_profileImagePath!.startsWith('http')
                        ? NetworkImage(_profileImagePath!) as ImageProvider
                        : FileImage(File(_profileImagePath!)))
                    : null,
                child: _profileImagePath == null || _profileImagePath!.isEmpty
                    ? Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                        style: GoogleFonts.plusJakartaSans(
                            color: theme.primaryColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold))
                    : null,
              ),
''';
  if (!content.contains('startsWith(\'http\')')) {
    content = content.replaceFirst(oldProfileAvatar, newProfileAvatar);
  }

  file.writeAsStringSync(content);
}
