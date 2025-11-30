import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../../auth/changePassword.dart'; // Goes up one level to 'lib', then into 'auth'
import '../../auth/login.dart'; // Goes up one level to 'lib', then into 'auth'
import 'feedback_screen.dart';
import 'privacy_screen.dart';
import 'terms_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  String? photoUrl;
  File? _imageFile;

  // Sakinah Colors
  final Color primaryColor = const Color(0xFF15803D);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    setState(() => isLoading = true);
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _emailController.text = data['email'] ?? user.email ?? '';
          photoUrl = data['photoUrl'] ?? '';
          isLoading = false;
        });
      } else {
        // If no firestore doc exists, use Auth data
        setState(() {
          _emailController.text = user.email ?? '';
          if (user.displayName != null) {
            final parts = user.displayName!.split(' ');
            _firstNameController.text = parts.isNotEmpty ? parts.first : '';
            _lastNameController.text = parts.length > 1 ? parts.last : '';
          }
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        isSaving = true;
      });
      await _uploadAndSaveProfilePicture(File(pickedFile.path));
    }
  }

  Future<void> _uploadAndSaveProfilePicture(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isSaving = false);
      return;
    }

    try {
      final ext = path.extension(imageFile.path);
      final ref = FirebaseStorage.instance.ref().child(
        'user_profile_pics/${user.uid}_profile$ext',
      );
      await ref.putFile(imageFile);
      final uploadedUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'photoUrl': uploadedUrl, 'updatedAt': FieldValue.serverTimestamp()},
      );

      setState(() {
        photoUrl = uploadedUrl;
        _imageFile = null;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      setState(() {
        _imageFile = null;
        isSaving = false;
      });
      // Note: You must enable Firebase Storage in your console for this to work
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Enable Storage in Firebase Console. $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update Auth Display Name as well
      await user.updateDisplayName("${_firstNameController.text.trim()} ${_lastNameController.text.trim()}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e'))
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // Remove all screens and go to Login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()), 
        (route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF15803D), 
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- Profile Picture Section ---
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : (photoUrl != null && photoUrl!.isNotEmpty
                                    ? NetworkImage(photoUrl!) as ImageProvider
                                    : null),
                            child: (photoUrl == null || photoUrl!.isEmpty) && _imageFile == null
                                ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: isSaving ? null : _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    '${_firstNameController.text} ${_lastNameController.text}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _emailController.text,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 32),

                  // --- Settings Section ---
                  _buildSectionHeader('Personal Information'),
                  const SizedBox(height: 16),
                  
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_firstNameController, 'First Name')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(_lastNameController, 'Last Name')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(_emailController, 'Email', readOnly: true),
                        
                        const SizedBox(height: 24),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Account Settings'),
                  
                  // Link to your existing Change Password File
                  _buildSettingsTile(
                    icon: Icons.lock_outline, 
                    title: 'Change Password',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
                    },
                  ),
                  
                  // Linked profile-related screens
                  _buildSettingsTile(
                    icon: Icons.feedback_outlined,
                    title: 'Feedback',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen()));
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Use',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen()));
                    },
                  ),

                  const SizedBox(height: 20),
                  
                  // Logout
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                    title: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    onTap: _logout,
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: (val) => val!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, color: Colors.grey.shade700),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}