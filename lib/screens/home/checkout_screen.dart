import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class DeliveryAddressSheet extends StatefulWidget {
  const DeliveryAddressSheet({super.key});

  @override
  State<DeliveryAddressSheet> createState() => _DeliveryAddressSheetState();
}

class _DeliveryAddressSheetState extends State<DeliveryAddressSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  String? _error;

  bool _isLoadingLocation = false;

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError('Location permission permanently denied. Please enable from settings.');
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _addressController.text = '${place.street ?? ''}, ${place.subLocality ?? ''}'.trim();
          _cityController.text = place.locality ?? place.administrativeArea ?? '';
          _pincodeController.text = place.postalCode ?? '';
          _error = null;
        });
      }
    } catch (e) {
      _showError('Could not get location. Try again.');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ✅ F-10: Validation add ki -- pehle zero validation tha
  void _onContinue() {
    setState(() => _error = null);

    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }
    if (_phoneController.text.trim().length != 10 ||
        !RegExp(r'^\d+$').hasMatch(_phoneController.text.trim())) {
      setState(() => _error = 'Enter valid 10-digit phone number');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your address');
      return;
    }
    if (_cityController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your city');
      return;
    }
    if (_pincodeController.text.trim().length != 6 ||
        !RegExp(r'^\d+$').hasMatch(_pincodeController.text.trim())) {
      setState(() => _error = 'Enter valid 6-digit pincode');
      return;
    }

    final address = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'pincode': _pincodeController.text.trim(),
    };
    Navigator.pop(context, address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: _isLoadingLocation ? null : _fetchCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location, color: Colors.orange),
                label: Text(
                  _isLoadingLocation ? 'Fetching...' : 'Use My Location',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildField(_nameController, 'Full Name'),
          _buildField(_phoneController, 'Phone', type: TextInputType.phone, max: 10),
          _buildField(_addressController, 'Address'),
          _buildField(_cityController, 'City'),
          _buildField(_pincodeController, 'Pincode', type: TextInputType.number, max: 6),
          // ✅ Error message show karo
          if (_error != null) Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB85C1A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continue',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text, int? max}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        maxLength: max,
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
