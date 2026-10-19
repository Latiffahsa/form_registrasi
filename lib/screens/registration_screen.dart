import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teleponController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _selectedDate;
  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];
  String? _selectedGender;
  bool _agreeTerms = false;
  bool _showTermsError = false;

  // state indikator kekuatan password
  String _passwordStrength = '';
  double _strengthValue = 0;
  Color _strengthColor = Colors.grey;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _teleponController.dispose();
    _tanggalLahirController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Format tanggal dd/MM/yyyy
  String _formatTanggal(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // Pilih tanggal lahir
  Future<void> _pickTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text = _formatTanggal(picked);
      });
    }
  }

  // Validasi nama
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  // Validasi no telepon
  String? _validateTelepon(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor Telepon tidak boleh kosong';
    }
    final telepon = value.trim();

    if (!RegExp(r'^[0-9]+$').hasMatch(telepon)) {
      return 'Nomor Telepon hanya boleh berisi angka';
    }
    if (telepon.length < 10) {
      return 'Nomor Telepon minimal 10 digit';
    }
    if (telepon.length > 13) {
      return 'Nomor Telepon maksimal 13 digit';
    }
    return null;
  }

  // Validasi tanggal lahir
  String? _validateTanggalLahir(String? value) {
    if (_selectedDate == null) {
      return 'Tanggal lahir tidak boleh kosong';
    }
    return null;
  }

  // Validasi jenis kelamin (required)
  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jenis kelamin harus dipilih';
    }
    return null;
  }

  // Validasi email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // Validasi password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf kapital';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }
    return null;
  }

  // Validasi konfirmasi password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  // Hitung kekuatan password
  void _checkPasswordStrength(String password) {
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSymbol = password.contains(RegExp(r'[^A-Za-z0-9]'));
    final hasLetter = hasUpper || hasLower;

    String label;
    double value;
    Color color;

    if (password.isEmpty) {
      label = '';
      value = 0;
      color = Colors.grey;
    } else if (password.length < 8) {
      label = 'Lemah';
      value = 0.33;
      color = Colors.red;
    } else if (hasUpper && hasLower && hasDigit && hasSymbol) {
      label = 'Kuat';
      value = 1.0;
      color = Colors.green;
    } else if (hasLetter && hasDigit) {
      label = 'Sedang';
      value = 0.66;
      color = Colors.orange;
    } else {
      // >= 8 karakter tapi belum memenuhi syarat Sedang (mis. huruf saja)
      label = 'Lemah';
      value = 0.33;
      color = Colors.red;
    }

    setState(() {
      _passwordStrength = label;
      _strengthValue = value;
      _strengthColor = color;
    });
  }

  // Handler submit form
  void _submitForm() {
    final isFormValid = _formKey.currentState!.validate();

    // cek checkbox syarat & ketentuan
    if (!_agreeTerms) {
      setState(() {
        _showTermsError = true;
      });
    }

    if (isFormValid && _agreeTerms) {
      setState(() {
        _isLoading = true;
      });
      // Simulasi proses registrasi
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        // Tampilkan dialog sukses
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registrasi Berhasil'),
            content: Text(
              'Selamat, ${_nameController.text}!\n'
              'No Telepon: ${_teleponController.text}\n'
              'Tanggal Lahir: ${_tanggalLahirController.text}\n'
              'Jenis Kelamin: $_selectedGender\n'
              'Email: ${_emailController.text}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  // Reset form
  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _teleponController.clear();
    _tanggalLahirController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _selectedDate = null;
      _selectedGender = null;
      _agreeTerms = false;
      _showTermsError = false;
      _passwordStrength = '';
      _strengthValue = 0;
      _strengthColor = Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Registrasi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const SizedBox(height: 16),
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isi form di bawah ini untuk mendaftar',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Field Nama
                CustomTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap Anda',
                  prefixIcon: Icons.person,
                  validator: _validateName,
                ),
                // Field No Telepon
                CustomTextField(
                  controller: _teleponController,
                  label: 'Nomor Telepon',
                  hint: 'Contoh: 081234567890',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: _validateTelepon,
                ),
                // Field Tanggal Lahir
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _tanggalLahirController,
                    readOnly: true,
                    onTap: _pickTanggalLahir,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      hintText: 'Pilih tanggal lahir Anda',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: _validateTanggalLahir,
                  ),
                ),
                // Field Jenis Kelamin
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      hintText: 'Pilih jenis kelamin',
                      prefixIcon: const Icon(Icons.wc),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: _genderOptions
                        .map(
                          (gender) => DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: _validateGender,
                  ),
                ),
                // Field Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Masukkan email Anda',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                // Field Password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Minimal 8 karakter, huruf kapital, angka',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscurePassword,
                    onChanged: _checkPasswordStrength, // [BARU Latihan 5]
                    validator: _validatePassword,
                  ),
                ),
                // Indikator kekuatan password
                if (_passwordStrength.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _strengthValue,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            color: _strengthColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kekuatan password: $_passwordStrength',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _strengthColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Field Konfirmasi Password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      hintText: 'Ulangi password Anda',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                  ),
                ),
                // Checkbox Syarat & Ketentuan
                CheckboxListTile(
                  value: _agreeTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeTerms = value ?? false;
                      if (_agreeTerms) {
                        _showTermsError =
                            false; // hilangkan error saat dicentang
                      }
                    });
                  },
                  title: const Text('Saya setuju dengan Syarat & Ketentuan'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.deepPurple,
                ),
                // Pesan error jika belum dicentang
                if (_showTermsError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      'Anda harus menyetujui Syarat & Ketentuan',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Tombol Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Daftar', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                // Tombol Reset
                OutlinedButton(
                  onPressed: _isLoading ? null : _resetForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Reset'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
