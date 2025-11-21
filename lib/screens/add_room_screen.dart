import 'package:flutter/material.dart';
import '../models/room_listing_model.dart';
import '../services/firestore_service.dart';

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  
  // Mode selection
  bool _isAdvancedMode = false;
  
  // Basic form controllers
  final _rentController = TextEditingController();
  final _locationController = TextEditingController();
  final _photoUrlController = TextEditingController();
  
  // Address controllers (Advanced)
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _landmarkController = TextEditingController();
  
  // Basic amenities
  bool _hasWifi = false;
  bool _hasAC = false;
  bool _isFurnished = false;
  
  // Advanced facilities
  bool _hasTV = false;
  bool _hasWaterSupply = false;
  bool _hasParking = false;
  bool _hasMessIncluded = false;
  bool _hasPlayground = false;
  bool _hasClubNearby = false;
  bool _hasOfficeNearby = false;
  bool _hasParkNearby = false;
  bool _hasPublicTransport = false;
  
  // Photo URLs list
  final List<String> _photoUrls = [];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _rentController.dispose();
    _locationController.dispose();
    _photoUrlController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _addPhotoUrl() {
    if (_photoUrlController.text.isNotEmpty) {
      setState(() {
        _photoUrls.add(_photoUrlController.text);
        _photoUrlController.clear();
      });
    }
  }

  void _removePhotoUrl(int index) {
    setState(() {
      _photoUrls.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_photoUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one photo URL'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Build location string
        String location = _locationController.text;
        if (_isAdvancedMode && _cityController.text.isNotEmpty) {
          location = '${_streetController.text.isEmpty ? '' : '${_streetController.text}, '}'
              '${_cityController.text}'
              '${_stateController.text.isEmpty ? '' : ', ${_stateController.text}'}'
              '${_countryController.text.isEmpty ? '' : ', ${_countryController.text}'}';
        }
        
        // Build preferences map
        final Map<String, dynamic> preferences = {
          'wifi': _hasWifi,
          'ac': _hasAC,
          'furnished': _isFurnished,
        };
        
        // Add advanced facilities if in advanced mode
        if (_isAdvancedMode) {
          preferences.addAll({
            'tv': _hasTV,
            'waterSupply': _hasWaterSupply,
            'parking': _hasParking,
            'messIncluded': _hasMessIncluded,
            'playground': _hasPlayground,
            'clubNearby': _hasClubNearby,
            'officeNearby': _hasOfficeNearby,
            'parkNearby': _hasParkNearby,
            'publicTransport': _hasPublicTransport,
          });
          if (_landmarkController.text.isNotEmpty) {
            preferences['landmark'] = _landmarkController.text;
          }
        }
        
        final room = RoomListingModel(
          rent: double.parse(_rentController.text),
          location: location,
          preferences: preferences,
          photos: _photoUrls,
        );

        await _firestoreService.addRoomListing(room);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Room listing added successfully!'),
              backgroundColor: Color(0xFF8BC34A),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        title: const Text(
          'Add New Room',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF22223B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF22223B)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode Selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFB5C7F7).withOpacity(0.2),
                      const Color(0xFFF9E79F).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB5C7F7).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isAdvancedMode ? Icons.tune_rounded : Icons.dashboard_rounded,
                      color: const Color(0xFFB5C7F7),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isAdvancedMode ? 'Advanced Mode' : 'Basic Mode',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22223B),
                        ),
                      ),
                    ),
                    Switch(
                      value: _isAdvancedMode,
                      onChanged: (value) {
                        setState(() {
                          _isAdvancedMode = value;
                        });
                      },
                      activeColor: const Color(0xFF8BC34A),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Rent Field
              _buildSectionTitle('Monthly Rent'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _rentController,
                label: 'Enter monthly rent',
                prefixIcon: Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rent amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Location Field
              _buildSectionTitle('Location'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _locationController,
                label: 'Enter location',
                prefixIcon: Icons.location_on_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              
              // Advanced Address Fields
              if (_isAdvancedMode) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Detailed Address'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _streetController,
                  label: 'Street/Area',
                  prefixIcon: Icons.home_rounded,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        prefixIcon: Icons.location_city_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _stateController,
                        label: 'State',
                        prefixIcon: Icons.map_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _countryController,
                  label: 'Country',
                  prefixIcon: Icons.public_rounded,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _landmarkController,
                  label: 'Nearby Landmark',
                  prefixIcon: Icons.place_rounded,
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Preferences Section
              _buildSectionTitle('Basic Amenities'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB5C7F7).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildCheckboxTile(
                      'WiFi Available',
                      Icons.wifi_rounded,
                      _hasWifi,
                      (value) => setState(() => _hasWifi = value!),
                    ),
                    const Divider(height: 1),
                    _buildCheckboxTile(
                      'AC Available',
                      Icons.ac_unit_rounded,
                      _hasAC,
                      (value) => setState(() => _hasAC = value!),
                    ),
                    const Divider(height: 1),
                    _buildCheckboxTile(
                      'Furnished',
                      Icons.weekend_rounded,
                      _isFurnished,
                      (value) => setState(() => _isFurnished = value!),
                    ),
                  ],
                ),
              ),
              
              // Advanced Facilities
              if (_isAdvancedMode) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Additional Facilities'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFB5C7F7).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildCheckboxTile(
                        'TV',
                        Icons.tv_rounded,
                        _hasTV,
                        (value) => setState(() => _hasTV = value!),
                      ),
                      const Divider(height: 1),
                      _buildCheckboxTile(
                        '24/7 Water Supply',
                        Icons.water_drop_rounded,
                        _hasWaterSupply,
                        (value) => setState(() => _hasWaterSupply = value!),
                      ),
                      const Divider(height: 1),
                      _buildCheckboxTile(
                        'Parking Available',
                        Icons.local_parking_rounded,
                        _hasParking,
                        (value) => setState(() => _hasParking = value!),
                      ),
                      const Divider(height: 1),
                      _buildCheckboxTile(
                        'Mess Included',
                        Icons.restaurant_rounded,
                        _hasMessIncluded,
                        (value) => setState(() => _hasMessIncluded = value!),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildSectionTitle('Nearby Facilities'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFB5C7F7).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildCheckboxTile(
                        'Park Nearby',
                        Icons.park_rounded,
                        _hasParkNearby,
                        (value) => setState(() => _hasParkNearby = value!),
                      ),
                      const Divider(height: 1),
                      _buildCheckboxTile(
                        'Playground',
                        Icons.sports_soccer_rounded,
                        _hasPlayground,
                        (value) => setState(() => _hasPlayground = value!),
                      ),
                      const Divider(height: 1),
                      _buildCheckboxTile(
                        'Club Nearby',
                        Icons.sports_tennis_rounded,
                        _hasClubNearby,
                        (value) => setState(() => _hasClubNearby = value!),
                      ),
                      const Divider(height: 1),
                      _buildCheckboxTile(
                        'Office Area Nearby',
                        Icons.business_rounded,
                        _hasOfficeNearby,
                        (value) => setState(() => _hasOfficeNearby = value!),
                      ),
                      const Divider(height: 1),
                      _buildCheckboxTile(
                        'Public Transport',
                        Icons.directions_bus_rounded,
                        _hasPublicTransport,
                        (value) => setState(() => _hasPublicTransport = value!),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Photos Section
              _buildSectionTitle('Room Photos (Add Image URLs)'),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB5C7F7).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _photoUrlController,
                            decoration: InputDecoration(
                              hintText: 'Enter photo URL',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: const Color(0xFFB5C7F7).withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: const Color(0xFFB5C7F7).withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFB5C7F7),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFB5C7F7),
                                Color(0xFF9FB3E8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _addPhotoUrl,
                            icon: const Icon(Icons.add_rounded, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    if (_photoUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...List.generate(_photoUrls.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F6F2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color(0xFFB5C7F7).withOpacity(0.2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _photoUrls[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.image_rounded,
                                          color: Color(0xFFB5C7F7),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _photoUrls[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removePhotoUrl(index),
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFB5C7F7),
                      Color(0xFF9FB3E8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB5C7F7).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add Room Listing',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF22223B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFFB5C7F7)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFFB5C7F7).withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFFB5C7F7).withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFB5C7F7),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(
    String title,
    IconData icon,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Row(
        children: [
          Icon(
            icon,
            color: value ? const Color(0xFF8BC34A) : Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: value ? const Color(0xFF22223B) : Colors.grey[600],
            ),
          ),
        ],
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF8BC34A),
      checkColor: Colors.white,
      contentPadding: EdgeInsets.zero,
    );
  }
}
