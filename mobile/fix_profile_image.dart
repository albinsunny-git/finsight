import 'dart:io';

void main() {
  var file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\settings\profile_edit_screen.dart');
  var content = file.readAsStringSync();

  // Fix _pickImage to upload to backend immediately
  if (content.contains('_pickImage()')) {
    var newPickImage = '''
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final uploadedPath = await _apiService.uploadProfileImage(image.path);
        
        // Save local path to shared preferences for instant offline access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path_\$_userId', image.path);
        
        if (uploadedPath != null) {
           // If we wanted to save the remote path too, we could update user_data
           final userDataStr = prefs.getString('user_data');
           if (userDataStr != null) {
              final userData = jsonDecode(userDataStr) as Map<String, dynamic>;
              userData['profile_image'] = uploadedPath;
              await prefs.setString('user_data', jsonEncode(userData));
           }
        }

        if (mounted) {
          setState(() {
            _profileImagePath = image.path;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image uploaded successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: \$e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
''';

    // Regex replace _pickImage
    final regex = RegExp(
        r'Future<void> _pickImage\(\) async \{.*?\}(?=\n\n  Future<void> _saveProfile)',
        dotAll: true);
    content = content.replaceFirst(regex, newPickImage.trim());
  }

  // Next, update _loadProfileImage to optionally use backend URL if local isn't found
  if (content.contains('_loadProfileImage()')) {
    var newLoadImage = '''
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    // Try local cached file first
    String? imagePath = prefs.getString('profile_image_path_\$_userId');
    
    // If not found, use remote URL from user data
    if (imagePath == null) {
      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr) as Map<String, dynamic>;
        if (userData['profile_image'] != null && userData['profile_image'].toString().isNotEmpty) {
           String backendImg = userData['profile_image'];
           // Make it full url
           String baseUrl = ApiService.baseUrl.replaceAll('/backend/api', '');
           if(!baseUrl.endsWith('/')) baseUrl += '/';
           imagePath = baseUrl + backendImg;
        }
      }
    }

    if (mounted && imagePath != null) {
      setState(() {
        _profileImagePath = imagePath;
      });
    }
  }
''';
    final regex = RegExp(
        r'Future<void> _loadProfileImage\(\) async \{.*?\}(?=\n\n  @override\n  void dispose\(\))',
        dotAll: true);
    content = content.replaceFirst(regex, newLoadImage.trim());
  }

  // Update NetworkImage logic instead of just FileImage if it starts with http
  var oldAvatar = '''
                            backgroundImage: _profileImagePath != null &&
                                    _profileImagePath!.isNotEmpty
                                ? FileImage(File(_profileImagePath!))
                                : null,
''';
  var newAvatar = '''
                            backgroundImage: _profileImagePath != null && _profileImagePath!.isNotEmpty
                                ? (_profileImagePath!.startsWith('http')
                                    ? NetworkImage(_profileImagePath!) as ImageProvider
                                    : FileImage(File(_profileImagePath!)))
                                : null,
''';
  if (!content.contains('startsWith(\'http\')')) {
    content = content.replaceFirst(oldAvatar, newAvatar);
  }

  file.writeAsStringSync(content);
}
